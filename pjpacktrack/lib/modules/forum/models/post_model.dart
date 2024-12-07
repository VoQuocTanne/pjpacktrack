import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String title;
  final String content;
  final List<String> imageUrls;
  final DateTime createdAt;
  final int viewCount;
  final int commentCount;

  PostModel({
    this.id = '',
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.content,
    this.imageUrls = const [],
    DateTime? createdAt,
    this.viewCount = 0,
    this.commentCount = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return PostModel(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Nhà Bán Hàng',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      viewCount: data['viewCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'title': title,
      'content': content,
      'imageUrls': imageUrls,
      'createdAt': createdAt,
      'viewCount': viewCount,
      'commentCount': commentCount,
    };
  }
}
