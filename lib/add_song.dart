import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';

class AddSongPage extends StatefulWidget {
  @override
  _AddSongPageState createState() => _AddSongPageState();
}

class _AddSongPageState extends State<AddSongPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  File? _imageFile;

  Future<void> _pickThumbnail() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileSize = await file.length();
      if (fileSize <= 2 * 1024 * 1024) {
        setState(() {
          _imageFile = file;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File too large. Max size is 2MB.')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageFile != null) {
      final uri = Uri.parse(
        'https://learn.smktelkom-mlg.sch.id/ukl2/playlists/song',
      );
      final request = http.MultipartRequest('POST', uri);

      request.fields['title'] = _titleController.text;
      request.fields['artist'] = _artistController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['source'] =
          _sourceController.text.isEmpty
              ? 'www.youtube.com'
              : _sourceController.text;

      debugPrint('File path: ${_imageFile!.path}');
      debugPrint('File extension: ${path.extension(_imageFile!.path)}');

      request.files.add(
        await http.MultipartFile.fromPath(
          'thumbnail',
          _imageFile!.path,
          contentType: MediaType(
            'image',
            path.extension(_imageFile!.path).toLowerCase().replaceAll('.', ''),
          ),
        ),
      );

      final response = await request.send();
      var responseData = await response.stream.bytesToString();
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: $responseData');
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Song saved!')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Source harus URL')));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Tambahkan thumbnail nya')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add new song',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator:
                    (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              TextFormField(
                controller: _artistController,
                decoration: InputDecoration(labelText: 'Artist'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Please enter artist name' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(labelText: 'Description'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Please enter description' : null,
              ),
              TextFormField(
                controller: _sourceController,
                decoration: InputDecoration(labelText: 'Source'),
                validator:
                    (value) => value!.isEmpty ? 'Please enter source' : null,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickThumbnail,
                child: Text(
                  _imageFile == null ? 'Choose Thumbnail' : 'Change Thumbnail',
                ),
              ),
              if (_imageFile != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _imageFile!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Save Song'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
