import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = [
      {
        "name": "Dr. Priya",
        "role": "Cardiologist",
        "time": "2 hrs ago",
        "content":
            "Completed an emergency CABG surgery today. Proud of the entire OT team! ❤️",
      },
      {
        "name": "Dr. Arjun",
        "role": "Orthopedic Surgeon",
        "time": "5 hrs ago",
        "content":
            "Looking for an orthopedic surgeon for a weekend duty in Chennai.",
      },
      {
        "name": "Nurse Kavya",
        "role": "ICU Nurse",
        "time": "Yesterday",
        "content":
            "Sharing some ICU patient handling tips for new nurses.",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xffFFF5F8),

      appBar: AppBar(
        title: const Text("Community"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_box_outlined),
          )
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffFF5C8D),
        onPressed: () {},
        child: const Icon(Icons.edit, color: Colors.white),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [

                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xffFFE6EE),
                        child: Icon(
                          Icons.person,
                          color: Color(0xffFF5C8D),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            Text(
                              post["name"]!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Text(
                              "${post["role"]} • ${post["time"]}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(Icons.more_vert),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Text(
                    post["content"]!,
                    style: const TextStyle(fontSize: 15),
                  ),

                  const SizedBox(height: 20),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      height: 180,
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(
                          Icons.image,
                          size: 70,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceAround,
                    children: const [

                      Row(
                        children: [
                          Icon(Icons.favorite_border),
                          SizedBox(width: 5),
                          Text("Like"),
                        ],
                      ),

                      Row(
                        children: [
                          Icon(Icons.comment_outlined),
                          SizedBox(width: 5),
                          Text("Comment"),
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}