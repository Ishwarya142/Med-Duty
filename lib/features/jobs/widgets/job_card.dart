import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/geo_utils.dart';
import '../../../models/job_with_distance.dart';
import '../job_helpers.dart';

const _cBlue = Color(0xFF2563EB);
const _cTeal = Color(0xFF0F766E);

/// Employment opportunity card — distinct from duty/shift cards.
class JobCard extends StatelessWidget {
  final JobWithDistance item;
  final bool isApplied;
  final bool isSaved;
  final bool compact;
  final VoidCallback? onTap;
  final VoidCallback? onApply;
  final VoidCallback? onSave;
  final String actionLabel;

  const JobCard({
    super.key,
    required this.item,
    this.isApplied = false,
    this.isSaved = false,
    this.compact = false,
    this.onTap,
    this.onApply,
    this.onSave,
    this.actionLabel = 'Apply',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final job = item.job;
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final distLabel = item.distanceKm != null
        ? formatDistanceKm(item.distanceKm!)
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap ?? () => openJobDetails(context, item),
        child: Ink(
          padding: EdgeInsets.all(compact ? 12 : 14),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: compact ? 42 : 46,
                    height: compact ? 42 : 46,
                    decoration: BoxDecoration(
                      color: _cBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_hospital_rounded,
                      color: _cBlue,
                      size: compact ? 22 : 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: TextStyle(
                            color: tx,
                            fontSize: compact ? 14.5 : 16,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                job.hospitalName,
                                style: const TextStyle(
                                  color: _cBlue,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (job.verified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified_rounded,
                                color: Color(0xFF16A34A),
                                size: 14,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (onSave != null)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: onSave,
                      icon: Icon(
                        isSaved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: isSaved ? _cBlue : sub,
                        size: 20,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 13, color: sub),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      distLabel != null
                          ? '${job.location} • $distLabel'
                          : job.location,
                      style: TextStyle(color: sub, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (job.specialization.isNotEmpty)
                    _chip(job.specialization, _cTeal),
                  _chip(job.employmentLabel, _cBlue),
                  _chip(job.experienceRequired, sub),
                  if (job.workingHours != null && job.workingHours!.isNotEmpty)
                    _chip(job.workingHours!, const Color(0xFF7C3AED)),
                  if (job.verified) _chip('Verified', const Color(0xFF16A34A)),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule_outlined, size: 12, color: sub),
                      const SizedBox(width: 4),
                      Text(
                        'Posted ${formatJobPostedDate(job.postedAt)}',
                        style: TextStyle(color: sub, fontSize: 11),
                      ),
                    ],
                  ),
                  if (job.applicationDeadline != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_busy_outlined, size: 12, color: sub),
                        const SizedBox(width: 4),
                        Text(
                          'Apply by ${DateFormat('d MMM').format(job.applicationDeadline!)}',
                          style: TextStyle(color: sub, fontSize: 11),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job.salaryLabel,
                      style: TextStyle(
                        color: tx,
                        fontSize: compact ? 15 : 16,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (onApply != null)
                    ElevatedButton(
                      onPressed: isApplied ? null : onApply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isApplied ? Colors.grey : _cTeal,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        isApplied ? 'Applied' : actionLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String formatJobPostedDate(DateTime postedAt) {
  final diff = DateTime.now().difference(postedAt);
  if (diff.inDays == 0) return 'Today';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  return DateFormat('d MMM').format(postedAt);
}
