import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ProductCodeService {
  static Future<String?> validateProductCode(String scannedCode) async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/product123_MOCK.json');

      final List<dynamic> products = json.decode(jsonString);

      // In ra mã đang quét để kiểm tra
      print('Scanned Code: $scannedCode');

      final matchedProduct = products.firstWhere(
          (product) =>
              product['codeId'].toString().trim().toLowerCase() ==
              scannedCode.trim().toLowerCase(),
          orElse: () => null);

      // Nếu tìm thấy sản phẩm, chuyển đổi mảng tên sản phẩm thành chuỗi
      return matchedProduct != null
          ? (matchedProduct['productName'] as List).join(', ')
          : null;
    } catch (e) {
      print('Error validating product code: $e');
      return null;
    }
  }
}
