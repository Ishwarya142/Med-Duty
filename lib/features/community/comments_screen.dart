import 'package:flutter/material.dart';

class CommentsScreen extends StatelessWidget {
  const CommentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final comments = [
      "Great work doctor 👏",
      "Congratulations ❤️",
      "Amazing achievement.",
      "Very inspiring.",
      "Keep saving lives.",
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Comments"),
      ),

      body: Column(
        children: [

          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xffFFE6EE),
                    child: Icon(
                      Icons.person,
                      color: Color(0xffFF5C8D),
                    ),
                  ),
                  title: Text(comments[index]),
                  subtitle: const Text("Just now"),
                );
              },
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [

                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Write a comment...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xffFF5C8D),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
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