import 'package:flutter/material.dart';
import 'song_lyrics_screen.dart';

class SongTile extends StatelessWidget {
  final String song;
  final String lyrics;
  final int? songId; // Add songId parameter

  const SongTile({
    required this.song,
    required this.lyrics,
    this.songId, // Add to constructor
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 167, 139, 1),
      child: ListTile(
        leading: const Icon(Icons.music_note, color: Colors.white),
        title: Text(song, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => SongLyricsScreen(
                    title: song,
                    lyrics: lyrics,
                    songId: songId, // Pass the songId
                  ),
            ),
          );
        },
      ),
    );
  }
}
