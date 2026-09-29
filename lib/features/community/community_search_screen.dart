// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../profile/public_doctor_profile_screen.dart';
import '../profile/public_hospital_profile_screen.dart';

const _cTeal   = Color(0xFF0B7A75);
const _cBlue   = Color(0xFF2563EB);

class CommunitySearchScreen extends StatefulWidget {
  const CommunitySearchScreen({super.key});
  @override
  State<CommunitySearchScreen> createState() => _CommunitySearchScreenState();
}

class _CommunitySearchScreenState extends State<CommunitySearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _ctrl = TextEditingController();
  String _query = '';
  late TabController _tabCtrl;

  final _doctors = [
    {'name': 'Dr. Neha Verma',   'role': 'Dermatologist',    'hospital': 'Max Hospital Delhi',        'location': 'Delhi'},
    {'name': 'Dr. Arjun Sharma', 'role': 'Diabetologist',    'hospital': 'Apollo Hospital Delhi',      'location': 'Delhi'},
    {'name': 'Dr. Priya Nair',   'role': 'Pediatrician',     'hospital': 'Fortis Hospital Bangalore',  'location': 'Bangalore'},
    {'name': 'Dr. Ramesh Iyer',  'role': 'Cardiologist',     'hospital': 'Apollo Heart',               'location': 'Mumbai'},
    {'name': 'Dr. Sita Krishnan','role': 'Neurologist',      'hospital': 'NIMHANS',                   'location': 'Bangalore'},
    {'name': 'Dr. Rohan Mehta',  'role': 'Cardiologist',     'hospital': 'Max Hospital',              'location': 'Delhi'},
    {'name': 'Dr. Ayesha Khan',  'role': 'Anesthesiologist', 'hospital': 'AIIMS',                     'location': 'Delhi'},
  ];

  final _hospitals = [
    {'name': 'Max Hospital Delhi',       'type': 'Multi-specialty', 'location': 'Delhi'},
    {'name': 'Apollo Hospital',          'type': 'Multi-specialty', 'location': 'Delhi'},
    {'name': 'Fortis Hospital',          'type': 'Multi-specialty', 'location': 'Bangalore'},
    {'name': 'AIIMS',                    'type': 'Government',      'location': 'Delhi'},
    {'name': 'NIMHANS',                  'type': 'Government',      'location': 'Bangalore'},
    {'name': 'Medanta',                  'type': 'Multi-specialty', 'location': 'Gurugram'},
  ];

  final _hashtags = [
    {'tag': '#MedDutyCommunity', 'posts': '3.2K'},
    {'tag': '#DoctorLife',       'posts': '2.8K'},
    {'tag': '#Cardiology',       'posts': '2.1K'},
    {'tag': '#Neurology',        'posts': '1.7K'},
    {'tag': '#Pediatrics',       'posts': '1.4K'},
    {'tag': '#PostCOVID',        'posts': '2.4K'},
    {'tag': '#BurnoutInHealth',  'posts': '1.8K'},
    {'tag': '#AIinMedicine',     'posts': '3.1K'},
  ];

  final _recentSearches = ['Dr. Neha Verma', '#Cardiology', 'Max Hospital', 'Neurology'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  String _initials(String name) {
    final p = name.trim().split(' ');
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return p[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg     = isDark ? AppColors.darkBackground    : AppColors.lightBackground;
    final card   = isDark ? AppColors.darkCardBg        : AppColors.lightCardBg;
    final border = isDark ? AppColors.darkBorder        : AppColors.lightBorder;
    final tx     = isDark ? AppColors.darkText          : AppColors.lightText;
    final sub    = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final filteredDoctors  = _query.isEmpty ? _doctors  : _doctors.where((d)  => d['name']!.toLowerCase().contains(_query.toLowerCase()) || d['role']!.toLowerCase().contains(_query.toLowerCase())).toList();
    final filteredHospitals= _query.isEmpty ? _hospitals: _hospitals.where((h) => h['name']!.toLowerCase().contains(_query.toLowerCase())).toList();
    final filteredHashtags  = _query.isEmpty ? _hashtags : _hashtags.where((h)  => h['tag']!.toLowerCase().contains(_query.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg, elevation: 0, scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_rounded, color: tx), onPressed: () => Navigator.pop(context)),
        title: Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
          child: TextField(
            controller: _ctrl,
            autofocus: true,
            style: TextStyle(color: tx, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search doctors, hospitals, posts, hashtags...',
              hintStyle: TextStyle(color: sub, fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(icon: Icon(Icons.close_rounded, color: sub, size: 18), onPressed: () => setState(() { _ctrl.clear(); _query = ''; }))
                  : Icon(Icons.search_rounded, color: sub, size: 18),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: _cTeal,
          unselectedLabelColor: sub,
          indicatorColor: _cTeal,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Doctors'),
            Tab(text: 'Hospitals'),
            Tab(text: 'Hashtags'),
          ],
        ),
      ),
      body: _query.isEmpty
          ? _buildEmptyState(tx, sub, card, border)
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _buildAllResults(filteredDoctors, filteredHospitals, filteredHashtags, tx, sub, card, border),
                _buildDoctorsList(filteredDoctors, tx, sub, card, border),
                _buildHospitalsList(filteredHospitals, tx, sub, card, border),
                _buildHashtagsList(filteredHashtags, tx, sub, card, border),
              ],
            ),
    );
  }

  Widget _buildEmptyState(Color tx, Color sub, Color card, Color border) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('Recent Searches', style: TextStyle(color: tx, fontSize: 15, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      ..._recentSearches.map((s) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(s.startsWith('#') ? Icons.tag_rounded : Icons.history_rounded, color: sub, size: 20),
        title: Text(s, style: TextStyle(color: tx, fontSize: 14)),
        trailing: Icon(Icons.north_west_rounded, color: sub, size: 16),
        onTap: () => setState(() { _ctrl.text = s; _query = s; }),
      )),
      const SizedBox(height: 20),
      Text('Trending Searches', style: TextStyle(color: tx, fontSize: 15, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        '#PostCOVID', '#BurnoutInHealth', '#AIinMedicine', '#DoctorLife', '#Cardiology', '#Pediatrics'
      ].map((tag) => GestureDetector(
        onTap: () => setState(() { _ctrl.text = tag; _query = tag; }),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: _cTeal.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20), border: Border.all(color: _cTeal.withValues(alpha: 0.25))),
          child: Text(tag, style: const TextStyle(color: _cTeal, fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      )).toList()),
    ]);
  }

  Widget _buildAllResults(List doctors, List hospitals, List hashtags, Color tx, Color sub, Color card, Color border) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      if (doctors.isNotEmpty) ...[
        Text('Doctors', style: TextStyle(color: tx, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...doctors.take(3).map((d) => _doctorTile(d as Map<String, String>, tx, sub, card, border)),
        const SizedBox(height: 16),
      ],
      if (hospitals.isNotEmpty) ...[
        Text('Hospitals', style: TextStyle(color: tx, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...hospitals.take(3).map((h) => _hospitalTile(h as Map<String, String>, tx, sub, card, border)),
        const SizedBox(height: 16),
      ],
      if (hashtags.isNotEmpty) ...[
        Text('Hashtags', style: TextStyle(color: tx, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...hashtags.take(4).map((h) => _hashtagTile(h as Map<String, String>, tx, sub)),
      ],
      if (doctors.isEmpty && hospitals.isEmpty && hashtags.isEmpty)
        Center(child: Padding(padding: const EdgeInsets.only(top: 40), child: Column(children: [
          Icon(Icons.search_off_rounded, color: sub, size: 48),
          const SizedBox(height: 12),
          Text('No results for "$_query"', style: TextStyle(color: sub, fontSize: 14)),
        ]))),
    ]);
  }

  Widget _buildDoctorsList(List doctors, Color tx, Color sub, Color card, Color border) {
    if (doctors.isEmpty) return Center(child: Text('No doctors found', style: TextStyle(color: sub)));
    return ListView(padding: const EdgeInsets.all(16), children: doctors.map((d) => _doctorTile(d as Map<String, String>, tx, sub, card, border)).toList());
  }

  Widget _buildHospitalsList(List hospitals, Color tx, Color sub, Color card, Color border) {
    if (hospitals.isEmpty) return Center(child: Text('No hospitals found', style: TextStyle(color: sub)));
    return ListView(padding: const EdgeInsets.all(16), children: hospitals.map((h) => _hospitalTile(h as Map<String, String>, tx, sub, card, border)).toList());
  }

  Widget _buildHashtagsList(List hashtags, Color tx, Color sub, Color card, Color border) {
    if (hashtags.isEmpty) return Center(child: Text('No hashtags found', style: TextStyle(color: sub)));
    return ListView(padding: const EdgeInsets.all(16), children: hashtags.map((h) => _hashtagTile(h as Map<String, String>, tx, sub)).toList());
  }

  Widget _doctorTile(Map<String, String> d, Color tx, Color sub, Color card, Color border) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PublicDoctorProfileScreen(
        doctorName: d['name']!, qualification: 'MBBS, MD', specialization: d['role']!,
        hospital: d['hospital']!, location: d['location']!, avatarInitials: _initials(d['name']!), avatarColor: _cTeal))),
      child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
        child: Row(children: [
          CircleAvatar(radius: 22, backgroundColor: _cTeal.withValues(alpha: 0.15),
            child: Text(_initials(d['name']!), style: const TextStyle(color: _cTeal, fontSize: 12, fontWeight: FontWeight.bold))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text(d['name']!, style: TextStyle(color: tx, fontSize: 14, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 4), const Icon(Icons.verified_rounded, color: _cBlue, size: 14),
            ]),
            Text('${d['role']} \u2022 ${d['hospital']}', style: TextStyle(color: sub, fontSize: 12), overflow: TextOverflow.ellipsis),
          ])),
          Icon(Icons.chevron_right_rounded, color: sub, size: 18),
        ])),
    );
  }

  Widget _hospitalTile(Map<String, String> h, Color tx, Color sub, Color card, Color border) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PublicHospitalProfileScreen(
        hospitalName: h['name']!, hospitalType: h['type']!, location: h['location']!))),
      child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
        child: Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: _cBlue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.local_hospital_rounded, color: _cBlue, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(h['name']!, style: TextStyle(color: tx, fontSize: 14, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
            Text('${h['type']} \u2022 ${h['location']}', style: TextStyle(color: sub, fontSize: 12)),
          ])),
          Icon(Icons.chevron_right_rounded, color: sub, size: 18),
        ])),
    );
  }

  Widget _hashtagTile(Map<String, String> h, Color tx, Color sub) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: _cTeal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.tag_rounded, color: _cTeal, size: 20)),
      title: Text(h['tag']!, style: TextStyle(color: _cTeal, fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text('${h['posts']} posts', style: TextStyle(color: sub, fontSize: 12)),
      trailing: Icon(Icons.chevron_right_rounded, color: sub, size: 18),
      onTap: () => setState(() { _ctrl.text = h['tag']!; _query = h['tag']!; }),
    );
  }
}
