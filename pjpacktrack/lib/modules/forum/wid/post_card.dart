import 'package:flutter/material.dart';
import '/modules/forum/models/post_model.dart';
import '/modules/forum/screens/post_detail_screen.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PostDetailScreen(post: post)));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // If there are images, show the first one
            if (post.imageUrls.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  post.imageUrls.first,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),

            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(post.content,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(post.authorName,
                          style: TextStyle(color: Colors.grey)),
                      Spacer(),
                      Icon(Icons.comment, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('${post.commentCount}',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
