// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../providers/location_provider.dart';
import '../duties/widgets/location_selector_sheet.dart';
import 'onboarding_data.dart';

const _cTeal   = Color(0xFF0F766E);
const _cBlue   = Color(0xFF2563EB);
const _cRed    = Color(0xFFEF4444);
const _cGreen  = Color(0xFF16A34A);

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNext() {
    HapticFeedback.lightImpact();
    if (_currentPage < onboardingPages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _onComplete();
    }
  }

  void _onBack() {
    HapticFeedback.lightImpact();
    if (_currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _onComplete() {
    HapticFeedback.mediumImpact();
    _showLocationPromptSheet(context);
  }

  void _navigateToNextRoute() {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.roleSelection,
    );
  }

  // ─── LOCATION DISCOVERY PROMPT MODAL ────────────────────────────────────────
  void _showLocationPromptSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (bCtx) {
        const card = Color(0xFF1A1A1A);
        const tx = Colors.white;
        final sub = Colors.white.withOpacity(0.5);
        const border = Color(0xFF262626);

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: BoxDecoration(
            color: card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: sub.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              // Location Icon Graphic
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _cTeal.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: _cTeal.withValues(alpha: 0.25), width: 1.5),
                ),
                child: const Center(
                  child: Icon(
                    Icons.location_on_rounded,
                    color: _cTeal,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Discover Opportunities Around You',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: tx,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'MedDuty uses your location to show nearby relieving duties, emergency cases, and hospital vacancies within your preferred radius.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: sub,
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              // Button 1: Enable Location
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    Navigator.pop(bCtx);
                    final loc = context.read<LocationProvider>();
                    await loc.tryUseCurrentLocation();
                    if (context.mounted) _navigateToNextRoute();
                  },
                  icon: const Icon(Icons.my_location_rounded, size: 18),
                  label: const Text(
                    'Enable Location',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Button 2: Choose Location Manually
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    Navigator.pop(bCtx);
                    await showLocationSelectorSheet(context);
                    if (context.mounted) _navigateToNextRoute();
                  },
                  icon: const Icon(Icons.edit_location_alt_rounded, size: 18),
                  label: const Text(
                    'Choose Location Manually',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Button 3: Not now
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(bCtx);
                  _navigateToNextRoute();
                },
                child: Text(
                  'Not now',
                  style: TextStyle(
                    color: sub,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg     = Color(0xFF0D0D0D);
    const card   = Color(0xFF1A1A1A);
    const border = Color(0xFF262626);
    const tx     = Colors.white;
    final sub    = Colors.white.withOpacity(0.5);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ─── TOP BAR (Back & Skip) ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedOpacity(
                    opacity: _currentPage > 0 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: tx),
                      onPressed: _currentPage > 0 ? _onBack : null,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  TextButton(
                    onPressed: _onComplete,
                    style: TextButton.styleFrom(
                      foregroundColor: sub,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: sub,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ─── PAGE VIEW ───────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: onboardingPages.length,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = onboardingPages[index];
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        // Visual Graphic Frame
                        _buildVisualFrame(page.category, card, border, tx, sub, true),
                        const SizedBox(height: 28),
                        // Badge Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: page.category == 'emergency'
                                ? _cRed.withValues(alpha: 0.1)
                                : _cTeal.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: page.category == 'emergency'
                                  ? _cRed.withValues(alpha: 0.25)
                                  : _cTeal.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            page.badge,
                            style: TextStyle(
                              color: page.category == 'emergency' ? _cRed : _cTeal,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Title Heading
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: tx,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Description Subtitle
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: sub,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
            // ─── BOTTOM CONTROLS (Indicator & Action Button) ─────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Smooth Pill Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingPages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 26 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? _cTeal
                              : sub.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Primary Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == onboardingPages.length - 1
                                ? 'Get Started'
                                : 'Next',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentPage == onboardingPages.length - 1
                                ? Icons.arrow_forward_rounded
                                : Icons.chevron_right_rounded,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── CUSTOM VISUAL ILLUSTRATIONS ───────────────────────────────────────────
  Widget _buildVisualFrame(
    String category,
    Color card,
    Color border,
    Color tx,
    Color sub,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      height: 230,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B)
            : const Color(0xFFF1F5F9).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (category == 'welcome') _buildWelcomeVisual(card, border, tx, sub, isDark),
          if (category == 'duties') _buildDutiesVisual(card, border, tx, sub, isDark),
          if (category == 'jobs') _buildJobsVisual(card, border, tx, sub, isDark),
          if (category == 'community') _buildCommunityVisual(card, border, tx, sub, isDark),
          if (category == 'emergency') _buildEmergencyVisual(card, border, tx, sub, isDark),
        ],
      ),
    );
  }

  // 1. Welcome Visual
  Widget _buildWelcomeVisual(Color card, Color border, Color tx, Color sub, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: _cTeal.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: _cTeal.withValues(alpha: 0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: _cTeal.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.favorite_rounded, color: _cTeal, size: 36),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              _visualPill(Icons.medical_services_rounded, 'Verified Doctors', _cTeal, card, border),
              _visualPill(Icons.local_hospital_rounded, 'Hospitals', _cBlue, card, border),
              _visualPill(Icons.health_and_safety_rounded, 'Nurses', _cGreen, card, border),
            ],
          ),
        ),
      ],
    );
  }

  // 2. Nearby Duties Visual
  Widget _buildDutiesVisual(Color card, Color border, Color tx, Color sub, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _cTeal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.local_hospital_rounded, color: _cTeal, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Apollo Hospital • ICU Shift',
                      style: TextStyle(color: tx, fontSize: 12.5, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '₹3,500 / shift • 3.2 km away',
                      style: TextStyle(color: sub, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _cGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(color: _cGreen, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _cBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.emergency_rounded, color: _cBlue, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Max Healthcare • ER Night Shift',
                      style: TextStyle(color: tx, fontSize: 12.5, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '₹4,200 / shift • 5.1 km away',
                      style: TextStyle(color: sub, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: _cTeal, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  // 3. Medical Jobs Visual
  Widget _buildJobsVisual(Color card, Color border, Color tx, Color sub, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _cBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.work_rounded, color: _cBlue, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Fortis Heart Institute',
                            style: TextStyle(color: sub, fontSize: 11.5, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded, color: _cBlue, size: 12),
                      ],
                    ),
                    Text(
                      'Consultant Cardiologist',
                      style: TextStyle(color: tx, fontSize: 14, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _tagChip('Full-Time', _cBlue),
              _tagChip('Cardiology', _cTeal),
              _tagChip('Delhi NCR', sub),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '₹1.8L - ₹2.4L / mo',
                  style: TextStyle(color: tx, fontSize: 12.5, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _cBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Apply Now',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4. Professional Community Visual
  Widget _buildCommunityVisual(Color card, Color border, Color tx, Color sub, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: _cTeal,
                child: const Text(
                  'NV',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Dr. Neha Verma',
                          style: TextStyle(color: tx, fontSize: 12.5, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded, color: _cBlue, size: 12),
                      ],
                    ),
                    Text(
                      'Dermatologist • Max Hospital',
                      style: TextStyle(color: sub, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Completed 6-month clinical residency on advanced laser protocols. Sharing key insights with the network! 🩺',
            style: TextStyle(color: tx, fontSize: 12, height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.favorite_rounded, color: _cRed, size: 14),
              const SizedBox(width: 3),
              Text('128', style: TextStyle(color: sub, fontSize: 10.5)),
              const SizedBox(width: 12),
              Icon(Icons.chat_bubble_outline_rounded, color: sub, size: 14),
              const SizedBox(width: 3),
              Text('24', style: TextStyle(color: sub, fontSize: 10.5)),
              const SizedBox(width: 12),
              Icon(Icons.repeat_rounded, color: sub, size: 14),
              const SizedBox(width: 3),
              Text('16', style: TextStyle(color: sub, fontSize: 10.5)),
            ],
          ),
        ],
      ),
    );
  }

  // 5. Emergency Opportunities Visual
  Widget _buildEmergencyVisual(Color card, Color border, Color tx, Color sub, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D1515) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cRed.withValues(alpha: 0.35), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _cRed,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'URGENT RELIEF',
                      style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '1.8 km away',
                style: TextStyle(color: _cRed, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Specialist Anesthetist Needed',
            style: TextStyle(color: tx, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            'City Care Trauma Center • Immediate Emergency Shift',
            style: TextStyle(color: sub, fontSize: 11.5),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹6,000 / shift',
                style: TextStyle(color: _cRed, fontSize: 13, fontWeight: FontWeight.w800),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _cRed,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Accept Duty',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _visualPill(IconData icon, String label, Color color, Color card, Color border) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _tagChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w600),
      ),
    );
  }
}
