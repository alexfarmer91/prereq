// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  googleUserId: json['google_user_id'] as String,
  bankrollDollars: (json['bankroll_dollars'] as num).toDouble(),
  termsAccepted: json['terms_accepted'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'google_user_id': instance.googleUserId,
      'bankroll_dollars': instance.bankrollDollars,
      'terms_accepted': instance.termsAccepted,
      'created_at': instance.createdAt.toIso8601String(),
    };
