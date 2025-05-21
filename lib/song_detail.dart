import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SongDetailPage extends StatefulWidget {
  final String songId;

  const SongDetailPage({Key? key, required this.songId}) : super(key: key);

  @override
  _SongDetailPageState createState() => _SongDetailPageState();
}

class _SongDetailPageState extends State<SongDetailPage> {
  Map<String, dynamic>? songData;
  bool isLoading = true;
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    fetchSongData();
  }

  Future<void> fetchSongData() async {
    final url =
        'https://learn.smktelkom-mlg.sch.id/ukl2/playlists/song/${widget.songId}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      setState(() {
        songData = json['data'];
        isLoading = false;

        final videoId = YoutubePlayer.convertUrlToId(songData!['source']);
        if (videoId != null) {
          _youtubeController = YoutubePlayerController(
            initialVideoId: videoId,
            flags: YoutubePlayerFlags(autoPlay: false, mute: false),
          );
        }
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Loading...')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (songData == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(child: Text('Failed to load song data')),
      );
    }

    final comments = songData!['comments'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(songData!['title'], style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                songData!['artist'],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              if (_youtubeController != null)
                YoutubePlayer(
                  controller: _youtubeController!,
                  showVideoProgressIndicator: true,
                )
              else
                Text('Video tidak tersedia'),
              SizedBox(height: 16),
              Text(
                'Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(songData!['description']),
              SizedBox(height: 20),
              Text(
                'Comments',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Divider(),
              ...List.generate(comments.length, (index) {
                final comment = comments[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${comment['creator']}:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(comment['comment_text']),
                      SizedBox(height: 6),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
