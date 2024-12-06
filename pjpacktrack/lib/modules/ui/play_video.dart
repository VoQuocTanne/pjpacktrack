import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AwsVideoPlayer extends StatefulWidget {
  final String videoId; // ID tài liệu chứa video
  const AwsVideoPlayer({super.key, required this.videoId});

  @override
  _AwsVideoPlayerState createState() => _AwsVideoPlayerState();
}

class _AwsVideoPlayerState extends State<AwsVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _videoUrl; // Đường dẫn video từ Firestore

  @override
  void initState() {
    super.initState();
    _fetchVideoUrl(); // Lấy URL video từ Firestore
  }

  Future<void> _fetchVideoUrl() async {
    setState(() {
      _isInitialized = false;
      _hasError = false;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('videos')
          .doc(widget.videoId)
          .get();

      if (doc.exists) {
        _videoUrl = doc['url'] as String; // Đường dẫn video
        _initializePlayer(_videoUrl!);
      } else {
        throw Exception('Tài liệu không tồn tại');
      }
    } catch (e) {
      print('Lỗi khi lấy URL video từ Firestore: $e');
      setState(() => _hasError = true);
    }
  }

  Future<void> _initializePlayer(String videoUrl) async {
    try {
      _controller = VideoPlayerController.network(videoUrl)
        ..initialize().then((_) {
          setState(() => _isInitialized = true);
          _controller.play();
        }).catchError((error) {
          print('Lỗi khi khởi tạo trình phát video: $error');
          setState(() => _hasError = true);
        });
    } catch (e) {
      print('Lỗi khi khởi tạo trình phát video: $e');
      setState(() => _hasError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xem Video'),
        backgroundColor: Colors.teal,
      ),
      body: _hasError
          ? _buildErrorUI()
          : !_isInitialized
              ? const Center(child: CircularProgressIndicator())
              : _buildVideoPlayerUI(),
    );
  }

  Widget _buildErrorUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Không thể tải video.',
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchVideoUrl,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayerUI() {
    return Column(
      children: [
        // Video that fits the screen
        Container(
          width: double.infinity,
          // Makes sure it uses the full width of the screen
          height: MediaQuery.of(context).size.height * 0.6,
          // Limit the height to 60% of screen height
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        ),
        VideoProgressIndicator(
          _controller,
          allowScrubbing: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: () {
                // Check if the controller is initialized
                if (_controller.value.isInitialized) {
                  setState(() {
                    // Play or pause based on the current state
                    if (_controller.value.isPlaying) {
                      _controller.pause(); // Pause the video if it's playing
                    } else {
                      _controller.play(); // Play the video if it's paused
                    }
                  });
                } else {
                  print('Video controller is not initialized yet.');
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: () {
                // Check if the controller is initialized
                if (_controller.value.isInitialized) {
                  setState(() {
                    _controller.seekTo(
                        Duration.zero); // Reset the video to the beginning
                    _controller.play(); // Play the video from the beginning
                  });
                } else {
                  print('Video controller is not initialized yet.');
                }
              },
            )
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
