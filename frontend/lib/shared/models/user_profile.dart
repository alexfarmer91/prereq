import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

/// Payload of `GET /me` / `PATCH /me`.
@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String googleUserId,
    required double bankrollDollars,
    required bool termsAccepted,
    required DateTime createdAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
