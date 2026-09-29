import 'package:flutter/material.dart';

/// Categories for healthcare professional posts.
enum ProfessionalPostCategory {
  clinicalExperience,
  dutyExperience,
  workshopConference,
  certification,
  research,
  publication,
  medicalEducation,
  careerAchievement,
  hospitalClinicExperience,
  professionalUpdate,
  poll,
  article,
  photoDocument,
}

extension ProfessionalPostCategoryX on ProfessionalPostCategory {
  String get label {
    switch (this) {
      case ProfessionalPostCategory.clinicalExperience:
        return 'Clinical Experience';
      case ProfessionalPostCategory.dutyExperience:
        return 'Duty Experience';
      case ProfessionalPostCategory.workshopConference:
        return 'Workshop / Conference';
      case ProfessionalPostCategory.certification:
        return 'Certification';
      case ProfessionalPostCategory.research:
        return 'Research';
      case ProfessionalPostCategory.publication:
        return 'Publication';
      case ProfessionalPostCategory.medicalEducation:
        return 'Medical Education';
      case ProfessionalPostCategory.careerAchievement:
        return 'Career Achievement';
      case ProfessionalPostCategory.hospitalClinicExperience:
        return 'Hospital / Clinic Experience';
      case ProfessionalPostCategory.professionalUpdate:
        return 'Professional Update';
      case ProfessionalPostCategory.poll:
        return 'Poll';
      case ProfessionalPostCategory.article:
        return 'Article';
      case ProfessionalPostCategory.photoDocument:
        return 'Photo / Document';
    }
  }

  String get firestoreValue => name;

  IconData get icon {
    switch (this) {
      case ProfessionalPostCategory.clinicalExperience:
        return Icons.local_hospital_rounded;
      case ProfessionalPostCategory.dutyExperience:
        return Icons.night_shelter_rounded;
      case ProfessionalPostCategory.workshopConference:
        return Icons.groups_outlined;
      case ProfessionalPostCategory.certification:
        return Icons.workspace_premium_rounded;
      case ProfessionalPostCategory.research:
        return Icons.science_outlined;
      case ProfessionalPostCategory.publication:
        return Icons.article_outlined;
      case ProfessionalPostCategory.medicalEducation:
        return Icons.school_outlined;
      case ProfessionalPostCategory.careerAchievement:
        return Icons.emoji_events_outlined;
      case ProfessionalPostCategory.hospitalClinicExperience:
        return Icons.business_rounded;
      case ProfessionalPostCategory.professionalUpdate:
        return Icons.campaign_outlined;
      case ProfessionalPostCategory.poll:
        return Icons.poll_outlined;
      case ProfessionalPostCategory.article:
        return Icons.article_rounded;
      case ProfessionalPostCategory.photoDocument:
        return Icons.attach_file_rounded;
    }
  }

  static ProfessionalPostCategory? fromString(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final c in ProfessionalPostCategory.values) {
      if (c.name == raw) return c;
    }
    return null;
  }
}
