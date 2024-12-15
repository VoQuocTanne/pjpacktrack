import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_upload_state.freezed.dart';

@freezed
class VideoUploadState with _$VideoUploadState {
  const factory VideoUploadState({
    @Default(false) bool isUploading,
    @Default(0.0) double uploadProgress,
    String? error,
    String? message,
  }) = _VideoUploadState;
}