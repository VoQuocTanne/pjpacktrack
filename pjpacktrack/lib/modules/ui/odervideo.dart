import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'order_process_screen.dart';

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
              _buildStatusCard('Đã tải lên', '$quantity/$limit', Colors.blue[100]!),
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
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _buildOrderItem(context,order);
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

  Widget _buildOrderItem(BuildContext context, DocumentSnapshot order) {
    final data = order.data() as Map<String, dynamic>;
    final status = data['status'] ?? 'pending';
    final isQRCode = data['isQRCode'] ?? false;

    return GestureDetector(
      onTap: () => _navigateToOrderProcess(
          context,
          data,
          order.id,
          isQRCode,
          FirebaseAuth.instance.currentUser?.uid ?? ''
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: const Icon(Icons.receipt_outlined),
          title: Text(
            order.id,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Ngày tải lên: ${formatDate(data['createDate'])}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          trailing: Icon(
            Icons.check_circle,
            color: status == 'completed' ? Colors.green : Colors.orange,
          ),
        ),
      ),
    );
  }
  String formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Không xác định';
    try {
      // Chuyển từ Timestamp Firestore sang DateTime
      DateTime date = (timestamp as Timestamp).toDate();
      // Trả về chuỗi định dạng ngày giờ
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    } catch (e) {
      return 'Không hợp lệ';
    }
  }



  void _navigateToOrderProcess(BuildContext context, Map<String, dynamic> data,
      String docId, bool isQRCode, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderProcessScreen(
          orderData: {
            ...data,
            'id': docId,
            'isQRCode': isQRCode,
          },
          videoData: {},
          orderDate: DateTime.now().toString(),
          userId: userId,
        ),
      ),
    );
  }
}