import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

class Song {
  final String title;
  final String lyrics;
  final String category;

  Song({required this.title, required this.lyrics, required this.category});

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      title: json['title'],
      lyrics: json['lyrics'],
      category: json['category'],
    );
  }
}

class DataLoader {
  static Future<void> loadSongs() async {
    final String jsonString = await rootBundle.loadString('assets/songs.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    final List<Song> songs =
        jsonList.map((json) => Song.fromJson(json)).toList();

    // Store songs in Hive database
    final Box songsBox = Hive.box('songs_box');
    await songsBox.put('songs', songs);
  }

  static List<Song> getSongs() {
    final Box songsBox = Hive.box('songs_box');
    return (songsBox.get('songs') as List<dynamic>).cast<Song>();
  }
}
