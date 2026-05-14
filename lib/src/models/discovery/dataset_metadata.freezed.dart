// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dataset_metadata.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DatasetMetadata _$DatasetMetadataFromJson(Map<String, dynamic> json) {
  return _DatasetMetadata.fromJson(json);
}

/// @nodoc
mixin _$DatasetMetadata {
  String get identifier => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String> get keyword => throw _privateConstructorUsedError;
  DateTime get modified => throw _privateConstructorUsedError;
  String get publisher => throw _privateConstructorUsedError;
  @JsonKey(name: 'contact_point')
  String? get contactPoint => throw _privateConstructorUsedError;
  String get spatial => throw _privateConstructorUsedError;
  String get temporal => throw _privateConstructorUsedError;
  @JsonKey(name: 'accrual_periodicity')
  String? get accrualPeriodicity => throw _privateConstructorUsedError;

  /// Serializes this DatasetMetadata to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DatasetMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DatasetMetadataCopyWith<DatasetMetadata> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DatasetMetadataCopyWith<$Res> {
  factory $DatasetMetadataCopyWith(
          DatasetMetadata value, $Res Function(DatasetMetadata) then) =
      _$DatasetMetadataCopyWithImpl<$Res, DatasetMetadata>;
  @useResult
  $Res call(
      {String identifier,
      String title,
      String description,
      List<String> keyword,
      DateTime modified,
      String publisher,
      @JsonKey(name: 'contact_point') String? contactPoint,
      String spatial,
      String temporal,
      @JsonKey(name: 'accrual_periodicity') String? accrualPeriodicity});
}

/// @nodoc
class _$DatasetMetadataCopyWithImpl<$Res, $Val extends DatasetMetadata>
    implements $DatasetMetadataCopyWith<$Res> {
  _$DatasetMetadataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DatasetMetadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? identifier = null,
    Object? title = null,
    Object? description = null,
    Object? keyword = null,
    Object? modified = null,
    Object? publisher = null,
    Object? contactPoint = freezed,
    Object? spatial = null,
    Object? temporal = null,
    Object? accrualPeriodicity = freezed,
  }) {
    return _then(_value.copyWith(
      identifier: null == identifier
          ? _value.identifier
          : identifier // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      keyword: null == keyword
          ? _value.keyword
          : keyword // ignore: cast_nullable_to_non_nullable
              as List<String>,
      modified: null == modified
          ? _value.modified
          : modified // ignore: cast_nullable_to_non_nullable
              as DateTime,
      publisher: null == publisher
          ? _value.publisher
          : publisher // ignore: cast_nullable_to_non_nullable
              as String,
      contactPoint: freezed == contactPoint
          ? _value.contactPoint
          : contactPoint // ignore: cast_nullable_to_non_nullable
              as String?,
      spatial: null == spatial
          ? _value.spatial
          : spatial // ignore: cast_nullable_to_non_nullable
              as String,
      temporal: null == temporal
          ? _value.temporal
          : temporal // ignore: cast_nullable_to_non_nullable
              as String,
      accrualPeriodicity: freezed == accrualPeriodicity
          ? _value.accrualPeriodicity
          : accrualPeriodicity // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DatasetMetadataImplCopyWith<$Res>
    implements $DatasetMetadataCopyWith<$Res> {
  factory _$$DatasetMetadataImplCopyWith(_$DatasetMetadataImpl value,
          $Res Function(_$DatasetMetadataImpl) then) =
      __$$DatasetMetadataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String identifier,
      String title,
      String description,
      List<String> keyword,
      DateTime modified,
      String publisher,
      @JsonKey(name: 'contact_point') String? contactPoint,
      String spatial,
      String temporal,
      @JsonKey(name: 'accrual_periodicity') String? accrualPeriodicity});
}

/// @nodoc
class __$$DatasetMetadataImplCopyWithImpl<$Res>
    extends _$DatasetMetadataCopyWithImpl<$Res, _$DatasetMetadataImpl>
    implements _$$DatasetMetadataImplCopyWith<$Res> {
  __$$DatasetMetadataImplCopyWithImpl(
      _$DatasetMetadataImpl _value, $Res Function(_$DatasetMetadataImpl) _then)
      : super(_value, _then);

  /// Create a copy of DatasetMetadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? identifier = null,
    Object? title = null,
    Object? description = null,
    Object? keyword = null,
    Object? modified = null,
    Object? publisher = null,
    Object? contactPoint = freezed,
    Object? spatial = null,
    Object? temporal = null,
    Object? accrualPeriodicity = freezed,
  }) {
    return _then(_$DatasetMetadataImpl(
      identifier: null == identifier
          ? _value.identifier
          : identifier // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      keyword: null == keyword
          ? _value._keyword
          : keyword // ignore: cast_nullable_to_non_nullable
              as List<String>,
      modified: null == modified
          ? _value.modified
          : modified // ignore: cast_nullable_to_non_nullable
              as DateTime,
      publisher: null == publisher
          ? _value.publisher
          : publisher // ignore: cast_nullable_to_non_nullable
              as String,
      contactPoint: freezed == contactPoint
          ? _value.contactPoint
          : contactPoint // ignore: cast_nullable_to_non_nullable
              as String?,
      spatial: null == spatial
          ? _value.spatial
          : spatial // ignore: cast_nullable_to_non_nullable
              as String,
      temporal: null == temporal
          ? _value.temporal
          : temporal // ignore: cast_nullable_to_non_nullable
              as String,
      accrualPeriodicity: freezed == accrualPeriodicity
          ? _value.accrualPeriodicity
          : accrualPeriodicity // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DatasetMetadataImpl implements _DatasetMetadata {
  const _$DatasetMetadataImpl(
      {required this.identifier,
      required this.title,
      required this.description,
      required final List<String> keyword,
      required this.modified,
      required this.publisher,
      @JsonKey(name: 'contact_point') required this.contactPoint,
      required this.spatial,
      required this.temporal,
      @JsonKey(name: 'accrual_periodicity') required this.accrualPeriodicity})
      : _keyword = keyword;

  factory _$DatasetMetadataImpl.fromJson(Map<String, dynamic> json) =>
      _$$DatasetMetadataImplFromJson(json);

  @override
  final String identifier;
  @override
  final String title;
  @override
  final String description;
  final List<String> _keyword;
  @override
  List<String> get keyword {
    if (_keyword is EqualUnmodifiableListView) return _keyword;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_keyword);
  }

  @override
  final DateTime modified;
  @override
  final String publisher;
  @override
  @JsonKey(name: 'contact_point')
  final String? contactPoint;
  @override
  final String spatial;
  @override
  final String temporal;
  @override
  @JsonKey(name: 'accrual_periodicity')
  final String? accrualPeriodicity;

  @override
  String toString() {
    return 'DatasetMetadata(identifier: $identifier, title: $title, description: $description, keyword: $keyword, modified: $modified, publisher: $publisher, contactPoint: $contactPoint, spatial: $spatial, temporal: $temporal, accrualPeriodicity: $accrualPeriodicity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DatasetMetadataImpl &&
            (identical(other.identifier, identifier) ||
                other.identifier == identifier) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._keyword, _keyword) &&
            (identical(other.modified, modified) ||
                other.modified == modified) &&
            (identical(other.publisher, publisher) ||
                other.publisher == publisher) &&
            (identical(other.contactPoint, contactPoint) ||
                other.contactPoint == contactPoint) &&
            (identical(other.spatial, spatial) || other.spatial == spatial) &&
            (identical(other.temporal, temporal) ||
                other.temporal == temporal) &&
            (identical(other.accrualPeriodicity, accrualPeriodicity) ||
                other.accrualPeriodicity == accrualPeriodicity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      identifier,
      title,
      description,
      const DeepCollectionEquality().hash(_keyword),
      modified,
      publisher,
      contactPoint,
      spatial,
      temporal,
      accrualPeriodicity);

  /// Create a copy of DatasetMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DatasetMetadataImplCopyWith<_$DatasetMetadataImpl> get copyWith =>
      __$$DatasetMetadataImplCopyWithImpl<_$DatasetMetadataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DatasetMetadataImplToJson(
      this,
    );
  }
}

abstract class _DatasetMetadata implements DatasetMetadata {
  const factory _DatasetMetadata(
      {required final String identifier,
      required final String title,
      required final String description,
      required final List<String> keyword,
      required final DateTime modified,
      required final String publisher,
      @JsonKey(name: 'contact_point') required final String? contactPoint,
      required final String spatial,
      required final String temporal,
      @JsonKey(name: 'accrual_periodicity')
      required final String? accrualPeriodicity}) = _$DatasetMetadataImpl;

  factory _DatasetMetadata.fromJson(Map<String, dynamic> json) =
      _$DatasetMetadataImpl.fromJson;

  @override
  String get identifier;
  @override
  String get title;
  @override
  String get description;
  @override
  List<String> get keyword;
  @override
  DateTime get modified;
  @override
  String get publisher;
  @override
  @JsonKey(name: 'contact_point')
  String? get contactPoint;
  @override
  String get spatial;
  @override
  String get temporal;
  @override
  @JsonKey(name: 'accrual_periodicity')
  String? get accrualPeriodicity;

  /// Create a copy of DatasetMetadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DatasetMetadataImplCopyWith<_$DatasetMetadataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
