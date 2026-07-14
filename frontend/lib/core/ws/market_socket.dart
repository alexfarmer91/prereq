import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../shared/models/ws_message.dart';

/// Manages the single WebSocket connection to `/ws/markets`.
///
/// - Connects lazily (on [ensureConnected] or the first [subscribe]).
/// - Re-sends the current subscription set after every (re)connect.
/// - Reconnects with capped exponential backoff.
/// - Broadcasts parsed [WsMessage]s; unknown message types are ignored.
class MarketSocket {
  MarketSocket({required this.uriBuilder});

  /// Builds the (token-bearing) WebSocket URI at connect time so a fresh
  /// session token is used for every reconnect.
  final Future<Uri> Function() uriBuilder;

  final _messages = StreamController<WsMessage>.broadcast();
  Stream<WsMessage> get messages => _messages.stream;

  Set<String> _subscribedTickers = const {};
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _channelSub;
  Timer? _reconnectTimer;
  bool _connecting = false;
  bool _disposed = false;
  int _retries = 0;

  bool get isConnected => _channel != null;

  /// Replace the set of tickers we want price updates for. Safe to call
  /// repeatedly with the same set.
  void subscribe(Set<String> tickers) {
    final changed = !setEquals(tickers, _subscribedTickers);
    _subscribedTickers = Set.unmodifiable(tickers);
    if (_channel == null) {
      ensureConnected();
    } else if (changed) {
      _sendSubscribe();
    }
  }

  Future<void> ensureConnected() async {
    if (_disposed || _connecting || _channel != null) return;
    _connecting = true;
    try {
      final uri = await uriBuilder();
      final channel = WebSocketChannel.connect(uri);
      await channel.ready;
      if (_disposed) {
        await channel.sink.close();
        return;
      }
      _channel = channel;
      _retries = 0;
      _channelSub = channel.stream.listen(
        _onData,
        onError: (Object _) => _onDisconnected(),
        onDone: _onDisconnected,
        cancelOnError: true,
      );
      _sendSubscribe();
    } catch (_) {
      _scheduleReconnect();
    } finally {
      _connecting = false;
    }
  }

  void _sendSubscribe() {
    _channel?.sink.add(jsonEncode({
      'type': 'subscribe',
      'tickers': _subscribedTickers.toList(),
    }));
  }

  void _onData(dynamic raw) {
    if (raw is! String) return;
    try {
      final json = jsonDecode(raw);
      if (json is Map<String, dynamic>) {
        final message = WsMessage.tryParse(json);
        if (message != null) _messages.add(message);
      }
    } catch (_) {
      // Ignore unknown or malformed messages.
    }
  }

  void _onDisconnected() {
    _channelSub?.cancel();
    _channelSub = null;
    _channel = null;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed || _reconnectTimer != null) return;
    _retries++;
    final delay = Duration(seconds: math.min(30, 1 << math.min(_retries, 5)));
    _reconnectTimer = Timer(delay, () {
      _reconnectTimer = null;
      ensureConnected();
    });
  }

  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _channelSub?.cancel();
    _channel?.sink.close();
    _messages.close();
  }
}
