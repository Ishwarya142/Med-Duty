class OnboardingData {
  final String title;
  final String description;
  final String badge;
  final String category;

  const OnboardingData({
    required this.title,
    required this.description,
    required this.badge,
    required this.category,
  });
}

final List<OnboardingData> onboardingPages = [
  const OnboardingData(
    badge: "RELIEVING DUTIES",
    category: "duties",
    title: "Find Duties Near You",
    description:
        "Discover location-based relieving duties and clinical shifts around you with upfront payouts, verified hospitals, and flexible hours.",
  ),
  const OnboardingData(
    badge: "CAREER OPPORTUNITIES",
    category: "jobs",
    title: "Find Healthcare Jobs",
    description:
        "Explore full-time, part-time, and locum career openings tailored to your medical specialty and experience level.",
  ),
  const OnboardingData(
    badge: "PROFESSIONAL NETWORK",
    category: "community",
    title: "Connect with Healthcare Professionals",
    description:
        "Share clinical experiences, discuss cases, celebrate milestones, and expand your professional medical network across India.",
  ),
];
