import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pjpacktrack/modules/forum/models/post_model.dart';
import 'package:pjpacktrack/modules/forum/screens/create_post_screen.dart';
import 'package:pjpacktrack/modules/forum/screens/post_detail_screen.dart';

class PostListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Diễn đàn',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        // backgroundColor: Color(0xFF284B8C),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var posts = snapshot.data!.docs
              .map((doc) => PostModel.fromFirestore(doc))
              .toList();

          return ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return _buildPostCard(context, posts[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => CreatePostScreen()));
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF284B8C),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, PostModel post) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailScreen(post: post),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Hiển thị avatar
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: (post.authorAvatar != null &&
                            post.authorAvatar!.isNotEmpty)
                        ? NetworkImage(post
                            .authorAvatar!) // Use the 'picture' field if available
                        : AssetImage('assets/default_avatar.png')
                            as ImageProvider, // Default avatar if no picture
                  ),

                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName, // Hiển thị tên người đăng
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year} ${post.createdAt.hour}:${post.createdAt.minute}',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(
                    post.content,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 18, fontFamily: 'Roboto'),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.comment, size: 18, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        '${post.commentCount}',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (post.imageUrls.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    post.imageUrls[0],
                    width: double.infinity,
                    height: 400, // Tăng chiều cao hình ảnh nếu cần
                    fit: BoxFit.cover, // Đảm bảo hình ảnh không bị cắt
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
