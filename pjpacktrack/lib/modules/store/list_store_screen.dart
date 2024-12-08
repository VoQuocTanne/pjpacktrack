import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pjpacktrack/future/store_provider.dart';
import 'package:pjpacktrack/future/store_selected_provider.dart';
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
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddStoreScreen(uid: uid)),
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
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: ListTile(
                    title: Text(store.storeName),
                    subtitle: Text(store.storeAddress),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ref.read(storeSelectedProvider.state).state = store;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã chọn: ${store.storeName}')),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
