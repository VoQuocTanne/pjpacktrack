import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'aws_config.dart';
import 'package:aws_client/s3_2006_03_01.dart';

class AwsVideoPlayer extends StatefulWidget {
  final String videoKey;
  final String bucketName;

  const AwsVideoPlayer({
    Key? key,
    required this.videoKey,
    required this.bucketName,
  }) : super(key: key);

  @override
  _AwsVideoPlayerState createState() => _AwsVideoPlayerState();
}

class _AwsVideoPlayerState extends State<AwsVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final videoUrl = await _getVideoUrl();
      // ignore: deprecated_member_use
      _controller = VideoPlayerController.network(videoUrl);
      await _controller.initialize();
      setState(() => _isInitialized = true);
    } catch (e) {
      print('Lỗi khởi tạo trình phát video: $e');
    }
  }

  Future<String> _getVideoUrl() async {
    final s3 = S3(
      region: AwsConfig.region,
      credentials: AwsClientCredentials(
        accessKey: AwsConfig.accessKey,
        secretKey: AwsConfig.secretKey,
      ),
    );

    try {
      final url =
          'https://${widget.bucketName}.s3.${AwsConfig.region}.amazonaws.com/${widget.videoKey}';
      s3.close();
      return url;
    } finally {
      s3.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xem Video'),
        backgroundColor: Colors.teal,
      ),
      body: _isInitialized
          ? Column(
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
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
                        _controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      onPressed: () {
                        setState(() {
                          _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play();
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.replay),
                      onPressed: () {
                        _controller.seekTo(Duration.zero);
                      },
                    ),
                  ],
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
