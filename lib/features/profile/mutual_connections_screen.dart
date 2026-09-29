import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/profile_provider.dart';
import 'public_doctor_profile_screen.dart';

class MutualConnectionsScreen extends StatefulWidget {
  final String targetUserId;
  final String targetName;

  const MutualConnectionsScreen({
    super.key,
    required this.targetUserId,
    required this.targetName,
  });

  @override
  State<MutualConnectionsScreen> createState() => _MutualConnectionsScreenState();
}

class _MutualConnectionsScreenState extends State<MutualConnectionsScreen> {
  List<Map<String, String>> _connections = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await context.read<ProfileProvider>().mutualConnections(widget.targetUserId);
      if (!mounted) return;
      setState(() {
        _connections = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to load mutual connections.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('Mutual Connections', style: TextStyle(color: textColor, fontWeight: FontWeight.w800)),
        backgroundColor: bg,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error!, style: TextStyle(color: subText)),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _load, child: const Text('Try Again')),
                ],
              ),
            )
          : _connections.isEmpty
          ? Center(child: Text('No mutual connections yet.', style: TextStyle(color: subText)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _connections.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final c = _connections[index];
                return ListTile(
                  tileColor: surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: border.withValues(alpha: 0.5)),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.accent,
                    child: Text(
                      (c['name'] ?? 'D')[0],
                      style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w800),
                    ),
                  ),
                  title: Text(c['name'] ?? 'Doctor', style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
                  subtitle: Text(c['specialization'] ?? '', style: TextStyle(color: subText, fontSize: 12)),
                  trailing: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PublicDoctorProfileScreen(
                            doctorId: c['id'],
                            doctorName: c['name'] ?? 'Doctor',
                            qualification: 'MBBS, MD',
                            specialization: c['specialization'] ?? 'Healthcare Professional',
                            hospital: c['hospital'] ?? '',
                            location: 'India',
                          ),
                        ),
                      );
                    },
                    child: const Text('View'),
                  ),
                );
              },
            ),
    );
  }
}
