import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      "Your duty application has been accepted.",
      "Apollo Hospital posted a new duty.",
      "New message from Dr. Priya.",
      "Certificate verification completed.",
      "Duty reminder for tomorrow.",
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xffFFE6EE),
                child: Icon(
                  Icons.notifications,
                  color: Color(0xffFF5C8D),
                ),
              ),
              title: Text(notifications[index]),
              subtitle: const Text("Just now"),
            ),
          );
        },
      ),
    );
  }
}