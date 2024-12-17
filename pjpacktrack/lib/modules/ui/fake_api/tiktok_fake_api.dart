import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TikTokFakeApi extends StatefulWidget {
  @override
  _TikTokFakeApiState createState() => _TikTokFakeApiState();
}

class _TikTokFakeApiState extends State<TikTokFakeApi> {
  List<dynamic> videos = [];

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  // Hàm gọi API và xử lý dữ liệu trả về
  Future<void> fetchVideos() async {
    final response = await http.get(
        Uri.parse('https://my.api.mockaroo.com/productName.json?key=3dbc3b50'));
    if (response.statusCode == 200) {
      final decodedResponse = json.decode(utf8.decode(response.bodyBytes));

      // Kiểm tra kiểu dữ liệu nếu cần
      if (decodedResponse is List) {
        setState(() {
          videos = decodedResponse;
        });
      } else {
        throw Exception('Unexpected response structure');
      }
    } else {
      throw Exception('Failed to load videos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TikTok Fake API"),
      ),
      body: videos.isEmpty
          ? Center(
              child:
                  CircularProgressIndicator()) // Hiển thị loading nếu chưa có dữ liệu
          : ListView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index]; // lấy video hiện tại
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 5,
                    child: Column(
                      children: [
                        ListTile(
                          title: Text("Order ID"),
                          subtitle: Text(
                              video['orderId']?.toString() ?? 'No Order ID'),
                        ),
                        ListTile(
                          title: Text("Product Name"),
                          subtitle: Text(video['productName']?.toString() ??
                              'No Product Name'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
