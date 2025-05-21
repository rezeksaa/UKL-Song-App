import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ukl/add_song.dart';
import 'dart:convert';

import 'package:ukl/song_list.dart';

class HomePage extends StatefulWidget {
  final String firstName;
  const HomePage({super.key, required this.firstName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    getPlaylist();
  }

  List playlists = [];
  bool isLoading = true;

  Future<void> getPlaylist() async {
    final response = await http.get(
      Uri.parse('https://learn.smktelkom-mlg.sch.id/ukl2/playlists'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        playlists = data['data'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Playlist Page", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddSongPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueGrey,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'Selamat datang ${widget.firstName}! Hari ini mau dengerin apa?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: playlists.length,
                        itemBuilder: (context, index) {
                          final item = playlists[index];
                          return Card(
                            margin: EdgeInsets.all(8),
                            child: ListTile(
                              title: Text(item['playlist_name']),
                              subtitle: Text(
                                'Song count: ${item['song_count']}',
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => SongListPage(
                                          playlistUuid: item['uuid'],
                                        ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
