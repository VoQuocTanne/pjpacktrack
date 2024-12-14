import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class AwsVideoPlayer extends StatefulWidget {
  final String orderId;
  final String deliveryOption;
  const AwsVideoPlayer({
    super.key,
    required this.orderId,
    required this.deliveryOption,
  });

  @override
  _AwsVideoPlayerState createState() => _AwsVideoPlayerState();
}

class _AwsVideoPlayerState extends State<AwsVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _videoUrl;

  @override
  void initState() {
    super.initState();
    _fetchVideoUrl();
  }

  Future<void> _fetchVideoUrl() async {
    try {
      final videoQuery = await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .collection('videos')
          .where('deliveryOption', isEqualTo: widget.deliveryOption)
          .get();

      if (videoQuery.docs.isNotEmpty) {
        _videoUrl = videoQuery.docs.first['url'] as String;
        await _initializePlayer(_videoUrl!);
      } else {
        throw Exception('Video không tồn tại');
      }
    } catch (e) {
      print('Lỗi khi lấy URL video: $e');
      setState(() => _hasError = true);
    }
  }

  Future<void> _initializePlayer(String videoUrl) async {
    try {
      _controller = VideoPlayerController.network(videoUrl);
      await _controller.initialize();
      setState(() => _isInitialized = true);
      _controller.play();
    } catch (e) {
      print('Lỗi khởi tạo video: $e');
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.7,
            color: Colors.black,
            child: Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
          Container(
            color: Colors.black12,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: Colors.teal,
                    bufferedColor: Colors.teal.withOpacity(0.2),
                    backgroundColor: Colors.grey.shade300,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      iconSize: 32,
                      icon: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.teal,
                      ),
                      onPressed: () {
                        if (_controller.value.isInitialized) {
                          setState(() {
                            _controller.value.isPlaying
                                ? _controller.pause()
                                : _controller.play();
                          });
                        }
                      },
                    ),
                    IconButton(
                      iconSize: 32,
                      icon: const Icon(Icons.replay, color: Colors.teal),
                      onPressed: () {
                        if (_controller.value.isInitialized) {
                          _controller.seekTo(Duration.zero);
                          _controller.play();
                        }
                      },
                    ),
                    // Thêm nút copy URL
                    IconButton(
                      iconSize: 32,
                      icon: const Icon(Icons.copy, color: Colors.teal),
                      onPressed: () {
                        if (_videoUrl != null) {
                          Clipboard.setData(ClipboardData(text: _videoUrl!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã sao chép đường dẫn video'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      tooltip: 'Sao chép đường dẫn video',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }
}
