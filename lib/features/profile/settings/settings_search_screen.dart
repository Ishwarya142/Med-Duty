import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import 'settings_search_catalog.dart';

class SettingsSearchScreen extends StatefulWidget {
  const SettingsSearchScreen({
    super.key,
    required this.items,
  });

  final List<SettingsSearchItem> items;

  @override
  State<SettingsSearchScreen> createState() => _SettingsSearchScreenState();
}

class _SettingsSearchScreenState extends State<SettingsSearchScreen> {
  final _queryCtrl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clearQuery() {
    _queryCtrl.clear();
    setState(() {});
    _focusNode.requestFocus();
  }

  void _openItem(SettingsSearchItem item) {
    Navigator.pop(context);
    item.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final iconBg = isDark ? AppColors.darkSurfaceVariant : AppColors.lightSecondary;

    final query = _queryCtrl.text;
    final results = filterSettingsSearchItems(widget.items, query);
    final showEmpty = query.trim().isEmpty;
    final commons = commonSettingsSearchItems(widget.items, l10n);

    return Scaffold(
      backgroundColor: bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: text, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _queryCtrl,
                      focusNode: _focusNode,
                      autofocus: true,
                      style: TextStyle(color: text, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Search settings...',
                        hintStyle: TextStyle(color: sub.withValues(alpha: 0.8)),
                        prefixIcon: Icon(Icons.search_rounded, color: sub, size: 22),
                        suffixIcon: query.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.close_rounded, color: sub, size: 20),
                                onPressed: _clearQuery,
                              )
                            : null,
                        filled: true,
                        fillColor: surface,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: showEmpty
                  ? _EmptySearchState(
                      text: text,
                      sub: sub,
                      surface: surface,
                      border: border,
                      iconBg: iconBg,
                      commons: commons,
                      onTap: _openItem,
                    )
                  : results.isEmpty
                      ? _NoResultsState(text: text, sub: sub)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                          itemCount: results.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            return _SearchResultTile(
                              item: results[index],
                              text: text,
                              sub: sub,
                              surface: surface,
                              border: border,
                              iconBg: iconBg,
                              onTap: () => _openItem(results[index]),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({
    required this.text,
    required this.sub,
    required this.surface,
    required this.border,
    required this.iconBg,
    required this.commons,
    required this.onTap,
  });

  final Color text;
  final Color sub;
  final Color surface;
  final Color border;
  final Color iconBg;
  final List<SettingsSearchItem> commons;
  final void Function(SettingsSearchItem item) onTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        Text('Search Settings', style: TextStyle(color: text, fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(
          'Find account, privacy, notification, security and other settings.',
          style: TextStyle(color: sub, height: 1.45, fontSize: 14.5),
        ),
        if (commons.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Commonly used', style: TextStyle(color: sub, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1)),
          const SizedBox(height: 10),
          ...commons.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SearchResultTile(
                item: item,
                text: text,
                sub: sub,
                surface: surface,
                border: border,
                iconBg: iconBg,
                onTap: () => onTap(item),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _NoResultsState extends StatelessWidget {
  const _NoResultsState({required this.text, required this.sub});

  final Color text;
  final Color sub;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 56, color: sub.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('No settings found', style: TextStyle(color: text, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              'Try searching for another setting.',
              textAlign: TextAlign.center,
              style: TextStyle(color: sub, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.item,
    required this.text,
    required this.sub,
    required this.surface,
    required this.border,
    required this.iconBg,
    required this.onTap,
  });

  final SettingsSearchItem item;
  final Color text;
  final Color sub;
  final Color surface;
  final Color border;
  final Color iconBg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border.withValues(alpha: 0.7)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: AppColors.accent, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(color: text, fontWeight: FontWeight.w700, fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.section,
                      style: TextStyle(color: sub, fontSize: 12.5, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: sub, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
