import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pjpacktrack/future/store_provider.dart';
import 'package:pjpacktrack/future/store_selected_provider.dart';
import 'package:pjpacktrack/modules/bottom_tab/bottom_tab_screen.dart';
import 'package:pjpacktrack/routes/routes.dart';
import '../../main.dart';
import 'add_store_screen.dart'; // Đảm bảo import đúng file AddStoreScreen

class StoreListScreen extends ConsumerWidget {
  final String uid;

  StoreListScreen({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeList =
        ref.watch(storeProvider(uid)); // storeList is now List<Store>

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Danh Sách Cửa Hàng',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xFF284B8C),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      AddStoreScreen(uid: uid), // Truyền tham số uid nếu cần
                ),
              );
            },
          ),
        ],
      ),
      body: storeList.isEmpty
          ? Center(child: Text('Không có cửa hàng nào.'))
          : ListView.builder(
              itemCount: storeList.length,
              itemBuilder: (context, index) {
                final store = storeList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: InkWell(
                    onTap: () {
                      // Điều hướng đến home khi nhấn vào bất kỳ đâu trong khung
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BottomTabScreen(
                            cameras: cameras,
                            storeId: store.storeId,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 6.0,
                            spreadRadius: 2.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Icon(
                              Icons.storefront,
                              size: 30.0,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  store.storeName,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey.shade800,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  'Địa chỉ: ${store.storeAddress}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  'SDT: ${store.storePhone}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.more_vert),
                            onPressed: () {
                              // Xử lý sự kiện khi nhấn nút ba chấm
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
