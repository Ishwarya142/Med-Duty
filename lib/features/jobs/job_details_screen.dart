import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/job_with_distance.dart';
import '../../providers/job_provider.dart';
import '../profile/public_hospital_profile_screen.dart';
import 'job_helpers.dart';
import 'widgets/job_card.dart';
import '../../shared/widgets/report_bottom_sheet.dart';

const _cTeal = Color(0xFF0F766E);
const _cBlue = Color(0xFF2563EB);

class JobDetailsScreen extends StatelessWidget {
  final JobWithDistance item;

  const JobDetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final job = item.job;
    final jobs = context.watch<JobProvider>();
    final isApplied = jobs.isJobApplied(job.id);
    final isSaved = jobs.isJobSaved(job.id);
    final distLabel = item.distanceKm != null
        ? item.formattedDistance
        : null;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text('Job Details', style: TextStyle(color: tx)),
        iconTheme: IconThemeData(color: tx),
        actions: [
          IconButton(
            onPressed: () => toggleJobSave(context, item),
            icon: Icon(
              isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isSaved ? _cBlue : tx,
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: tx),
            onSelected: (val) {
              if (val == 'report') {
                showContentReportSheet(
                  context,
                  subjectLabel: 'Job (${job.title} at ${job.hospitalName})',
                  targetId: job.id,
                  targetName: '${job.title} - ${job.hospitalName}',
                  reportType: 'job',
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.flag_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Report Job'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.title,
              style: TextStyle(
                color: tx,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              job.hospitalName,
              style: const TextStyle(
                color: _cBlue,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: sub),
                const SizedBox(width: 4),
                Text(
                  distLabel != null
                      ? '${job.location} • $distLabel'
                      : job.location,
                  style: TextStyle(color: sub, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _sectionCard(card, border, [
              _infoRow('Employment', job.employmentLabel, tx, sub),
              _infoRow('Experience', job.experienceRequired, tx, sub),
              _infoRow('Salary', job.salaryLabel, tx, sub),
              _infoRow('Qualification', job.qualification, tx, sub),
              if (job.workingHours != null && job.workingHours!.isNotEmpty)
                _infoRow('Working Hours', job.workingHours!, tx, sub),
              _infoRow('Positions', '${job.positions} position${job.positions > 1 ? "s" : ""}', tx, sub),
              _infoRow(
                'Posted',
                formatJobPostedDate(job.postedAt),
                tx,
                sub,
              ),
              if (job.applicationDeadline != null)
                _infoRow(
                  'Application Deadline',
                  '${job.applicationDeadline!.day}/${job.applicationDeadline!.month}/${job.applicationDeadline!.year}',
                  tx,
                  sub,
                ),
            ]),
            const SizedBox(height: 16),
            _heading('About the Role', tx),
            const SizedBox(height: 8),
            _sectionCard(card, border, [
              Text(
                job.description ?? 'No description provided.',
                style: TextStyle(color: sub, fontSize: 14, height: 1.5),
              ),
            ]),
            if (job.responsibilities.isNotEmpty) ...[
              const SizedBox(height: 16),
              _heading('Responsibilities', tx),
              const SizedBox(height: 8),
              _sectionCard(
                card,
                border,
                job.responsibilities
                    .map((r) => _bullet(r, sub))
                    .toList(),
              ),
            ],
            if (job.requirements.isNotEmpty) ...[
              const SizedBox(height: 16),
              _heading('Requirements', tx),
              const SizedBox(height: 8),
              _sectionCard(
                card,
                border,
                job.requirements.map((r) => _bullet(r, sub)).toList(),
              ),
            ],
            if (job.skills.isNotEmpty) ...[
              const SizedBox(height: 16),
              _heading('Skills', tx),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: job.skills
                    .map(
                      (s) => Chip(
                        label: Text(s),
                        backgroundColor: _cBlue.withValues(alpha: 0.08),
                        side: BorderSide(
                          color: _cBlue.withValues(alpha: 0.15),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            if (job.benefits.isNotEmpty) ...[
              const SizedBox(height: 16),
              _heading('Benefits', tx),
              const SizedBox(height: 8),
              _sectionCard(
                card,
                border,
                job.benefits.map((b) => _bullet(b, sub)).toList(),
              ),
            ],
            const SizedBox(height: 16),
            _heading('Hospital', tx),
            const SizedBox(height: 8),
            _sectionCard(card, border, [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: _cBlue.withValues(alpha: 0.12),
                  child: const Icon(Icons.local_hospital_rounded, color: _cBlue),
                ),
                title: Text(
                  job.hospitalName,
                  style: TextStyle(
                    color: tx,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(job.location, style: TextStyle(color: sub)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PublicHospitalProfileScreen(
                        hospitalId: job.hospitalId,
                        hospitalName: job.hospitalName,
                        hospitalType: 'Hospital',
                        location: job.location,
                        speciality: job.specialization,
                      ),
                    ),
                  );
                },
              ),
            ]),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              OutlinedButton(
                onPressed: () => toggleJobSave(context, item),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: border),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Text(isSaved ? 'Saved' : 'Save'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isApplied ? null : () => applyForJob(context, item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isApplied ? Colors.grey : _cTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    isApplied ? 'Applied' : 'Apply Now',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heading(String text, Color tx) {
    return Text(
      text,
      style: TextStyle(color: tx, fontSize: 16, fontWeight: FontWeight.w800),
    );
  }

  Widget _sectionCard(Color card, Color border, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _infoRow(String label, String value, Color tx, Color sub) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(color: sub, fontSize: 12)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: tx,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bullet(String text, Color sub) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: sub)),
          Expanded(
            child: Text(text, style: TextStyle(color: sub, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
