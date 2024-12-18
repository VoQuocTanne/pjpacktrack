import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kommunicate_flutter/kommunicate_flutter.dart';
import 'package:pjpacktrack/constants/text_styles.dart';
import 'package:pjpacktrack/model/setting_list_data.dart';
import 'package:pjpacktrack/modules/ui/aws_config.dart';
import 'package:pjpacktrack/routes/route_names.dart';
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
              child: Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: appBar(),
              ),
            ),
            const SizedBox(height: 22),
            _buildSearchBar(),
            const SizedBox(height: 22),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom),
                itemCount: helpSearchList.length,
                itemBuilder: (context, index) {
                  final item = helpSearchList[index];

                  // Shopee, Lazada, TikTok (Danh mục lớn)
                  if (item.titleTxt.isNotEmpty && item.titleminTxt.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: SvgPicture.asset(
                              item.iconimg,
                              height: 24,
                              width: 24,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Text(
                                item.titleTxt,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Các danh mục con (titleminTxt)
                  if (item.titleminTxt.isNotEmpty && item.subTxt.isEmpty) {
                    final subItems = helpSearchList
                        .where((subItem) =>
                            subItem.titleTxt == item.titleTxt &&
                            subItem.titleminTxt == item.titleminTxt &&
                            subItem.subTxt.isNotEmpty)
                        .toList();

                    return ExpansionTile(
                      leading: SvgPicture.asset(
                        item.iconimg,
                        height: 24,
                        width: 24,
                      ),
                      title: Text(
                        item.titleminTxt,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      children: subItems.map((subItem) {
                        return ListTile(
                          title: Text(subItem.subTxt),
                          trailing: Icon(
                            Icons.keyboard_arrow_right,
                            color: Theme.of(context)
                                .disabledColor
                                .withOpacity(0.3),
                          ),
                          onTap: () {
                            if (subItem.url.isNotEmpty) {
                              NavigationServices(context)
                                  .gotoViewWeb(subItem.url);
                            }
                          },
                        );
                      }).toList(),
                    );
                  }

                  // Trường hợp không có dữ liệu gì
                  return const SizedBox.shrink();
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16), // Nâng lên 16px
        child: FloatingActionButton.extended(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () async {
            try {
              var conversationObject = {
                'appId': AwsConfig.appKey,
              };

              dynamic result = await KommunicateFlutterPlugin.buildConversation(
                conversationObject,
              );

              print("Chatbot mở thành công: $result");
            } catch (e) {
              print("Lỗi khi mở chatbot: $e");
            }
          },
          icon: const Icon(Icons.chat),
          label: const Text(
            'BOT hỗ trợ',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  // searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
        ],
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
