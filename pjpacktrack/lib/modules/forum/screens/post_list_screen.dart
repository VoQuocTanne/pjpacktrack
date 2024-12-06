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
          'Diễn Đàn Nhà Bán Hàng',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xFF284B8C),
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
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Display Author Name
            Text(post.authorName,
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),

            // Row 2: Display Date (formatted)
            Text(
              '${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year} ${post.createdAt.hour}:${post.createdAt.minute}',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 8),

            // Row 3: Display Content and Comment Count
            Text(post.content, maxLines: 2, overflow: TextOverflow.ellipsis),
            Row(
              children: [
                Icon(Icons.comment, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text('${post.commentCount}',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
            SizedBox(height: 8),

            // Row 4: Display Images (if any)
            //abc
            if (post.imageUrls.isNotEmpty)
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Image.network(
                        post.imageUrls[index],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PostDetailScreen(post: post)));
        },
      ),
    );
  }
}
