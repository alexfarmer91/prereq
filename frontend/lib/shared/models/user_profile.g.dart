// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  clerkUserId: json['clerk_user_id'] as String,
  bankrollDollars: (json['bankroll_dollars'] as num).toDouble(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'clerk_user_id': instance.clerkUserId,
      'bankroll_dollars': instance.bankrollDollars,
      'created_at': instance.createdAt.toIso8601String(),
    };
