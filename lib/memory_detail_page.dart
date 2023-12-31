import 'package:flutter/material.dart';
import 'memory.dart';
import 'dart:io';

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
          Expanded(
            child: Padding(
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
                    constraints: BoxConstraints(
                      maxHeight: 200.0, // Maksimum yükseklik
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Detaylar: ${memory.details ?? ''}',
                          style: TextStyle(fontSize: 15.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
