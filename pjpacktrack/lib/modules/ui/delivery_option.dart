import 'package:flutter/material.dart';

class DeliveryOptionsWidget extends StatelessWidget {
  final Function(String) onOptionSelected;

  const DeliveryOptionsWidget({
    super.key,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildOptionButton(
            context,
            'Đóng gói',
            Icons.inventory_2,
            Colors.blue,
            () => _handleOptionTap(context, 'Đóng gói'),
          ),
          const SizedBox(height: 20),
          _buildOptionButton(
            context,
            'Giao hàng',
            Icons.local_shipping,
            Colors.green,
            () => _handleOptionTap(context, 'Giao hàng'),
          ),
          const SizedBox(height: 20),
          _buildOptionButton(
            context,
            'Trả hàng',
            Icons.assignment_return,
            Colors.orange,
            () => _handleOptionTap(context, 'Trả hàng'),
          ),
          const SizedBox(height: 20),
        ],
      ),
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
              Icon(icon, color: Colors.white),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleOptionTap(BuildContext context, String option) {
    onOptionSelected(option);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã chọn: $option')),
    );
  }
}
