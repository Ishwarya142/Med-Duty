import 'package:flutter/material.dart';

import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = [
      {
        "name": "Apollo Hospital",
        "message": "Your duty has been approved.",
        "time": "10:30 AM",
      },
      {
        "name": "Dr. Rahul",
        "message": "Can you swap tomorrow's shift?",
        "time": "09:15 AM",
      },
      {
        "name": "Fortis Hospital",
        "message": "Please confirm your availability.",
        "time": "Yesterday",
      },
      {
        "name": "MIOT Hospital",
        "message": "Duty completed successfully.",
        "time": "Yesterday",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
      ),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];

          return ListTile(
            leading: const CircleAvatar(
              radius: 25,
              backgroundColor: Color(0xffFFE6EE),
              child: Icon(
                Icons.person,
                color: Color(0xffFF5C8D),
              ),
            ),
            title: Text(
              chat["name"]!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(chat["message"]!),
            trailing: Text(chat["time"]!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    receiverName: chat["name"]!,
                    ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}