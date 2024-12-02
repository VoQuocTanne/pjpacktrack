import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pjpacktrack/store/store_provider.dart';

class AddStoreScreen extends ConsumerStatefulWidget {
  final String uid;

  const AddStoreScreen({required this.uid, Key? key}) : super(key: key);

  @override
  ConsumerState<AddStoreScreen> createState() => _AddStoreScreenState();
}

class _AddStoreScreenState extends ConsumerState<AddStoreScreen> {
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _storePhoneController = TextEditingController();
  final TextEditingController _storeAddressController = TextEditingController();

  bool _isLoading = false;

  void _addStore(BuildContext context, WidgetRef ref) async {
    if (_isLoading) return; // Tránh gọi lại nhiều lần
    setState(() => _isLoading = true);

    try {
      final storeName = _storeNameController.text.trim();
      final storePhone = _storePhoneController.text.trim();
      final storeAddress = _storeAddressController.text.trim();

      if (storeName.isEmpty || storePhone.isEmpty || storeAddress.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
        );
        return; // Thoát sớm nếu dữ liệu không hợp lệ
      }

      final store = Store(
        storeName: storeName,
        storePhone: storePhone,
        storeAddress: storeAddress,
      );

      await ref
          .read(storeProvider(widget.uid).notifier)
          .addStore(widget.uid, store);

      Navigator.pop(context); // Quay lại màn hình trước nếu thành công
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thêm cửa hàng thất bại: $e')),
      );
    } finally {
      setState(() => _isLoading = false); // Đảm bảo đặt lại trạng thái
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm Cửa Hàng')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _storeNameController,
              decoration: const InputDecoration(labelText: 'Tên Cửa Hàng'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _storePhoneController,
              decoration: const InputDecoration(labelText: 'Số Điện Thoại'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _storeAddressController,
              decoration: const InputDecoration(labelText: 'Địa Chỉ'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _addStore(context, ref),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Thêm Cửa Hàng'),
            )
          ],
        ),
      ),
    );
  }
}
