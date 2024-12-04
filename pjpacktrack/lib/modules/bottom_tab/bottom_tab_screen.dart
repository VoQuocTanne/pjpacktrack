import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pjpacktrack/constants/themes.dart';
import 'package:pjpacktrack/language/app_localizations.dart';
import 'package:pjpacktrack/modules/bottom_tab/components/tab_button_UI.dart';
import 'package:pjpacktrack/modules/profile/profile_screen.dart';
import 'package:pjpacktrack/modules/ui/RecordingScreen.dart';
import 'package:pjpacktrack/modules/ui/odervideo.dart';
import 'package:pjpacktrack/widgets/common_card.dart';

class BottomTabScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const BottomTabScreen({Key? key, required this.cameras}) : super(key: key);
  @override
  State<BottomTabScreen> createState() => _BottomTabScreenState();
}

class _BottomTabScreenState extends State<BottomTabScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isFirstTime = true;
  Widget _indexView = Container();
  BottomBarType bottomBarType = BottomBarType.order;

  @override
  void initState() {
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    _indexView = Container();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startLoadScreen());
    super.initState();
  }

  Future _startLoadScreen() async {
    await Future.delayed(const Duration(milliseconds: 480));
    setState(() {
      _isFirstTime = false;
      _indexView = OrderHistoryScreen();
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SizedBox(
          height: 60 + MediaQuery.of(context).padding.bottom,
          child: getBottomBarUI(bottomBarType)),
      body: _isFirstTime
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : _indexView,
    );
  }

  void tabClick(BottomBarType tabType) {
    if (tabType != bottomBarType) {
      bottomBarType = tabType;
      _animationController.reverse().then((f) {
        if (tabType == BottomBarType.order) {
          setState(() {
            _indexView = OrderHistoryScreen();
          });
        } else if (tabType == BottomBarType.camqr) {
          setState(() {
            _indexView = RecordingScreen(cameras: widget.cameras);
          });
        } else if (tabType == BottomBarType.profile) {
          setState(() {
            _indexView = ProfileScreen(
              animationController: _animationController,
            );
          });
        }
      });
    }
  }

  Widget getBottomBarUI(BottomBarType tabType) {
    return CommonCard(
      color: AppTheme.backgroundColor,
      radius: 0,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              TabButtonUI(
                icon: Icons.search,
                isSelected: tabType == BottomBarType.order,
                text: Loc.alized.explore,
                onTap: () {
                  tabClick(BottomBarType.order);
                },
              ),
              TabButtonUI(
                icon: FontAwesomeIcons.qrcode,
                isSelected: tabType == BottomBarType.camqr,
                text: Loc.alized.trips,
                onTap: () {
                  tabClick(BottomBarType.camqr);
                },
              ),
              TabButtonUI(
                icon: FontAwesomeIcons.user,
                isSelected: tabType == BottomBarType.profile,
                text: Loc.alized.profile,
                onTap: () {
                  tabClick(BottomBarType.profile);
                },
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).padding.bottom,
          )
        ],
      ),
    );
  }
}

enum BottomBarType { order, camqr, profile }
