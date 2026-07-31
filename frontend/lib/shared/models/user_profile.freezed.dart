// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfile {

 String get googleUserId; double get bankrollDollars; String get plan; bool get termsAccepted; String? get email; bool get emailVerified; String? get displayName; String? get avatarUrl; DateTime get createdAt; DateTime get updatedAt; DateTime? get lastSeenAt;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.googleUserId, googleUserId) || other.googleUserId == googleUserId)&&(identical(other.bankrollDollars, bankrollDollars) || other.bankrollDollars == bankrollDollars)&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.termsAccepted, termsAccepted) || other.termsAccepted == termsAccepted)&&(identical(other.email, email) || other.email == email)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,googleUserId,bankrollDollars,plan,termsAccepted,email,emailVerified,displayName,avatarUrl,createdAt,updatedAt,lastSeenAt);

@override
String toString() {
  return 'UserProfile(googleUserId: $googleUserId, bankrollDollars: $bankrollDollars, plan: $plan, termsAccepted: $termsAccepted, email: $email, emailVerified: $emailVerified, displayName: $displayName, avatarUrl: $avatarUrl, createdAt: $createdAt, updatedAt: $updatedAt, lastSeenAt: $lastSeenAt)';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
 String googleUserId, double bankrollDollars, String plan, bool termsAccepted, String? email, bool emailVerified, String? displayName, String? avatarUrl, DateTime createdAt, DateTime updatedAt, DateTime? lastSeenAt
});




}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? googleUserId = null,Object? bankrollDollars = null,Object? plan = null,Object? termsAccepted = null,Object? email = freezed,Object? emailVerified = null,Object? displayName = freezed,Object? avatarUrl = freezed,Object? createdAt = null,Object? updatedAt = null,Object? lastSeenAt = freezed,}) {
  return _then(_self.copyWith(
googleUserId: null == googleUserId ? _self.googleUserId : googleUserId // ignore: cast_nullable_to_non_nullable
as String,bankrollDollars: null == bankrollDollars ? _self.bankrollDollars : bankrollDollars // ignore: cast_nullable_to_non_nullable
as double,plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as String,termsAccepted: null == termsAccepted ? _self.termsAccepted : termsAccepted // ignore: cast_nullable_to_non_nullable
as bool,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String googleUserId,  double bankrollDollars,  String plan,  bool termsAccepted,  String? email,  bool emailVerified,  String? displayName,  String? avatarUrl,  DateTime createdAt,  DateTime updatedAt,  DateTime? lastSeenAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.googleUserId,_that.bankrollDollars,_that.plan,_that.termsAccepted,_that.email,_that.emailVerified,_that.displayName,_that.avatarUrl,_that.createdAt,_that.updatedAt,_that.lastSeenAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String googleUserId,  double bankrollDollars,  String plan,  bool termsAccepted,  String? email,  bool emailVerified,  String? displayName,  String? avatarUrl,  DateTime createdAt,  DateTime updatedAt,  DateTime? lastSeenAt)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.googleUserId,_that.bankrollDollars,_that.plan,_that.termsAccepted,_that.email,_that.emailVerified,_that.displayName,_that.avatarUrl,_that.createdAt,_that.updatedAt,_that.lastSeenAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String googleUserId,  double bankrollDollars,  String plan,  bool termsAccepted,  String? email,  bool emailVerified,  String? displayName,  String? avatarUrl,  DateTime createdAt,  DateTime updatedAt,  DateTime? lastSeenAt)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.googleUserId,_that.bankrollDollars,_that.plan,_that.termsAccepted,_that.email,_that.emailVerified,_that.displayName,_that.avatarUrl,_that.createdAt,_that.updatedAt,_that.lastSeenAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfile implements UserProfile {
  const _UserProfile({required this.googleUserId, required this.bankrollDollars, required this.plan, required this.termsAccepted, this.email, required this.emailVerified, this.displayName, this.avatarUrl, required this.createdAt, required this.updatedAt, this.lastSeenAt});
  factory _UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

@override final  String googleUserId;
@override final  double bankrollDollars;
@override final  String plan;
@override final  bool termsAccepted;
@override final  String? email;
@override final  bool emailVerified;
@override final  String? displayName;
@override final  String? avatarUrl;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? lastSeenAt;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.googleUserId, googleUserId) || other.googleUserId == googleUserId)&&(identical(other.bankrollDollars, bankrollDollars) || other.bankrollDollars == bankrollDollars)&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.termsAccepted, termsAccepted) || other.termsAccepted == termsAccepted)&&(identical(other.email, email) || other.email == email)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,googleUserId,bankrollDollars,plan,termsAccepted,email,emailVerified,displayName,avatarUrl,createdAt,updatedAt,lastSeenAt);

@override
String toString() {
  return 'UserProfile(googleUserId: $googleUserId, bankrollDollars: $bankrollDollars, plan: $plan, termsAccepted: $termsAccepted, email: $email, emailVerified: $emailVerified, displayName: $displayName, avatarUrl: $avatarUrl, createdAt: $createdAt, updatedAt: $updatedAt, lastSeenAt: $lastSeenAt)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
 String googleUserId, double bankrollDollars, String plan, bool termsAccepted, String? email, bool emailVerified, String? displayName, String? avatarUrl, DateTime createdAt, DateTime updatedAt, DateTime? lastSeenAt
});




}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? googleUserId = null,Object? bankrollDollars = null,Object? plan = null,Object? termsAccepted = null,Object? email = freezed,Object? emailVerified = null,Object? displayName = freezed,Object? avatarUrl = freezed,Object? createdAt = null,Object? updatedAt = null,Object? lastSeenAt = freezed,}) {
  return _then(_UserProfile(
googleUserId: null == googleUserId ? _self.googleUserId : googleUserId // ignore: cast_nullable_to_non_nullable
as String,bankrollDollars: null == bankrollDollars ? _self.bankrollDollars : bankrollDollars // ignore: cast_nullable_to_non_nullable
as double,plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as String,termsAccepted: null == termsAccepted ? _self.termsAccepted : termsAccepted // ignore: cast_nullable_to_non_nullable
as bool,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
