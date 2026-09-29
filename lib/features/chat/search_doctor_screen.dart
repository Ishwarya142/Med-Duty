import 'package:flutter/material.dart';

class SearchDoctorScreen extends StatefulWidget {
  const SearchDoctorScreen({super.key});

  @override
  State<SearchDoctorScreen> createState() => _SearchDoctorScreenState();
}

class _SearchDoctorScreenState extends State<SearchDoctorScreen> {
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, String>> doctors = [
    {
      "name": "Dr. Priya",
      "speciality": "Cardiologist",
      "hospital": "Apollo Hospital",
    },
    {
      "name": "Dr. Arjun",
      "speciality": "Orthopedic",
      "hospital": "Fortis Hospital",
    },
    {
      "name": "Dr. Meera",
      "speciality": "Neurologist",
      "hospital": "MIOT Hospital",
    },
    {
      "name": "Dr. Rahul",
      "speciality": "Pediatrician",
      "hospital": "CMC Hospital",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF5F8),

      appBar: AppBar(
        title: const Text("Search Doctors"),
      ),

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search Doctor",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          Expanded(
            child: ListView(
              children: doctors
                  .where((doctor) => doctor["name"]!
                      .toLowerCase()
                      .contains(searchController.text.toLowerCase()))
                  .map(
                    (doctor) => Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xffFFE6EE),
                          child: Icon(
                            Icons.person,
                            color: Color(0xffFF5C8D),
                          ),
                        ),
                        title: Text(doctor["name"]!),
                        subtitle: Text(
                          "${doctor["speciality"]}\n${doctor["hospital"]}",
                        ),
                        isThreeLine: true,
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffFF5C8D),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {},
                          child: const Text("Chat"),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}