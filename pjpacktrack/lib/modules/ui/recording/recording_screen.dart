import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pjpacktrack/modules/ui/recording/recording_controller.dart';
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
            onPressed:
                ref.read(recordingControllerProvider.notifier).toggleFlash,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (state.isScanning)
            MobileScanner(
              controller: ref
                  .read(recordingControllerProvider.notifier)
                  .scannerController,
              onDetect: ref
                  .read(recordingControllerProvider.notifier)
                  .handleBarcodeDetection,
            ),
          if (state.isRecording && state.isInitialized)
            CameraPreview(ref
                .read(recordingControllerProvider.notifier)
                .cameraController!),
          if (state.productName != null)
            _buildProductNameOverlay(state.productName!),
          _buildDeliveryOptions(ref.read(recordingControllerProvider.notifier)),
          if (!state.isRecording && state.selectedDeliveryOption == null)
            const StartPrompt(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(
          context, state, ref.read(recordingControllerProvider.notifier)),
    );
  }

  Widget _buildProductNameOverlay(String productName) {
    // Chia danh sách sản phẩm thành từng dòng
    final List<String> productList = productName.split(',');

    return Positioned(
      top: 82,
      left: 0, // Sát lề trái của màn hình
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Căn lề trái các sản phẩm
          children: [
            for (var product in productList) // Duyệt qua từng sản phẩm
              Padding(
                padding: const EdgeInsets.only(
                    bottom: 4), // Khoảng cách giữa các dòng
                child: Text(
                  product.trim(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanner(RecordingController controller) {
    return MobileScanner(
      controller: controller.scannerController,
      onDetect: controller.handleBarcodeDetection,
      errorBuilder: (context, error, child) {
        return Center(child: Text('Scanner error: $error'));
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
          color: Colors.black.withOpacity(0),
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

  Widget _buildUploadStatus(String status) {
    return Positioned(
      top: 60,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          status,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
