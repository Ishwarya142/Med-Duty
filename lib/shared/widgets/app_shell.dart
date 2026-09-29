import 'package:flutter/material.dart';

/// Provides a way for any descendant widget to switch the main bottom tab
/// without using Navigator.push (which would hide the bottom nav).
class AppShell extends InheritedWidget {
  const AppShell({
    super.key,
    required this.switchTab,
    required super.child,
  });

  /// Call this to switch to a primary tab index:
  /// 0=Home, 1=Duties, 2=Community, 3=Chat, 4=Profile
  final void Function(int index) switchTab;

  static AppShell? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppShell>();
  }

  static AppShell of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'No AppShell found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppShell oldWidget) => false;
}
