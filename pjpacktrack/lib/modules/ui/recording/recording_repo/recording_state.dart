// recording_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'recording_state.freezed.dart';

@freezed
class RecordingState with _$RecordingState {
  const factory RecordingState({
    @Default(false) bool isRecording,
    @Default(true) bool isScanning,
    @Default(false) bool isFlashOn,
    @Default(false) bool isQRCode,
    @Default(false) bool isInitialized,
    @Default(false) bool continuousRecording,
    String? lastScannedCode,
    String? selectedDeliveryOption,
    @Default([]) List<String> videoPaths,
    @Default(false) bool isContinuousScanning,
  }) = _RecordingState;
}
