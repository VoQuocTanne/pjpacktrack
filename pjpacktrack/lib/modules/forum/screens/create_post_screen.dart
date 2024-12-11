import 'dart:io';
import 'package:aws_storage_service/aws_storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pjpacktrack/modules/forum/wid/custom_textField.dart';
import 'package:pjpacktrack/modules/ui/aws_config.dart';
import '/modules/forum/models/post_model.dart';
import 'package:path/path.dart' as p;

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _imageFiles = [];

  final user = FirebaseAuth.instance.currentUser;

  void _pickImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null) {
      setState(() {
        _imageFiles = selectedImages;
      });
    }
  }

  final AwsCredentialsConfig credentialsConfig = AwsCredentialsConfig(
    accessKey: AwsConfig.accessKey, // Sử dụng giá trị từ AwsConfig
    secretKey: AwsConfig.secretKey,
    bucketName: AwsConfig.bucketName,
    region: AwsConfig.region,
  );

  // Cập nhật ảnh đại diện trong Firestore
  Future<void> updateProfileAvatar(String avatarUrl) async {
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user!.uid);
    await userDoc.update({
      'avatar': avatarUrl, // Lưu URL ảnh đại diện vào Firestore
    });
  }

  Future<List<String>> _uploadImagesToAWS() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang tải ảnh lên AWS...')),
      );

      List<String> imageUrls = [];

      for (var imageFile in _imageFiles) {
        String filePath = imageFile.path;
        String fileName = p.basename(filePath);

        UploadTaskConfig uploadConfig = UploadTaskConfig(
          credentailsConfig: credentialsConfig,
          url: 'avatar/$fileName', // Lưu ảnh vào thư mục "images"
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
      }

      return imageUrls;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải ảnh lên AWS: $e')),
      );
      return [];
    }
  }

  void _createPost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập tiêu đề và nội dung')),
      );
      return;
    }

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng đăng nhập trước khi tạo bài viết')),
      );
      return;
    }

    try {
      List<String> imageUrls = [];
      if (_imageFiles.isNotEmpty) {
        imageUrls = await _uploadImagesToAWS();
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid) // Ensure user is not null
          .get();

      String authorName = userDoc.exists && userDoc['fullname'] != null
          ? userDoc['fullname']
          : 'Người Dùng';

// Access the 'picture' field for avatar
      String? authorAvatar = userDoc.exists && userDoc['picture'] != null
          ? userDoc['picture']
          : null; // Set to null if picture does not exist

      final post = PostModel(
        content: _contentController.text.trim(),
        authorId: user!.uid, // Using current user ID
        authorName: authorName, // Assigning user's name
        authorAvatar: authorAvatar, // Add the picture field here
        imageUrls: imageUrls,
        createdAt: DateTime.now(),
        viewCount: 0,
        commentCount: 0,
      );

      // Thêm bài viết vào Firestore và nhận ID được tạo
      DocumentReference postRef = await FirebaseFirestore.instance
          .collection('posts')
          .add(post.toFirestore());

      // Cập nhật PostModel với ID của bài viết
      post.id = postRef.id;

      Navigator.pop(context);
    } catch (e) {
      print('Error creating post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi khi tạo bài viết: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(
        //   'Tạo Bài Viết Mới',
        //   style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        // ),
        backgroundColor: Color(0xFF284B8C),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: 'Nội dung bài viết',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 6,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: Icon(Icons.image),
              label: Text('Thêm Ảnh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF284B8C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            SizedBox(height: 16),
            // Display selected images
            _imageFiles.isNotEmpty
                ? GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _imageFiles.length > 9 ? 9 : _imageFiles.length,
                    itemBuilder: (context, index) {
                      return Image.file(
                        File(_imageFiles[index].path),
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : SizedBox.shrink(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createPost,
              child: Text('Tạo Bài Viết'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF284B8C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
