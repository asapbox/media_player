import 'package:flutter/material.dart';

class MediaManager extends ChangeNotifier {
  late String selectedVideoId;
  late int selectedId;
  late String currentTitle;
  bool isVideoPlayerVisible = false;
  bool isEditorVisible = false;
  double opacity = 1.0;

  void setVideoId(String videoId) {
    selectedVideoId = videoId;
    notifyListeners();
    debugPrint('selectedVideoId = $selectedVideoId');
  }

  void setId(int id) {
    selectedId = id;
    notifyListeners();
    debugPrint('selectedId = $selectedId');
  }

  void setCurrentTitle(String currentTitle) {
    this.currentTitle = currentTitle;
    notifyListeners();
    debugPrint('newTitle = ${this.currentTitle}');
  }

  void setIsIsVideoPlayerVisible(bool isVisible) {
    isVideoPlayerVisible = isVisible;
    notifyListeners();
    debugPrint('isVisible = $isVisible');
  }

  void setIsEditorVisible(bool isVisible) {
    isEditorVisible = isVisible;
    notifyListeners();
    debugPrint('isEditorVisible = $isEditorVisible');
  }

  void setOpacity(double opacity) {
    this.opacity = opacity;
    notifyListeners();
    debugPrint('opacity = $opacity');
  }
}
