// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'price_point.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PricePoint {

 DateTime get ts; double get yesPrice;
/// Create a copy of PricePoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PricePointCopyWith<PricePoint> get copyWith => _$PricePointCopyWithImpl<PricePoint>(this as PricePoint, _$identity);

  /// Serializes this PricePoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PricePoint&&(identical(other.ts, ts) || other.ts == ts)&&(identical(other.yesPrice, yesPrice) || other.yesPrice == yesPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ts,yesPrice);

@override
String toString() {
  return 'PricePoint(ts: $ts, yesPrice: $yesPrice)';
}


}

/// @nodoc
abstract mixin class $PricePointCopyWith<$Res>  {
  factory $PricePointCopyWith(PricePoint value, $Res Function(PricePoint) _then) = _$PricePointCopyWithImpl;
@useResult
$Res call({
 DateTime ts, double yesPrice
});




}
/// @nodoc
class _$PricePointCopyWithImpl<$Res>
    implements $PricePointCopyWith<$Res> {
  _$PricePointCopyWithImpl(this._self, this._then);

  final PricePoint _self;
  final $Res Function(PricePoint) _then;

/// Create a copy of PricePoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ts = null,Object? yesPrice = null,}) {
  return _then(_self.copyWith(
ts: null == ts ? _self.ts : ts // ignore: cast_nullable_to_non_nullable
as DateTime,yesPrice: null == yesPrice ? _self.yesPrice : yesPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PricePoint].
extension PricePointPatterns on PricePoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PricePoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PricePoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PricePoint value)  $default,){
final _that = this;
switch (_that) {
case _PricePoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PricePoint value)?  $default,){
final _that = this;
switch (_that) {
case _PricePoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime ts,  double yesPrice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PricePoint() when $default != null:
return $default(_that.ts,_that.yesPrice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime ts,  double yesPrice)  $default,) {final _that = this;
switch (_that) {
case _PricePoint():
return $default(_that.ts,_that.yesPrice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime ts,  double yesPrice)?  $default,) {final _that = this;
switch (_that) {
case _PricePoint() when $default != null:
return $default(_that.ts,_that.yesPrice);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PricePoint implements PricePoint {
  const _PricePoint({required this.ts, required this.yesPrice});
  factory _PricePoint.fromJson(Map<String, dynamic> json) => _$PricePointFromJson(json);

@override final  DateTime ts;
@override final  double yesPrice;

/// Create a copy of PricePoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PricePointCopyWith<_PricePoint> get copyWith => __$PricePointCopyWithImpl<_PricePoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PricePointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PricePoint&&(identical(other.ts, ts) || other.ts == ts)&&(identical(other.yesPrice, yesPrice) || other.yesPrice == yesPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ts,yesPrice);

@override
String toString() {
  return 'PricePoint(ts: $ts, yesPrice: $yesPrice)';
}


}

/// @nodoc
abstract mixin class _$PricePointCopyWith<$Res> implements $PricePointCopyWith<$Res> {
  factory _$PricePointCopyWith(_PricePoint value, $Res Function(_PricePoint) _then) = __$PricePointCopyWithImpl;
@override @useResult
$Res call({
 DateTime ts, double yesPrice
});




}
/// @nodoc
class __$PricePointCopyWithImpl<$Res>
    implements _$PricePointCopyWith<$Res> {
  __$PricePointCopyWithImpl(this._self, this._then);

  final _PricePoint _self;
  final $Res Function(_PricePoint) _then;

/// Create a copy of PricePoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ts = null,Object? yesPrice = null,}) {
  return _then(_PricePoint(
ts: null == ts ? _self.ts : ts // ignore: cast_nullable_to_non_nullable
as DateTime,yesPrice: null == yesPrice ? _self.yesPrice : yesPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
