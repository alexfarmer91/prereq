// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Bet {

 String get id; String get marketTicker; String get marketTitle; BetSide get side; double get entryPriceDollars; int get contracts; double get yourProbability; double? get kellyFraction; BetOutcome get outcome; double? get exitPriceDollars; DateTime get placedAt; DateTime? get resolvedAt;
/// Create a copy of Bet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BetCopyWith<Bet> get copyWith => _$BetCopyWithImpl<Bet>(this as Bet, _$identity);

  /// Serializes this Bet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Bet&&(identical(other.id, id) || other.id == id)&&(identical(other.marketTicker, marketTicker) || other.marketTicker == marketTicker)&&(identical(other.marketTitle, marketTitle) || other.marketTitle == marketTitle)&&(identical(other.side, side) || other.side == side)&&(identical(other.entryPriceDollars, entryPriceDollars) || other.entryPriceDollars == entryPriceDollars)&&(identical(other.contracts, contracts) || other.contracts == contracts)&&(identical(other.yourProbability, yourProbability) || other.yourProbability == yourProbability)&&(identical(other.kellyFraction, kellyFraction) || other.kellyFraction == kellyFraction)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.exitPriceDollars, exitPriceDollars) || other.exitPriceDollars == exitPriceDollars)&&(identical(other.placedAt, placedAt) || other.placedAt == placedAt)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,marketTicker,marketTitle,side,entryPriceDollars,contracts,yourProbability,kellyFraction,outcome,exitPriceDollars,placedAt,resolvedAt);

@override
String toString() {
  return 'Bet(id: $id, marketTicker: $marketTicker, marketTitle: $marketTitle, side: $side, entryPriceDollars: $entryPriceDollars, contracts: $contracts, yourProbability: $yourProbability, kellyFraction: $kellyFraction, outcome: $outcome, exitPriceDollars: $exitPriceDollars, placedAt: $placedAt, resolvedAt: $resolvedAt)';
}


}

/// @nodoc
abstract mixin class $BetCopyWith<$Res>  {
  factory $BetCopyWith(Bet value, $Res Function(Bet) _then) = _$BetCopyWithImpl;
@useResult
$Res call({
 String id, String marketTicker, String marketTitle, BetSide side, double entryPriceDollars, int contracts, double yourProbability, double? kellyFraction, BetOutcome outcome, double? exitPriceDollars, DateTime placedAt, DateTime? resolvedAt
});




}
/// @nodoc
class _$BetCopyWithImpl<$Res>
    implements $BetCopyWith<$Res> {
  _$BetCopyWithImpl(this._self, this._then);

  final Bet _self;
  final $Res Function(Bet) _then;

/// Create a copy of Bet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? marketTicker = null,Object? marketTitle = null,Object? side = null,Object? entryPriceDollars = null,Object? contracts = null,Object? yourProbability = null,Object? kellyFraction = freezed,Object? outcome = null,Object? exitPriceDollars = freezed,Object? placedAt = null,Object? resolvedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,marketTicker: null == marketTicker ? _self.marketTicker : marketTicker // ignore: cast_nullable_to_non_nullable
as String,marketTitle: null == marketTitle ? _self.marketTitle : marketTitle // ignore: cast_nullable_to_non_nullable
as String,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as BetSide,entryPriceDollars: null == entryPriceDollars ? _self.entryPriceDollars : entryPriceDollars // ignore: cast_nullable_to_non_nullable
as double,contracts: null == contracts ? _self.contracts : contracts // ignore: cast_nullable_to_non_nullable
as int,yourProbability: null == yourProbability ? _self.yourProbability : yourProbability // ignore: cast_nullable_to_non_nullable
as double,kellyFraction: freezed == kellyFraction ? _self.kellyFraction : kellyFraction // ignore: cast_nullable_to_non_nullable
as double?,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as BetOutcome,exitPriceDollars: freezed == exitPriceDollars ? _self.exitPriceDollars : exitPriceDollars // ignore: cast_nullable_to_non_nullable
as double?,placedAt: null == placedAt ? _self.placedAt : placedAt // ignore: cast_nullable_to_non_nullable
as DateTime,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Bet].
extension BetPatterns on Bet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Bet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Bet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Bet value)  $default,){
final _that = this;
switch (_that) {
case _Bet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Bet value)?  $default,){
final _that = this;
switch (_that) {
case _Bet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String marketTicker,  String marketTitle,  BetSide side,  double entryPriceDollars,  int contracts,  double yourProbability,  double? kellyFraction,  BetOutcome outcome,  double? exitPriceDollars,  DateTime placedAt,  DateTime? resolvedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Bet() when $default != null:
return $default(_that.id,_that.marketTicker,_that.marketTitle,_that.side,_that.entryPriceDollars,_that.contracts,_that.yourProbability,_that.kellyFraction,_that.outcome,_that.exitPriceDollars,_that.placedAt,_that.resolvedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String marketTicker,  String marketTitle,  BetSide side,  double entryPriceDollars,  int contracts,  double yourProbability,  double? kellyFraction,  BetOutcome outcome,  double? exitPriceDollars,  DateTime placedAt,  DateTime? resolvedAt)  $default,) {final _that = this;
switch (_that) {
case _Bet():
return $default(_that.id,_that.marketTicker,_that.marketTitle,_that.side,_that.entryPriceDollars,_that.contracts,_that.yourProbability,_that.kellyFraction,_that.outcome,_that.exitPriceDollars,_that.placedAt,_that.resolvedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String marketTicker,  String marketTitle,  BetSide side,  double entryPriceDollars,  int contracts,  double yourProbability,  double? kellyFraction,  BetOutcome outcome,  double? exitPriceDollars,  DateTime placedAt,  DateTime? resolvedAt)?  $default,) {final _that = this;
switch (_that) {
case _Bet() when $default != null:
return $default(_that.id,_that.marketTicker,_that.marketTitle,_that.side,_that.entryPriceDollars,_that.contracts,_that.yourProbability,_that.kellyFraction,_that.outcome,_that.exitPriceDollars,_that.placedAt,_that.resolvedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Bet implements Bet {
  const _Bet({required this.id, required this.marketTicker, required this.marketTitle, required this.side, required this.entryPriceDollars, required this.contracts, required this.yourProbability, this.kellyFraction, required this.outcome, this.exitPriceDollars, required this.placedAt, this.resolvedAt});
  factory _Bet.fromJson(Map<String, dynamic> json) => _$BetFromJson(json);

@override final  String id;
@override final  String marketTicker;
@override final  String marketTitle;
@override final  BetSide side;
@override final  double entryPriceDollars;
@override final  int contracts;
@override final  double yourProbability;
@override final  double? kellyFraction;
@override final  BetOutcome outcome;
@override final  double? exitPriceDollars;
@override final  DateTime placedAt;
@override final  DateTime? resolvedAt;

/// Create a copy of Bet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BetCopyWith<_Bet> get copyWith => __$BetCopyWithImpl<_Bet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Bet&&(identical(other.id, id) || other.id == id)&&(identical(other.marketTicker, marketTicker) || other.marketTicker == marketTicker)&&(identical(other.marketTitle, marketTitle) || other.marketTitle == marketTitle)&&(identical(other.side, side) || other.side == side)&&(identical(other.entryPriceDollars, entryPriceDollars) || other.entryPriceDollars == entryPriceDollars)&&(identical(other.contracts, contracts) || other.contracts == contracts)&&(identical(other.yourProbability, yourProbability) || other.yourProbability == yourProbability)&&(identical(other.kellyFraction, kellyFraction) || other.kellyFraction == kellyFraction)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.exitPriceDollars, exitPriceDollars) || other.exitPriceDollars == exitPriceDollars)&&(identical(other.placedAt, placedAt) || other.placedAt == placedAt)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,marketTicker,marketTitle,side,entryPriceDollars,contracts,yourProbability,kellyFraction,outcome,exitPriceDollars,placedAt,resolvedAt);

@override
String toString() {
  return 'Bet(id: $id, marketTicker: $marketTicker, marketTitle: $marketTitle, side: $side, entryPriceDollars: $entryPriceDollars, contracts: $contracts, yourProbability: $yourProbability, kellyFraction: $kellyFraction, outcome: $outcome, exitPriceDollars: $exitPriceDollars, placedAt: $placedAt, resolvedAt: $resolvedAt)';
}


}

/// @nodoc
abstract mixin class _$BetCopyWith<$Res> implements $BetCopyWith<$Res> {
  factory _$BetCopyWith(_Bet value, $Res Function(_Bet) _then) = __$BetCopyWithImpl;
@override @useResult
$Res call({
 String id, String marketTicker, String marketTitle, BetSide side, double entryPriceDollars, int contracts, double yourProbability, double? kellyFraction, BetOutcome outcome, double? exitPriceDollars, DateTime placedAt, DateTime? resolvedAt
});




}
/// @nodoc
class __$BetCopyWithImpl<$Res>
    implements _$BetCopyWith<$Res> {
  __$BetCopyWithImpl(this._self, this._then);

  final _Bet _self;
  final $Res Function(_Bet) _then;

/// Create a copy of Bet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? marketTicker = null,Object? marketTitle = null,Object? side = null,Object? entryPriceDollars = null,Object? contracts = null,Object? yourProbability = null,Object? kellyFraction = freezed,Object? outcome = null,Object? exitPriceDollars = freezed,Object? placedAt = null,Object? resolvedAt = freezed,}) {
  return _then(_Bet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,marketTicker: null == marketTicker ? _self.marketTicker : marketTicker // ignore: cast_nullable_to_non_nullable
as String,marketTitle: null == marketTitle ? _self.marketTitle : marketTitle // ignore: cast_nullable_to_non_nullable
as String,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as BetSide,entryPriceDollars: null == entryPriceDollars ? _self.entryPriceDollars : entryPriceDollars // ignore: cast_nullable_to_non_nullable
as double,contracts: null == contracts ? _self.contracts : contracts // ignore: cast_nullable_to_non_nullable
as int,yourProbability: null == yourProbability ? _self.yourProbability : yourProbability // ignore: cast_nullable_to_non_nullable
as double,kellyFraction: freezed == kellyFraction ? _self.kellyFraction : kellyFraction // ignore: cast_nullable_to_non_nullable
as double?,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as BetOutcome,exitPriceDollars: freezed == exitPriceDollars ? _self.exitPriceDollars : exitPriceDollars // ignore: cast_nullable_to_non_nullable
as double?,placedAt: null == placedAt ? _self.placedAt : placedAt // ignore: cast_nullable_to_non_nullable
as DateTime,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$BetsPage {

 List<Bet> get bets; int get total; int get page; int get perPage;
/// Create a copy of BetsPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BetsPageCopyWith<BetsPage> get copyWith => _$BetsPageCopyWithImpl<BetsPage>(this as BetsPage, _$identity);

  /// Serializes this BetsPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BetsPage&&const DeepCollectionEquality().equals(other.bets, bets)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.perPage, perPage) || other.perPage == perPage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(bets),total,page,perPage);

@override
String toString() {
  return 'BetsPage(bets: $bets, total: $total, page: $page, perPage: $perPage)';
}


}

/// @nodoc
abstract mixin class $BetsPageCopyWith<$Res>  {
  factory $BetsPageCopyWith(BetsPage value, $Res Function(BetsPage) _then) = _$BetsPageCopyWithImpl;
@useResult
$Res call({
 List<Bet> bets, int total, int page, int perPage
});




}
/// @nodoc
class _$BetsPageCopyWithImpl<$Res>
    implements $BetsPageCopyWith<$Res> {
  _$BetsPageCopyWithImpl(this._self, this._then);

  final BetsPage _self;
  final $Res Function(BetsPage) _then;

/// Create a copy of BetsPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bets = null,Object? total = null,Object? page = null,Object? perPage = null,}) {
  return _then(_self.copyWith(
bets: null == bets ? _self.bets : bets // ignore: cast_nullable_to_non_nullable
as List<Bet>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,perPage: null == perPage ? _self.perPage : perPage // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BetsPage].
extension BetsPagePatterns on BetsPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BetsPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BetsPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BetsPage value)  $default,){
final _that = this;
switch (_that) {
case _BetsPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BetsPage value)?  $default,){
final _that = this;
switch (_that) {
case _BetsPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Bet> bets,  int total,  int page,  int perPage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BetsPage() when $default != null:
return $default(_that.bets,_that.total,_that.page,_that.perPage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Bet> bets,  int total,  int page,  int perPage)  $default,) {final _that = this;
switch (_that) {
case _BetsPage():
return $default(_that.bets,_that.total,_that.page,_that.perPage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Bet> bets,  int total,  int page,  int perPage)?  $default,) {final _that = this;
switch (_that) {
case _BetsPage() when $default != null:
return $default(_that.bets,_that.total,_that.page,_that.perPage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BetsPage implements BetsPage {
  const _BetsPage({required final  List<Bet> bets, required this.total, required this.page, required this.perPage}): _bets = bets;
  factory _BetsPage.fromJson(Map<String, dynamic> json) => _$BetsPageFromJson(json);

 final  List<Bet> _bets;
@override List<Bet> get bets {
  if (_bets is EqualUnmodifiableListView) return _bets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bets);
}

@override final  int total;
@override final  int page;
@override final  int perPage;

/// Create a copy of BetsPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BetsPageCopyWith<_BetsPage> get copyWith => __$BetsPageCopyWithImpl<_BetsPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BetsPageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BetsPage&&const DeepCollectionEquality().equals(other._bets, _bets)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.perPage, perPage) || other.perPage == perPage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_bets),total,page,perPage);

@override
String toString() {
  return 'BetsPage(bets: $bets, total: $total, page: $page, perPage: $perPage)';
}


}

/// @nodoc
abstract mixin class _$BetsPageCopyWith<$Res> implements $BetsPageCopyWith<$Res> {
  factory _$BetsPageCopyWith(_BetsPage value, $Res Function(_BetsPage) _then) = __$BetsPageCopyWithImpl;
@override @useResult
$Res call({
 List<Bet> bets, int total, int page, int perPage
});




}
/// @nodoc
class __$BetsPageCopyWithImpl<$Res>
    implements _$BetsPageCopyWith<$Res> {
  __$BetsPageCopyWithImpl(this._self, this._then);

  final _BetsPage _self;
  final $Res Function(_BetsPage) _then;

/// Create a copy of BetsPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bets = null,Object? total = null,Object? page = null,Object? perPage = null,}) {
  return _then(_BetsPage(
bets: null == bets ? _self._bets : bets // ignore: cast_nullable_to_non_nullable
as List<Bet>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,perPage: null == perPage ? _self.perPage : perPage // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
