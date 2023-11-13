import 'package:flutter/material.dart';
import 'memory.dart';
import 'dart:io';
import 'memory_page.dart';

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
