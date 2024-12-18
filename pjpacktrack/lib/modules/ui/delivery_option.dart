import 'package:flutter/material.dart';

class DeliveryOptionsWidget extends StatelessWidget {
  final Function(String) onOptionSelected;

  const DeliveryOptionsWidget({
    super.key,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildOptionButton(
          context,
          'Đóng gói',
          Icons.inventory_2,
          Colors.green[100]!,
          () => _handleOptionTap(context, 'Đóng gói'),
        ),
        const SizedBox(width: 20),
        _buildOptionButton(
          context,
          'Giao hàng',
          Icons.local_shipping,
          Colors.orange[100]!,
          () => _handleOptionTap(context, 'Giao hàng'),
        ),
        const SizedBox(width: 20),
        _buildOptionButton(
          context,
          'Trả hàng',
          Icons.assignment_return,
          Colors.blue[100]!,
          () => _handleOptionTap(context, 'Trả hàng'),
        ),
      ],
    );
  }

  Widget _buildOptionButton(BuildContext context, String label, IconData icon,
      Color color, VoidCallback onTap) {
    return Material(
      color: color.withOpacity(0.9),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.black87),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleOptionTap(BuildContext context, String option) {
    onOptionSelected(option);

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Đã chọn: $option',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );

    // Tự động đóng sau 2 giây
    Future.delayed(Duration(milliseconds: 200), () {
      Navigator.of(context).pop();
    });
  }
}
