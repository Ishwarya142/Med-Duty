import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/role_card.dart';
import 'auth_navigation_helper.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String selectedRole = '';
  bool _isSaving = false;

  bool get _googleComplete {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['googleComplete'] == true) return true;
    return false;
  }

  Future<void> _selectRole(String role, UserRole userRole) async {
    if (_isSaving) return;
    setState(() {
      selectedRole = role;
      _isSaving = true;
    });

    if (_googleComplete) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.completeGoogleRegistration(userRole);
        if (!mounted) return;
        await navigateAfterAuthentication(context, authProvider);
      } catch (e) {
        if (!mounted) return;
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save your role. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pushNamed(
      context,
      AppRoutes.register,
      arguments: role,
    );
  }

  @override
  Widget build(BuildContext context) {
    final googleComplete = _googleComplete;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(
                googleComplete ? 'Complete Your Profile' : 'Choose Your Role',
                style: AppTextStyles.display,
              ),
              const SizedBox(height: 8),
              Text(
                googleComplete
                    ? 'Select your professional role to continue using MedDuty'
                    : 'Select how you want to use MedDuty',
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: 36),
              RoleCard(
                icon: Icons.medical_services_rounded,
                title: 'Doctor',
                subtitle: 'Find and apply for duties',
                onTap: () => _selectRole('doctor', UserRole.doctor),
              ),
              const SizedBox(height: 16),
              RoleCard(
                icon: Icons.local_hospital_rounded,
                title: 'Nurse',
                subtitle: 'Find nursing duties nearby',
                onTap: () => _selectRole('nurse', UserRole.nurse),
              ),
              const SizedBox(height: 16),
              RoleCard(
                icon: Icons.business_rounded,
                title: 'Hospital',
                subtitle: 'Post and manage duties',
                onTap: () => _selectRole('hospital', UserRole.hospital),
              ),
              if (_isSaving) ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
              ],
              const Spacer(),
              if (!googleComplete)
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.body,
                        children: [
                          const TextSpan(text: 'Already have an account? '),
                          TextSpan(
                            text: 'Login',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
