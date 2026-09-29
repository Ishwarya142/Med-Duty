import 'package:flutter/material.dart';

class PostDetailsScreen extends StatelessWidget {
  const PostDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF5F8),

      appBar: AppBar(
        title: const Text("Post"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Color(0xffFFE6EE),
                child: Icon(
                  Icons.person,
                  color: Color(0xffFF5C8D),
                ),
              ),
              title: Text(
                "Dr. Priya",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text("2 hours ago"),
            ),

            const SizedBox(height: 15),

            const Text(
              "Completed another successful emergency surgery today. Huge thanks to the entire operation theatre team.",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: Icon(
                  Icons.image,
                  size: 80,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

                Row(
                  children: [
                    Icon(Icons.favorite_border),
                    SizedBox(width: 5),
                    Text("256"),
                  ],
                ),

                Row(
                  children: [
                    Icon(Icons.comment_outlined),
                    SizedBox(width: 5),
                    Text("58"),
                  ],
                ),

                Row(
                  children: [
                    Icon(Icons.share_outlined),
                    SizedBox(width: 5),
                    Text("Share"),
                  ],
                ),
              ],
            ),

            const Divider(height: 35),

            const Text(
              "Comments",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}