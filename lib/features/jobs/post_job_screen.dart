import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/job_model.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _titleCtrl = TextEditingController();
  final _salaryMinCtrl = TextEditingController();
  final _salaryMaxCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _qualificationCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _positionsCtrl = TextEditingController(text: '1');

  String? _specialization;
  EmploymentType _employmentType = EmploymentType.fullTime;

  static const _specialties = [
    'General Medicine',
    'General Physician',
    'Cardiology',
    'Pediatrics',
    'Dermatology',
    'Orthopedic Surgery',
    'Anesthesiology',
    'Emergency Medicine',
    'Radiology',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _salaryMinCtrl.dispose();
    _salaryMaxCtrl.dispose();
    _experienceCtrl.dispose();
    _qualificationCtrl.dispose();
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    _positionsCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty ||
        _specialization == null ||
        _locationCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Job posted: ${_titleCtrl.text.trim()} (${_employmentType.name})',
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Post a Job')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Job Posting',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Job Title *',
                hintText: 'e.g. Senior Resident — General Medicine',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _specialization,
              decoration: const InputDecoration(labelText: 'Specialization *'),
              items: _specialties
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _specialization = v),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<EmploymentType>(
              initialValue: _employmentType,
              decoration: const InputDecoration(labelText: 'Employment Type'),
              items: EmploymentType.values
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(_employmentLabel(t)),
                    ),
                  )
                  .toList(),
              onChanged: (v) =>
                  setState(() => _employmentType = v ?? EmploymentType.fullTime),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _experienceCtrl,
              decoration: const InputDecoration(
                labelText: 'Experience Required',
                hintText: 'e.g. 2–5 years',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _qualificationCtrl,
              decoration: const InputDecoration(
                labelText: 'Qualification',
                hintText: 'e.g. MBBS, MD General Medicine',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _salaryMinCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Salary Min (₹/month)',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _salaryMaxCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Salary Max (₹/month)',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationCtrl,
              decoration: const InputDecoration(
                labelText: 'Location *',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Job Description',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _positionsCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of Positions',
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Post Job'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _employmentLabel(EmploymentType t) {
    switch (t) {
      case EmploymentType.fullTime:
        return 'Full-time';
      case EmploymentType.partTime:
        return 'Part-time';
      case EmploymentType.contract:
        return 'Contract';
      case EmploymentType.permanent:
        return 'Permanent';
      case EmploymentType.locum:
        return 'Locum';
      case EmploymentType.remote:
        return 'Remote';
      case EmploymentType.hybrid:
        return 'Hybrid';
      case EmploymentType.internship:
        return 'Internship';
      case EmploymentType.fellowship:
        return 'Fellowship';
      case EmploymentType.residency:
        return 'Residency';
      case EmploymentType.temporary:
        return 'Temporary';
    }
  }
}
