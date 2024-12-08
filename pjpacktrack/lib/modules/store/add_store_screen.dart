import 'package:flutter/material.dart';
import 'package:pjpacktrack/future/store_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pjpacktrack/future/store_selected_provider.dart';

class AddStoreScreen extends ConsumerStatefulWidget {
  final String uid;

  AddStoreScreen({required this.uid});

  @override
  _AddStoreScreenState createState() => _AddStoreScreenState();
}

class _AddStoreScreenState extends ConsumerState<AddStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _storePhoneController = TextEditingController();
  final _storeAddressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm Cửa Hàng'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _storeNameController,
                decoration: InputDecoration(labelText: 'Tên cửa hàng'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên cửa hàng';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _storePhoneController,
                decoration: InputDecoration(labelText: 'Số điện thoại'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _storeAddressController,
                decoration: InputDecoration(labelText: 'Địa chỉ cửa hàng'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập địa chỉ cửa hàng';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    try {
                      final store = Store(
                        storeName: _storeNameController.text,
                        storePhone: _storePhoneController.text,
                        storeAddress: _storeAddressController.text,
                      );
                      await ref
                          .read(storeProvider(widget.uid).notifier)
                          .addStore(widget.uid, store);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã thêm cửa hàng thành công')),
                      );
                      Navigator.pop(
                          context); // Quay lại trang danh sách cửa hàng
                    } catch (e) {
                      // Hiển thị lỗi khi không thể thêm cửa hàng (ví dụ: đã vượt quá 2 cửa hàng)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  }
                },
                child: Text('Thêm cửa hàng'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
