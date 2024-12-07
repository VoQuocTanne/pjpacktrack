import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Store {
  final String storeName;
  final String storePhone;
  final String storeAddress;

  Store({
    required this.storeName,
    required this.storePhone,
    required this.storeAddress,
  });

  // Hàm chuyển đổi từ Firestore document thành đối tượng Store
  factory Store.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Store(
      storeName: data['storeName'] ?? '',
      storePhone: data['storePhone'] ?? '',
      storeAddress: data['storeAddress'] ?? '',
    );
  }

  // Hàm chuyển Store thành dữ liệu để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'storeName': storeName,
      'storePhone': storePhone,
      'storeAddress': storeAddress,
    };
  }
}

class StoreNotifier extends StateNotifier<List<Store>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StoreNotifier() : super([]); // List<Store> is the state

  // Fetch stores from Firestore
  Future<void> fetchStores(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('stores')
          .get();

      state =
          querySnapshot.docs.map((doc) => Store.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy dữ liệu cửa hàng: $e');
    }
  }

  // Add a store to Firestore
  Future<void> addStore(String uid, Store store) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('stores')
          .get();

      // Kiểm tra nếu số lượng cửa hàng đã vượt quá 2
      if (querySnapshot.docs.length >= 1) {
        throw Exception('Bạn không thể thêm quá 1 cửa hàng');
      }

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('stores')
          .add(store.toMap());
      state = [...state, store]; // Update the list immediately
    } catch (e) {
      throw Exception('Không thể thêm cửa hàng: $e');
    }
  }
}

final storeProvider =
    StateNotifierProvider.family<StoreNotifier, List<Store>, String>(
        (ref, uid) {
  final storeNotifier = StoreNotifier();
  storeNotifier.fetchStores(uid); // Fetch stores when the provider is created
  return storeNotifier;
});
