import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../authentication/auth_navigation_helper.dart';

class SplashController {
  static void start(BuildContext context) {
    Timer(const Duration(seconds: 3), () async {
      if (!context.mounted) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (authProvider.isAuthenticated) {
        await navigateAfterAuthentication(context, authProvider);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    });
  }
}
