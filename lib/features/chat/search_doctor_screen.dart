import 'package:flutter/material.dart';
import 'chat_screen.dart';

const _cTeal = Color(0xFF0F766E);
const _cBlue = Color(0xFF2563EB);

class SearchDoctorScreen extends StatefulWidget {
  const SearchDoctorScreen({super.key});

  @override
  State<SearchDoctorScreen> createState() => _SearchDoctorScreenState();
}

class _SearchDoctorScreenState extends State<SearchDoctorScreen> {
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, String>> doctors = [
    {
      "name": "Dr. Rohan Mehta",
      "speciality": "Cardiologist",
      "hospital": "Apollo Hospital",
      "initials": "RM",
      "online": "true",
    },
    {
      "name": "Dr. Neha Verma",
      "speciality": "Dermatologist",
      "hospital": "Max Hospital",
      "initials": "NV",
      "online": "true",
    },
    {
      "name": "Dr. Priya Nair",
      "speciality": "Pediatrician",
      "hospital": "Cloudnine Hospital",
      "initials": "PN",
      "online": "false",
    },
    {
      "name": "Dr. Karan Patel",
      "speciality": "Orthopedic Surgeon",
      "hospital": "MGM Healthcare",
      "initials": "KP",
      "online": "false",
    },
    {
      "name": "Dr. Arjun Sharma",
      "speciality": "Diabetologist",
      "hospital": "Apollo Hospital",
      "initials": "AS",
      "online": "true",
    },
    {
      "name": "Dr. Meera Nambiar",
      "speciality": "Neurologist",
      "hospital": "MIOT Hospital",
      "initials": "MN",
      "online": "true",
    },
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final filtered = doctors.where((doctor) {
      final q = searchController.text.toLowerCase();
      return doctor["name"]!.toLowerCase().contains(q) ||
          doctor["speciality"]!.toLowerCase().contains(q) ||
          doctor["hospital"]!.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          "Find Doctors & Colleagues",
          style: TextStyle(
            color: tx,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: TextField(
                controller: searchController,
                autofocus: false,
                style: TextStyle(color: tx, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Search doctor name, specialty, or hospital...",
                  hintStyle: TextStyle(color: sub, fontSize: 13.5),
                  prefixIcon: Icon(Icons.search_rounded, color: sub, size: 22),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close_rounded, color: sub, size: 18),
                          onPressed: () {
                            searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          color: sub.withValues(alpha: 0.4),
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No doctors found",
                          style: TextStyle(
                            color: tx,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Try searching another specialty or name.",
                          style: TextStyle(color: sub, fontSize: 12.5),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final doc = filtered[i];
                      final isOnline = doc["online"] == "true";
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: border),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: const Color(0xFF0F172A)
                                        .withValues(alpha: 0.03),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: _cTeal.withValues(alpha: 0.15),
                                child: Text(
                                  doc["initials"] ?? doc["name"]![0],
                                  style: const TextStyle(
                                    color: _cTeal,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isOnline)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 11,
                                    height: 11,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF16A34A),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  doc["name"]!,
                                  style: TextStyle(
                                    color: tx,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified_rounded,
                                color: _cBlue,
                                size: 14,
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              "${doc["speciality"]} • ${doc["hospital"]}",
                              style: TextStyle(
                                color: sub,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _cTeal,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    receiverName: doc['name']!,
                                    receiverRole: doc['speciality'] ?? 'Doctor',
                                    isOnline: isOnline,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "Message",
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
