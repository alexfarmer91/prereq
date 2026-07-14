// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'arb.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Arb {

 String get kalshiTicker; String get kalshiTitle; String get polymarketId; String get polymarketQuestion; double get kalshiYesAsk; double get polymarketNoAsk; double get combinedCost; double get edge; DateTime get detectedAt;
/// Create a copy of Arb
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArbCopyWith<Arb> get copyWith => _$ArbCopyWithImpl<Arb>(this as Arb, _$identity);

  /// Serializes this Arb to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Arb&&(identical(other.kalshiTicker, kalshiTicker) || other.kalshiTicker == kalshiTicker)&&(identical(other.kalshiTitle, kalshiTitle) || other.kalshiTitle == kalshiTitle)&&(identical(other.polymarketId, polymarketId) || other.polymarketId == polymarketId)&&(identical(other.polymarketQuestion, polymarketQuestion) || other.polymarketQuestion == polymarketQuestion)&&(identical(other.kalshiYesAsk, kalshiYesAsk) || other.kalshiYesAsk == kalshiYesAsk)&&(identical(other.polymarketNoAsk, polymarketNoAsk) || other.polymarketNoAsk == polymarketNoAsk)&&(identical(other.combinedCost, combinedCost) || other.combinedCost == combinedCost)&&(identical(other.edge, edge) || other.edge == edge)&&(identical(other.detectedAt, detectedAt) || other.detectedAt == detectedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kalshiTicker,kalshiTitle,polymarketId,polymarketQuestion,kalshiYesAsk,polymarketNoAsk,combinedCost,edge,detectedAt);

@override
String toString() {
  return 'Arb(kalshiTicker: $kalshiTicker, kalshiTitle: $kalshiTitle, polymarketId: $polymarketId, polymarketQuestion: $polymarketQuestion, kalshiYesAsk: $kalshiYesAsk, polymarketNoAsk: $polymarketNoAsk, combinedCost: $combinedCost, edge: $edge, detectedAt: $detectedAt)';
}


}

/// @nodoc
abstract mixin class $ArbCopyWith<$Res>  {
  factory $ArbCopyWith(Arb value, $Res Function(Arb) _then) = _$ArbCopyWithImpl;
@useResult
$Res call({
 String kalshiTicker, String kalshiTitle, String polymarketId, String polymarketQuestion, double kalshiYesAsk, double polymarketNoAsk, double combinedCost, double edge, DateTime detectedAt
});




}
/// @nodoc
class _$ArbCopyWithImpl<$Res>
    implements $ArbCopyWith<$Res> {
  _$ArbCopyWithImpl(this._self, this._then);

  final Arb _self;
  final $Res Function(Arb) _then;

/// Create a copy of Arb
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kalshiTicker = null,Object? kalshiTitle = null,Object? polymarketId = null,Object? polymarketQuestion = null,Object? kalshiYesAsk = null,Object? polymarketNoAsk = null,Object? combinedCost = null,Object? edge = null,Object? detectedAt = null,}) {
  return _then(_self.copyWith(
kalshiTicker: null == kalshiTicker ? _self.kalshiTicker : kalshiTicker // ignore: cast_nullable_to_non_nullable
as String,kalshiTitle: null == kalshiTitle ? _self.kalshiTitle : kalshiTitle // ignore: cast_nullable_to_non_nullable
as String,polymarketId: null == polymarketId ? _self.polymarketId : polymarketId // ignore: cast_nullable_to_non_nullable
as String,polymarketQuestion: null == polymarketQuestion ? _self.polymarketQuestion : polymarketQuestion // ignore: cast_nullable_to_non_nullable
as String,kalshiYesAsk: null == kalshiYesAsk ? _self.kalshiYesAsk : kalshiYesAsk // ignore: cast_nullable_to_non_nullable
as double,polymarketNoAsk: null == polymarketNoAsk ? _self.polymarketNoAsk : polymarketNoAsk // ignore: cast_nullable_to_non_nullable
as double,combinedCost: null == combinedCost ? _self.combinedCost : combinedCost // ignore: cast_nullable_to_non_nullable
as double,edge: null == edge ? _self.edge : edge // ignore: cast_nullable_to_non_nullable
as double,detectedAt: null == detectedAt ? _self.detectedAt : detectedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Arb].
extension ArbPatterns on Arb {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Arb value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Arb() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Arb value)  $default,){
final _that = this;
switch (_that) {
case _Arb():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Arb value)?  $default,){
final _that = this;
switch (_that) {
case _Arb() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String kalshiTicker,  String kalshiTitle,  String polymarketId,  String polymarketQuestion,  double kalshiYesAsk,  double polymarketNoAsk,  double combinedCost,  double edge,  DateTime detectedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Arb() when $default != null:
return $default(_that.kalshiTicker,_that.kalshiTitle,_that.polymarketId,_that.polymarketQuestion,_that.kalshiYesAsk,_that.polymarketNoAsk,_that.combinedCost,_that.edge,_that.detectedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String kalshiTicker,  String kalshiTitle,  String polymarketId,  String polymarketQuestion,  double kalshiYesAsk,  double polymarketNoAsk,  double combinedCost,  double edge,  DateTime detectedAt)  $default,) {final _that = this;
switch (_that) {
case _Arb():
return $default(_that.kalshiTicker,_that.kalshiTitle,_that.polymarketId,_that.polymarketQuestion,_that.kalshiYesAsk,_that.polymarketNoAsk,_that.combinedCost,_that.edge,_that.detectedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String kalshiTicker,  String kalshiTitle,  String polymarketId,  String polymarketQuestion,  double kalshiYesAsk,  double polymarketNoAsk,  double combinedCost,  double edge,  DateTime detectedAt)?  $default,) {final _that = this;
switch (_that) {
case _Arb() when $default != null:
return $default(_that.kalshiTicker,_that.kalshiTitle,_that.polymarketId,_that.polymarketQuestion,_that.kalshiYesAsk,_that.polymarketNoAsk,_that.combinedCost,_that.edge,_that.detectedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Arb implements Arb {
  const _Arb({required this.kalshiTicker, required this.kalshiTitle, required this.polymarketId, required this.polymarketQuestion, required this.kalshiYesAsk, required this.polymarketNoAsk, required this.combinedCost, required this.edge, required this.detectedAt});
  factory _Arb.fromJson(Map<String, dynamic> json) => _$ArbFromJson(json);

@override final  String kalshiTicker;
@override final  String kalshiTitle;
@override final  String polymarketId;
@override final  String polymarketQuestion;
@override final  double kalshiYesAsk;
@override final  double polymarketNoAsk;
@override final  double combinedCost;
@override final  double edge;
@override final  DateTime detectedAt;

/// Create a copy of Arb
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArbCopyWith<_Arb> get copyWith => __$ArbCopyWithImpl<_Arb>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ArbToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Arb&&(identical(other.kalshiTicker, kalshiTicker) || other.kalshiTicker == kalshiTicker)&&(identical(other.kalshiTitle, kalshiTitle) || other.kalshiTitle == kalshiTitle)&&(identical(other.polymarketId, polymarketId) || other.polymarketId == polymarketId)&&(identical(other.polymarketQuestion, polymarketQuestion) || other.polymarketQuestion == polymarketQuestion)&&(identical(other.kalshiYesAsk, kalshiYesAsk) || other.kalshiYesAsk == kalshiYesAsk)&&(identical(other.polymarketNoAsk, polymarketNoAsk) || other.polymarketNoAsk == polymarketNoAsk)&&(identical(other.combinedCost, combinedCost) || other.combinedCost == combinedCost)&&(identical(other.edge, edge) || other.edge == edge)&&(identical(other.detectedAt, detectedAt) || other.detectedAt == detectedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kalshiTicker,kalshiTitle,polymarketId,polymarketQuestion,kalshiYesAsk,polymarketNoAsk,combinedCost,edge,detectedAt);

@override
String toString() {
  return 'Arb(kalshiTicker: $kalshiTicker, kalshiTitle: $kalshiTitle, polymarketId: $polymarketId, polymarketQuestion: $polymarketQuestion, kalshiYesAsk: $kalshiYesAsk, polymarketNoAsk: $polymarketNoAsk, combinedCost: $combinedCost, edge: $edge, detectedAt: $detectedAt)';
}


}

/// @nodoc
abstract mixin class _$ArbCopyWith<$Res> implements $ArbCopyWith<$Res> {
  factory _$ArbCopyWith(_Arb value, $Res Function(_Arb) _then) = __$ArbCopyWithImpl;
@override @useResult
$Res call({
 String kalshiTicker, String kalshiTitle, String polymarketId, String polymarketQuestion, double kalshiYesAsk, double polymarketNoAsk, double combinedCost, double edge, DateTime detectedAt
});




}
/// @nodoc
class __$ArbCopyWithImpl<$Res>
    implements _$ArbCopyWith<$Res> {
  __$ArbCopyWithImpl(this._self, this._then);

  final _Arb _self;
  final $Res Function(_Arb) _then;

/// Create a copy of Arb
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kalshiTicker = null,Object? kalshiTitle = null,Object? polymarketId = null,Object? polymarketQuestion = null,Object? kalshiYesAsk = null,Object? polymarketNoAsk = null,Object? combinedCost = null,Object? edge = null,Object? detectedAt = null,}) {
  return _then(_Arb(
kalshiTicker: null == kalshiTicker ? _self.kalshiTicker : kalshiTicker // ignore: cast_nullable_to_non_nullable
as String,kalshiTitle: null == kalshiTitle ? _self.kalshiTitle : kalshiTitle // ignore: cast_nullable_to_non_nullable
as String,polymarketId: null == polymarketId ? _self.polymarketId : polymarketId // ignore: cast_nullable_to_non_nullable
as String,polymarketQuestion: null == polymarketQuestion ? _self.polymarketQuestion : polymarketQuestion // ignore: cast_nullable_to_non_nullable
as String,kalshiYesAsk: null == kalshiYesAsk ? _self.kalshiYesAsk : kalshiYesAsk // ignore: cast_nullable_to_non_nullable
as double,polymarketNoAsk: null == polymarketNoAsk ? _self.polymarketNoAsk : polymarketNoAsk // ignore: cast_nullable_to_non_nullable
as double,combinedCost: null == combinedCost ? _self.combinedCost : combinedCost // ignore: cast_nullable_to_non_nullable
as double,edge: null == edge ? _self.edge : edge // ignore: cast_nullable_to_non_nullable
as double,detectedAt: null == detectedAt ? _self.detectedAt : detectedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
