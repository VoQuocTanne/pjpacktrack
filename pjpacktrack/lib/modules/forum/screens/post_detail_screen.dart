import 'package:firebase_auth/firebase_auth.dart';
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
  final user = FirebaseAuth.instance.currentUser;

  void _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final comment = CommentModel(
      postId: widget.post.id!,
      authorId: user!.uid, // Use actual user ID from FirebaseAuth
      authorName:
          'Nhà Bán Hàng', // This can be updated to use the actual user name
      content: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    await FirebaseFirestore.instance
        .collection('comments')
        .add(comment.toFirestore());

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
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post Author and Date
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          widget.post.authorName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      widget.post.content,
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                    SizedBox(height: 16),

                    // Display Post Images
                    if (widget.post.imageUrls.isNotEmpty)
                      Column(
                        children: widget.post.imageUrls.map((imageUrl) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageUrl,
                                width: double.infinity,
                                fit: BoxFit.contain,
                                height: 300, // Adjust height as needed
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                    Divider(height: 32, color: Colors.grey),

                    // Display Comments Section
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('comments')
                          .where('postId', isEqualTo: widget.post.id)
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Đã xảy ra lỗi khi tải bình luận.',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.red),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Chi tiết lỗi:',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  snapshot.error.toString(),
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('Chưa có bình luận nào.'));
                        }

                        // Lấy danh sách các bình luận từ Firestore
                        var comments = snapshot.data!.docs
                            .map((doc) => CommentModel.fromFirestore(doc))
                            .toList();

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(
                                      comments[index].authorId) // Get user data
                                  .get(),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return ListTile(
                                    title: Text('Đang tải tên người dùng...'),
                                  );
                                }

                                if (userSnapshot.hasError) {
                                  return ListTile(
                                    title: Text('Lỗi tải tên người dùng'),
                                  );
                                }

                                // Retrieve the author's name
                                String authorName = userSnapshot.hasData &&
                                        userSnapshot.data!.exists &&
                                        userSnapshot.data!['fullname'] != null
                                    ? userSnapshot.data!['fullname']
                                    : 'Người Dùng';

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      authorName,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      comments[index].content,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    trailing: Text(
                                      '${comments[index].createdAt.day}/${comments[index].createdAt.month}/${comments[index].createdAt.year} ${comments[index].createdAt.hour}:${comments[index].createdAt.minute}',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Comment Input Box
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
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
