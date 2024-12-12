import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pjpacktrack/constants/text_styles.dart';
import 'package:pjpacktrack/constants/themes.dart';
import 'package:pjpacktrack/language/app_localizations.dart';
import 'package:pjpacktrack/model/setting_list_data.dart';
import 'package:pjpacktrack/model/user_repo/user_provider.dart';
import 'package:pjpacktrack/routes/route_names.dart';
import 'package:pjpacktrack/widgets/bottom_top_move_animation_view.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final AnimationController animationController;

  const ProfileScreen({Key? key, required this.animationController})
      : super(key: key);
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    widget.animationController.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final String userId = auth.currentUser?.uid ?? '';

    if (userId.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text('Không tìm thấy UID người dùng. Vui lòng đăng nhập lại.'),
        ),
      );
    }

    final userAsyncValue = ref.watch(userProvider(userId));
    List<SettingsListData> userSettingsList = SettingsListData.userSettingsList;

    return BottomTopMoveAnimationView(
      animationController: widget.animationController,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Container(child: appBar(ref)), // Truyền ref vào appBar
          ),
          // Thêm khu vực bán gói dịch vụ
          // Thêm vào phần thay thế "Dịch vụ Premium"
          Padding(
            padding: const EdgeInsets.all(12.0), // Giảm padding tổng thể
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0), // Giảm bo góc
                color: Colors.blue.shade50, // Màu nền nhẹ nhàng
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 6.0,
                    spreadRadius: 2.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12.0), // Giảm padding bên trong
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Gói miễn phí',
                        style: const TextStyle(
                          fontSize: 16, // Giảm kích thước chữ tiêu đề
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      Text(
                        'Hết hạn',
                        style: TextStyle(
                          fontSize: 12, // Giảm kích thước chữ trạng thái
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.blueAccent, thickness: 1),
                  const SizedBox(
                      height: 8), // Giảm khoảng cách giữa các thành phần
                  _buildFeatureRowWithIcon(
                    context,
                    'Video đóng hàng',
                    Icons.inbox_rounded,
                    300,
                    600,
                  ),
                  const SizedBox(height: 10), // Giảm khoảng cách giữa các dòng
                  _buildFeatureRowWithIcon(
                    context,
                    'Video đơn vị vận chuyển',
                    Icons.local_shipping,
                    0,
                    600,
                  ),
                  const SizedBox(height: 10),
                  _buildFeatureRowWithIcon(
                    context,
                    'Video trả hàng',
                    Icons.assignment_return,
                    0,
                    600,
                  ),
                  const SizedBox(height: 16), // Giảm khoảng cách trước nút
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Chức năng nâng cấp gói chưa khả dụng')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20), // Giảm padding của nút
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Nâng cấp gói',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.white), // Giảm kích thước chữ
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(0.0),
              itemCount: userSettingsList.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () async {
                    // setting screen view
                    if (index == 5) {
                      NavigationServices(context).gotoSettingsScreen();
                    }
                    // help center screen view
                    else if (index == 3) {
                      NavigationServices(context).gotoHeplCenterScreen();
                    }
                    // change password screen view
                    else if (index == 0) {
                      NavigationServices(context).gotoChangepasswordScreen();
                    }
                    // invite friend screen view
                    else if (index == 1) {
                      // NavigationServices(context).gotoInviteFriend();
                    }
                    // store screen view
                    else if (index == 2) {
                      final String uid =
                          FirebaseAuth.instance.currentUser?.uid ?? '';
                      if (uid.isNotEmpty) {
                        NavigationServices(context).gotoStoreScreen(uid);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Không tìm thấy UID người dùng')),
                        );
                      }
                    }
                  },
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 16),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  userSettingsList[index].titleTxt,
                                  style: TextStyles(context)
                                      .getRegularStyle()
                                      .copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Icon(
                                userSettingsList[index].iconData,
                                color: AppTheme.secondaryTextColor
                                    .withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: Divider(height: 1),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRowWithIcon(
      BuildContext context, String title, IconData icon, int used, int total) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4.0,
            spreadRadius: 1.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.shade100,
            ),
            padding: const EdgeInsets.all(6),
            child: Icon(
              icon,
              color: Colors.blueAccent,
              size: 18, // Giảm kích thước icon
            ),
          ),
          const SizedBox(width: 10), // Giảm khoảng cách
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13, // Giảm kích thước chữ
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$used video / $total video/tháng',
                      style: TextStyle(
                        fontSize:
                            11, // Giảm kích thước chữ của thông tin chi tiết
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: used / total,
                        backgroundColor: Colors.grey.shade300,
                        color: Colors.blueAccent,
                        minHeight: 4, // Giảm chiều cao của progress bar
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget appBar(WidgetRef ref) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final String userId = auth.currentUser?.uid ?? '';
    final userAsyncValue = ref.watch(userProvider(userId));

    return userAsyncValue.when(
      data: (userData) => InkWell(
        onTap: () {
          NavigationServices(context).gotoEditProfile(userData);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      userData!.fullname,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      Loc.alized.view_edit,
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  right: 24, top: 16, bottom: 16, left: 24),
              child: SizedBox(
                width: 70,
                height: 70,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(40.0)),
                  child:
                      (userData.picture != null && userData.picture!.isNotEmpty)
                          ? Image.network(
                              userData.picture!,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.person,
                              size: 70.0,
                              color: const Color.fromARGB(179, 41, 40, 40)),
                ),
              ),
            ),
          ],
        ),
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stackTrace) => Text('Error loading user data'),
    );
  }
}
