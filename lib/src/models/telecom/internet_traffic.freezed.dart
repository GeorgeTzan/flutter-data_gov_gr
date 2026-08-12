// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'internet_traffic.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InternetTraffic {

/// The published `date` value.
@SourceDateConverter() SourceDate get date;/// The published `avg_in` value.
@JsonKey(name: 'avg_in') num? get avgIn;/// The published `avg_out` value.
@JsonKey(name: 'avg_out') num? get avgOut;/// The published `max_in` value.
@JsonKey(name: 'max_in') num? get maxIn;/// The published `max_out` value.
@JsonKey(name: 'max_out') num? get maxOut;/// Immutable original source cells, including unknown columns.
@ImmutableSourceConverter() JsonObject get raw;/// Selected source identity and measured retrieval time.
@SourceProvenanceConverter() SourceProvenance get provenance;
/// Create a copy of InternetTraffic
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InternetTrafficCopyWith<InternetTraffic> get copyWith => _$InternetTrafficCopyWithImpl<InternetTraffic>(this as InternetTraffic, _$identity);

  /// Serializes this InternetTraffic to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InternetTraffic&&(identical(other.date, date) || other.date == date)&&(identical(other.avgIn, avgIn) || other.avgIn == avgIn)&&(identical(other.avgOut, avgOut) || other.avgOut == avgOut)&&(identical(other.maxIn, maxIn) || other.maxIn == maxIn)&&(identical(other.maxOut, maxOut) || other.maxOut == maxOut)&&const DeepCollectionEquality().equals(other.raw, raw)&&(identical(other.provenance, provenance) || other.provenance == provenance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,avgIn,avgOut,maxIn,maxOut,const DeepCollectionEquality().hash(raw),provenance);

@override
String toString() {
  return 'InternetTraffic(date: $date, avgIn: $avgIn, avgOut: $avgOut, maxIn: $maxIn, maxOut: $maxOut, raw: $raw, provenance: $provenance)';
}


}

/// @nodoc
abstract mixin class $InternetTrafficCopyWith<$Res>  {
  factory $InternetTrafficCopyWith(InternetTraffic value, $Res Function(InternetTraffic) _then) = _$InternetTrafficCopyWithImpl;
@useResult
$Res call({
@SourceDateConverter() SourceDate date,@JsonKey(name: 'avg_in') num? avgIn,@JsonKey(name: 'avg_out') num? avgOut,@JsonKey(name: 'max_in') num? maxIn,@JsonKey(name: 'max_out') num? maxOut,@ImmutableSourceConverter() JsonObject raw,@SourceProvenanceConverter() SourceProvenance provenance
});




}
/// @nodoc
class _$InternetTrafficCopyWithImpl<$Res>
    implements $InternetTrafficCopyWith<$Res> {
  _$InternetTrafficCopyWithImpl(this._self, this._then);

  final InternetTraffic _self;
  final $Res Function(InternetTraffic) _then;

/// Create a copy of InternetTraffic
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? avgIn = freezed,Object? avgOut = freezed,Object? maxIn = freezed,Object? maxOut = freezed,Object? raw = null,Object? provenance = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as SourceDate,avgIn: freezed == avgIn ? _self.avgIn : avgIn // ignore: cast_nullable_to_non_nullable
as num?,avgOut: freezed == avgOut ? _self.avgOut : avgOut // ignore: cast_nullable_to_non_nullable
as num?,maxIn: freezed == maxIn ? _self.maxIn : maxIn // ignore: cast_nullable_to_non_nullable
as num?,maxOut: freezed == maxOut ? _self.maxOut : maxOut // ignore: cast_nullable_to_non_nullable
as num?,raw: null == raw ? _self.raw : raw // ignore: cast_nullable_to_non_nullable
as JsonObject,provenance: null == provenance ? _self.provenance : provenance // ignore: cast_nullable_to_non_nullable
as SourceProvenance,
  ));
}

}


/// Adds pattern-matching-related methods to [InternetTraffic].
extension InternetTrafficPatterns on InternetTraffic {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InternetTraffic value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InternetTraffic() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InternetTraffic value)  $default,){
final _that = this;
switch (_that) {
case _InternetTraffic():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InternetTraffic value)?  $default,){
final _that = this;
switch (_that) {
case _InternetTraffic() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@SourceDateConverter()  SourceDate date, @JsonKey(name: 'avg_in')  num? avgIn, @JsonKey(name: 'avg_out')  num? avgOut, @JsonKey(name: 'max_in')  num? maxIn, @JsonKey(name: 'max_out')  num? maxOut, @ImmutableSourceConverter()  JsonObject raw, @SourceProvenanceConverter()  SourceProvenance provenance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InternetTraffic() when $default != null:
return $default(_that.date,_that.avgIn,_that.avgOut,_that.maxIn,_that.maxOut,_that.raw,_that.provenance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@SourceDateConverter()  SourceDate date, @JsonKey(name: 'avg_in')  num? avgIn, @JsonKey(name: 'avg_out')  num? avgOut, @JsonKey(name: 'max_in')  num? maxIn, @JsonKey(name: 'max_out')  num? maxOut, @ImmutableSourceConverter()  JsonObject raw, @SourceProvenanceConverter()  SourceProvenance provenance)  $default,) {final _that = this;
switch (_that) {
case _InternetTraffic():
return $default(_that.date,_that.avgIn,_that.avgOut,_that.maxIn,_that.maxOut,_that.raw,_that.provenance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@SourceDateConverter()  SourceDate date, @JsonKey(name: 'avg_in')  num? avgIn, @JsonKey(name: 'avg_out')  num? avgOut, @JsonKey(name: 'max_in')  num? maxIn, @JsonKey(name: 'max_out')  num? maxOut, @ImmutableSourceConverter()  JsonObject raw, @SourceProvenanceConverter()  SourceProvenance provenance)?  $default,) {final _that = this;
switch (_that) {
case _InternetTraffic() when $default != null:
return $default(_that.date,_that.avgIn,_that.avgOut,_that.maxIn,_that.maxOut,_that.raw,_that.provenance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InternetTraffic implements InternetTraffic {
  const _InternetTraffic({@SourceDateConverter() required this.date, @JsonKey(name: 'avg_in') this.avgIn, @JsonKey(name: 'avg_out') this.avgOut, @JsonKey(name: 'max_in') this.maxIn, @JsonKey(name: 'max_out') this.maxOut, @ImmutableSourceConverter() required final  JsonObject raw, @SourceProvenanceConverter() required this.provenance}): _raw = raw;
  factory _InternetTraffic.fromJson(Map<String, dynamic> json) => _$InternetTrafficFromJson(json);

/// The published `date` value.
@override@SourceDateConverter() final  SourceDate date;
/// The published `avg_in` value.
@override@JsonKey(name: 'avg_in') final  num? avgIn;
/// The published `avg_out` value.
@override@JsonKey(name: 'avg_out') final  num? avgOut;
/// The published `max_in` value.
@override@JsonKey(name: 'max_in') final  num? maxIn;
/// The published `max_out` value.
@override@JsonKey(name: 'max_out') final  num? maxOut;
/// Immutable original source cells, including unknown columns.
 final  JsonObject _raw;
/// Immutable original source cells, including unknown columns.
@override@ImmutableSourceConverter() JsonObject get raw {
  if (_raw is EqualUnmodifiableMapView) return _raw;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_raw);
}

/// Selected source identity and measured retrieval time.
@override@SourceProvenanceConverter() final  SourceProvenance provenance;

/// Create a copy of InternetTraffic
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InternetTrafficCopyWith<_InternetTraffic> get copyWith => __$InternetTrafficCopyWithImpl<_InternetTraffic>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InternetTrafficToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InternetTraffic&&(identical(other.date, date) || other.date == date)&&(identical(other.avgIn, avgIn) || other.avgIn == avgIn)&&(identical(other.avgOut, avgOut) || other.avgOut == avgOut)&&(identical(other.maxIn, maxIn) || other.maxIn == maxIn)&&(identical(other.maxOut, maxOut) || other.maxOut == maxOut)&&const DeepCollectionEquality().equals(other._raw, _raw)&&(identical(other.provenance, provenance) || other.provenance == provenance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,avgIn,avgOut,maxIn,maxOut,const DeepCollectionEquality().hash(_raw),provenance);

@override
String toString() {
  return 'InternetTraffic(date: $date, avgIn: $avgIn, avgOut: $avgOut, maxIn: $maxIn, maxOut: $maxOut, raw: $raw, provenance: $provenance)';
}


}

/// @nodoc
abstract mixin class _$InternetTrafficCopyWith<$Res> implements $InternetTrafficCopyWith<$Res> {
  factory _$InternetTrafficCopyWith(_InternetTraffic value, $Res Function(_InternetTraffic) _then) = __$InternetTrafficCopyWithImpl;
@override @useResult
$Res call({
@SourceDateConverter() SourceDate date,@JsonKey(name: 'avg_in') num? avgIn,@JsonKey(name: 'avg_out') num? avgOut,@JsonKey(name: 'max_in') num? maxIn,@JsonKey(name: 'max_out') num? maxOut,@ImmutableSourceConverter() JsonObject raw,@SourceProvenanceConverter() SourceProvenance provenance
});




}
/// @nodoc
class __$InternetTrafficCopyWithImpl<$Res>
    implements _$InternetTrafficCopyWith<$Res> {
  __$InternetTrafficCopyWithImpl(this._self, this._then);

  final _InternetTraffic _self;
  final $Res Function(_InternetTraffic) _then;

/// Create a copy of InternetTraffic
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? avgIn = freezed,Object? avgOut = freezed,Object? maxIn = freezed,Object? maxOut = freezed,Object? raw = null,Object? provenance = null,}) {
  return _then(_InternetTraffic(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as SourceDate,avgIn: freezed == avgIn ? _self.avgIn : avgIn // ignore: cast_nullable_to_non_nullable
as num?,avgOut: freezed == avgOut ? _self.avgOut : avgOut // ignore: cast_nullable_to_non_nullable
as num?,maxIn: freezed == maxIn ? _self.maxIn : maxIn // ignore: cast_nullable_to_non_nullable
as num?,maxOut: freezed == maxOut ? _self.maxOut : maxOut // ignore: cast_nullable_to_non_nullable
as num?,raw: null == raw ? _self._raw : raw // ignore: cast_nullable_to_non_nullable
as JsonObject,provenance: null == provenance ? _self.provenance : provenance // ignore: cast_nullable_to_non_nullable
as SourceProvenance,
  ));
}


}

// dart format on
