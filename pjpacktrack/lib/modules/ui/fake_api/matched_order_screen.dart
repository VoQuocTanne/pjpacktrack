import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'order_service.dart';

class MatchedOrderScreen extends ConsumerWidget {
  final String scannedCodeId;

  const MatchedOrderScreen({Key? key, required this.scannedCodeId})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchedOrdersState = ref.watch(matchedOrdersProvider);

    // Gọi hàm để khớp đơn hàng với mã đã quét
    ref.read(matchedOrdersProvider.notifier).matchOrder(scannedCodeId);

    // Kiểm tra và hiển thị UI
    return Scaffold(
      appBar: AppBar(
        title: Text('$scannedCodeId'),
        backgroundColor: Colors.blue,
      ),
      body: matchedOrdersState.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 100, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(
                    'Không tìm thấy đơn hàng phù hợp',
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: 1, // Chỉ hiển thị 1 item
              itemBuilder: (context, index) {
                final order = matchedOrdersState[0]; // Lấy đơn hàng đầu tiên
                return Card(
                  margin: const EdgeInsets.all(8),
                  elevation: 4,
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kiểm tra nếu có tên sản phẩm thì hiển thị từng tên một
                        if (order['productName'] != null)
                          for (var product in order['productName'])
                            Text(
                              product,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                        // Nếu không có tên sản phẩm, hiển thị thông báo
                        if (order['productName'] == null ||
                            order['productName'].isEmpty)
                          Text(
                            'Không có tên sản phẩm',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                      ],
                    ),
                    leading:
                        Icon(Icons.shopping_basket, color: Colors.blue[700]),
                  ),
                );
              },
            ),
    );
  }
}
