import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pjpacktrack/modules/ui/play_video.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatefulWidget {
  final String storeId;

  const OrderHistoryScreen({
    super.key,
    required this.storeId,
  });

  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String? searchQuery;
  String? userName;

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Center(child: Text('Chưa đăng nhập'));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Row(
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
            const SizedBox(width: 50),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildStatusCards(),
            Expanded(
              child: _buildOrdersList(currentUser.uid),
            ),
          ],
        ),
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _buildStatusCard('Đơn hàng', quantity, Colors.green[100]!,
                  Icons.assignment_turned_in),
              const SizedBox(width: 8),
              _buildStatusCard(
                  'Đóng hàng', quantity, Colors.orange[100]!, Icons.archive),
              const SizedBox(width: 8),
              _buildStatusCard('Đã tải lên', '$quantity/$limit',
                  Colors.blue[100]!, Icons.cloud_upload),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(
      String title, String count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20),
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
          .where('storeId', isEqualTo: widget.storeId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Lấy danh sách đơn hàng từ dữ liệu
        var orders = snapshot.data!.docs;

        // Lọc nếu có từ khóa tìm kiếm
        if (searchQuery != null && searchQuery!.isNotEmpty) {
          orders = orders.where((order) {
            final data = order.data() as Map<String, dynamic>;
            final code = data['code']?.toString() ?? '';
            return code.toLowerCase().contains(searchQuery!.toLowerCase());
          }).toList();
        }

        // Sắp xếp danh sách theo thời gian giảm dần
        orders.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;

          final aTimestamp = aData['createDate'] as Timestamp?;
          final bTimestamp = bData['createDate'] as Timestamp?;

          if (aTimestamp == null || bTimestamp == null) {
            return 0; // Không sắp xếp nếu thiếu dữ liệu
          }

          return bTimestamp.compareTo(aTimestamp);
        });

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
                  data['id'] = order.id; // Thêm ID document vào data
                  final code = data['code'].toString();
                  final isQRCode = data['isQRCode'] ?? false;

                  return _buildOrderCard(
                    code,
                    data,
                    isQRCode,
                    context,
                    userId,
                    index,
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
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
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
      BuildContext context, String userId, int index) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderHeader(code, data, isQRCode, context, index),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchUserName(); // Gọi hàm lấy tên người dùng
  }

  Future<void> _fetchUserName() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        // Truy vấn tên người dùng từ Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userName =
                userDoc.data()?['fullname'] ?? 'Không xác định'; // Lưu tên
          });
        }
      } catch (e) {
        debugPrint('Error fetching user name: $e');
      }
    }
  }

  Widget _buildOrderHeader(String code, Map<String, dynamic> data,
      bool isQRCode, BuildContext context, int index) {
    // Lấy logo theo thứ tự
    String logoAsset;
    if (index % 3 == 0) {
      logoAsset =
          'assets/images/icons8-shopee.svg'; // Shopee cho video đầu tiên
    } else if (index % 3 == 1) {
      logoAsset = 'assets/images/icons8-tiktok.svg'; // TikTok cho video thứ hai
    } else {
      logoAsset = 'assets/images/icons8-lazada.svg'; // Lazada cho video thứ ba
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${isQRCode ? "Mã đơn hàng" : "Mã đơn hàng"}: $code',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Hiển thị logo dựa trên thứ tự
                  SvgPicture.asset(
                    logoAsset,
                    height: 24,
                    width: 24,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Ngày tạo đơn: ${formatDate(data['createDate'])}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Người thực hiện: ${userName ?? 'Đang tải...'}',
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

    final orderId = data['id'] ?? '';

    print('OrderId: $orderId');

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
          _buildStatusChip('Đóng gói', Colors.green[100]!, () {
            navigateToVideo('Đóng gói');
          }),
        if (data['shippingStatus'] == true)
          _buildStatusChip('Giao hàng', Colors.orange[100]!, () {
            navigateToVideo('Giao hàng');
          }),
        if (data['returnStatus'] == true)
          _buildStatusChip('Trả hàng', Colors.blue[100]!, () {
            navigateToVideo('Trả hàng');
          }),
      ],
    );
  }

  Widget _buildStatusChip(String label, Color color, VoidCallback onClick) {
    return SizedBox(
        child: InkWell(
      onTap: onClick,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10), // Bo tròn góc
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2), // Đổ bóng nhẹ
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ));
  }
}
