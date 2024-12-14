import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pjpacktrack/modules/ui/recording/recording_controller.dart';
import 'package:pjpacktrack/modules/ui/recording/recording_indicator.dart';
import 'package:pjpacktrack/modules/ui/recording/recording_repo/recording_state.dart';
import 'package:pjpacktrack/modules/ui/recording/start_prompt.dart';
import 'delivery_option.dart';

final uploadStatusProvider = StateProvider<String?>((ref) => null);

class RecordingScreen extends ConsumerWidget {
  final List<CameraDescription> cameras;
  final String storeId;

  const RecordingScreen({
    super.key,
    required this.cameras,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recordingControllerProvider);
    final controller = ref.watch(recordingControllerProvider.notifier);

    if (controller.cameraController == null) {
      controller.initializeCamera(cameras);
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(state.isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: controller.toggleFlash,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Scanner luôn hiển thị khi isScanning = true
          if (state.isScanning) _buildScanner(controller),

          // Camera preview chỉ hiển thị khi recording
          if (state.isRecording && state.isInitialized)
            CameraPreview(controller.cameraController!),

          _buildDeliveryOptions(controller),

          if (!state.isRecording && state.selectedDeliveryOption == null)
            const StartPrompt(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, state, controller),
    );
  }

  Widget _buildScanner(RecordingController controller) {
    return MobileScanner(
      controller: controller.scannerController,
      onDetect: controller.handleBarcodeDetection,
      errorBuilder: (context, error, child) {
        return Center(
          child: Text('Scanner error: $error'),
        );
      },
    );
  }

  Widget _buildDeliveryOptions(RecordingController controller) {
    return Positioned(
      top: 0,
      right: 0,
      left: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
        ),
        child: DeliveryOptionsWidget(
          onOptionSelected: controller.setDeliveryOption,
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, RecordingState state,
      RecordingController controller) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: ElevatedButton(
          onPressed:
              state.isRecording ? () => controller.stopAndReset(storeId) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(state.isRecording ? Icons.stop : Icons.videocam),
              const SizedBox(width: 8),
              Text(
                state.isRecording ? 'Dừng quay video' : 'Chờ quét mã',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
