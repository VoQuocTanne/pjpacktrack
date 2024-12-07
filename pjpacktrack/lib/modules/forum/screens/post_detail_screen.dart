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
      postId:
          widget.post.id!, // The id will now be non-null after saving the post
      authorId: 'current_user_id', // Replace with actual user ID
      authorName: 'Nhà Bán Hàng', // Replace with actual user name
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
          // Combined post content and comments
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   widget.post.title,
                    //   style:
                    //       TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    // ),
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
                    SizedBox(height: 16),

                    // Display Post Images
                    if (widget.post.imageUrls.isNotEmpty)
                      Column(
                        children: widget.post.imageUrls.map((imageUrl) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Image.network(
                              imageUrl,
                              width: double.infinity,
                              fit: BoxFit
                                  .contain, // Ensure image is displayed as is
                            ),
                          );
                        }).toList(),
                      ),

                    Divider(height: 32, color: Colors.grey),

                    // Display Comments
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

                        var comments = snapshot.data!.docs
                            .map((doc) => CommentModel.fromFirestore(doc))
                            .toList();

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(comments[index].authorName),
                              subtitle: Text(comments[index].content),
                              trailing: Text(
                                '${comments[index].createdAt.day}/${comments[index].createdAt.month}/${comments[index].createdAt.year} ${comments[index].createdAt.hour}:${comments[index].createdAt.minute}',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
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
