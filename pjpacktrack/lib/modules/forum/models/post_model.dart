import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String? id; // Added id as nullable
  final String authorId;
  final String authorName;
  final String? authorAvatar; // URL ảnh đại diện, có thể null
  final String content;
  final List<String> imageUrls;
  final DateTime createdAt;
  final int commentCount;
  final int viewCount; // Added viewCount field here.

  PostModel({
    this.id, // Allow id to be null initially
    required this.authorId,
    required this.authorName,
    this.authorAvatar, // Có thể null
    required this.content,
    required this.imageUrls,
    required this.createdAt,
    required this.commentCount,
    required this.viewCount, // Initialize viewCount
  });

  // Convert PostModel to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar, // Thêm authorAvatar vào Firestore
      'content': content,
      'imageUrls': imageUrls,
      'createdAt': createdAt,
      'commentCount': commentCount,
      'viewCount': viewCount, // Added viewCount field here.
    };
  }

  // Convert Firestore document to PostModel
  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PostModel(
      id: doc.id,
      authorId: data['authorId'],
      authorName: data['authorName'],
      authorAvatar:
          data['authorAvatar'] ?? '', // Trường hợp không tồn tại hoặc null
      content: data['content'],
      imageUrls: List<String>.from(data['imageUrls'] ??
          []), // Nếu không có trường imageUrls, gán danh sách rỗng
      commentCount: data['commentCount'] ?? 0, // Mặc định 0 nếu không có
      viewCount: data['viewCount'] ?? 0, // Mặc định 0 nếu không có
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
