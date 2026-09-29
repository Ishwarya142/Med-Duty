import 'package:flutter/material.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController postController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF5F8),

      appBar: AppBar(
        title: const Text("Create Post"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffFF5C8D),
                foregroundColor: Colors.white,
              ),
              onPressed: () {},
              child: const Text("Post"),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [

            const Row(
              children: [

                CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(0xffFFE6EE),
                  child: Icon(
                    Icons.person,
                    color: Color(0xffFF5C8D),
                  ),
                ),

                SizedBox(width: 12),

                Text(
                  "Dr. Priya",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: TextField(
                controller: postController,
                expands: true,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: "Share your thoughts...",
                  border: InputBorder.none,
                ),
              ),
            ),

            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.image),
                ),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt),
                ),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.location_on),
                ),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.tag),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}