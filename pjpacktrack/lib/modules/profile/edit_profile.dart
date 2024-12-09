import 'dart:io';
import 'package:aws_storage_service/aws_storage_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pjpacktrack/constants/themes.dart';
import 'package:pjpacktrack/language/app_localizations.dart';
import 'package:pjpacktrack/model/setting_list_data.dart';
import 'package:pjpacktrack/model/user_repo/my_user.dart';
import 'package:pjpacktrack/model/user_repo/user_provider.dart';
import 'package:pjpacktrack/modules/ui/aws_config.dart';
import 'package:pjpacktrack/widgets/common_appbar_view.dart';
import 'package:pjpacktrack/widgets/common_card.dart';
import 'package:pjpacktrack/widgets/remove_focuse.dart';
import 'package:path/path.dart' as p;

class EditProfile extends ConsumerStatefulWidget {
  final MyUser myUser;
  const EditProfile({Key? key, required this.myUser}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<EditProfile> {
  List<SettingsListData> userInfoList = SettingsListData.userInfoList;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Các bộ điều khiển cho các trường thông tin người dùng
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _birthdayController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.myUser.fullname);
    _emailController = TextEditingController(text: widget.myUser.email);
    _phoneController = TextEditingController(text: widget.myUser.phonenumber);
    _birthdayController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(widget.myUser.birthday),
    );
  }

  final AwsCredentialsConfig credentialsConfig = AwsCredentialsConfig(
    accessKey: AwsConfig.accessKey, // Sử dụng giá trị từ AwsConfig
    secretKey: AwsConfig.secretKey,
    bucketName: AwsConfig.bucketName,
    region: AwsConfig.region,
  );

  // Hàm chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    } else {
      print("Chưa chọn ảnh nào");
    }
  }

  // Hàm chọn ngày sinh
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.myUser.birthday,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != widget.myUser.birthday) {
      setState(() {
        _birthdayController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  // Hàm lưu thay đổi (bao gồm tải lên ảnh nếu có và cập nhật thông tin người dùng)
  Future<void> _saveChanges() async {
    try {
      String? photoURL;

      // Kiểm tra nếu có ảnh mới thì tải ảnh lên AWS và lấy URL
      if (_imageFile != null) {
        final userId = widget.myUser.userId;
        String filePath = _imageFile!.path;
        String fileName = p.basename(filePath);

        // Tải ảnh lên AWS
        List<String> imageUrls = await _uploadImagesToAWS(filePath);

        if (imageUrls.isNotEmpty) {
          photoURL = imageUrls[0]; // Lấy URL của ảnh đầu tiên nếu có
        }
      }

      // Cập nhật thông tin người dùng với dữ liệu mới
      final updatedUser = widget.myUser.copyWith(
        fullname: _nameController.text,
        phonenumber: _phoneController.text,
        picture: photoURL ?? widget.myUser.picture, // Cập nhật hình ảnh
        birthday: DateFormat('dd/MM/yyyy').parse(_birthdayController.text),
      );

      // Cập nhật Firestore với thông tin người dùng mới
      await ref.read(userServiceProvider).updateUser(updatedUser);

      setState(() {
        // Cập nhật đối tượng người dùng trong UI để phản ánh ngay lập tức
        widget.myUser.fullname = _nameController.text;
        widget.myUser.phonenumber = _phoneController.text;
        widget.myUser.picture = photoURL ?? widget.myUser.picture;
        widget.myUser.birthday =
            DateFormat('dd/MM/yyyy').parse(_birthdayController.text);
      });

      Navigator.pop(context);

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Loc.alized.update_user_successfully),
          backgroundColor: Colors.green,
        ),
      );
      print("Đã cập nhật thông tin người dùng thành công");
    } catch (e) {
      print("Lỗi khi cập nhật thông tin người dùng: $e");
    }
  }

// Hàm tải ảnh lên AWS
  Future<List<String>> _uploadImagesToAWS(String filePath) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang tải ảnh lên AWS...')),
      );

      List<String> imageUrls = [];
      String fileName = p.basename(filePath);

      // Tạo cấu hình tải ảnh lên AWS
      UploadTaskConfig uploadConfig = UploadTaskConfig(
        credentailsConfig: credentialsConfig,
        url: 'avatar/$fileName', // Lưu ảnh vào thư mục "avatar"
        uploadType: UploadType.file,
        file: File(filePath),
      );

      UploadFile uploadFile = UploadFile(config: uploadConfig);

      await uploadFile.upload().then((value) async {
        // Sau khi tải lên thành công, lấy URL công khai từ S3
        String imageUrl =
            'https://${AwsConfig.bucketName}.s3.${AwsConfig.region}.amazonaws.com/avatar/$fileName';

        imageUrls.add(imageUrl);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tải ảnh lên thành công: $fileName')),
        );
        uploadFile.dispose(); // Giải phóng tài nguyên
      });

      return imageUrls;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải ảnh lên AWS: $e')),
      );
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      body: RemoveFocuse(
        onClick: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CommonAppbarView(
              iconData: Icons.arrow_back,
              titleText: Loc.alized.edit_profile,
              onBackClick: () {
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(
                    bottom: 16 + MediaQuery.of(context).padding.bottom),
                children: [
                  getProfileUI(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEditableField(
                            Loc.alized.full_name, _nameController),
                        _buildEditableField("Email", _emailController,
                            enabled: false),
                        _buildEditableField(Loc.alized.phone, _phoneController),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: _buildEditableField(
                              Loc.alized.birthday,
                              _birthdayController,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: ElevatedButton(
                            onPressed: _saveChanges,
                            child: Text(Loc.alized.update),
                          ),
                        ),
                      ],
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

  Widget getProfileUI() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 130,
            height: 130,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Theme.of(context).dividerColor,
                        blurRadius: 8,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(60.0)),
                    child: (_imageFile != null)
                        ? Image.file(_imageFile!,
                            fit: BoxFit.cover) // Hiển thị ảnh đã chọn
                        : (widget.myUser.picture != null &&
                                widget.myUser.picture!.isNotEmpty)
                            ? Image.network(widget.myUser.picture!,
                                fit: BoxFit.cover) // Hiển thị ảnh từ URL
                            : Icon(Icons.person,
                                size: 70.0,
                                color: const Color.fromARGB(179, 41, 40, 40)),
                  ),
                ),
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: CommonCard(
                    color: AppTheme.primaryColor,
                    radius: 36,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(24.0)),
                        onTap: _pickImage, // Chọn ảnh
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.camera_alt,
                            color: Theme.of(context).colorScheme.background,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller,
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
