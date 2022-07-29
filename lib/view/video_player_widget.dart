import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:media_player/view_model/media_manager.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoId;

  const VideoPlayerWidget({super.key, required this.videoId});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        'https://czlpob05.directus.app/assets/${widget.videoId}');
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void playPauseVideo() {
    setState(
      () {
        if (_controller.value.isPlaying) {
          _controller.pause();
        } else {
          _controller.play();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return GestureDetector(
            onTap: () {
              playPauseVideo();
            },
            child: Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  children: [
                    VideoPlayer(_controller),
                    Align(
                        alignment: AlignmentDirectional.bottomCenter,
                        child: buildVideoProgressIndicator()),
                    Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: buildCloseButton(),
                    ),
                    Align(
                      alignment: AlignmentDirectional.center,
                      child: buildPlayButton(),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget buildCloseButton() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _controller.value.isPlaying ? 0.2 : 1,
      child: IconButton(
        icon: const Icon(
          Icons.close_outlined,
          size: 30.0,
          color: Colors.white,
        ),
        onPressed: () {
          context.read<MediaManager>().setIsIsVideoPlayerVisible(false);
          context.read<MediaManager>().setOpacity(1.0);
        },
      ),
    );
  }

  Widget buildPlayButton() {
    return IconButton(
      onPressed: () {
        playPauseVideo();
      },
      icon: Icon(
        _controller.value.isPlaying
            ? null // Icons.pause
            : Icons.play_arrow,
        size: 60.0,
        color: Colors.white,
      ),
    );
  }

  Widget buildVideoProgressIndicator() {
    return VideoProgressIndicator(
      _controller,
      allowScrubbing: true,
      colors: const VideoProgressColors(
          backgroundColor: Colors.red,
          bufferedColor: Colors.black,
          playedColor: Colors.blueAccent),
    );
  }
}
