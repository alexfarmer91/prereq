// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'watchlist_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WatchlistItem {

 String get id; String get marketTicker; double? get alertEdgeThreshold; double? get edgeAtAdd; DateTime get createdAt; Market? get market;
/// Create a copy of WatchlistItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WatchlistItemCopyWith<WatchlistItem> get copyWith => _$WatchlistItemCopyWithImpl<WatchlistItem>(this as WatchlistItem, _$identity);

  /// Serializes this WatchlistItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WatchlistItem&&(identical(other.id, id) || other.id == id)&&(identical(other.marketTicker, marketTicker) || other.marketTicker == marketTicker)&&(identical(other.alertEdgeThreshold, alertEdgeThreshold) || other.alertEdgeThreshold == alertEdgeThreshold)&&(identical(other.edgeAtAdd, edgeAtAdd) || other.edgeAtAdd == edgeAtAdd)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.market, market) || other.market == market));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,marketTicker,alertEdgeThreshold,edgeAtAdd,createdAt,market);

@override
String toString() {
  return 'WatchlistItem(id: $id, marketTicker: $marketTicker, alertEdgeThreshold: $alertEdgeThreshold, edgeAtAdd: $edgeAtAdd, createdAt: $createdAt, market: $market)';
}


}

/// @nodoc
abstract mixin class $WatchlistItemCopyWith<$Res>  {
  factory $WatchlistItemCopyWith(WatchlistItem value, $Res Function(WatchlistItem) _then) = _$WatchlistItemCopyWithImpl;
@useResult
$Res call({
 String id, String marketTicker, double? alertEdgeThreshold, double? edgeAtAdd, DateTime createdAt, Market? market
});


$MarketCopyWith<$Res>? get market;

}
/// @nodoc
class _$WatchlistItemCopyWithImpl<$Res>
    implements $WatchlistItemCopyWith<$Res> {
  _$WatchlistItemCopyWithImpl(this._self, this._then);

  final WatchlistItem _self;
  final $Res Function(WatchlistItem) _then;

/// Create a copy of WatchlistItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? marketTicker = null,Object? alertEdgeThreshold = freezed,Object? edgeAtAdd = freezed,Object? createdAt = null,Object? market = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,marketTicker: null == marketTicker ? _self.marketTicker : marketTicker // ignore: cast_nullable_to_non_nullable
as String,alertEdgeThreshold: freezed == alertEdgeThreshold ? _self.alertEdgeThreshold : alertEdgeThreshold // ignore: cast_nullable_to_non_nullable
as double?,edgeAtAdd: freezed == edgeAtAdd ? _self.edgeAtAdd : edgeAtAdd // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,market: freezed == market ? _self.market : market // ignore: cast_nullable_to_non_nullable
as Market?,
  ));
}
/// Create a copy of WatchlistItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MarketCopyWith<$Res>? get market {
    if (_self.market == null) {
    return null;
  }

  return $MarketCopyWith<$Res>(_self.market!, (value) {
    return _then(_self.copyWith(market: value));
  });
}
}


/// Adds pattern-matching-related methods to [WatchlistItem].
extension WatchlistItemPatterns on WatchlistItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WatchlistItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WatchlistItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WatchlistItem value)  $default,){
final _that = this;
switch (_that) {
case _WatchlistItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WatchlistItem value)?  $default,){
final _that = this;
switch (_that) {
case _WatchlistItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String marketTicker,  double? alertEdgeThreshold,  double? edgeAtAdd,  DateTime createdAt,  Market? market)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WatchlistItem() when $default != null:
return $default(_that.id,_that.marketTicker,_that.alertEdgeThreshold,_that.edgeAtAdd,_that.createdAt,_that.market);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String marketTicker,  double? alertEdgeThreshold,  double? edgeAtAdd,  DateTime createdAt,  Market? market)  $default,) {final _that = this;
switch (_that) {
case _WatchlistItem():
return $default(_that.id,_that.marketTicker,_that.alertEdgeThreshold,_that.edgeAtAdd,_that.createdAt,_that.market);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String marketTicker,  double? alertEdgeThreshold,  double? edgeAtAdd,  DateTime createdAt,  Market? market)?  $default,) {final _that = this;
switch (_that) {
case _WatchlistItem() when $default != null:
return $default(_that.id,_that.marketTicker,_that.alertEdgeThreshold,_that.edgeAtAdd,_that.createdAt,_that.market);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WatchlistItem implements WatchlistItem {
  const _WatchlistItem({required this.id, required this.marketTicker, this.alertEdgeThreshold, this.edgeAtAdd, required this.createdAt, this.market});
  factory _WatchlistItem.fromJson(Map<String, dynamic> json) => _$WatchlistItemFromJson(json);

@override final  String id;
@override final  String marketTicker;
@override final  double? alertEdgeThreshold;
@override final  double? edgeAtAdd;
@override final  DateTime createdAt;
@override final  Market? market;

/// Create a copy of WatchlistItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WatchlistItemCopyWith<_WatchlistItem> get copyWith => __$WatchlistItemCopyWithImpl<_WatchlistItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WatchlistItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WatchlistItem&&(identical(other.id, id) || other.id == id)&&(identical(other.marketTicker, marketTicker) || other.marketTicker == marketTicker)&&(identical(other.alertEdgeThreshold, alertEdgeThreshold) || other.alertEdgeThreshold == alertEdgeThreshold)&&(identical(other.edgeAtAdd, edgeAtAdd) || other.edgeAtAdd == edgeAtAdd)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.market, market) || other.market == market));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,marketTicker,alertEdgeThreshold,edgeAtAdd,createdAt,market);

@override
String toString() {
  return 'WatchlistItem(id: $id, marketTicker: $marketTicker, alertEdgeThreshold: $alertEdgeThreshold, edgeAtAdd: $edgeAtAdd, createdAt: $createdAt, market: $market)';
}


}

/// @nodoc
abstract mixin class _$WatchlistItemCopyWith<$Res> implements $WatchlistItemCopyWith<$Res> {
  factory _$WatchlistItemCopyWith(_WatchlistItem value, $Res Function(_WatchlistItem) _then) = __$WatchlistItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String marketTicker, double? alertEdgeThreshold, double? edgeAtAdd, DateTime createdAt, Market? market
});


@override $MarketCopyWith<$Res>? get market;

}
/// @nodoc
class __$WatchlistItemCopyWithImpl<$Res>
    implements _$WatchlistItemCopyWith<$Res> {
  __$WatchlistItemCopyWithImpl(this._self, this._then);

  final _WatchlistItem _self;
  final $Res Function(_WatchlistItem) _then;

/// Create a copy of WatchlistItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? marketTicker = null,Object? alertEdgeThreshold = freezed,Object? edgeAtAdd = freezed,Object? createdAt = null,Object? market = freezed,}) {
  return _then(_WatchlistItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,marketTicker: null == marketTicker ? _self.marketTicker : marketTicker // ignore: cast_nullable_to_non_nullable
as String,alertEdgeThreshold: freezed == alertEdgeThreshold ? _self.alertEdgeThreshold : alertEdgeThreshold // ignore: cast_nullable_to_non_nullable
as double?,edgeAtAdd: freezed == edgeAtAdd ? _self.edgeAtAdd : edgeAtAdd // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,market: freezed == market ? _self.market : market // ignore: cast_nullable_to_non_nullable
as Market?,
  ));
}

/// Create a copy of WatchlistItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MarketCopyWith<$Res>? get market {
    if (_self.market == null) {
    return null;
  }

  return $MarketCopyWith<$Res>(_self.market!, (value) {
    return _then(_self.copyWith(market: value));
  });
}
}

// dart format on
