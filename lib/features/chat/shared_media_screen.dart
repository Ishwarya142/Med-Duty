import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _cTeal = Color(0xFF0F766E);
const _cBlue = Color(0xFF2563EB);
const _cAmber = Color(0xFFF59E0B);
const _cRed = Color(0xFFEF4444);
const _cPurple = Color(0xFF7C3AED);

class SharedMediaItem {
  final String id;
  final String type;
  final String text;
  final String time;
  final bool isMe;
  final String? fileName;
  final String? fileSize;
  final String? fileExt;
  final String? filePath;
  final String? imageCaption;
  final Map<String, dynamic>? extraData;

  const SharedMediaItem({
    required this.id,
    required this.type,
    required this.text,
    required this.time,
    required this.isMe,
    this.fileName,
    this.fileSize,
    this.fileExt,
    this.filePath,
    this.imageCaption,
    this.extraData,
  });
}

class SharedMediaScreen extends StatefulWidget {
  final List<SharedMediaItem> items;
  final int initialTab;
  final String title;

  const SharedMediaScreen({
    super.key,
    required this.items,
    this.initialTab = 0,
    this.title = 'Media, links & documents',
  });

  @override
  State<SharedMediaScreen> createState() => _SharedMediaScreenState();
}

class _SharedMediaScreenState extends State<SharedMediaScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  List<SharedMediaItem> get _photos =>
      widget.items.where((m) => m.type == 'image').toList();

  List<SharedMediaItem> get _videos =>
      widget.items.where((m) => m.type == 'video').toList();

  List<SharedMediaItem> get _documents => widget.items
      .where(
        (m) =>
            m.type == 'pdf' ||
            (m.fileExt != null && m.fileExt!.isNotEmpty && m.type != 'image'),
      )
      .toList();

  List<SharedMediaItem> get _links =>
      widget.items.where((m) => m.type == 'link').toList();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 3),
    );
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, {Color bg = _cTeal}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE8EDF2);
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: tx,
        title: Text(
          widget.title,
          style: TextStyle(
            color: tx,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: border)),
            ),
            child: TabBar(
              controller: _tabCtrl,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: _cTeal,
              unselectedLabelColor: sub,
              indicatorColor: _cTeal,
              indicatorWeight: 2.5,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(text: 'Photos (${_photos.length})'),
                Tab(text: 'Videos (${_videos.length})'),
                Tab(text: 'Documents (${_documents.length})'),
                Tab(text: 'Links (${_links.length})'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildPhotoGrid(_photos, tx, sub, card, border),
          _buildVideoGrid(_videos, tx, sub, card, border),
          _buildDocumentList(_documents, tx, sub, card, border),
          _buildLinkList(_links, tx, sub, card, border),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(
    List<SharedMediaItem> items,
    Color tx,
    Color sub,
    Color card,
    Color border,
  ) {
    if (items.isEmpty) return _emptyState(Icons.photo_library_rounded, 'No photos shared yet', sub);
    final cols = MediaQuery.of(context).size.width > 600 ? 4 : 3;
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _photoTile(items[i], tx, sub, card, border),
    );
  }

  Widget _photoTile(
    SharedMediaItem item,
    Color tx,
    Color sub,
    Color card,
    Color border,
  ) {
    final colors = [_cTeal, _cBlue, _cPurple, _cAmber];
    final bgColor = colors[item.id.hashCode.abs() % colors.length];
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          HapticFeedback.lightImpact();
          _snack('Opening ${item.fileName ?? item.text}');
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                bgColor.withValues(alpha: 0.85),
                bgColor.withValues(alpha: 0.55),
              ],
            ),
            border: Border.all(color: border.withValues(alpha: 0.5)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: Icon(
                  Icons.image_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 36,
                ),
              ),
              Positioned(
                left: 6,
                right: 6,
                bottom: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.fileName ?? item.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (item.imageCaption != null)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.closed_caption_rounded, color: Colors.white, size: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoGrid(
    List<SharedMediaItem> items,
    Color tx,
    Color sub,
    Color card,
    Color border,
  ) {
    if (items.isEmpty) return _emptyState(Icons.videocam_rounded, 'No videos shared yet', sub);
    final cols = MediaQuery.of(context).size.width > 600 ? 3 : 2;
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 16 / 11,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _videoTile(items[i], tx, sub, card, border),
    );
  }

  Widget _videoTile(
    SharedMediaItem item,
    Color tx,
    Color sub,
    Color card,
    Color border,
  ) {
    final duration = item.extraData?['videoDuration'] as String? ?? '';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          HapticFeedback.lightImpact();
          _snack('Playing ${item.fileName ?? item.text}');
        },
        child: Ink(
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: _cRed.withValues(alpha: 0.12),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.play_circle_filled_rounded, color: _cRed, size: 44),
                      if (duration.isNotEmpty)
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              duration,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.fileName ?? item.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: tx,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.fileSize ?? ''} • ${item.time}',
                      style: TextStyle(color: sub, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentList(
    List<SharedMediaItem> items,
    Color tx,
    Color sub,
    Color card,
    Color border,
  ) {
    if (items.isEmpty) {
      return _emptyState(Icons.picture_as_pdf_rounded, 'No documents shared yet', sub);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _documentTile(items[i], tx, sub, card, border),
    );
  }

  Widget _documentTile(
    SharedMediaItem item,
    Color tx,
    Color sub,
    Color card,
    Color border,
  ) {
    final ext = (item.fileExt ?? 'PDF').toUpperCase();
    final extColor = ext == 'PDF'
        ? _cRed
        : ext.contains('DOC')
            ? _cBlue
            : _cAmber;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          HapticFeedback.lightImpact();
          _snack('Opening ${item.fileName ?? item.text}');
        },
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: extColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    ext.length > 4 ? ext.substring(0, 3) : ext,
                    style: TextStyle(
                      color: extColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.fileName ?? item.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: tx,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${item.fileSize ?? ''} • ${item.time}${item.isMe ? ' • You' : ''}',
                      style: TextStyle(color: sub, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              Icon(Icons.download_rounded, color: _cTeal, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkList(
    List<SharedMediaItem> items,
    Color tx,
    Color sub,
    Color card,
    Color border,
  ) {
    if (items.isEmpty) return _emptyState(Icons.link_rounded, 'No links shared yet', sub);
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _linkTile(items[i], tx, sub, card, border),
    );
  }

  Widget _linkTile(
    SharedMediaItem item,
    Color tx,
    Color sub,
    Color card,
    Color border,
  ) {
    final title = item.extraData?['linkTitle'] as String? ?? item.text;
    final host = item.extraData?['linkHost'] as String? ?? Uri.tryParse(item.text)?.host ?? '';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          HapticFeedback.lightImpact();
          _snack('Opening $host', bg: _cBlue);
        },
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _cBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.link_rounded, color: _cBlue, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: tx,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      host,
                      style: const TextStyle(
                        color: _cBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.time}${item.isMe ? ' • You' : ''}',
                      style: TextStyle(color: sub, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Icon(Icons.open_in_new_rounded, color: sub.withValues(alpha: 0.7), size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(IconData icon, String message, Color sub) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: sub.withValues(alpha: 0.6)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: sub,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
