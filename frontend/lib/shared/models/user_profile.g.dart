// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  googleUserId: json['google_user_id'] as String,
  bankrollDollars: (json['bankroll_dollars'] as num).toDouble(),
  plan: json['plan'] as String,
  email: json['email'] as String?,
  emailVerified: json['email_verified'] as bool,
  displayName: json['display_name'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  lastSeenAt: json['last_seen_at'] == null
      ? null
      : DateTime.parse(json['last_seen_at'] as String),
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'google_user_id': instance.googleUserId,
      'bankroll_dollars': instance.bankrollDollars,
      'plan': instance.plan,
      'email': instance.email,
      'email_verified': instance.emailVerified,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'last_seen_at': instance.lastSeenAt?.toIso8601String(),
    };
