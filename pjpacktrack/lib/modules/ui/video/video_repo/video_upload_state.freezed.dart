// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_upload_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$VideoUploadState {
  bool get isUploading => throw _privateConstructorUsedError;
  double get uploadProgress => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  /// Create a copy of VideoUploadState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoUploadStateCopyWith<VideoUploadState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoUploadStateCopyWith<$Res> {
  factory $VideoUploadStateCopyWith(
          VideoUploadState value, $Res Function(VideoUploadState) then) =
      _$VideoUploadStateCopyWithImpl<$Res, VideoUploadState>;
  @useResult
  $Res call(
      {bool isUploading,
      double uploadProgress,
      String? error,
      String? message});
}

/// @nodoc
class _$VideoUploadStateCopyWithImpl<$Res, $Val extends VideoUploadState>
    implements $VideoUploadStateCopyWith<$Res> {
  _$VideoUploadStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoUploadState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isUploading = null,
    Object? uploadProgress = null,
    Object? error = freezed,
    Object? message = freezed,
  }) {
    return _then(_value.copyWith(
      isUploading: null == isUploading
          ? _value.isUploading
          : isUploading // ignore: cast_nullable_to_non_nullable
              as bool,
      uploadProgress: null == uploadProgress
          ? _value.uploadProgress
          : uploadProgress // ignore: cast_nullable_to_non_nullable
              as double,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VideoUploadStateImplCopyWith<$Res>
    implements $VideoUploadStateCopyWith<$Res> {
  factory _$$VideoUploadStateImplCopyWith(_$VideoUploadStateImpl value,
          $Res Function(_$VideoUploadStateImpl) then) =
      __$$VideoUploadStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isUploading,
      double uploadProgress,
      String? error,
      String? message});
}

/// @nodoc
class __$$VideoUploadStateImplCopyWithImpl<$Res>
    extends _$VideoUploadStateCopyWithImpl<$Res, _$VideoUploadStateImpl>
    implements _$$VideoUploadStateImplCopyWith<$Res> {
  __$$VideoUploadStateImplCopyWithImpl(_$VideoUploadStateImpl _value,
      $Res Function(_$VideoUploadStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of VideoUploadState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isUploading = null,
    Object? uploadProgress = null,
    Object? error = freezed,
    Object? message = freezed,
  }) {
    return _then(_$VideoUploadStateImpl(
      isUploading: null == isUploading
          ? _value.isUploading
          : isUploading // ignore: cast_nullable_to_non_nullable
              as bool,
      uploadProgress: null == uploadProgress
          ? _value.uploadProgress
          : uploadProgress // ignore: cast_nullable_to_non_nullable
              as double,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$VideoUploadStateImpl implements _VideoUploadState {
  const _$VideoUploadStateImpl(
      {this.isUploading = false,
      this.uploadProgress = 0.0,
      this.error,
      this.message});

  @override
  @JsonKey()
  final bool isUploading;
  @override
  @JsonKey()
  final double uploadProgress;
  @override
  final String? error;
  @override
  final String? message;

  @override
  String toString() {
    return 'VideoUploadState(isUploading: $isUploading, uploadProgress: $uploadProgress, error: $error, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoUploadStateImpl &&
            (identical(other.isUploading, isUploading) ||
                other.isUploading == isUploading) &&
            (identical(other.uploadProgress, uploadProgress) ||
                other.uploadProgress == uploadProgress) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isUploading, uploadProgress, error, message);

  /// Create a copy of VideoUploadState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoUploadStateImplCopyWith<_$VideoUploadStateImpl> get copyWith =>
      __$$VideoUploadStateImplCopyWithImpl<_$VideoUploadStateImpl>(
          this, _$identity);
}

abstract class _VideoUploadState implements VideoUploadState {
  const factory _VideoUploadState(
      {final bool isUploading,
      final double uploadProgress,
      final String? error,
      final String? message}) = _$VideoUploadStateImpl;

  @override
  bool get isUploading;
  @override
  double get uploadProgress;
  @override
  String? get error;
  @override
  String? get message;

  /// Create a copy of VideoUploadState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoUploadStateImplCopyWith<_$VideoUploadStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
