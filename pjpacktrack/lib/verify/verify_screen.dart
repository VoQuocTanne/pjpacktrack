import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pjpacktrack/ui/QRScannerAndVideo.dart';

class Verify extends StatefulWidget {
  const Verify({super.key});

  @override
  State<Verify> createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  @override
  void initState() {
    sendverifylink();
    super.initState();
  }

  sendverifylink() async {
    final user = FirebaseAuth.instance.currentUser!;
    await user.sendEmailVerification().then((value) => {
          Get.snackbar('Link sent', 'A link has been sent to your email',
              margin: EdgeInsets.all(30), snackPosition: SnackPosition.BOTTOM)
        });
  }

  reload() async {
    try {
      await FirebaseAuth.instance.currentUser!.reload();
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        final cameras = await availableCameras();
        Get.offAll(QRScannerAndVideo(
          cameras: cameras,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email chưa được xác minh!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verification")),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Center(
          child: Text(
              "Open your mail and click on the link provided to verify email and reload this page"),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: reload,
        child: Icon(Icons.restart_alt_rounded),
      ),
    );
  }
}
