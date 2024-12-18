import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pjpacktrack/language/app_localizations.dart';

class SettingsListData {
  String titleTxt;
  String titleminTxt;
  String subTxt;
  String url;
  String iconimg;
  IconData iconData;
  bool isSelected;

  SettingsListData({
    this.titleTxt = '',
    this.titleminTxt = '',
    this.isSelected = false,
    this.subTxt = '',
    this.url = '',
    this.iconimg = "assets/images/icons8-shopee.svg",
    this.iconData = Icons.supervised_user_circle,
  });

  List<SettingsListData> getCountryListFromJson(Map<String, dynamic> json) {
    List<SettingsListData> countryList = [];
    if (json['countryList'] != null) {
      json['countryList'].forEach((v) {
        SettingsListData data = SettingsListData();
        data.titleTxt = v["name"];
        data.subTxt = v["code"];
        countryList.add(data);
      });
    }
    return countryList;
  }

  static List<SettingsListData> get userSettingsList => [
        SettingsListData(
          titleTxt: Loc.alized.change_password,
          isSelected: false,
          iconData: FontAwesomeIcons.lock,
        ),
        SettingsListData(
          titleTxt: Loc.alized.invite_friend,
          isSelected: false,
          iconData: FontAwesomeIcons.userGroup,
        ),
        SettingsListData(
          titleTxt: Loc.alized.credit_coupons,
          isSelected: false,
          iconData: FontAwesomeIcons.gift,
        ),
        SettingsListData(
          titleTxt: Loc.alized.help_center,
          isSelected: false,
          iconData: FontAwesomeIcons.circleInfo,
        ),
        SettingsListData(
          titleTxt: Loc.alized.payment_text,
          isSelected: false,
          iconData: FontAwesomeIcons.wallet,
        ),
        SettingsListData(
          titleTxt: Loc.alized.setting_text,
          isSelected: false,
          iconData: FontAwesomeIcons.gear,
        )
      ];
  static List<SettingsListData> get settingsList => [
        SettingsListData(
          titleTxt: Loc.alized.notifications,
          isSelected: false,
          iconData: FontAwesomeIcons.solidBell,
        ),
        SettingsListData(
          titleTxt: Loc.alized.theme_mode,
          isSelected: false,
          iconData: FontAwesomeIcons.skyatlas,
        ),
        SettingsListData(
          titleTxt: Loc.alized.fonts,
          isSelected: false,
          iconData: FontAwesomeIcons.font,
        ),
        SettingsListData(
          titleTxt: Loc.alized.color,
          isSelected: false,
          iconData: Icons.color_lens,
        ),
        SettingsListData(
          titleTxt: Loc.alized.language,
          isSelected: false,
          iconData: Icons.translate_outlined,
        ),
        SettingsListData(
          titleTxt: Loc.alized.country,
          isSelected: false,
          iconData: FontAwesomeIcons.userGroup,
        ),
        SettingsListData(
          titleTxt: Loc.alized.currency,
          isSelected: false,
          iconData: FontAwesomeIcons.gift,
        ),
        SettingsListData(
          titleTxt: Loc.alized.terms_of_services,
          isSelected: false,
          iconData: Icons.keyboard_arrow_right,
        ),
        SettingsListData(
          titleTxt: Loc.alized.privacy_policy,
          isSelected: false,
          iconData: Icons.keyboard_arrow_right,
        ),
        SettingsListData(
          titleTxt: Loc.alized.give_us_feedbacks,
          isSelected: false,
          iconData: Icons.keyboard_arrow_right,
        ),
        SettingsListData(
          titleTxt: Loc.alized.log_out,
          isSelected: false,
          iconData: Icons.keyboard_arrow_right,
        )
      ];

  static List<SettingsListData> currencyList = [
    SettingsListData(
      titleTxt: 'Australia Dollar',
      subTxt: "\$ AUD",
    ),
    SettingsListData(
      titleTxt: 'Argentina Peso',
      subTxt: "\$ ARS",
    ),
    SettingsListData(
      titleTxt: 'Indian rupee',
      subTxt: "₹ Rupee",
    ),
    SettingsListData(
      titleTxt: 'United States Dollar',
      subTxt: "\$ USD",
    ),
    SettingsListData(
      titleTxt: 'Chinese Yuan',
      subTxt: "¥ Yuan",
    ),
    SettingsListData(
      titleTxt: 'Belgian Euro',
      subTxt: "€ Euro",
    ),
    SettingsListData(
      titleTxt: 'Brazilian Real',
      subTxt: "R\$ Real",
    ),
    SettingsListData(
      titleTxt: 'Canadian Dollar',
      subTxt: "\$ CAD",
    ),
    SettingsListData(
      titleTxt: 'Cuban Peso',
      subTxt: "₱ PESO",
    ),
    SettingsListData(
      titleTxt: 'French Euro',
      subTxt: "€ Euro",
    ),
    SettingsListData(
      titleTxt: 'Hong Kong Dollar',
      subTxt: "\$ HKD",
    ),
    SettingsListData(
      titleTxt: 'Italian Lira',
      subTxt: "€ Euro",
    ),
    SettingsListData(
      titleTxt: 'New Zealand Dollar',
      subTxt: "\$ NZ",
    ),
  ];

  static List<SettingsListData> helpSearchList = [
    // Shopee
    SettingsListData(
      titleTxt: "Shopee",
      titleminTxt: '',
      subTxt: "",
      iconimg: "assets/images/icons8-shopee.svg",
    ),

    // Danh mục lớn: Tổng quan
    SettingsListData(
      titleTxt: "Shopee",
      titleminTxt: 'Tổng quan về quản lý đơn hàng và hoàn trả',
      subTxt: '',
      iconimg: "assets/images/default-icon.svg",
    ),
    SettingsListData(
      titleTxt: "Shopee",
      titleminTxt: "Tổng quan về quản lý đơn hàng và hoàn trả",
      subTxt: "Quản lý yêu cầu hủy đơn khi vận chuyển",
      iconimg: "assets/images/default-icon.svg",
      url: "https://banhang.shopee.vn/edu/article/21031",
    ),
    SettingsListData(
      titleTxt: "Shopee",
      titleminTxt: "Tổng quan về quản lý đơn hàng và hoàn trả",
      subTxt: "Tổng quan trang quản lý Trả hàng/Hoàn tiền",
      iconimg: "assets/images/default-icon.svg",
      url: "https://banhang.shopee.vn/edu/article/21021",
    ),
    SettingsListData(
      titleTxt: "Shopee",
      titleminTxt: "Tổng quan về quản lý đơn hàng và hoàn trả",
      subTxt: "Hướng dẫn Người bán nhận hàng hoàn trả",
      iconimg: "assets/images/default-icon.svg",
      url: "https://banhang.shopee.vn/edu/article/12227",
    ),

    // Danh mục lớn: Bồi thường & Khiếu nại
    SettingsListData(
      titleTxt: "Shopee",
      titleminTxt: 'Hướng dẫn bồi thường và khiếu nại',
      subTxt: '',
      iconimg: "assets/images/default-icon.svg",
    ),
    SettingsListData(
      titleTxt: "Shopee",
      titleminTxt: "Hướng dẫn bồi thường và khiếu nại",
      subTxt: "Quy trình Shopee bồi thường đơn 'Chưa nhận được hàng'",
      iconimg: "assets/images/default-icon.svg",
      url: "https://banhang.shopee.vn/edu/article/20822",
    ),
    SettingsListData(
      titleTxt: "Shopee",
      titleminTxt: "Hướng dẫn bồi thường và khiếu nại",
      subTxt: "Chính sách khiếu nại yêu cầu bồi thường sản phẩm hư hỏng",
      iconimg: "assets/images/default-icon.svg",
      url: "https://banhang.shopee.vn/edu/article/19443",
    ),
    SettingsListData(
      titleTxt: "Shopee",
      titleminTxt: "Hướng dẫn bồi thường và khiếu nại",
      subTxt: "Hướng dẫn gửi khiếu nại tới Shopee (Shopee Mall)",
      iconimg: "assets/images/default-icon.svg",
      url: "https://banhang.shopee.vn/edu/article/7936",
    ),
    SettingsListData(
      titleTxt: "Shopee",
      titleminTxt: "Hướng dẫn bồi thường và khiếu nại",
      subTxt: "Hướng dẫn Người bán khiếu nại yêu cầu Trả hàng/Hoàn tiền",
      iconimg: "assets/images/default-icon.svg",
      url: "https://banhang.shopee.vn/edu/article/18501",
    ),

    // Danh mục lớn: Quản lý trả hàng
    SettingsListData(
      titleTxt: "Shopee",
      titleminTxt: 'Xử lý các đơn hàng hoàn trả',
      subTxt: '',
      iconimg: "assets/images/default-icon.svg",
    ),
    SettingsListData(
      titleTxt: "Shopee",
      titleminTxt: "Xử lý các đơn hàng hoàn trả",
      subTxt: "Hướng dẫn bổ sung bằng chứng Trả hàng/Hoàn tiền",
      iconimg: "assets/images/default-icon.svg",
      url: "https://banhang.shopee.vn/edu/article/8001",
    ),
    SettingsListData(
      titleTxt: "Shopee",
      titleminTxt: "Xử lý các đơn hàng hoàn trả",
      subTxt: "Hướng dẫn theo dõi hành trình hàng trả về",
      iconimg: "assets/images/default-icon.svg",
      url: "https://banhang.shopee.vn/edu/article/12227",
    ),
    SettingsListData(
      titleTxt: "Shopee",
      titleminTxt: "Xử lý các đơn hàng hoàn trả",
      subTxt: "Hướng dẫn thực hiện phản hồi khác khi quản lý Trả hàng",
      iconimg: "assets/images/default-icon.svg",
      url: "https://banhang.shopee.vn/edu/article/7937",
    ),
    SettingsListData(
      titleTxt: "Shopee",
      titleminTxt: "Xử lý các đơn hàng hoàn trả",
      subTxt: "Hướng dẫn Người bán đề xuất Hoàn tiền ngay (Shopee Mall)",
      iconimg: "assets/images/default-icon.svg",
      url: "https://banhang.shopee.vn/edu/article/7937",
    ),

    // Danh mục lớn: Chính sách bổ sung
    SettingsListData(
      titleTxt: "Shopee",
      titleminTxt: "Chi tiết các chính sách bổ sung",
      subTxt: "",
      iconimg: "assets/images/default-icon.svg",
    ),
    SettingsListData(
      titleTxt: "Shopee",
      titleminTxt: "Chi tiết các chính sách bổ sung",
      subTxt: "Hướng dẫn gửi Khiếu nại tới Shopee (Shopee Mall)",
      iconimg: "assets/images/default-icon.svg",
      url: "https://banhang.shopee.vn/edu/article/7936",
    ),
    SettingsListData(
      titleTxt: "Shopee",
      titleminTxt: "Chi tiết các chính sách bổ sung",
      subTxt: "Điều kiện và Chính sách bồi thường Shopee",
      iconimg: "assets/images/default-icon.svg",
      url: "https://banhang.shopee.vn/edu/article/5633",
    ),
    SettingsListData(
      titleTxt: "Shopee",
      titleminTxt: "Chi tiết các chính sách bổ sung",
      subTxt: "Quy trình Trả hàng/Hoàn tiền dành cho Người bán",
      iconimg: "assets/images/default-icon.svg",
      url: "https://banhang.shopee.vn/edu/article/8655",
    ),
    // Lazada
    SettingsListData(
      titleTxt: "Lazada",
      titleminTxt: "",
      subTxt: "",
      iconimg: "assets/images/icons8-lazada.svg",
    ),

    // Danh mục lớn: Tổng quan quy trình trả hàng
    SettingsListData(
      titleTxt: "Lazada",
      titleminTxt: "Tổng quan quy trình trả hàng",
      subTxt: "",
      iconimg: "assets/images/default-icon.svg",
    ),
    SettingsListData(
      titleTxt: "Lazada",
      titleminTxt: "Tổng quan quy trình trả hàng",
      subTxt: "Hướng dẫn trả hàng về Lazada/LazMall nội địa",
      iconimg: "assets/images/default-icon.svg",
      url:
          "https://helpcenter.lazada.vn/s/faq/knowledge?categoryId=1000027309&language=vi_VN&m_station=BuyerHelp&questionId=1000140798",
    ),
    SettingsListData(
      titleTxt: "Lazada",
      titleminTxt: "Tổng quan quy trình trả hàng",
      subTxt: "Làm thế nào để hủy đơn hàng?",
      iconimg: "assets/images/default-icon.svg",
      url:
          "https://helpcenter.lazada.vn/s/faq/knowledge?categoryId=1000027311&language=vi_VN&m_station=BuyerHelp&questionId=1000140743",
    ),
    SettingsListData(
      titleTxt: "Lazada",
      titleminTxt: "Tổng quan quy trình trả hàng",
      subTxt: "Thông báo cập nhật thời gian trả hàng",
      iconimg: "assets/images/default-icon.svg",
      url:
          "https://helpcenter.lazada.vn/s/faq/knowledge?categoryId=1000027309&language=vi_VN&m_station=BuyerHelp&questionId=1000141155",
    ),

    // Danh mục lớn: Hướng dẫn xử lý khiếu nại & hoàn tiền
    SettingsListData(
      titleTxt: "Lazada",
      titleminTxt: "Hướng dẫn xử lý khiếu nại & hoàn tiền",
      subTxt: "",
      iconimg: "assets/images/default-icon.svg",
    ),
    SettingsListData(
      titleTxt: "Lazada",
      titleminTxt: "Hướng dẫn xử lý khiếu nại & hoàn tiền",
      subTxt: "Lazada yêu cầu bổ sung bằng chứng trên hệ thống",
      iconimg: "assets/images/default-icon.svg",
      url:
          "https://helpcenter.lazada.vn/s/faq/knowledge?categoryId=1000027305&language=vi_VN&m_station=BuyerHelp&questionId=1000140908",
    ),
    SettingsListData(
      titleTxt: "Lazada",
      titleminTxt: "Hướng dẫn xử lý khiếu nại & hoàn tiền",
      subTxt: "Tại sao yêu cầu trả hàng của tôi bị hủy?",
      iconimg: "assets/images/default-icon.svg",
      url:
          "https://helpcenter.lazada.vn/s/faq/knowledge?categoryId=1000027306&language=vi_VN&m_station=BuyerHelp&questionId=1000140981",
    ),
    SettingsListData(
      titleTxt: "Lazada",
      titleminTxt: "Hướng dẫn xử lý khiếu nại & hoàn tiền",
      subTxt: "Lazada mất bao lâu để kiểm định sản phẩm hoàn trả?",
      iconimg: "assets/images/default-icon.svg",
      url:
          "https://helpcenter.lazada.vn/s/faq/knowledge?categoryId=1000027307&language=vi_VN&m_station=BuyerHelp&questionId=1000140897",
    ),

    // Danh mục lớn: Chính sách & điều kiện trả hàng
    SettingsListData(
      titleTxt: "Lazada",
      titleminTxt: "Chính sách & điều kiện trả hàng",
      subTxt: "",
      iconimg: "assets/images/default-icon.svg",
    ),
    SettingsListData(
      titleTxt: "Lazada",
      titleminTxt: "Chính sách & điều kiện trả hàng",
      subTxt: "Điều kiện và chính sách trả hàng tại Lazada",
      iconimg: "assets/images/default-icon.svg",
      url:
          "https://helpcenter.lazada.vn/s/faq/knowledge?categoryId=1000027304&language=vi_VN&m_station=BuyerHelp&questionId=1000140967",
    ),
    SettingsListData(
      titleTxt: "Lazada",
      titleminTxt: "Chính sách & điều kiện trả hàng",
      subTxt: "Cập nhật mới về thuế VAT 8% và mã giảm giá hoàn thuế",
      iconimg: "assets/images/default-icon.svg",
      url:
          "https://helpcenter.lazada.vn/s/faq/knowledge?categoryId=1000027310&language=vi_VN&m_station=BuyerHelp&questionId=1000140842",
    ),

    // Danh mục lớn: Xử lý các đơn hàng hoàn trả
    SettingsListData(
      titleTxt: "Lazada",
      titleminTxt: "Xử lý các đơn hàng hoàn trả",
      subTxt: "",
      iconimg: "assets/images/default-icon.svg",
    ),
    SettingsListData(
      titleTxt: "Lazada",
      titleminTxt: "Xử lý các đơn hàng hoàn trả",
      subTxt: "Tôi cần làm gì nếu sản phẩm nhận được bị hư hỏng ngoại quan?",
      iconimg: "assets/images/default-icon.svg",
      url:
          "https://helpcenter.lazada.vn/s/faq/knowledge?categoryId=1000027305&language=vi_VN&m_station=BuyerHelp&questionId=1000140986",
    ),
    SettingsListData(
      titleTxt: "Lazada",
      titleminTxt: "Xử lý các đơn hàng hoàn trả",
      subTxt: "Tôi cần lưu ý gì khi gửi trả hàng?",
      iconimg: "assets/images/default-icon.svg",
      url:
          "https://helpcenter.lazada.vn/s/faq/knowledge?categoryId=1000027306&language=vi_VN&m_station=BuyerHelp&questionId=1000140875",
    ),
    SettingsListData(
      titleTxt: "Lazada",
      titleminTxt: "Xử lý các đơn hàng hoàn trả",
      subTxt: "Nếu quá thời hạn trả hàng, tôi có thể trả hàng được không?",
      iconimg: "assets/images/default-icon.svg",
      url:
          "https://helpcenter.lazada.vn/s/faq/knowledge?categoryId=1000027304&language=vi_VN&m_station=BuyerHelp&questionId=1000140667",
    ),
    // TikTok
    SettingsListData(
      titleTxt: "TikTok",
      titleminTxt: "",
      subTxt: "",
      iconimg: "assets/images/icons8-tiktok.svg",
    ),

    // Danh mục lớn: Quản lý yêu cầu trả hàng/hoàn tiền
    SettingsListData(
      titleTxt: "TikTok",
      titleminTxt: "Quản lý yêu cầu trả hàng/hoàn tiền",
      subTxt: "",
      iconimg: "assets/images/default-icon.svg",
    ),
    SettingsListData(
      titleTxt: "TikTok",
      titleminTxt: "Quản lý yêu cầu trả hàng/hoàn tiền",
      subTxt: "Quản lý yêu cầu trả hàng/hoàn tiền",
      iconimg: "assets/images/default-icon.svg",
      url:
          "https://seller-vn.tiktok.com/university/essay?knowledge_id=6819122768905985&default_language=vi-VN&identity=1",
    ),
    SettingsListData(
      titleTxt: "TikTok",
      titleminTxt: "Quản lý yêu cầu trả hàng/hoàn tiền",
      subTxt: "Quản lý yêu cầu trả hàng/hoàn tiền trên ứng dụng",
      iconimg: "assets/images/default-icon.svg",
      url:
          "https://seller-vn.tiktok.com/university/essay?knowledge_id=3726084311222032&default_language=vi-VN&identity=1",
    ),
    SettingsListData(
      titleTxt: "TikTok",
      titleminTxt: "Quản lý yêu cầu trả hàng/hoàn tiền",
      subTxt: "Phương thức trả hàng và hoàn tiền",
      iconimg: "assets/images/default-icon.svg",
      url:
          "https://seller-vn.tiktok.com/university/essay?knowledge_id=1398156382422785&default_language=vi-VN&identity=1",
    ),
    SettingsListData(
      titleTxt: "TikTok",
      titleminTxt: "Quản lý yêu cầu trả hàng/hoàn tiền",
      subTxt: "Hoàn tiền một phần",
      iconimg: "assets/images/default-icon.svg",
      url:
          "https://seller-vn.tiktok.com/university/essay?knowledge_id=3325723009222416&default_language=vi-VN&identity=1",
    ),

    // Danh mục lớn: Hướng dẫn bồi thường và khiếu nại
    SettingsListData(
      titleTxt: "TikTok",
      titleminTxt: "Hướng dẫn bồi thường và khiếu nại",
      subTxt: "",
      iconimg: "assets/images/default-icon.svg",
    ),
    SettingsListData(
      titleTxt: "TikTok",
      titleminTxt: "Hướng dẫn bồi thường và khiếu nại",
      subTxt: "Bồi thường tự động cho các yêu cầu trả hàng",
      iconimg: "assets/images/default-icon.svg",
      url:
          "https://seller-vn.tiktok.com/university/essay?knowledge_id=6790288090941186&default_language=vi-VN&identity=1",
    ),
    SettingsListData(
      titleTxt: "TikTok",
      titleminTxt: "Hướng dẫn bồi thường và khiếu nại",
      subTxt: "Khiếu nại yêu cầu trả hàng/hoàn tiền",
      iconimg: "assets/images/default-icon.svg",
      url:
          "https://seller-vn.tiktok.com/university/essay?knowledge_id=5104634859620098&default_language=vi-VN&identity=1",
    ),
    SettingsListData(
      titleTxt: "TikTok",
      titleminTxt: "Hướng dẫn bồi thường và khiếu nại",
      subTxt: "Bằng chứng cần cung cấp để từ chối yêu cầu hậu mãi",
      iconimg: "assets/images/default-icon.svg",
      url:
          "https://seller-vn.tiktok.com/university/essay?knowledge_id=6837795793012482&default_language=vi-VN&identity=1",
    ),

    // Danh mục lớn: Xử lý các đơn hàng hoàn trả
    SettingsListData(
      titleTxt: "TikTok",
      titleminTxt: "Xử lý các đơn hàng hoàn trả",
      subTxt: "",
      iconimg: "assets/images/default-icon.svg",
    ),
    SettingsListData(
      titleTxt: "TikTok",
      titleminTxt: "Xử lý các đơn hàng hoàn trả",
      subTxt: "Trả hàng không thành công",
      iconimg: "assets/images/default-icon.svg",
      url:
          "https://seller-vn.tiktok.com/university/essay?knowledge_id=8356736328402705&default_language=vi-VN&identity=1",
    ),
    SettingsListData(
      titleTxt: "TikTok",
      titleminTxt: "Xử lý các đơn hàng hoàn trả",
      subTxt: "Đơn trả hàng và hoàn tiền",
      iconimg: "assets/images/default-icon.svg",
      url:
          "https://seller-vn.tiktok.com/university/essay?knowledge_id=6209644738184961&default_language=vi-VN&identity=1",
    ),
    SettingsListData(
      titleTxt: "TikTok",
      titleminTxt: "Xử lý các đơn hàng hoàn trả",
      subTxt: "Nguyên tắc hủy đơn, trả hàng và hoàn tiền trên TikTok Shop",
      iconimg: "assets/images/default-icon.svg",
      url:
          "https://seller-vn.tiktok.com/university/essay?knowledge_id=6837773789234946&default_language=vi-VN&identity=1",
    ),
  ];

  static List<SettingsListData> subHelpList = [
    SettingsListData(titleTxt: "", subTxt: "You can cancel"),
    SettingsListData(
      titleTxt: "",
      subTxt: "GO to Trips and choose yotr trip",
    ),
    SettingsListData(titleTxt: "", subTxt: "You'll be taken to"),
    SettingsListData(titleTxt: "", subTxt: "If you cancel, your "),
    SettingsListData(
      titleTxt: "",
      subTxt: "Give feedback",
      isSelected: true,
    ),
    SettingsListData(
      titleTxt: "Related articles",
      subTxt: "",
    ),
    SettingsListData(
      titleTxt: "",
      subTxt: "Can I change",
    ),
    SettingsListData(
      titleTxt: "",
      subTxt: "HoW do I cancel",
    ),
    SettingsListData(
      titleTxt: "",
      subTxt: "What is the",
    ),
  ];

  static List<SettingsListData> userInfoList = [
    SettingsListData(
      titleTxt: '',
      subTxt: "",
    ),
    SettingsListData(
      titleTxt: 'username_text',
      subTxt: "Amanda Jane",
    ),
    SettingsListData(
      titleTxt: 'mail_text',
      subTxt: "amanda@gmail.com",
    ),
    SettingsListData(
      titleTxt: 'phone',
      subTxt: "+65 1122334455",
    ),
    SettingsListData(
      titleTxt: 'date_of_birth',
      subTxt: "20, Aug, 1990",
    ),
    // SettingsListData(
    //   titleTxt: 'address_text',
    //   subTxt: "123 Royal Street, New York",
    // ),
  ];
}
