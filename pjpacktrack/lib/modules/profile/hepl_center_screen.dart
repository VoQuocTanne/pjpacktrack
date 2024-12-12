import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kommunicate_flutter/kommunicate_flutter.dart';
import 'package:pjpacktrack/constants/text_styles.dart';
import 'package:pjpacktrack/constants/themes.dart';
import 'package:pjpacktrack/language/app_localizations.dart';
import 'package:pjpacktrack/model/setting_list_data.dart';
import 'package:pjpacktrack/modules/ui/aws_config.dart';
import 'package:pjpacktrack/routes/route_names.dart';
import 'package:pjpacktrack/widgets/common_appbar_view.dart';
import 'package:pjpacktrack/widgets/common_card.dart';
import 'package:pjpacktrack/widgets/common_search_bar.dart';
import 'package:pjpacktrack/widgets/remove_focuse.dart';

class HeplCenterScreen extends StatefulWidget {
  const HeplCenterScreen({Key? key}) : super(key: key);

  @override
  State<HeplCenterScreen> createState() => _HeplCenterScreenState();
}

class _HeplCenterScreenState extends State<HeplCenterScreen> {
  @override
  Widget build(BuildContext context) {
    List<SettingsListData> helpSearchList = SettingsListData.helpSearchList;

    return Scaffold(
      body: RemoveFocuse(
        onClick: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              // color: Theme.of(context).primaryColor,
              child: appBar(),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom),
                itemCount: helpSearchList.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: helpSearchList[index].subTxt != ""
                        ? () {
                            NavigationServices(context)
                                .gotoViewWeb(helpSearchList[index].url);
                          }
                        : null,
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
                                    helpSearchList[index].titleTxt != ""
                                        ? helpSearchList[index].titleTxt
                                        : helpSearchList[index].subTxt,
                                    style: TextStyles(context)
                                        .getRegularStyle()
                                        .copyWith(
                                            fontWeight: helpSearchList[index]
                                                        .titleTxt !=
                                                    ""
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            fontSize: helpSearchList[index]
                                                        .titleTxt !=
                                                    ""
                                                ? 18
                                                : 14),
                                  ),
                                ),
                              ),
                              helpSearchList[index].subTxt != ""
                                  ? Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Icon(Icons.keyboard_arrow_right,
                                          color: Theme.of(context)
                                              .disabledColor
                                              .withOpacity(0.3)),
                                    )
                                  : const SizedBox()
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: Divider(
                            height: 1,
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async {
          try {
            // Cấu hình chatbot với App ID của bạn từ Kommunicate
            var conversationObject = {
              'appId':
                  AwsConfig.appKey, // Thay bằng App ID từ Kommunicate Dashboard
            };

            dynamic result = await KommunicateFlutterPlugin.buildConversation(
              conversationObject,
            );

            print("Chatbot mở thành công: $result");
          } catch (e) {
            print("Lỗi khi mở chatbot: $e");
          }
        },
        child: const Icon(Icons.chat),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      // backgroundColor: Theme.of(context).primaryColor,
      title: Text(
        'Hỗ trợ',
        style: TextStyle(
          // fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      centerTitle: true,
      // leading: IconButton(
      //   icon: const Icon(Icons.arrow_back),
      //   onPressed: () => Navigator.of(context).pop(),
      //   color: Color.fromARGB(255, 255, 255, 255),
      // ),
    );
  }
}
