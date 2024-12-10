import 'package:flutter/material.dart';
import 'package:pjpacktrack/future/store_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pjpacktrack/future/store_selected_provider.dart';
import 'package:pjpacktrack/modules/profile/profile_screen.dart';
import 'package:pjpacktrack/routes/routes.dart';

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
        title: Text(
          'Thêm Cửa Hàng',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xFF284B8C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _storeNameController,
                decoration: InputDecoration(
                  labelText: 'Tên cửa hàng',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Bo tròn khung
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên cửa hàng';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _storePhoneController,
                decoration: InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Bo tròn khung
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _storeAddressController,
                decoration: InputDecoration(
                  labelText: 'Địa chỉ cửa hàng',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Bo tròn khung
                  ),
                ),
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

                      // Thêm cửa hàng qua Riverpod provider
                      await ref
                          .read(storeProvider(widget.uid).notifier)
                          .addStore(widget.uid, store);

                      // Hiển thị thông báo thành công
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã thêm cửa hàng thành công')),
                      );

                      // Chuyển hướng đến home
                      Navigator.pushNamed(context, RoutesName.home);
                    } catch (e) {
                      // Hiển thị lỗi khi không thể thêm cửa hàng
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFF284B8C), // Màu chữ của nút
                ),
                child: Text('Đăng ký cửa hàng'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
