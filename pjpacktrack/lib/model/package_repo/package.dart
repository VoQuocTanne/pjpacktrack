import 'package:cloud_firestore/cloud_firestore.dart';

class Package {
  final String packageId; // ID của gói (Firestore document ID)
  final String name; // Tên gói
  final String price; // Giá gói
  final List<String> features; // Danh sách tính năng của gói
  final int videoLimit; // Số lượng video giới hạn
  final bool isFree; // Gói miễn phí hay không

  Package({
    required this.packageId,
    required this.name,
    required this.price,
    required this.features,
    required this.videoLimit,
    this.isFree = false,
  });

  /// Tạo Package từ Firestore document
  factory Package.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Package(
      packageId: doc.id,
      name: data['name'] ?? '',
      price: data['price'] ?? '',
      features: List<String>.from(data['features'] ?? []),
      videoLimit: data['videoLimit'] ?? 0,
      isFree: data['isFree'] ?? false,
    );
  }

  /// Chuyển Package thành Map để lưu trữ trong Firestore
  Map<String, dynamic> toDocument() {
    return {
      'name': name,
      'price': price,
      'features': features,
      'videoLimit': videoLimit,
      'isFree': isFree,
    };
  }
}
Future<List<Package>> fetchPackages() async {
  try {
    final querySnapshot = await FirebaseFirestore.instance.collection('packages').get();
    return querySnapshot.docs.map((doc) => Package.fromDocument(doc)).toList();
  } catch (e) {
    throw Exception("Lỗi khi tải danh sách gói: $e");
  }
}