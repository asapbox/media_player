import 'package:media_player/view/list_media_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:media_player/view_model/media_manager.dart';
import 'package:provider/provider.dart';

void main() => runApp(
      ChangeNotifierProvider<MediaManager>(
        create: (context) => MediaManager(),
        child: const MediaPlayerApp(),
      ),
    );

class MediaPlayerApp extends StatefulWidget {
  const MediaPlayerApp({super.key});

  @override
  State<MediaPlayerApp> createState() => _MediaPlayerAppState();
}

class _MediaPlayerAppState extends State<MediaPlayerApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Media Player',
      home: ListMediaView(),
    );
  }
}
