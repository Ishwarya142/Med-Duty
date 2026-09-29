/// Visibility for community / professional posts.
enum PostVisibility {
  public,
  followers,
  private,
}

extension PostVisibilityX on PostVisibility {
  String get label {
    switch (this) {
      case PostVisibility.public:
        return 'Public';
      case PostVisibility.followers:
        return 'Followers';
      case PostVisibility.private:
        return 'Only me';
    }
  }

  String get firestoreValue => name;

  static PostVisibility fromString(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'followers':
        return PostVisibility.followers;
      case 'private':
      case 'only_me':
        return PostVisibility.private;
      default:
        return PostVisibility.public;
    }
  }
}

/// Healthcare profile privacy settings.
enum ProfilePrivacy {
  public,
  followers,
  private,
}

extension ProfilePrivacyX on ProfilePrivacy {
  String get label {
    switch (this) {
      case ProfilePrivacy.public:
        return 'Public';
      case ProfilePrivacy.followers:
        return 'Followers Only';
      case ProfilePrivacy.private:
        return 'Private';
    }
  }

  String get description {
    switch (this) {
      case ProfilePrivacy.public:
        return 'Anyone on MedDuty can view your full professional profile and credentials.';
      case ProfilePrivacy.followers:
        return 'Only confirmed followers and colleagues can view your details and credentials.';
      case ProfilePrivacy.private:
        return 'Only you and direct healthcare employers can view your full details.';
    }
  }

  String get firestoreValue => name;

  static ProfilePrivacy fromString(String? raw, {bool defaultPublic = true}) {
    switch (raw?.toLowerCase()) {
      case 'followers':
        return ProfilePrivacy.followers;
      case 'private':
        return ProfilePrivacy.private;
      case 'public':
        return ProfilePrivacy.public;
      default:
        return defaultPublic ? ProfilePrivacy.public : ProfilePrivacy.private;
    }
  }
}
