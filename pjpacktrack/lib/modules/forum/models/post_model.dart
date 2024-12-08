import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String? id; // Added id as nullable
  final String authorId;
  final String authorName;
  final String content;
  final List<String> imageUrls;
  final DateTime createdAt;
  final int commentCount;
  final int viewCount; // Added viewCount field here.

  PostModel({
    this.id, // Allow id to be null initially
    required this.authorId,
    required this.authorName,
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
      'content': content,
      'imageUrls': imageUrls,
      'createdAt': createdAt,
      'commentCount': commentCount,
      'viewCount': viewCount, // Added viewCount field here.
    };
  }

  // Convert Firestore document to PostModel
  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id, // Get Firestore document ID
      authorId: data['authorId'],
      authorName: data['authorName'],
      content: data['content'],
      imageUrls: List<String>.from(data['imageUrls']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      commentCount: data['commentCount'],
      viewCount:
          data['viewCount'] ?? 0, // Default viewCount to 0 if not present
    );
  }
}
