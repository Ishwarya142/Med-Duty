class OnboardingData {
  final String title;
  final String description;
  final String icon;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
  });
}

final List<OnboardingData> onboardingPages = [
  OnboardingData(
    title: "Find Nearby Duties",
    description:
        "Discover nearby clinics and hospitals looking for doctors and nurses.",
    icon: "🏥",
  ),
  OnboardingData(
    title: "Connect with Doctors",
    description:
        "Build your professional medical network across India.",
    icon: "👨‍⚕️",
  ),
  OnboardingData(
    title: "Grow Your Career",
    description:
        "Temporary duties, specialists and permanent hiring in one place.",
    icon: "🚑",
  ),
];