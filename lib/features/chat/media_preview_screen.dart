import 'package:flutter/material.dart';

class MediaPreviewScreen extends StatelessWidget {
  const MediaPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text("Media Preview"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.download),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share),
          ),
        ],
      ),

      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          height: 350,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Icon(
              Icons.image,
              size: 120,
              color: Colors.white54,
            ),
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 55),
              backgroundColor: const Color(0xffFF5C8D),
              foregroundColor: Colors.white,
            ),
            onPressed: () {},
            icon: const Icon(Icons.send),
            label: const Text("Send"),
          ),
        ),
      ),
    );
  }
}