import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'base_layout.dart';
import 'package:share_plus/share_plus.dart';
import 'db_helper.dart';

class SongLyricsScreen extends StatefulWidget {
  final String title;
  final String lyrics;
  final int? songId; // Add songId parameter

  const SongLyricsScreen({
    required this.title,
    required this.lyrics,
    this.songId,
    super.key,
  });

  @override
  State<SongLyricsScreen> createState() => _SongLyricsScreenState();
}

class _SongLyricsScreenState extends State<SongLyricsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    if (widget.songId != null) {
      setState(() => _isLoading = true);
      try {
        final song = await DBHelper.instance.getSongById(widget.songId!);
        if (song.isNotEmpty) {
          setState(() {
            _isFavorite = song.first['is_favorite'] == 1;
          });
        }
      } catch (e) {
        debugPrint('Error checking favorite status: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (widget.songId == null) return;

    setState(() => _isLoading = true);
    try {
      await DBHelper.instance.toggleFavorite(widget.songId!);
      setState(() {
        _isFavorite = !_isFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? 'Added to favorites' : 'Removed from favorites',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating favorite: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 0 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 0 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  List<TextSpan> _buildFormattedLyrics() {
    final List<TextSpan> spans = [];
    final lines = widget.lyrics
        .replaceAll('<bold>', '')
        .replaceAll('</bold>', '')
        .split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim() == 'ትርጉም') {
        spans.add(
          TextSpan(
            text: line,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 16,
              height: 1.8,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        spans.add(
          TextSpan(
            text: '\n',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              height: 0.5,
              decoration: TextDecoration.underline,
              decorationColor: Theme.of(context).primaryColor,
              decorationThickness: 2,
            ),
          ),
        );
      } else if (line.trim().contains(RegExp(r'\d+'))) {
        spans.add(
          TextSpan(
            text: line,
            style: TextStyle(
              color: const Color(0xFF00494D),
              fontSize: 16,
              height: 1.8,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        spans.add(
          const TextSpan(text: '\n'),
        ); // Add one newline after the number
      } else if (line.trim() == 'አዝ') {
        spans.add(
          TextSpan(
            text: line,
            style: const TextStyle(
              color: Color(0xFF00494D),
              fontSize: 16,
              height: 1.8,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        spans.add(const TextSpan(text: '\n')); // Add one newline after "አዝ"
      } else {
        spans.add(
          TextSpan(
            text: line,
            style: TextStyle(
              color: const Color(0xFF00494D),
              fontSize: 16,
              height: 1.8,
            ),
          ),
        );
        spans.add(const TextSpan(text: '\n')); // Add one newline after the line
      }
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: _isScrolled ? 1 : 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF00494D)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.title,
            style: const TextStyle(
              color: Color(0xFF00494D),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            if (widget.songId != null)
              IconButton(
                icon:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color:
                              _isFavorite
                                  ? Colors.red
                                  : const Color(0xFF00494D),
                        ),
                onPressed: _isLoading ? null : _toggleFavorite,
              ),
            IconButton(
              icon: const Icon(Icons.share, color: Color(0xFF00494D)),
              onPressed: () {
                final String shareContent =
                    "${widget.title}\n\n${widget.lyrics}";
                Share.share(shareContent);
              },
            ),
          ],
        ),
        body: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00494D).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText.rich(
                TextSpan(children: _buildFormattedLyrics()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
