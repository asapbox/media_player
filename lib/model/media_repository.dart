import 'package:media_player/apis/media_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'media.dart';
import 'package:flutter/material.dart';

class MediaRepository {
  final mediaService = MediaService();

  Future<List<Media>> fetchMedias() async {
    final response = await http.get(Uri.parse(mediaService.url));

    if (response.statusCode == 200) {
      final decodedString = jsonDecode(response.body) as Map<String, dynamic>;
      final List<Media> medias = [];
      for (final decodedMedia in decodedString.values.first) {
        medias.add(Media.fromJson(decodedMedia));
      }
      return medias;
    } else {
      throw Exception(
          'Failed to load media. StatusCode = ${response.statusCode}');
    }
  }

  Future<void> deleteMedia(int id) async {
    final response = await http.delete(
      Uri.parse('${mediaService.url}$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 204) {
      debugPrint('Video is deleted');
    } else {
      throw Exception(
          'Failed to delete media. statusCode = ${response.statusCode}');
    }
  }

  Future<void> updateMedia(int id, String newTitle) async {
    final response = await http.patch(Uri.parse('${mediaService.url}$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'title': newTitle,
        }));
    if (response.statusCode == 200) {
      debugPrint('Media is updated');
    } else {
      throw Exception(
          'Failed to update media. StatusCode = ${response.statusCode}');
    }
  }
}
