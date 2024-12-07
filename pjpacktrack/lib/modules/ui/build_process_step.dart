import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pjpacktrack/modules/ui/play_video.dart';

class ProcessStepWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isActive;
  final Map<String, dynamic> orderData;
  final String userId;

  const ProcessStepWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.isActive,
    required this.orderData,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive ? color : Colors.grey.withOpacity(0.3),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          if (isActive) _buildVideoSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? color.withOpacity(0.1) : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isActive ? color : Colors.grey,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isActive ? color : Colors.grey[600],
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Trạng thái hiện tại',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            isActive ? Icons.check_circle : Icons.circle_outlined,
            color: isActive ? color : Colors.grey,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    final collection = orderData['isQRCode'] ? 'qr_codes' : 'barcodes';
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collection)
          .doc(orderData['id'])
          .collection('videos')
          .where('deliveryOption', isEqualTo: title)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox();
        }

        final video = snapshot.data!.docs.first;
        return _buildVideoPlayer(context, video.data() as Map<String, dynamic>);
      },
    );
  }

  Widget _buildVideoPlayer(BuildContext context, Map<String, dynamic> videoData) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AwsVideoPlayer(
            orderId: orderData['id'],
            isQRCode: orderData['isQRCode'],
            deliveryOption: title,
            userId: userId,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.play_circle_outline, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                videoData['fileName'] ?? 'Video',
                style: TextStyle(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}