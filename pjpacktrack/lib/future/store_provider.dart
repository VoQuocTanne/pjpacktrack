import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Store {
  final String storeId;
  final String storeName;
  final String storePhone;
  final String storeAddress;

  Store({
    required this.storeId,
    required this.storeName,
    required this.storePhone,
    required this.storeAddress,
  });

  // Hàm chuyển đổi từ Firestore document thành đối tượng Store
  factory Store.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Store(
      storeId: doc.id, // Lấy ID từ Firestore document
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

  StoreNotifier() : super([]);

  // Phương thức để tải danh sách cửa hàng từ Firestore
  Future<void> fetchStores(String uid) async {
    try {
      final userStoresCollection =
          _firestore.collection('users').doc(uid).collection('stores');
      final querySnapshot = await userStoresCollection.get();

      // Chuyển đổi dữ liệu từ Firestore thành danh sách các cửa hàng
      final stores =
          querySnapshot.docs.map((doc) => Store.fromFirestore(doc)).toList();

      // Cập nhật state với danh sách cửa hàng
      state = stores;
    } catch (e) {
      throw Exception('Không thể tải danh sách cửa hàng: $e');
    }
  }

  // Phương thức thêm cửa hàng
  Future<void> addStore(String uid, Store store) async {
    try {
      final userStoresCollection =
          _firestore.collection('users').doc(uid).collection('stores');

      // Kiểm tra số lượng cửa hàng của người dùng
      final querySnapshot = await userStoresCollection.get();
      if (querySnapshot.docs.length >= 2) {
        throw Exception('Bạn không thể thêm quá 2 cửa hàng');
      }

      // Tạo document mới trong Firestore và lấy ID của nó
      final newDoc = await userStoresCollection.add(store.toMap());

      // Gắn ID của cửa hàng với document ID mới
      final storeWithId = Store(
        storeId: newDoc.id, // Gán ID của document Firestore
        storeName: store.storeName,
        storePhone: store.storePhone,
        storeAddress: store.storeAddress,
      );

      // Cập nhật lại state sau khi thêm cửa hàng
      state = [...state, storeWithId];
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
