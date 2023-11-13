import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class Memory {
  String? name;
  String? thumbnail;
  String? details;
  String? date;

  Memory({this.name, this.thumbnail, this.details, this.date});

  void viewMemory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemoryDetailPage(memory: this),
      ),
    );
  }
}

class MemoryDetailPage extends StatelessWidget {
  final Memory memory;

  MemoryDetailPage({required this.memory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(memory.name ?? ''),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              // Favoriye ekleme işlemleri burada yapılabilir.
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 200.0,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: memory.thumbnail != null
                ? Image.file(
                    File(memory.thumbnail!),
                    height: 200.0,
                    fit: BoxFit.cover,
                  )
                : Container(),
          ),
          SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.0),
                Text(
                  'Tarih: ${memory.date ?? ''}',
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(height: 16.0),
                Container(
                  height: MediaQuery.of(context).size.height *
                      0.6, // Adjusted height
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 14.0),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            'Detaylar: ${memory.details ?? ''}',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

class MyHomePage extends StatefulWidget {
  List<Memory> memories = [];

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget _buildMemoryTile(int index) {
    int startIndex = index * 2;
    int endIndex = (index * 2) + 1;

    Widget buildTile(int tileIndex) {
      if (tileIndex < widget.memories.length) {
        return ListTile(
          title: Text(widget.memories[tileIndex].name ?? ''),
          leading: widget.memories[tileIndex].thumbnail != null
              ? Image.file(File(widget.memories[tileIndex].thumbnail!))
              : null,
          onTap: () {
            widget.memories[tileIndex].viewMemory(context);
          },
        );
      } else {
        return Container();
      }
    }

    return Row(
      children: [
        Expanded(
          child: buildTile(startIndex),
        ),
        SizedBox(width: 8.0),
        Expanded(
          child: buildTile(endIndex),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memories'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: (widget.memories.length / 2).ceil(),
        itemBuilder: (context, index) {
          return _buildMemoryTile(index);
        },
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
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MemoryPage()),
          );

          if (result != null && result is Memory) {
            setState(() {
              widget.memories.add(result);
            });
          }
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
  TextEditingController _dateController = TextEditingController();

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

  Future<void> _generateVideoThumbnail() async {
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

  void _saveMemory() {
    if (_nameController.text.isNotEmpty) {
      Memory newMemory = Memory(
        name: _nameController.text,
        thumbnail:
            _videoThumbnail ?? (_imageFile != null ? _imageFile!.path : null),
        details: _detailsController.text,
        date: _dateController.text,
      );

      Navigator.pop(context, newMemory);
    } else {
      // Kullanıcıya isim girmesi hatırlatılabilir.
    }
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
                    onTap: _showMediaOptions,
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
              controller: _dateController,
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
                  controller: _detailsController,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _saveMemory,
        child: Icon(Icons.check),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> _showNameDetailsDialog() async {
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
}
