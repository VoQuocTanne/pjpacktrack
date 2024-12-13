import 'package:cloud_firestore/cloud_firestore.dart';

Future<String?> getPackageName(String packageId) async {
  try {
    final packageDoc = await FirebaseFirestore.instance
        .collection('packages')
        .where('packageId', isEqualTo: packageId)
        .limit(1)
        .get();

    if (packageDoc.docs.isNotEmpty) {
      return packageDoc.docs.first.data()['name']; // Trả về tên gói
    } else {
      return null; // Không tìm thấy gói
    }
  } catch (e) {
    print('Lỗi khi lấy tên gói: $e');
    return null;
  }
}