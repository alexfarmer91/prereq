// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ws_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WsPriceUpdate {

 String get ticker; double get yesBid; double get yesAsk; DateTime get ts;
/// Create a copy of WsPriceUpdate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WsPriceUpdateCopyWith<WsPriceUpdate> get copyWith => _$WsPriceUpdateCopyWithImpl<WsPriceUpdate>(this as WsPriceUpdate, _$identity);

  /// Serializes this WsPriceUpdate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WsPriceUpdate&&(identical(other.ticker, ticker) || other.ticker == ticker)&&(identical(other.yesBid, yesBid) || other.yesBid == yesBid)&&(identical(other.yesAsk, yesAsk) || other.yesAsk == yesAsk)&&(identical(other.ts, ts) || other.ts == ts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ticker,yesBid,yesAsk,ts);

@override
String toString() {
  return 'WsPriceUpdate(ticker: $ticker, yesBid: $yesBid, yesAsk: $yesAsk, ts: $ts)';
}


}

/// @nodoc
abstract mixin class $WsPriceUpdateCopyWith<$Res>  {
  factory $WsPriceUpdateCopyWith(WsPriceUpdate value, $Res Function(WsPriceUpdate) _then) = _$WsPriceUpdateCopyWithImpl;
@useResult
$Res call({
 String ticker, double yesBid, double yesAsk, DateTime ts
});




}
/// @nodoc
class _$WsPriceUpdateCopyWithImpl<$Res>
    implements $WsPriceUpdateCopyWith<$Res> {
  _$WsPriceUpdateCopyWithImpl(this._self, this._then);

  final WsPriceUpdate _self;
  final $Res Function(WsPriceUpdate) _then;

/// Create a copy of WsPriceUpdate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ticker = null,Object? yesBid = null,Object? yesAsk = null,Object? ts = null,}) {
  return _then(_self.copyWith(
ticker: null == ticker ? _self.ticker : ticker // ignore: cast_nullable_to_non_nullable
as String,yesBid: null == yesBid ? _self.yesBid : yesBid // ignore: cast_nullable_to_non_nullable
as double,yesAsk: null == yesAsk ? _self.yesAsk : yesAsk // ignore: cast_nullable_to_non_nullable
as double,ts: null == ts ? _self.ts : ts // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [WsPriceUpdate].
extension WsPriceUpdatePatterns on WsPriceUpdate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WsPriceUpdate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WsPriceUpdate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WsPriceUpdate value)  $default,){
final _that = this;
switch (_that) {
case _WsPriceUpdate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WsPriceUpdate value)?  $default,){
final _that = this;
switch (_that) {
case _WsPriceUpdate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ticker,  double yesBid,  double yesAsk,  DateTime ts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WsPriceUpdate() when $default != null:
return $default(_that.ticker,_that.yesBid,_that.yesAsk,_that.ts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ticker,  double yesBid,  double yesAsk,  DateTime ts)  $default,) {final _that = this;
switch (_that) {
case _WsPriceUpdate():
return $default(_that.ticker,_that.yesBid,_that.yesAsk,_that.ts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ticker,  double yesBid,  double yesAsk,  DateTime ts)?  $default,) {final _that = this;
switch (_that) {
case _WsPriceUpdate() when $default != null:
return $default(_that.ticker,_that.yesBid,_that.yesAsk,_that.ts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WsPriceUpdate implements WsPriceUpdate {
  const _WsPriceUpdate({required this.ticker, required this.yesBid, required this.yesAsk, required this.ts});
  factory _WsPriceUpdate.fromJson(Map<String, dynamic> json) => _$WsPriceUpdateFromJson(json);

@override final  String ticker;
@override final  double yesBid;
@override final  double yesAsk;
@override final  DateTime ts;

/// Create a copy of WsPriceUpdate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WsPriceUpdateCopyWith<_WsPriceUpdate> get copyWith => __$WsPriceUpdateCopyWithImpl<_WsPriceUpdate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WsPriceUpdateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WsPriceUpdate&&(identical(other.ticker, ticker) || other.ticker == ticker)&&(identical(other.yesBid, yesBid) || other.yesBid == yesBid)&&(identical(other.yesAsk, yesAsk) || other.yesAsk == yesAsk)&&(identical(other.ts, ts) || other.ts == ts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ticker,yesBid,yesAsk,ts);

@override
String toString() {
  return 'WsPriceUpdate(ticker: $ticker, yesBid: $yesBid, yesAsk: $yesAsk, ts: $ts)';
}


}

/// @nodoc
abstract mixin class _$WsPriceUpdateCopyWith<$Res> implements $WsPriceUpdateCopyWith<$Res> {
  factory _$WsPriceUpdateCopyWith(_WsPriceUpdate value, $Res Function(_WsPriceUpdate) _then) = __$WsPriceUpdateCopyWithImpl;
@override @useResult
$Res call({
 String ticker, double yesBid, double yesAsk, DateTime ts
});




}
/// @nodoc
class __$WsPriceUpdateCopyWithImpl<$Res>
    implements _$WsPriceUpdateCopyWith<$Res> {
  __$WsPriceUpdateCopyWithImpl(this._self, this._then);

  final _WsPriceUpdate _self;
  final $Res Function(_WsPriceUpdate) _then;

/// Create a copy of WsPriceUpdate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ticker = null,Object? yesBid = null,Object? yesAsk = null,Object? ts = null,}) {
  return _then(_WsPriceUpdate(
ticker: null == ticker ? _self.ticker : ticker // ignore: cast_nullable_to_non_nullable
as String,yesBid: null == yesBid ? _self.yesBid : yesBid // ignore: cast_nullable_to_non_nullable
as double,yesAsk: null == yesAsk ? _self.yesAsk : yesAsk // ignore: cast_nullable_to_non_nullable
as double,ts: null == ts ? _self.ts : ts // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$WsArbCount {

 int get count;
/// Create a copy of WsArbCount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WsArbCountCopyWith<WsArbCount> get copyWith => _$WsArbCountCopyWithImpl<WsArbCount>(this as WsArbCount, _$identity);

  /// Serializes this WsArbCount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WsArbCount&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count);

@override
String toString() {
  return 'WsArbCount(count: $count)';
}


}

/// @nodoc
abstract mixin class $WsArbCountCopyWith<$Res>  {
  factory $WsArbCountCopyWith(WsArbCount value, $Res Function(WsArbCount) _then) = _$WsArbCountCopyWithImpl;
@useResult
$Res call({
 int count
});




}
/// @nodoc
class _$WsArbCountCopyWithImpl<$Res>
    implements $WsArbCountCopyWith<$Res> {
  _$WsArbCountCopyWithImpl(this._self, this._then);

  final WsArbCount _self;
  final $Res Function(WsArbCount) _then;

/// Create a copy of WsArbCount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,}) {
  return _then(_self.copyWith(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WsArbCount].
extension WsArbCountPatterns on WsArbCount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WsArbCount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WsArbCount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WsArbCount value)  $default,){
final _that = this;
switch (_that) {
case _WsArbCount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WsArbCount value)?  $default,){
final _that = this;
switch (_that) {
case _WsArbCount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WsArbCount() when $default != null:
return $default(_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int count)  $default,) {final _that = this;
switch (_that) {
case _WsArbCount():
return $default(_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int count)?  $default,) {final _that = this;
switch (_that) {
case _WsArbCount() when $default != null:
return $default(_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WsArbCount implements WsArbCount {
  const _WsArbCount({required this.count});
  factory _WsArbCount.fromJson(Map<String, dynamic> json) => _$WsArbCountFromJson(json);

@override final  int count;

/// Create a copy of WsArbCount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WsArbCountCopyWith<_WsArbCount> get copyWith => __$WsArbCountCopyWithImpl<_WsArbCount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WsArbCountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WsArbCount&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count);

@override
String toString() {
  return 'WsArbCount(count: $count)';
}


}

/// @nodoc
abstract mixin class _$WsArbCountCopyWith<$Res> implements $WsArbCountCopyWith<$Res> {
  factory _$WsArbCountCopyWith(_WsArbCount value, $Res Function(_WsArbCount) _then) = __$WsArbCountCopyWithImpl;
@override @useResult
$Res call({
 int count
});




}
/// @nodoc
class __$WsArbCountCopyWithImpl<$Res>
    implements _$WsArbCountCopyWith<$Res> {
  __$WsArbCountCopyWithImpl(this._self, this._then);

  final _WsArbCount _self;
  final $Res Function(_WsArbCount) _then;

/// Create a copy of WsArbCount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,}) {
  return _then(_WsArbCount(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
