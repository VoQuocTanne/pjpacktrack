import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pjpacktrack/modules/ui/play_video.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Center(child: Text('Chưa đăng nhập'));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStatusCards(),
            Expanded(
              child: _buildOrdersList(currentUser.uid),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/appIcon.png',
            height: 32,
            width: 32,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          const Text(
            'Pack Track',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCards() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final quantity = data['quantity']?.toString() ?? '0';
        final limit = data['limit']?.toString() ?? '0';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildStatusCard('Đơn hàng', quantity, Colors.green[100]!),
              const SizedBox(width: 8),
              _buildStatusCard('Đóng hàng', quantity, Colors.orange[100]!),
              const SizedBox(width: 8),
              _buildStatusCard(
                  'Đã tải lên', '$quantity/$limit', Colors.blue[100]!),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.inventory_2, size: 20),
            const SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12)),
                Text(count, style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 16),
                  const Text(
                    'Danh sách mã vận đơn',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final data = order.data() as Map<String, dynamic>;
                  // Thêm document ID vào data
                  data['id'] = order.id; // Thêm ID document vào data
                  final code = data['code'].toString();
                  final isQRCode = data['isQRCode'] ?? false;

                  return _buildOrderCard(
                    code,
                    data,
                    isQRCode,
                    context,
                    userId,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm mã vận đơn',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(String code, Map<String, dynamic> data, bool isQRCode,
      BuildContext context, String userId) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        // onTap: () =>
        //     _navigateToOrderProcess(context, data, code, isQRCode, userId),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderHeader(code, data, isQRCode, context),
              const Divider(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader(String code, Map<String, dynamic> data,
      bool isQRCode, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${isQRCode ? "Mã đơn hàng" : "Mã đơn hàng"}: $code',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ngày tạo đơn: ${formatDate(data['createDate'])}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              _buildStatusChips(data, context),
            ],
          ),
        ),
      ],
    );
  }

  String formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      final hour = date.hour;
      final minute = date.minute;
      final period = hour < 12 ? 'AM' : 'PM';
      final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final minuteStr = minute.toString().padLeft(2, '0');
      return '${date.day}/${date.month}/${date.year} - ${hour12}:$minuteStr $period';
    }
    return 'N/A';
  }

  Widget _buildStatusChips(Map<String, dynamic> data, BuildContext context) {
    // Debug
    print('Data received: $data');

    // Lấy orderId từ id của document thay vì orderId
    final orderId = data['id'] ?? '';

    // Debug
    print('OrderId: $orderId');

    // Kiểm tra orderId trước khi navigate
    void navigateToVideo(String deliveryOption) {
      if (orderId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy mã đơn hàng')),
        );
        return;
      }

      print(
          'Navigating with orderId: $orderId, deliveryOption: $deliveryOption, ');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AwsVideoPlayer(
            orderId: orderId,
            deliveryOption: deliveryOption,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      children: [
        if (data['closedStatus'] == true)
          _buildStatusChip('Đóng gói', Colors.blue, () {
            navigateToVideo('Đóng gói');
          }),
        if (data['shippingStatus'] == true)
          _buildStatusChip('Giao hàng', Colors.green, () {
            navigateToVideo('Giao hàng');
          }),
        if (data['returnStatus'] == true)
          _buildStatusChip('Trả hàng', Colors.orange, () {
            navigateToVideo('Trả hàng');
          }),
      ],
    );
  }

  Widget _buildStatusChip(String label, Color color, VoidCallback onClick) {
    return SizedBox(
      child: InkWell(
        onTap: onClick,
        child: Chip(
          label: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          backgroundColor: color,
        ),
      ),
    );
  }
}
