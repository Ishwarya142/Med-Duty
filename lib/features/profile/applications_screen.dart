
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/duty_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/application_model.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  ApplicationStatus? selectedFilter;

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

    final pendingCount = dutyProvider.pendingApplicationsCount;
    final acceptedCount = dutyProvider.acceptedApplicationsCount;
    final rejectedCount = dutyProvider.rejectedApplicationsCount;
    final shortlistedCount = dutyProvider.shortlistedApplicationsCount;
    final completedCount = dutyProvider.completedApplicationsCount;
    final withdrawnCount = dutyProvider.withdrawnApplicationsCount;

    final filteredApplications = selectedFilter == null
        ? dutyProvider.applications
        : dutyProvider.applications.where((a) => a.status == selectedFilter).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Applications'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        foregroundColor: AppColors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatsGrid(pendingCount, acceptedCount, rejectedCount, shortlistedCount, completedCount, withdrawnCount),
          const SizedBox(height: 24),
          _buildFilterSection(),
          const SizedBox(height: 16),
          _buildApplicationsList(filteredApplications),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(int pending, int accepted, int rejected, int shortlisted, int completed, int withdrawn) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard('Pending', pending, AppColors.warning, Icons.hourglass_empty),
        _buildStatCard('Accepted', accepted, AppColors.success, Icons.check_circle),
        _buildStatCard('Rejected', rejected, AppColors.error, Icons.cancel),
        _buildStatCard('Shortlisted', shortlisted, AppColors.info, Icons.star),
        _buildStatCard('Completed', completed, AppColors.accent, Icons.work),
        _buildStatCard('Withdrawn', withdrawn, AppColors.textSecondary, Icons.exit_to_app),
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
          _buildFilterChip('Pending', ApplicationStatus.pending),
          _buildFilterChip('Accepted', ApplicationStatus.accepted),
          _buildFilterChip('Rejected', ApplicationStatus.rejected),
          _buildFilterChip('Shortlisted', ApplicationStatus.shortlisted),
          _buildFilterChip('Completed', ApplicationStatus.completed),
          _buildFilterChip('Withdrawn', ApplicationStatus.withdrawn),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, ApplicationStatus? status) {
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
              Icon(Icons.description_outlined, size: 64, color: AppColors.textSecondary),
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
        final application = applications[index];
        return _buildApplicationCard(application);
      },
    );
  }

  Widget _buildApplicationCard(ApplicationModel application) {
    final dutyProvider = context.read<DutyProvider>();

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
          Text(
            application.role,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
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
              Icon(Icons.calendar_today, color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 4),
              Text(
                '${application.appliedAt.day}/${application.appliedAt.month}/${application.appliedAt.year}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(application.status).withValues(alpha: 0.2),
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
              if (application.status == ApplicationStatus.pending || application.status == ApplicationStatus.shortlisted)
                ElevatedButton(
                  onPressed: () async {
                    await dutyProvider.withdrawApplication(application.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Application withdrawn successfully'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Withdraw'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return AppColors.warning;
      case ApplicationStatus.accepted:
        return AppColors.success;
      case ApplicationStatus.rejected:
        return AppColors.error;
      case ApplicationStatus.shortlisted:
        return AppColors.info;
      case ApplicationStatus.completed:
        return AppColors.accent;
      case ApplicationStatus.withdrawn:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.shortlisted:
        return 'Shortlisted';
      case ApplicationStatus.completed:
        return 'Completed';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
    }
  }
}
