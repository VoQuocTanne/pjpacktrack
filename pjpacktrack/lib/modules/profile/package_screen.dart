import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';
import 'package:pjpacktrack/model/package_repo/package.dart';
import 'package:pjpacktrack/model/user_repo/user_provider.dart';
import 'package:http/http.dart' as http;

import '../../model/user_repo/firebase_user_repo.dart';
import '../../widgets/app_constant.dart';

class ServicePackageScreen extends StatefulWidget {
  @override
  _ServicePackageScreenState createState() => _ServicePackageScreenState();
}

class _ServicePackageScreenState extends State<ServicePackageScreen> {
  final PageController _pageController = PageController();
  final oCcy = NumberFormat("#,##0", "vi_VN");
  int _currentIndex = 0;
  Map<String, dynamic>? paymentIntent;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text(
            'Pack Track',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: FutureBuilder<List<Package>>(
            future: fetchPackages(),
            builder: (context, snapshot) {
              // if (snapshot.connectionState == ConnectionState.waiting) {
              //   return const Center(child: CircularProgressIndicator());
              // }
              if (snapshot.hasError) {
                return Center(child: Text("Lỗi: ${snapshot.error}"));
              }

              final packages = snapshot.data ?? [];
              return Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemCount: packages.length,
                      itemBuilder: (context, index) {
                        final package = packages[index];
                        return buildPackageCard(
                          title: package.name,
                          features: package.features,
                          packageId: package.packageId,
                          price: package.price,
                          videoLimit: package.videoLimit,
                          borderColor:
                              package.isFree ? Colors.green : Colors.blue,
                          onBuyTap: package.isFree
                              ? null // Gói miễn phí không có hành động mua
                              : () {
                                  // Xử lý sự kiện mua gói
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Đã chọn mua gói ${package.name}'),
                                    ),
                                  );
                                },
                        );
                      },
                    ),
                  ),
                  //const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildPageIndicator(isActive: _currentIndex == 0),
                      buildPageIndicator(isActive: _currentIndex == 1),
                    ],
                  ),
                  //const SizedBox(height: 380),
                ],
              );
            }));
  }

  Widget buildPackageCard({
    required String title,
    required List<String> features,
    required String price,
    required Color borderColor,
    required int videoLimit,
    required String packageId, // Số lượng video mà gói cung cấp
    VoidCallback? onBuyTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6.0,
              spreadRadius: 2.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: borderColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8.0),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    feature,
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )),
            Align(
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    num.parse(price) == 0
                        ? 'Miễn phí'
                        : "${(oCcy.format(num.parse(price)))}₫",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  if (onBuyTap != null)
                    ElevatedButton(
                      onPressed: () async {
                        final userId = FirebaseAuth.instance.currentUser?.uid;
                        if (userId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Vui lòng đăng nhập để nâng cấp gói.")),
                          );
                          return;
                        }
                        makePayment(price, userId, packageId, videoLimit);
                        // try {
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     SnackBar(
                        //         content: Text(
                        //             "Giới hạn video đã được nâng cấp lên $packageId.")),
                        //   );
                        // } catch (e) {
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     SnackBar(content: Text("Đã xảy ra lỗi: $e")),
                        //   );
                        // }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: borderColor,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        "Nâng cấp",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPageIndicator({required bool isActive}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      width: 10.0,
      height: 10.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? const Color(0xFF1E2A39) : Colors.grey,
      ),
    );
  }

  Future<void> makePayment(
      String amount, String userId, String packageId, int videoLimit) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'VND');
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent!['client_secret'],
                  style: ThemeMode.dark,
                  merchantDisplayName: 'Quoc Tan'))
          .then((value) {});

      //now finally display payment sheeet
      displayPaymentSheet(amount, userId, packageId, videoLimit);
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayPaymentSheet(
      String amount, String userId, String packageId, int videoLimit) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        await updateUserPackage(userId, packageId, videoLimit);

        showDialog(
          context: context,
          barrierDismissible:
              false, // Ngăn người dùng tắt dialog bằng cách nhấn bên ngoài
          builder: (context) => WillPopScope(
            onWillPop: () async =>
                false, // Ngăn người dùng tắt dialog bằng nút back
            child: AlertDialog(
              content: SingleChildScrollView(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              // NavigationServices(context).gotoLoginApp();
                            },
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(
                            width: 16.0,
                          ),
                          Center(
                            child: Text(
                              "Giới hạn video đã được nâng cấp lên",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.lightGreen.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      const Text(
                        "Cảm ơn",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            // // Điều hướng về trang chủ
                            // NavigationServices(context).gotoLoginApp();
                          },
                          child: Container(
                            width: 100,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF008080),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                "Trang chủ",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        paymentIntent = null;
      }).onError((error, stackTrace) {
        print('Error is:--->$error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                content: Text("Cancelled "),
              ));
    } catch (e) {
      print('$e');
    }
  }

  //  Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      // ignore: avoid_print
      print('Payment Intent Body->>> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      // ignore: avoid_print
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final calculatedAmout = (int.parse(amount));

    return calculatedAmout.toString();
  }
}
