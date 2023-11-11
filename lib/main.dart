import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memories'),
        centerTitle: true,
      ),
      body: Center(
        child: Text('Body Content Goes Here'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.collections),
            label: 'Memories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MemoryPage()),
          );
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}

class MemoryPage extends StatefulWidget {
  @override
  _MemoryPageState createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> {
  File? _imageFile;
  File? _videoFile;
  final picker = ImagePicker();
  VideoPlayerController? _videoPlayerController;
  String? _videoThumbnail;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _detailsController = TextEditingController();
  TextEditingController _details2Controller = TextEditingController();

  Future _getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        _videoFile = null;
        _videoPlayerController?.dispose();
        _videoPlayerController = null;
        _videoThumbnail = null;
      }
    });
  }

  Future _getVideo(ImageSource source) async {
    final pickedFile = await picker.pickVideo(source: source);

    setState(() {
      if (pickedFile != null) {
        _videoFile = File(pickedFile.path);
        _imageFile = null;
        _videoPlayerController?.dispose();
        _videoPlayerController = VideoPlayerController.file(_videoFile!)
          ..initialize().then((_) {
            setState(() {});
          });
        _generateVideoThumbnail();
      }
    });
  }

  void _generateVideoThumbnail() async {
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: _videoFile!.path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128,
      quality: 25,
    );

    setState(() {
      _videoThumbnail = thumbnailPath;
    });
  }

  Future<void> _showMediaOptions() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Medya Seçin'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Galeriden Fotoğraf Seç'),
                onTap: () {
                  _getImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Galeriden Video Seç'),
                onTap: () {
                  _getVideo(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Kameradan Fotoğraf Çek'),
                onTap: () {
                  _getImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Kameradan Video Çek'),
                onTap: () {
                  _getVideo(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showMediaOptionsForChange() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Medya Değiştir'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Galeriden Fotoğraf Seç'),
                onTap: () {
                  _getImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Galeriden Video Seç'),
                onTap: () {
                  _getVideo(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Kameradan Fotoğraf Çek'),
                onTap: () {
                  _getImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Kameradan Video Çek'),
                onTap: () {
                  _getVideo(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDetailsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detaylar'),
          content: TextField(
            controller: _detailsController,
            maxLines: null,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16.0),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  void _showNameDetailsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('İsim Detayları'),
          content: TextField(
            controller: _nameController,
            maxLines: null,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16.0),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Memory'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _imageFile != null || _videoFile != null
                ? GestureDetector(
                    onTap: _showMediaOptionsForChange,
                    child: Container(
                      height: 150.0,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: _imageFile != null
                          ? Image.file(
                              _imageFile!,
                              height: 150.0,
                              fit: BoxFit.cover,
                            )
                          : _videoFile != null
                              ? Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    AspectRatio(
                                      aspectRatio: _videoPlayerController!
                                          .value.aspectRatio,
                                      child:
                                          VideoPlayer(_videoPlayerController!),
                                    ),
                                    if (_videoThumbnail != null)
                                      Image.file(
                                        File(_videoThumbnail!),
                                        height: 150.0,
                                        fit: BoxFit.cover,
                                      ),
                                  ],
                                )
                              : Container(),
                    ),
                  )
                : Container(
                    height: 150.0,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _showMediaOptions,
                      icon: Icon(Icons.add),
                      label: Text('Medya Ekleyin'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                  ),
            SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'İsim',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Tarih',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            GestureDetector(
              onTap: _showNameDetailsDialog,
              child: Container(
                height: 150.0,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: TextField(
                  controller: _details2Controller,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Detaylar',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
