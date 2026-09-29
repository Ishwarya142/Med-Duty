import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/supabase_constants.dart';
import '../core/services/google_auth_service.dart';
import '../core/services/account_service.dart';
import '../core/utils/account_status_utils.dart';

export '../core/constants/supabase_constants.dart' show SupabaseUserExtension;

enum UserRole { doctor, nurse, hospital }

String getFirebaseErrorMessage(dynamic error) {
  if (error is AuthException) {
    return error.message;
  }
  return error?.toString() ?? 'An error occurred';
}

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? _user;
  UserRole? _userRole;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _rememberMe = false;

  User? get user => _user;
  UserRole? get userRole => _userRole;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  bool get isGoogleLoading => _isGoogleLoading;
  bool get rememberMe => _rememberMe;
  bool get isAuthenticated => _user != null;

  bool get isAccountDeactivated => AccountStatusUtils.isDeactivated(_userData);

  bool get isGoogleAuthUser =>
      _user?.appMetadata['provider'] == 'google' ||
      (_user?.identities?.any((i) => i.provider == 'google') ?? false);

  bool get isPasswordAuthUser =>
      _user?.appMetadata['provider'] == 'email' ||
      (_user?.identities?.any((i) => i.provider == 'email') ?? false);

  dynamic _pendingDeletionCredential;
  bool _deletionReauthConfirmed = false;

  /// True when the user is signed in but has not chosen a professional role.
  bool get needsRoleSelection {
    if (_user == null) return false;
    if (_userData == null) return true;
    final role = _userData!['role'];
    if (role == null) return true;
    if (role is String && role.trim().isEmpty) return true;
    return false;
  }

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadRememberMe();
    _user = _supabase.auth.currentUser;
    if (_user != null) {
      await _loadUserData();
    }
    _supabase.auth.onAuthStateChange.listen((data) {
      _onAuthStateChanged(data.session?.user);
    });
  }

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    _rememberMe = prefs.getBool('rememberMe') ?? false;
    notifyListeners();
  }

  Future<void> _onAuthStateChanged(User? supabaseUser) async {
    _user = supabaseUser;
    if (_user != null) {
      await _loadUserData();
    } else {
      _userData = null;
      _userRole = null;
    }
    notifyListeners();
  }

  Future<void> _loadUserData() async {
    if (_user == null) return;
    try {
      final res = await _supabase
          .from(SupabaseConstants.users)
          .select()
          .eq('uid', _user!.id)
          .maybeSingle();
      if (res != null) {
        _userData = Map<String, dynamic>.from(res);
        final roleStr = _userData!['role']?.toString().trim() ?? '';
        if (roleStr.isEmpty) {
          _userRole = null;
        } else {
          _userRole = UserRole.values.firstWhere(
            (e) => e.name == roleStr,
            orElse: () => UserRole.doctor,
          );
        }
      } else {
        _userData = null;
        _userRole = null;
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  void setGoogleLoading(bool value) {
    _isGoogleLoading = value;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> setRememberMe(bool value) async {
    _rememberMe = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', value);
    notifyListeners();
  }

  Future<AuthResponse?> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    setLoading(true);
    try {
      debugPrint('Attempting to register user with email: $email');
      final res = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'name': name,
          'role': role.name,
        },
      );
      final registeredUser = res.user;
      debugPrint('User registered: ${registeredUser?.id}');

      if (registeredUser != null) {
        final profileData = {
          'uid': registeredUser.id,
          'name': name,
          'email': email.trim(),
          'role': role.name,
          'createdAt': DateTime.now().toIso8601String(),
          'profilePhoto': '',
          'coverPhoto': '',
          'phone': '',
          'bio': '',
          'qualification': '',
          'experience': 0,
          'specialization': '',
          'hospitalAffiliation': '',
          'certificates': [],
          'rating': 0.0,
          'reviews': [],
          'location': null,
          'availability': true,
          'joinedDate': DateTime.now().toIso8601String(),
          'accountStatus': 'active',
          'profileVisible': true,
          'isDiscoverable': true,
        };
        await _supabase.from(SupabaseConstants.users).upsert(profileData);
        debugPrint('User profile saved to Supabase users table');
      }

      return res;
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<AuthResponse?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    setLoading(true);
    try {
      debugPrint('Attempting to login user with email: $email');
      final res = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      debugPrint('Login successful: ${res.user?.id}');
      return res;
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email.trim());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await GoogleAuthService.signOut();
      await _supabase.auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      if (!_rememberMe) {
        await prefs.clear();
      }
      _user = null;
      _userData = null;
      _userRole = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> signInWithGoogle() async {
    setGoogleLoading(true);
    try {
      debugPrint('Starting Google sign-in...');
      final user = await GoogleAuthService.signIn();
      if (user == null) {
        debugPrint('Google sign-in cancelled or redirect started');
        return null;
      }

      try {
        await _ensureGoogleUserProfile(user);
      } catch (e) {
        debugPrint('Profile setup after Google sign-in failed: $e');
      }
      await _loadUserData();
      debugPrint('Google sign-in successful: ${user.id}');
      return user;
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      rethrow;
    } finally {
      setGoogleLoading(false);
    }
  }

  Future<void> _ensureGoogleUserProfile(User user) async {
    final existing = await _supabase
        .from(SupabaseConstants.users)
        .select('uid')
        .eq('uid', user.id)
        .maybeSingle();
    if (existing != null) return;

    final displayName = user.userMetadata?['full_name'] ??
        user.userMetadata?['name'] ??
        '';
    final email = user.email ?? '';
    final photoUrl = user.userMetadata?['avatar_url'] ??
        user.userMetadata?['picture'] ??
        '';

    await _supabase.from(SupabaseConstants.users).upsert({
      'uid': user.id,
      'name': displayName,
      'email': email,
      'role': '',
      'authProvider': 'google',
      'createdAt': DateTime.now().toIso8601String(),
      'profilePhoto': photoUrl,
      'coverPhoto': '',
      'phone': '',
      'bio': '',
      'qualification': '',
      'experience': 0,
      'specialization': '',
      'hospitalAffiliation': '',
      'certificates': [],
      'rating': 0.0,
      'reviews': [],
      'location': null,
      'availability': true,
      'joinedDate': DateTime.now().toIso8601String(),
      'accountStatus': 'active',
      'profileVisible': true,
      'isDiscoverable': true,
    });
    debugPrint('Created MedDuty profile for new Google user: ${user.id}');
  }

  Future<void> completeGoogleRegistration(UserRole role) async {
    if (_user == null) return;
    setLoading(true);
    try {
      await _supabase.from(SupabaseConstants.users).update({
        'role': role.name,
        'updatedAt': DateTime.now().toIso8601String(),
      }).eq('uid', _user!.id);
      await _loadUserData();
      notifyListeners();
    } finally {
      setLoading(false);
    }
  }

  Future<void> reloadUser() async {
    final currentUser = _supabase.auth.currentUser;
    _user = currentUser;
    await _loadUserData();
    notifyListeners();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (_user == null) {
        throw Exception('No user is signed in.');
      }
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deactivateAccount() async {
    if (_user == null) return;
    setLoading(true);
    try {
      await AccountService.instance.deactivateAccount(_user!.id);
      await _loadUserData();
      await logout();
    } finally {
      setLoading(false);
    }
  }

  Future<void> reactivateAccount() async {
    if (_user == null) return;
    setLoading(true);
    try {
      await AccountService.instance.reactivateAccount(_user!.id);
      await _loadUserData();
      notifyListeners();
    } finally {
      setLoading(false);
    }
  }

  Future<void> reauthenticateForDeletion({required String password}) async {
    if (_user == null) throw AccountDeletionAuthException();
    try {
      if (_user!.email == null || password.isEmpty) {
        throw AccountDeletionAuthException();
      }
      await _supabase.auth.signInWithPassword(
        email: _user!.email!,
        password: password,
      );
      _deletionReauthConfirmed = true;
    } catch (e) {
      throw AccountDeletionAuthException();
    }
  }

  Future<void> reauthenticateForDeletionWithGoogle() async {
    if (_user == null) throw AccountDeletionAuthException();
    try {
      final user = await GoogleAuthService.reauthenticate();
      if (user != null) {
        _deletionReauthConfirmed = true;
      } else {
        throw AccountDeletionAuthException();
      }
    } catch (e) {
      throw AccountDeletionAuthException();
    }
  }

  Future<void> permanentlyDeleteAccount() async {
    if (_user == null) return;
    if (!_deletionReauthConfirmed) {
      throw AccountDeletionAuthException('Please confirm your identity before deleting your account.');
    }

    setLoading(true);
    try {
      await AccountService.instance.permanentlyDeleteAccount(
        user: _user!,
        credential: _pendingDeletionCredential,
        skipReauth: true,
      );
      _pendingDeletionCredential = null;
      _deletionReauthConfirmed = false;
      await _clearLocalSession();
    } catch (e) {
      _pendingDeletionCredential = null;
      _deletionReauthConfirmed = false;
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> _clearLocalSession() async {
    try {
      await GoogleAuthService.signOut();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _user = null;
    _userData = null;
    _userRole = null;
    _pendingDeletionCredential = null;
    _deletionReauthConfirmed = false;
    notifyListeners();
  }
}
