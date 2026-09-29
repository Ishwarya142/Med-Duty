import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'auth_navigation_helper.dart';
import 'widgets/google_sign_in_button.dart';
import '../../core/services/google_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obscurePassword = true;
  bool _showEmailForm = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.loginWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (!mounted) return;
      await navigateAfterAuthentication(context, authProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getFirebaseErrorMessage(e)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 10),
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final result = await authProvider.signInWithGoogle();
      if (!mounted || result == null) return;
      await navigateAfterAuthentication(context, authProvider);
    } on GoogleAccountConflictException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getGoogleSignInErrorMessage(GoogleAccountConflictException())),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final message = getGoogleSignInErrorMessage(e);
      if (message.isEmpty) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    // Force dark minimalist aesthetic
    const bgColor = Color(0xFF0D0D0D); // Deep black/gray
    const textColor = Colors.white;
    final subTextColor = Colors.white.withOpacity(0.5);
    const borderColor = Color(0xFF262626);
    const cardColor = Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo & Brand
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.monitor_heart_rounded, color: Colors.black, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "MedDuty",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Title
                  const Text(
                    "Sign in to your account",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      letterSpacing: -0.8,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Google Sign-In (Styled dark)
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cardColor,
                        foregroundColor: textColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: borderColor),
                        ),
                      ),
                      onPressed: authProvider.isLoading || authProvider.isGoogleLoading
                          ? null
                          : _handleGoogleSignIn,
                      child: authProvider.isGoogleLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.g_mobiledata_rounded, size: 28, color: Colors.white),
                                const SizedBox(width: 8),
                                const Text("Login with Google", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                              ],
                            ),
                    ),
                  ),
                  
                  // Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Row(
                      children: [
                        const Expanded(child: Divider(color: borderColor)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text("OR", style: TextStyle(color: subTextColor, fontSize: 12)),
                        ),
                        const Expanded(child: Divider(color: borderColor)),
                      ],
                    ),
                  ),

                  // Email Flow
                  AnimatedCrossFade(
                    firstChild: SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => setState(() => _showEmailForm = true),
                        child: const Text("Continue with Email", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    secondChild: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: textColor, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: "Email address",
                              hintStyle: TextStyle(color: subTextColor),
                              filled: true,
                              fillColor: cardColor,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white54)),
                            ),
                            validator: (value) => (value?.trim().isEmpty ?? true) ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            style: const TextStyle(color: textColor, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: "Password",
                              hintStyle: TextStyle(color: subTextColor),
                              filled: true,
                              fillColor: cardColor,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white54)),
                              suffixIcon: IconButton(
                                icon: Icon(obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: subTextColor, size: 18),
                                onPressed: () => setState(() => obscurePassword = !obscurePassword),
                              ),
                            ),
                            validator: (value) => (value?.trim().isEmpty ?? true) ? 'Required' : null,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    child: Checkbox(
                                      value: authProvider.rememberMe,
                                      onChanged: (v) => authProvider.setRememberMe(v ?? false),
                                      fillColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.selected) ? Colors.white : Colors.transparent),
                                      checkColor: Colors.black,
                                      side: BorderSide(color: subTextColor),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text("Remember me", style: TextStyle(color: subTextColor, fontSize: 12)),
                                ],
                              ),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                                child: Text("Forgot Password?", style: TextStyle(color: subTextColor, fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: authProvider.isLoading ? null : _handleLogin,
                              child: authProvider.isLoading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                                  : const Text("Sign In", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    crossFadeState: _showEmailForm ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),

                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ", style: TextStyle(color: subTextColor, fontSize: 13)),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.register),
                        child: const Text("Register", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
