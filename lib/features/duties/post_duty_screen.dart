import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/duty_model.dart';

class PostDutyScreen extends StatefulWidget {
  const PostDutyScreen({super.key});

  @override
  State<PostDutyScreen> createState() => _PostDutyScreenState();
}

class _PostDutyScreenState extends State<PostDutyScreen> {
  final _roleCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  DutyPriority _priority = DutyPriority.normal;
  String? _selectedSpecialty;

  static const _specialties = [
    'General Surgery',
    'General Physician',
    'Cardiology',
    'Emergency Medicine',
    'Pediatrics',
    'Anesthesiology',
    'Orthopedic Surgery',
    'Critical Care / ICU',
    'Dermatology',
    'Radiology',
  ];

  @override
  void dispose() {
    _roleCtrl.dispose();
    _salaryCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_roleCtrl.text.trim().isEmpty) {
      _showError('Please enter the duty role.');
      return;
    }
    if (_priority == DutyPriority.emergency &&
        (_selectedSpecialty == null || _selectedSpecialty!.trim().isEmpty)) {
      _showError('Emergency duties require a specialty.');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _priority == DutyPriority.emergency
              ? 'Emergency duty posted with $_selectedSpecialty requirement.'
              : 'Duty posted successfully.',
        ),
      ),
    );
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEmergency = _priority == DutyPriority.emergency;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Post a Duty')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create Duty Posting', style: AppTextStyles.heading),
            const SizedBox(height: 8),
            Text(
              'Fill in the details to find medical staff.',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 28),
            Text('Duty Priority', style: AppTextStyles.label),
            const SizedBox(height: 8),
            SegmentedButton<DutyPriority>(
              segments: const [
                ButtonSegment(
                  value: DutyPriority.normal,
                  label: Text('Normal'),
                ),
                ButtonSegment(
                  value: DutyPriority.emergency,
                  label: Text('🚨 Emergency'),
                ),
              ],
              selected: {_priority},
              onSelectionChanged: (value) {
                setState(() => _priority = value.first);
              },
            ),
            if (isEmergency) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
                ),
                child: const Text(
                  'Emergency duties are shown to nearby doctors for 24 hours '
                  'and require a specialty.',
                  style: TextStyle(color: Color(0xFFB91C1C), fontSize: 13),
                ),
              ),
            ],
            const SizedBox(height: 20),
            TextField(
              controller: _roleCtrl,
              decoration: const InputDecoration(
                labelText: 'Role / Position',
                hintText: 'e.g. Emergency Surgery',
                prefixIcon: Icon(Icons.medical_services_outlined),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedSpecialty,
              decoration: InputDecoration(
                labelText: isEmergency ? 'Specialty Required *' : 'Specialty',
                prefixIcon: const Icon(Icons.local_hospital_outlined),
              ),
              items: _specialties
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedSpecialty = value),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _salaryCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Salary / Day',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submit,
                child: Text(isEmergency ? 'Post Emergency Duty' : 'Post Duty'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
