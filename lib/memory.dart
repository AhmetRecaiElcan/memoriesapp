import 'package:flutter/material.dart';
import 'memory_detail_page.dart';
import 'memory_page.dart';

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
