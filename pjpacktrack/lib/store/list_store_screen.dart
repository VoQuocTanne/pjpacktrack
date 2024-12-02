import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:pjpacktrack/store/add_store_screen.dart';
import 'package:pjpacktrack/store/firebase_auth_provider.dart';
import 'package:pjpacktrack/store/store_provider.dart';
import 'package:pjpacktrack/store/store_selected_provider.dart';
import 'package:pjpacktrack/ui/QRScannerAndVideo.dart';
// Import ProcessScreen

class StoreListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Theo dõi trạng thái người dùng
    final userAsyncValue = ref.watch(userProvider);

    // Hiển thị khi trạng thái người dùng đang tải
    if (userAsyncValue.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Lấy dữ liệu người dùng
    final user = userAsyncValue.value;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Vui lòng đăng nhập.')),
      );
    }

    // Lấy danh sách cửa hàng của người dùng hiện tại
    final stores = ref.watch(storeProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cửa Hàng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddStoreScreen(uid: user.uid),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Chào, ${user.email}',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
      body: stores.isEmpty
          ? const Center(child: Text('Không có cửa hàng nào.'))
          : ListView.builder(
              itemCount: stores.length,
              itemBuilder: (context, index) {
                final store = stores[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 4, // Độ sâu của bóng
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Bo góc
                    ),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.all(16.0), // Khoảng cách trong Card
                      title: Text(store.storeName,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Địa chỉ: ${store.storeAddress}'),
                          Text('SĐT: ${store.storePhone}'),
                        ],
                      ),
                      onTap: () async {
                        // Lưu thông tin cửa hàng vào storeSelectedProvider
                        ref.read(storeSelectedProvider.notifier).state = store;

                        final cameras = await availableCameras();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRScannerAndVideo(
                              cameras: cameras,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
