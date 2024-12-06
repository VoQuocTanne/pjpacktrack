import 'package:flutter/material.dart';
import 'build_process_step.dart';

class OrderProcessScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final String orderDate;

  const OrderProcessScreen({
    super.key,
    required this.orderData,
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
      body: Stack(
        children: [
          Column(
            children: [
              Container(
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
                            'Mã QR: ${orderData['qrCode']}',
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
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ProcessStepWidget(
                        title: 'Đóng gói',
                        icon: Icons.abc_outlined,
                        color: Colors.blue,
                        isActive: orderData['deliveryOption'] == 'Đóng gói',
                        orderData:orderData,
                    ),
                    ProcessStepWidget(
                      title: 'Giao hàng',
                      icon:Icons.local_shipping,
                      color: Colors.green,
                      isActive:orderData['deliveryOption'] == 'Giao hàng',
                      orderData:orderData,
                    ),
                    ProcessStepWidget(
                      title:
                      'Trả hàng',
                      icon: Icons.assignment_return,
                      color: Colors.orange,
                      isActive: orderData['deliveryOption'] == 'Trả hàng',
                      orderData:orderData,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

