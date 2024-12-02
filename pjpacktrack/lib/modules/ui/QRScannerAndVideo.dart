import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:pjpacktrack/modules/ui/RecordingScreen.dart';
import 'package:pjpacktrack/modules/ui/odervideo.dart';
import 'package:pjpacktrack/modules/ui/profile.dart';

class QRScannerAndVideo extends StatefulWidget {
  final List<CameraDescription> cameras;

  const QRScannerAndVideo({super.key, required this.cameras});

  @override
  _QRScannerAndVideoState createState() => _QRScannerAndVideoState();
}

class _QRScannerAndVideoState extends State<QRScannerAndVideo> {
  int _currentIndex = 1; // Mục "Ghi hình" sẽ là mục mặc định
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ProfileScreen(), // Hồ sơ
      RecordingScreen(cameras: widget.cameras), // Ghi hình
      OrderHistoryScreen(), // Đơn hàng
    ];
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Ghi hình',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Đơn hàng',
          ),
        ],
      ),
    );
  }
}
