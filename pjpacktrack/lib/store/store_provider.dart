import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';

class Store {
  final String storeName;
  final String storePhone;
  final String storeAddress;

  Store({
    required this.storeName,
    required this.storePhone,
    required this.storeAddress,
  });
}

class StoreNotifier extends StateNotifier<List<Store>> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  StoreNotifier() : super([]);

  Future<void> fetchStores(String uid) async {
    final snapshot = await _databaseRef.child('users/$uid/stores').get();

    if (snapshot.exists) {
      final storeData = snapshot.value as Map<dynamic, dynamic>;
      state = storeData.entries.map((entry) {
        final data = entry.value as Map;
        return Store(
          storeName: data['storeName'] ?? '',
          storePhone: data['storePhone'] ?? '',
          storeAddress: data['storeAddress'] ?? '',
        );
      }).toList();
    }
  }

  Future<void> addStore(String uid, Store store) async {
    try {
      await _databaseRef.child('users/$uid/stores').push().set({
        'storeName': store.storeName,
        'storePhone': store.storePhone,
        'storeAddress': store.storeAddress,
      });
      state = [...state, store]; // Cập nhật danh sách ngay
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
