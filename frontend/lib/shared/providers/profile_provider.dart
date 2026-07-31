import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user_profile.dart';
import 'api_client_provider.dart';

part 'profile_provider.g.dart';

/// The signed-in user's profile (`/me`), including bankroll.
@Riverpod(keepAlive: true)
class Profile extends _$Profile {
  @override
  Future<UserProfile> build() {
    return ref.watch(apiClientProvider).getMe();
  }

  /// Persist a new bankroll via `PATCH /me` and update local state.
  Future<void> saveBankroll(double bankrollDollars) async {
    final updated =
        await ref.read(apiClientProvider).updateBankroll(bankrollDollars);
    state = AsyncData(updated);
  }

  /// Accept the terms via `POST /me/accept-terms` and update local state.
  Future<void> acceptTerms() async {
    final updated = await ref.read(apiClientProvider).acceptTerms();
    state = AsyncData(updated);
  }

  /// Persist a chosen display name via `PATCH /me/profile` and update local
  /// state.
  Future<void> updateDisplayName(String displayName) async {
    final updated = await ref
        .read(apiClientProvider)
        .updateProfile(displayName: displayName);
    state = AsyncData(updated);
  }

  /// Upload a profile picture via `POST /me/avatar` and update local state
  /// with the resulting `avatarUrl`.
  Future<void> uploadAvatar({
    required Uint8List bytes,
    required String filename,
    required String contentType,
  }) async {
    final updated = await ref.read(apiClientProvider).uploadAvatar(
          bytes: bytes,
          filename: filename,
          contentType: contentType,
        );
    state = AsyncData(updated);
  }
}
