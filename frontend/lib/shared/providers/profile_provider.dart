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
}
