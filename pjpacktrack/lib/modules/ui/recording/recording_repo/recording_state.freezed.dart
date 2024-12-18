// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recording_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$RecordingState {
  bool get isRecording => throw _privateConstructorUsedError;
  bool get isScanning => throw _privateConstructorUsedError;
  bool get isFlashOn => throw _privateConstructorUsedError;
  bool get isQRCode => throw _privateConstructorUsedError;
  bool get isInitialized => throw _privateConstructorUsedError;
  bool get continuousRecording => throw _privateConstructorUsedError;
  String? get lastScannedCode => throw _privateConstructorUsedError;
  String? get selectedDeliveryOption => throw _privateConstructorUsedError;
  List<String> get videoPaths => throw _privateConstructorUsedError;
  bool get isContinuousScanning => throw _privateConstructorUsedError;
  List<ImageLabel> get imageLabels => throw _privateConstructorUsedError;
  List<DetectedObject> get detectedObjects =>
      throw _privateConstructorUsedError;
  bool get isProcessingML => throw _privateConstructorUsedError;

  /// Create a copy of RecordingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecordingStateCopyWith<RecordingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecordingStateCopyWith<$Res> {
  factory $RecordingStateCopyWith(
          RecordingState value, $Res Function(RecordingState) then) =
      _$RecordingStateCopyWithImpl<$Res, RecordingState>;
  @useResult
  $Res call(
      {bool isRecording,
      bool isScanning,
      bool isFlashOn,
      bool isQRCode,
      bool isInitialized,
      bool continuousRecording,
      String? lastScannedCode,
      String? selectedDeliveryOption,
      List<String> videoPaths,
      bool isContinuousScanning,
      List<ImageLabel> imageLabels,
      List<DetectedObject> detectedObjects,
      bool isProcessingML});
}

/// @nodoc
class _$RecordingStateCopyWithImpl<$Res, $Val extends RecordingState>
    implements $RecordingStateCopyWith<$Res> {
  _$RecordingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecordingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isRecording = null,
    Object? isScanning = null,
    Object? isFlashOn = null,
    Object? isQRCode = null,
    Object? isInitialized = null,
    Object? continuousRecording = null,
    Object? lastScannedCode = freezed,
    Object? selectedDeliveryOption = freezed,
    Object? videoPaths = null,
    Object? isContinuousScanning = null,
    Object? imageLabels = null,
    Object? detectedObjects = null,
    Object? isProcessingML = null,
  }) {
    return _then(_value.copyWith(
      isRecording: null == isRecording
          ? _value.isRecording
          : isRecording // ignore: cast_nullable_to_non_nullable
              as bool,
      isScanning: null == isScanning
          ? _value.isScanning
          : isScanning // ignore: cast_nullable_to_non_nullable
              as bool,
      isFlashOn: null == isFlashOn
          ? _value.isFlashOn
          : isFlashOn // ignore: cast_nullable_to_non_nullable
              as bool,
      isQRCode: null == isQRCode
          ? _value.isQRCode
          : isQRCode // ignore: cast_nullable_to_non_nullable
              as bool,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
      continuousRecording: null == continuousRecording
          ? _value.continuousRecording
          : continuousRecording // ignore: cast_nullable_to_non_nullable
              as bool,
      lastScannedCode: freezed == lastScannedCode
          ? _value.lastScannedCode
          : lastScannedCode // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedDeliveryOption: freezed == selectedDeliveryOption
          ? _value.selectedDeliveryOption
          : selectedDeliveryOption // ignore: cast_nullable_to_non_nullable
              as String?,
      videoPaths: null == videoPaths
          ? _value.videoPaths
          : videoPaths // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isContinuousScanning: null == isContinuousScanning
          ? _value.isContinuousScanning
          : isContinuousScanning // ignore: cast_nullable_to_non_nullable
              as bool,
      imageLabels: null == imageLabels
          ? _value.imageLabels
          : imageLabels // ignore: cast_nullable_to_non_nullable
              as List<ImageLabel>,
      detectedObjects: null == detectedObjects
          ? _value.detectedObjects
          : detectedObjects // ignore: cast_nullable_to_non_nullable
              as List<DetectedObject>,
      isProcessingML: null == isProcessingML
          ? _value.isProcessingML
          : isProcessingML // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecordingStateImplCopyWith<$Res>
    implements $RecordingStateCopyWith<$Res> {
  factory _$$RecordingStateImplCopyWith(_$RecordingStateImpl value,
          $Res Function(_$RecordingStateImpl) then) =
      __$$RecordingStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isRecording,
      bool isScanning,
      bool isFlashOn,
      bool isQRCode,
      bool isInitialized,
      bool continuousRecording,
      String? lastScannedCode,
      String? selectedDeliveryOption,
      List<String> videoPaths,
      bool isContinuousScanning,
      List<ImageLabel> imageLabels,
      List<DetectedObject> detectedObjects,
      bool isProcessingML});
}

/// @nodoc
class __$$RecordingStateImplCopyWithImpl<$Res>
    extends _$RecordingStateCopyWithImpl<$Res, _$RecordingStateImpl>
    implements _$$RecordingStateImplCopyWith<$Res> {
  __$$RecordingStateImplCopyWithImpl(
      _$RecordingStateImpl _value, $Res Function(_$RecordingStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecordingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isRecording = null,
    Object? isScanning = null,
    Object? isFlashOn = null,
    Object? isQRCode = null,
    Object? isInitialized = null,
    Object? continuousRecording = null,
    Object? lastScannedCode = freezed,
    Object? selectedDeliveryOption = freezed,
    Object? videoPaths = null,
    Object? isContinuousScanning = null,
    Object? imageLabels = null,
    Object? detectedObjects = null,
    Object? isProcessingML = null,
  }) {
    return _then(_$RecordingStateImpl(
      isRecording: null == isRecording
          ? _value.isRecording
          : isRecording // ignore: cast_nullable_to_non_nullable
              as bool,
      isScanning: null == isScanning
          ? _value.isScanning
          : isScanning // ignore: cast_nullable_to_non_nullable
              as bool,
      isFlashOn: null == isFlashOn
          ? _value.isFlashOn
          : isFlashOn // ignore: cast_nullable_to_non_nullable
              as bool,
      isQRCode: null == isQRCode
          ? _value.isQRCode
          : isQRCode // ignore: cast_nullable_to_non_nullable
              as bool,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
      continuousRecording: null == continuousRecording
          ? _value.continuousRecording
          : continuousRecording // ignore: cast_nullable_to_non_nullable
              as bool,
      lastScannedCode: freezed == lastScannedCode
          ? _value.lastScannedCode
          : lastScannedCode // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedDeliveryOption: freezed == selectedDeliveryOption
          ? _value.selectedDeliveryOption
          : selectedDeliveryOption // ignore: cast_nullable_to_non_nullable
              as String?,
      videoPaths: null == videoPaths
          ? _value._videoPaths
          : videoPaths // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isContinuousScanning: null == isContinuousScanning
          ? _value.isContinuousScanning
          : isContinuousScanning // ignore: cast_nullable_to_non_nullable
              as bool,
      imageLabels: null == imageLabels
          ? _value._imageLabels
          : imageLabels // ignore: cast_nullable_to_non_nullable
              as List<ImageLabel>,
      detectedObjects: null == detectedObjects
          ? _value._detectedObjects
          : detectedObjects // ignore: cast_nullable_to_non_nullable
              as List<DetectedObject>,
      isProcessingML: null == isProcessingML
          ? _value.isProcessingML
          : isProcessingML // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$RecordingStateImpl implements _RecordingState {
  const _$RecordingStateImpl(
      {this.isRecording = false,
      this.isScanning = true,
      this.isFlashOn = false,
      this.isQRCode = false,
      this.isInitialized = false,
      this.continuousRecording = false,
      this.lastScannedCode,
      this.selectedDeliveryOption,
      final List<String> videoPaths = const [],
      this.isContinuousScanning = false,
      final List<ImageLabel> imageLabels = const [],
      final List<DetectedObject> detectedObjects = const [],
      this.isProcessingML = false})
      : _videoPaths = videoPaths,
        _imageLabels = imageLabels,
        _detectedObjects = detectedObjects;

  @override
  @JsonKey()
  final bool isRecording;
  @override
  @JsonKey()
  final bool isScanning;
  @override
  @JsonKey()
  final bool isFlashOn;
  @override
  @JsonKey()
  final bool isQRCode;
  @override
  @JsonKey()
  final bool isInitialized;
  @override
  @JsonKey()
  final bool continuousRecording;
  @override
  final String? lastScannedCode;
  @override
  final String? selectedDeliveryOption;
  final List<String> _videoPaths;
  @override
  @JsonKey()
  List<String> get videoPaths {
    if (_videoPaths is EqualUnmodifiableListView) return _videoPaths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_videoPaths);
  }

  @override
  @JsonKey()
  final bool isContinuousScanning;
  final List<ImageLabel> _imageLabels;
  @override
  @JsonKey()
  List<ImageLabel> get imageLabels {
    if (_imageLabels is EqualUnmodifiableListView) return _imageLabels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_imageLabels);
  }

  final List<DetectedObject> _detectedObjects;
  @override
  @JsonKey()
  List<DetectedObject> get detectedObjects {
    if (_detectedObjects is EqualUnmodifiableListView) return _detectedObjects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_detectedObjects);
  }

  @override
  @JsonKey()
  final bool isProcessingML;

  @override
  String toString() {
    return 'RecordingState(isRecording: $isRecording, isScanning: $isScanning, isFlashOn: $isFlashOn, isQRCode: $isQRCode, isInitialized: $isInitialized, continuousRecording: $continuousRecording, lastScannedCode: $lastScannedCode, selectedDeliveryOption: $selectedDeliveryOption, videoPaths: $videoPaths, isContinuousScanning: $isContinuousScanning, imageLabels: $imageLabels, detectedObjects: $detectedObjects, isProcessingML: $isProcessingML)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecordingStateImpl &&
            (identical(other.isRecording, isRecording) ||
                other.isRecording == isRecording) &&
            (identical(other.isScanning, isScanning) ||
                other.isScanning == isScanning) &&
            (identical(other.isFlashOn, isFlashOn) ||
                other.isFlashOn == isFlashOn) &&
            (identical(other.isQRCode, isQRCode) ||
                other.isQRCode == isQRCode) &&
            (identical(other.isInitialized, isInitialized) ||
                other.isInitialized == isInitialized) &&
            (identical(other.continuousRecording, continuousRecording) ||
                other.continuousRecording == continuousRecording) &&
            (identical(other.lastScannedCode, lastScannedCode) ||
                other.lastScannedCode == lastScannedCode) &&
            (identical(other.selectedDeliveryOption, selectedDeliveryOption) ||
                other.selectedDeliveryOption == selectedDeliveryOption) &&
            const DeepCollectionEquality()
                .equals(other._videoPaths, _videoPaths) &&
            (identical(other.isContinuousScanning, isContinuousScanning) ||
                other.isContinuousScanning == isContinuousScanning) &&
            const DeepCollectionEquality()
                .equals(other._imageLabels, _imageLabels) &&
            const DeepCollectionEquality()
                .equals(other._detectedObjects, _detectedObjects) &&
            (identical(other.isProcessingML, isProcessingML) ||
                other.isProcessingML == isProcessingML));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isRecording,
      isScanning,
      isFlashOn,
      isQRCode,
      isInitialized,
      continuousRecording,
      lastScannedCode,
      selectedDeliveryOption,
      const DeepCollectionEquality().hash(_videoPaths),
      isContinuousScanning,
      const DeepCollectionEquality().hash(_imageLabels),
      const DeepCollectionEquality().hash(_detectedObjects),
      isProcessingML);

  /// Create a copy of RecordingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecordingStateImplCopyWith<_$RecordingStateImpl> get copyWith =>
      __$$RecordingStateImplCopyWithImpl<_$RecordingStateImpl>(
          this, _$identity);
}

abstract class _RecordingState implements RecordingState {
  const factory _RecordingState(
      {final bool isRecording,
      final bool isScanning,
      final bool isFlashOn,
      final bool isQRCode,
      final bool isInitialized,
      final bool continuousRecording,
      final String? lastScannedCode,
      final String? selectedDeliveryOption,
      final List<String> videoPaths,
      final bool isContinuousScanning,
      final List<ImageLabel> imageLabels,
      final List<DetectedObject> detectedObjects,
      final bool isProcessingML}) = _$RecordingStateImpl;

  @override
  bool get isRecording;
  @override
  bool get isScanning;
  @override
  bool get isFlashOn;
  @override
  bool get isQRCode;
  @override
  bool get isInitialized;
  @override
  bool get continuousRecording;
  @override
  String? get lastScannedCode;
  @override
  String? get selectedDeliveryOption;
  @override
  List<String> get videoPaths;
  @override
  bool get isContinuousScanning;
  @override
  List<ImageLabel> get imageLabels;
  @override
  List<DetectedObject> get detectedObjects;
  @override
  bool get isProcessingML;

  /// Create a copy of RecordingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecordingStateImplCopyWith<_$RecordingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
