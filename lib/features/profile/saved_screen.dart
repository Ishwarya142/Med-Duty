import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/saved_provider.dart';
import '../jobs/job_helpers.dart';
import '../../models/saved_item_model.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavedProvider>().loadSavedItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final savedProvider = context.watch<SavedProvider>();

    final tabs = ['All', 'Duties', 'Jobs', 'Hospitals', 'Posts', 'Searches'];

    List<SavedItemModel> filteredItems = [];
    switch (_selectedIndex) {
      case 0:
        filteredItems = savedProvider.savedItems;
        break;
      case 1:
        filteredItems = savedProvider.savedItems
            .where((item) => item.type == SavedItemType.duty)
            .toList();
        break;
      case 2:
        filteredItems = savedProvider.savedItems
            .where((item) => item.type == SavedItemType.job)
            .toList();
        break;
      case 3:
        filteredItems = savedProvider.savedItems
            .where((item) => item.type == SavedItemType.hospital)
            .toList();
        break;
      case 4:
        filteredItems = savedProvider.savedItems
            .where((item) => item.type == SavedItemType.post)
            .toList();
        break;
      case 5:
        filteredItems = savedProvider.savedItems
            .where((item) => item.type == SavedItemType.search)
            .toList();
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Saved'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        foregroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          // Tabs
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(tabs[index]),
                    selected: _selectedIndex == index,
                    onSelected: (selected) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      color: _selectedIndex == index
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Content
          Expanded(child: _buildContent(filteredItems, savedProvider)),
        ],
      ),
    );
  }

  Widget _buildContent(List<SavedItemModel> items, SavedProvider provider) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bookmark_border,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'No saved items yet',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildSavedItemCard(item, provider);
      },
    );
  }

  Widget _buildSavedItemCard(SavedItemModel item, SavedProvider provider) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: item.type == SavedItemType.job
          ? () => openJobDetailsById(context, item.itemId)
          : null,
      child: Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getItemIcon(item.type),
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.subtitle != null)
                  Text(
                    item.subtitle!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.bookmark, color: AppColors.accent),
            onPressed: () async {
              await provider.removeSavedItem(item.id);
            },
          ),
        ],
      ),
    ),
    );
  }

  IconData _getItemIcon(SavedItemType type) {
    switch (type) {
      case SavedItemType.duty:
        return Icons.schedule_rounded;
      case SavedItemType.job:
        return Icons.work_outline_rounded;
      case SavedItemType.hospital:
        return Icons.local_hospital;
      case SavedItemType.post:
        return Icons.article;
      case SavedItemType.search:
        return Icons.search;
      case SavedItemType.doctor:
        return Icons.person;
    }
  }
}
