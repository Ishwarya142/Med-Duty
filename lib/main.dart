import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

import 'app/app.dart';
import 'core/constants/supabase_constants.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/duty_provider.dart';
import 'providers/job_provider.dart';
import 'providers/community_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/location_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/saved_provider.dart';
import 'providers/activity_provider.dart';
import 'providers/settings_preferences_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('Starting MedDuty app...');

  try {
    debugPrint('Initializing Supabase...');
    await Supabase.initialize(
      url: SupabaseConstants.supabaseUrl,
      anonKey: SupabaseConstants.supabaseAnonKey,
    );
    debugPrint('Supabase initialized successfully');

    // Global error handlers
    FlutterError.onError = (details) {
      debugPrint('Flutter Error: ${details.exception}');
      debugPrintStack(stackTrace: details.stack);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('Async Error: $error');
      debugPrintStack(stackTrace: stack);
      return true;
    };

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => DutyProvider()),
          ChangeNotifierProvider(create: (_) => JobProvider()),
          ChangeNotifierProvider(create: (_) => CommunityProvider()),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
          ChangeNotifierProvider(create: (_) => LocationProvider()),
          ChangeNotifierProvider(create: (_) => WalletProvider()),
          ChangeNotifierProvider(create: (_) => SavedProvider()),
          ChangeNotifierProvider(create: (_) => ActivityProvider()),
          ChangeNotifierProvider(
            create: (_) => SettingsPreferencesProvider()..load(),
          ),
        ],
        child: const MedDutyApp(),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('Supabase initialization failed: $e');
    debugPrintStack(stackTrace: stackTrace);
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Supabase Configuration Error',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error details:\n$e',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.red),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Steps to fix:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Go to https://supabase.com/dashboard\n'
                      '2. Open your project\n'
                      '3. Check Settings > API for correct URL & keys\n'
                      '4. Ensure tables and RLS policies are configured',
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
