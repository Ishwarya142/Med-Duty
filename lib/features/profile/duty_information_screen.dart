import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/duty_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/duty_model.dart';
import '../../models/application_model.dart';

class DutyInformationScreen extends StatefulWidget {
  const DutyInformationScreen({super.key});

  @override
  State<DutyInformationScreen> createState() => _DutyInformationScreenState();
}

class _DutyInformationScreenState extends State<DutyInformationScreen> {
  DutyStatus? selectedFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null) {
        context.read<DutyProvider>().loadDutyData(authProvider.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dutyProvider = context.watch<DutyProvider>();

    final completedDuties = dutyProvider.completedDutiesCount;
    final upcomingDuties = dutyProvider.upcomingDutiesCount;
    final appliedDuties = dutyProvider.applications.length;
    final savedDuties = dutyProvider.savedDutiesCount;
    final cancelledDuties = 0; // For now

    final filteredList = selectedFilter == null
        ? dutyProvider.applications
        : dutyProvider.applications
              .where((a) => a.status.name == selectedFilter?.name)
              .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Duty Information'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        foregroundColor: AppColors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatsGrid(
            completedDuties,
            upcomingDuties,
            appliedDuties,
            savedDuties,
            cancelledDuties,
          ),
          const SizedBox(height: 24),
          _buildFilterSection(),
          const SizedBox(height: 16),
          _buildApplicationsList(filteredList),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    int completed,
    int upcoming,
    int applied,
    int saved,
    int cancelled,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          'Completed',
          completed,
          AppColors.success,
          Icons.check_circle,
        ),
        _buildStatCard(
          'Upcoming',
          upcoming,
          AppColors.accent,
          Icons.calendar_today,
        ),
        _buildStatCard('Applied', applied, AppColors.info, Icons.send),
        _buildStatCard('Saved', saved, AppColors.secondary, Icons.bookmark),
        _buildStatCard('Cancelled', cancelled, AppColors.error, Icons.cancel),
        _buildStatCard(
          'Total',
          completed + upcoming + applied + saved + cancelled,
          AppColors.primary,
          Icons.work,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, int count, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All', null),
          _buildFilterChip('Upcoming', DutyStatus.upcoming),
          _buildFilterChip('Applied', DutyStatus.applied),
          _buildFilterChip('Completed', DutyStatus.completed),
          _buildFilterChip('Cancelled', DutyStatus.cancelled),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, DutyStatus? status) {
    final isSelected = selectedFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedFilter = selected ? status : null;
          });
        },
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        checkmarkColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildApplicationsList(List<ApplicationModel> applications) {
    if (applications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.work_off, size: 64, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              Text(
                'No applications found',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: applications.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final app = applications[index];
        return _buildApplicationCard(app);
      },
    );
  }

  Widget _buildApplicationCard(ApplicationModel application) {
    final dutyProvider = context.watch<DutyProvider>();
    final isSaved = dutyProvider.isDutySaved(application.dutyId);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  application.role,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved ? AppColors.primary : AppColors.textSecondary,
                ),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await dutyProvider.toggleSaveDuty(
                    application.dutyId,
                    application.role,
                    application.location,
                    application.salary,
                  );
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        dutyProvider.isDutySaved(application.dutyId)
                            ? 'Duty saved'
                            : 'Removed from saved duties',
                      ),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            application.hospitalName,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  application.location,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    application.status,
                  ).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusText(application.status),
                  style: TextStyle(
                    color: _getStatusColor(application.status),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (application.salary != null)
                Text(
                  '₹${application.salary}',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(dynamic status) {
    if (status.toString() == 'ApplicationStatus.pending' ||
        status == DutyStatus.upcoming) {
      return AppColors.accent;
    } else if (status.toString() == 'ApplicationStatus.accepted' ||
        status == DutyStatus.applied) {
      return AppColors.info;
    } else if (status.toString() == 'ApplicationStatus.completed' ||
        status == DutyStatus.completed) {
      return AppColors.success;
    } else {
      return AppColors.error;
    }
  }

  String _getStatusText(dynamic status) {
    if (status.toString() == 'ApplicationStatus.pending') {
      return 'Pending';
    } else if (status.toString() == 'ApplicationStatus.accepted') {
      return 'Accepted';
    } else if (status.toString() == 'ApplicationStatus.rejected') {
      return 'Rejected';
    } else if (status.toString() == 'ApplicationStatus.shortlisted') {
      return 'Shortlisted';
    } else if (status.toString() == 'ApplicationStatus.completed') {
      return 'Completed';
    } else if (status.toString() == 'ApplicationStatus.withdrawn') {
      return 'Withdrawn';
    } else if (status == DutyStatus.upcoming) {
      return 'Upcoming';
    } else if (status == DutyStatus.applied) {
      return 'Applied';
    } else if (status == DutyStatus.completed) {
      return 'Completed';
    } else if (status == DutyStatus.cancelled) {
      return 'Cancelled';
    } else {
      return 'Unknown';
    }
  }
}
