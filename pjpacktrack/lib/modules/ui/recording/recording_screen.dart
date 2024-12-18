// recording_screen.dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pjpacktrack/modules/ui/recording/recording_controller.dart';
import 'package:pjpacktrack/modules/ui/recording/recording_repo/recording_state.dart';
import 'recording_indicator.dart';
import 'delivery_option.dart';

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

    // Step 1: Initialize camera
    if (!state.isInitialized) {
      controller.initializeCamera(cameras);
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: _buildStatusText(state),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(state.isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: controller.toggleFlash,
          ),
        ],
      ),
      body: _buildBody(context, state, controller),
    );
  }

  Widget _buildStatusText(RecordingState state) {
    if (!state.isInitialized) {
      return const Text('Initializing...');
    }
    if (state.selectedDeliveryOption == null) {
      return const Text('Select Delivery Option');
    }
    if (!state.isRecording) {
      return const Text('Ready to Scan');
    }
    return const Text('Recording...');
  }

  Widget _buildBody(BuildContext context, RecordingState state, RecordingController controller) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Step 2: Always show camera preview after initialization
        if (state.isInitialized)
          CameraPreview(controller.cameraController!),

        // Step 3: Show delivery options if not selected
        if (state.selectedDeliveryOption == null)
          _buildDeliveryOptions(controller),

        // Step 4: Show scanning overlay when ready
        if (state.selectedDeliveryOption != null && !state.isRecording)
          _buildScanningOverlay(),

        // Step 5: Show recording indicator and detected labels during recording
        if (state.isRecording) ...[
          const RecordingIndicator(),
          _buildDetectedLabelsOverlay(state),
        ],

        // Bottom bar for recording controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomBar(context, state, controller),
        ),
      ],
    );
  }

  Widget _buildScanningOverlay() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(50),
      child: const Center(
        child: Text(
          'Position barcode in frame',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildDeliveryOptions(RecordingController controller) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Delivery Option',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 20),
              DeliveryOptionsWidget(
                onOptionSelected: controller.setDeliveryOption,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetectedLabelsOverlay(RecordingState state) {
    if (state.imageLabels.isEmpty && state.detectedObjects.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 100,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.detectedObjects.isNotEmpty) ...[
              Text(
                'Objects: ${state.detectedObjects.map((obj) => obj.labels.first.text).join(", ")}',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 4),
            ],
            if (state.imageLabels.isNotEmpty)
              Text(
                'Labels: ${state.imageLabels.map((label) => label.label).join(", ")}',
                style: const TextStyle(color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, RecordingState state,
      RecordingController controller) {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: state.isRecording ? () => controller.stopAndReset(storeId) : null,
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
              Icon(state.isRecording ? Icons.stop : Icons.qr_code_scanner),
              const SizedBox(width: 8),
              Text(
                _getBottomButtonText(state),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getBottomButtonText(RecordingState state) {
    if (!state.isInitialized) return 'Initializing...';
    if (state.selectedDeliveryOption == null) return 'Select Delivery Option';
    if (state.isRecording) return 'Stop Recording';
    return 'Scan QR Code';
  }
}