import 'package:flutter/foundation.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

/// The user's analytics consent decision. [unknown] means they haven't been
/// asked yet — the consent banner shows and no events are sent.
enum ConsentStatus { unknown, granted, denied }

/// Thin wrapper around Mixpanel. Every call is a no-op until [init] succeeds,
/// so analytics can never break the app (missing token, blocked network,
/// platform init failure).
///
/// Consent gate: the SDK initializes opted-out ([Mixpanel.init] with
/// `optOutTrackingDefault: true`) and only starts sending after the user
/// accepts via [setConsent]. The choice is persisted and honored on
/// subsequent launches.
///
/// Event naming convention: `object_verb` in snake_case, lowercase string
/// property values, numeric values unquoted.
abstract final class Analytics {
  static Mixpanel? _mixpanel;
  static String? _pendingUserId;
  static const String _consentPrefKey = 'analytics_consent';

  /// Drives the consent banner. Starts [ConsentStatus.denied] so no banner
  /// shows when analytics is disabled entirely (empty token / failed init).
  static final ValueNotifier<ConsentStatus> consent =
      ValueNotifier(ConsentStatus.denied);

  static Future<void> init() async {
    if (AppConfig.mixpanelToken.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getBool(_consentPrefKey);
      final mixpanel = await Mixpanel.init(
        AppConfig.mixpanelToken,
        optOutTrackingDefault: true,
        trackAutomaticEvents: true,
      );
      _mixpanel = mixpanel;
      if (stored == true) {
        mixpanel.optInTracking();
        _registerSuperProperties(mixpanel);
      }
      consent.value = switch (stored) {
        true => ConsentStatus.granted,
        false => ConsentStatus.denied,
        null => ConsentStatus.unknown,
      };
    } catch (e) {
      debugPrint('Mixpanel init failed (tracking disabled): $e');
    }
  }

  /// Called from the consent banner. Persists the choice and flips the SDK's
  /// opt-in state; on grant, replays the identity captured while gated.
  static Future<void> setConsent({required bool granted}) async {
    consent.value = granted ? ConsentStatus.granted : ConsentStatus.denied;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_consentPrefKey, granted);
    } catch (e) {
      debugPrint('Failed to persist analytics consent: $e');
    }
    final mixpanel = _mixpanel;
    if (mixpanel == null) return;
    if (granted) {
      mixpanel.optInTracking();
      // Opted-out SDKs drop identify/super-property calls, so re-apply them.
      _registerSuperProperties(mixpanel);
      final userId = _pendingUserId;
      if (userId != null) mixpanel.identify(userId);
    } else {
      mixpanel.optOutTracking();
    }
  }

  static void _registerSuperProperties(Mixpanel mixpanel) {
    mixpanel.registerSuperProperties({
      'platform': kIsWeb ? 'web' : defaultTargetPlatform.name.toLowerCase(),
      // Lets prod dashboards filter out local/dev sessions until a separate
      // dev project token is provisioned.
      'env': kDebugMode ? 'dev' : 'prod',
    });
  }

  static void track(String event, [Map<String, dynamic>? properties]) {
    _mixpanel?.track(event, properties: properties);
  }

  /// Ties events to the Clerk user id (never email — ids are stable).
  static void identify(String userId) {
    _pendingUserId = userId;
    _mixpanel?.identify(userId);
  }

  /// Clears the identity on sign-out so the next user isn't merged.
  static void reset() {
    _pendingUserId = null;
    _mixpanel?.reset();
  }
}
