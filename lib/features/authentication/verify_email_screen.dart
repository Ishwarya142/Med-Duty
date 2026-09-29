import 'package:flutter/material.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF5F8),
      appBar: AppBar(
        title: const Text("Verify Email"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Icon(
                Icons.mark_email_read,
                size: 90,
                color: Color(0xffFF5C8D),
              ),

              const SizedBox(height: 25),

              const Text(
                "Verify Your Email",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                "A verification link has been sent to your email address.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffFF5C8D),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {},
                  child: const Text("I've Verified"),
                ),
              ),

              TextButton(
                onPressed: () {},
                child: const Text("Resend Email"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
