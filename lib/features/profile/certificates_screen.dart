import 'package:flutter/material.dart';

class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final certificates = [
      "MBBS Certificate",
      "MD Cardiology",
      "BLS Certification",
      "ACLS Certification",
      "Medical License",
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Certificates"),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffFF5C8D),
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: certificates.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: const Icon(
                Icons.picture_as_pdf,
                color: Colors.red,
              ),
              title: Text(certificates[index]),
              trailing: const Icon(Icons.visibility),
            ),
          );
        },
      ),
    );
  }
}