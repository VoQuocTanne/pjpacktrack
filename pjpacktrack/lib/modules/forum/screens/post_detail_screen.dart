import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pjpacktrack/modules/forum/models/comment_model.dart';
import 'package:pjpacktrack/modules/forum/models/post_model.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;

  PostDetailScreen({required this.post});

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  void _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final comment = CommentModel(
      postId: widget.post.id,
      authorId: 'current_user_id', // Thay bằng ID người dùng thực tế
      authorName: 'Nhà Bán Hàng', // Thay bằng tên người dùng thực tế
      content: _commentController.text.trim(),
    );

    await FirebaseFirestore.instance
        .collection('comments')
        .add(comment.toFirestore());

    // Cập nhật số lượng comment
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .update({'commentCount': FieldValue.increment(1)});

    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chi Tiết Bài Viết',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xFF284B8C),
      ),
      body: Column(
        children: [
          // Nội dung bài viết
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.title,
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(widget.post.authorName),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(widget.post.content),
                  ],
                ),
              ),
            ),
          ),

          // Danh sách bình luận
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('comments')
                  .where('postId', isEqualTo: widget.post.id)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var comments = snapshot.data!.docs
                    .map((doc) => CommentModel.fromFirestore(doc))
                    .toList();

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(comments[index].authorName),
                      subtitle: Text(comments[index].content),
                    );
                  },
                );
              },
            ),
          ),

          // Ô nhập bình luận
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Nhập bình luận...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.black),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
