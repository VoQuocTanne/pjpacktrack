import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ProductCodeService {
  // static Future<String?> validateProductCode(String scannedCode) async {
  //   try {
  //     // Load the JSON file
  //     final String jsonString =
  //         await rootBundle.loadString('assets/data/product123_MOCK.json');

  //     // Parse the JSON
  //     final Map<String, dynamic> data = json.decode(jsonString);

  //     // Find the product with matching code
  //     final List<dynamic> products = data['products'];
  //     final matchedProduct = products.firstWhere(
  //         (product) => product['codeId'] == scannedCode,
  //         orElse: () => null);

  //     // Return product name if found, otherwise null
  //     return matchedProduct?['productName'];
  //   } catch (e) {
  //     print('Error validating product code: $e');
  //     return null;
  //   }
  // }
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
