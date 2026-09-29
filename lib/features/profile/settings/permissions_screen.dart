import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import 'settings_ui_helpers.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _loading = true;
  final Map<String, PermissionStatus?> _statuses = {};

  static const _permissionKeys = [
    'location',
    'camera',
    'microphone',
    'photos',
    'notifications',
  ];

  Permission? _permissionFor(String key) {
    switch (key) {
      case 'location':
        return Permission.location;
      case 'camera':
        return Permission.camera;
      case 'microphone':
        return Permission.microphone;
      case 'photos':
        return Permission.photos;
      case 'notifications':
        return Permission.notification;
      default:
        return null;
    }
  }

  String _labelName(String key, AppLocalizations l10n) {
    switch (key) {
      case 'location':
        return l10n.location;
      case 'camera':
        return l10n.camera;
      case 'microphone':
        return l10n.microphone;
      case 'photos':
        return l10n.photos;
      case 'notifications':
        return l10n.notificationsPerm;
      default:
        return key;
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    for (final key in _permissionKeys) {
      final permission = _permissionFor(key);
      if (permission == null) {
        _statuses[key] = null;
        continue;
      }
      try {
        _statuses[key] = await permission.status;
      } catch (_) {
        _statuses[key] = null;
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  String _label(PermissionStatus? status, AppLocalizations l10n) {
    if (status == null) {
      return kIsWeb ? l10n.browserPermissionHint : l10n.notAllowed;
    }
    if (status.isGranted || status.isLimited) return l10n.allowed;
    return l10n.notAllowed;
  }

  Future<void> _manage(String key) async {
    final l10n = context.l10n;
    final permission = _permissionFor(key);
    if (permission == null) return;

    try {
      var status = await permission.status;
      if (status.isGranted || status.isLimited) {
        if (!kIsWeb) {
          final opened = await openAppSettings();
          if (!mounted) return;
          SettingsUi.snack(
            context,
            opened ? 'Opening app settings...' : l10n.browserPermissionHint,
          );
        } else {
          if (mounted) SettingsUi.snack(context, l10n.browserPermissionHint);
        }
      } else if (status.isPermanentlyDenied) {
        if (!kIsWeb) {
          await openAppSettings();
        } else {
          if (mounted) SettingsUi.snack(context, l10n.browserPermissionHint);
        }
      } else {
        status = await permission.request();
        if (!mounted) return;
        if (status.isGranted || status.isLimited) {
          SettingsUi.snack(context, l10n.allowed);
        } else {
          SettingsUi.snack(context, l10n.notAllowed);
        }
      }
    } catch (_) {
      if (mounted) SettingsUi.snack(context, l10n.browserPermissionHint);
    }

    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: bg,
      appBar: SettingsUi.appBar(context, l10n.permissions, text, bg),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _permissionKeys.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final key = _permissionKeys[index];
                final name = _labelName(key, l10n);
                final statusLabel = _label(_statuses[key], l10n);
                final isAllowed = statusLabel == l10n.allowed;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: TextStyle(color: text, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(
                              statusLabel,
                              style: TextStyle(
                                color: isAllowed ? AppColors.success : AppColors.warning,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => _manage(key),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          side: const BorderSide(color: AppColors.accent),
                        ),
                        child: Text(l10n.manage),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
