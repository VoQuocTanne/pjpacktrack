import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pjpacktrack/modules/ui/play_video.dart';

import 'build_process_step.dart';

class OrderProcessScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final Map<String, dynamic> videoData;
  final String orderDate;

  const OrderProcessScreen({
    super.key,
    required this.orderData,
    required this.videoData,
    required this.orderDate,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quy trình đơn hàng'),
          backgroundColor: Colors.teal,
          elevation: 0,
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.inventory_2, color: Colors.blue),
                text: 'Đóng gói',
              ),
              Tab(
                icon: Icon(Icons.local_shipping, color: Colors.green),
                text: 'Giao hàng',
              ),
              Tab(
                icon: Icon(Icons.assignment_return, color: Colors.orange),
                text: 'Trả hàng',
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildOrderInfo(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildDeliveryTab('Đóng gói', Icons.inventory_2, Colors.blue),
                  _buildDeliveryTab('Giao hàng', Icons.local_shipping, Colors.green),
                  _buildDeliveryTab('Trả hàng', Icons.assignment_return, Colors.orange),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryTab(String title, IconData icon, Color color) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ProcessStepWidget(
          title: title,
          icon: icon,
          color: color,
          isActive: _getStatusForStep(title),
          orderData: {...orderData, 'currentStep': title},
        ),
        const Divider(height: 32),
        _buildVideoList(title),
      ],
    );
  }

  Widget _buildVideoList(String deliveryOption) {
    final collection = orderData['isQRCode'] ? 'qr_codes' : 'barcodes';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collection)
          .doc(orderData['id'])
          .collection('videos')
          .where('deliveryOption', isEqualTo: deliveryOption)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'Không có video cho $deliveryOption',
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final video = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final uploadDate = (video['uploadDate'] as Timestamp?)?.toDate();
            final formattedDate = uploadDate != null
                ? '${uploadDate.day}/${uploadDate.month}/${uploadDate.year}'
                : 'Không xác định';

            return Card(
              child: Dismissible(
                key: Key(video['fileName']),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) => _showDeleteConfirmation(context),
                onDismissed: (direction) => _deleteVideo(
                  orderData['id'],
                  orderData['isQRCode'],
                  snapshot.data!.docs[index].id,
                  video['url'],
                ),
                child: ListTile(
                  leading: Icon(Icons.play_circle_fill, color: Colors.black12),
                  title: Text(video['fileName'] ?? 'Video'),
                  subtitle: Text('Ngày tải lên: $formattedDate'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AwsVideoPlayer(
                        orderId: orderData['id'],
                        isQRCode: orderData['isQRCode'],
                        deliveryOption: deliveryOption,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  bool _getStatusForStep(String step) {
    switch (step) {
      case 'Đóng gói':
        return orderData['closedStatus'] ?? false;
      case 'Giao hàng':
        return orderData['shippingStatus'] ?? false;
      case 'Trả hàng':
        return orderData['returnStatus'] ?? false;
      default:
        return false;
    }
  }
  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa video'),
        content: const Text('Bạn có chắc chắn muốn xóa video này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _deleteVideo(String docId, bool isQRCode, String videoId, String videoUrl) async {
    try {
      final collection = isQRCode ? 'qr_codes' : 'barcodes';
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(docId)
          .collection('videos')
          .doc(videoId)
          .delete();

      // TODO: Delete video from AWS S3
    } catch (e) {
      print('Error deleting video: $e');
    }
  }

  Widget _buildOrderInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.teal.withOpacity(0.1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.teal),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${orderData['isQRCode'] ? "Mã đơn hàng" : "Mã đơn hàng"}: ${orderData['id']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ngày tạo: $orderDate',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}