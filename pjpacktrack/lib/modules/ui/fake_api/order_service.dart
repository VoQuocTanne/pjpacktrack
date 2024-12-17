import 'dart:convert';
import 'package:flutter/services.dart'; // Để sử dụng rootBundle
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderService {
  // Đọc dữ liệu từ file assets
  Future<List<dynamic>> loadJsonFromAssets() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/product123_MOCK.json');
      final data = json.decode(response);
      return data;
    } catch (e) {
      throw Exception('Failed to load data from assets: $e');
    }
  }

  Future<List<dynamic>> getMatchingOrders(String scannedCodeId) async {
    final allOrders =
        await loadJsonFromAssets(); // Lấy tất cả đơn hàng từ assets
    final filteredOrders = allOrders
        .where((order) =>
            order['codeId']?.toString() ==
            scannedCodeId) // Kiểm tra mã đơn hàng
        .toList();

    // Loại bỏ trùng lặp nếu có
    return filteredOrders.toSet().toList();
  }
}

final orderServiceProvider = Provider((ref) => OrderService());

final matchedOrdersProvider =
    StateNotifierProvider<MatchedOrdersNotifier, List<dynamic>>((ref) {
  return MatchedOrdersNotifier(ref.read(orderServiceProvider));
});

class MatchedOrdersNotifier extends StateNotifier<List<dynamic>> {
  final OrderService _orderService;

  MatchedOrdersNotifier(this._orderService) : super([]);

  Future<void> matchOrder(String scannedOrderId) async {
    try {
      final matchedOrders =
          await _orderService.getMatchingOrders(scannedOrderId);
      state = matchedOrders;
    } catch (e) {
      state = [];
      print('Error matching order: $e');
    }
  }
}
