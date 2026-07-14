// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'market_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MarketDetail {

 Market get market; List<Market> get eventMarkets;
/// Create a copy of MarketDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarketDetailCopyWith<MarketDetail> get copyWith => _$MarketDetailCopyWithImpl<MarketDetail>(this as MarketDetail, _$identity);

  /// Serializes this MarketDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarketDetail&&(identical(other.market, market) || other.market == market)&&const DeepCollectionEquality().equals(other.eventMarkets, eventMarkets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,market,const DeepCollectionEquality().hash(eventMarkets));

@override
String toString() {
  return 'MarketDetail(market: $market, eventMarkets: $eventMarkets)';
}


}

/// @nodoc
abstract mixin class $MarketDetailCopyWith<$Res>  {
  factory $MarketDetailCopyWith(MarketDetail value, $Res Function(MarketDetail) _then) = _$MarketDetailCopyWithImpl;
@useResult
$Res call({
 Market market, List<Market> eventMarkets
});


$MarketCopyWith<$Res> get market;

}
/// @nodoc
class _$MarketDetailCopyWithImpl<$Res>
    implements $MarketDetailCopyWith<$Res> {
  _$MarketDetailCopyWithImpl(this._self, this._then);

  final MarketDetail _self;
  final $Res Function(MarketDetail) _then;

/// Create a copy of MarketDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? market = null,Object? eventMarkets = null,}) {
  return _then(_self.copyWith(
market: null == market ? _self.market : market // ignore: cast_nullable_to_non_nullable
as Market,eventMarkets: null == eventMarkets ? _self.eventMarkets : eventMarkets // ignore: cast_nullable_to_non_nullable
as List<Market>,
  ));
}
/// Create a copy of MarketDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MarketCopyWith<$Res> get market {
  
  return $MarketCopyWith<$Res>(_self.market, (value) {
    return _then(_self.copyWith(market: value));
  });
}
}


/// Adds pattern-matching-related methods to [MarketDetail].
extension MarketDetailPatterns on MarketDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarketDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarketDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarketDetail value)  $default,){
final _that = this;
switch (_that) {
case _MarketDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarketDetail value)?  $default,){
final _that = this;
switch (_that) {
case _MarketDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Market market,  List<Market> eventMarkets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarketDetail() when $default != null:
return $default(_that.market,_that.eventMarkets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Market market,  List<Market> eventMarkets)  $default,) {final _that = this;
switch (_that) {
case _MarketDetail():
return $default(_that.market,_that.eventMarkets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Market market,  List<Market> eventMarkets)?  $default,) {final _that = this;
switch (_that) {
case _MarketDetail() when $default != null:
return $default(_that.market,_that.eventMarkets);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MarketDetail implements MarketDetail {
  const _MarketDetail({required this.market, required final  List<Market> eventMarkets}): _eventMarkets = eventMarkets;
  factory _MarketDetail.fromJson(Map<String, dynamic> json) => _$MarketDetailFromJson(json);

@override final  Market market;
 final  List<Market> _eventMarkets;
@override List<Market> get eventMarkets {
  if (_eventMarkets is EqualUnmodifiableListView) return _eventMarkets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_eventMarkets);
}


/// Create a copy of MarketDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarketDetailCopyWith<_MarketDetail> get copyWith => __$MarketDetailCopyWithImpl<_MarketDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MarketDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarketDetail&&(identical(other.market, market) || other.market == market)&&const DeepCollectionEquality().equals(other._eventMarkets, _eventMarkets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,market,const DeepCollectionEquality().hash(_eventMarkets));

@override
String toString() {
  return 'MarketDetail(market: $market, eventMarkets: $eventMarkets)';
}


}

/// @nodoc
abstract mixin class _$MarketDetailCopyWith<$Res> implements $MarketDetailCopyWith<$Res> {
  factory _$MarketDetailCopyWith(_MarketDetail value, $Res Function(_MarketDetail) _then) = __$MarketDetailCopyWithImpl;
@override @useResult
$Res call({
 Market market, List<Market> eventMarkets
});


@override $MarketCopyWith<$Res> get market;

}
/// @nodoc
class __$MarketDetailCopyWithImpl<$Res>
    implements _$MarketDetailCopyWith<$Res> {
  __$MarketDetailCopyWithImpl(this._self, this._then);

  final _MarketDetail _self;
  final $Res Function(_MarketDetail) _then;

/// Create a copy of MarketDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? market = null,Object? eventMarkets = null,}) {
  return _then(_MarketDetail(
market: null == market ? _self.market : market // ignore: cast_nullable_to_non_nullable
as Market,eventMarkets: null == eventMarkets ? _self._eventMarkets : eventMarkets // ignore: cast_nullable_to_non_nullable
as List<Market>,
  ));
}

/// Create a copy of MarketDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MarketCopyWith<$Res> get market {
  
  return $MarketCopyWith<$Res>(_self.market, (value) {
    return _then(_self.copyWith(market: value));
  });
}
}

// dart format on
