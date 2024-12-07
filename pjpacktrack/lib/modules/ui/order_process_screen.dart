import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quy trình đơn hàng'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildOrderInfo(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ProcessStepWidget(
                  title: 'Đóng gói',
                  icon: Icons.inventory_2,
                  color: Colors.blue,
                  isActive: orderData['closedStatus'] ?? false,
                  orderData: {...orderData, 'currentStep': 'Đóng gói'},
                ),
                ProcessStepWidget(
                  title: 'Giao hàng',
                  icon: Icons.local_shipping,
                  color: Colors.green,
                  isActive: orderData['shippingStatus'] ?? false,
                  orderData: {...orderData, 'currentStep': 'Giao hàng'},
                ),
                ProcessStepWidget(
                  title: 'Trả hàng',
                  icon: Icons.assignment_return,
                  color: Colors.orange,
                  isActive: orderData['returnStatus'] ?? false,
                  orderData: {...orderData, 'currentStep': 'Trả hàng'},
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                  '${orderData['isQRCode'] ? "QR Code" : "Barcode"}: ${orderData['id']}',
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