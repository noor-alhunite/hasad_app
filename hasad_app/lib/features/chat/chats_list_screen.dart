// قائمة المحادثات: تُصفّى عبر ChatInboxProvider.threadsFor(role).
// — مزارع: صفوف تعرض عرضاً سعرياً وحالة (قيد المراجعة / مقبول / مرفوض).
// — تاجر: آخر رسالة + تاريخ آخر عرض؛ الأيقونة تمثل المزارع.
// — مصنع: نوع عقد وهمي + موعد توريد؛ الأيقونة تمثل المزارع.
import 'package:flutter/material.dart';
import 'package:hasad_app/core/models/user_model.dart';
import 'package:hasad_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/providers/chat_inbox_provider.dart';
import '../../core/providers/user_provider.dart';
import 'chat_detail_screen.dart';
import 'chat_models.dart';
import 'chat_time_format.dart';

/// أيقونة الطرف الآخر في المحادثة (مزرعة / متجر / مصنع).
IconData _peerKindIcon(ChatPeerKind k) {
  switch (k) {
    case ChatPeerKind.farmer:
      return Icons.agriculture;
    case ChatPeerKind.trader:
      return Icons.storefront;
    case ChatPeerKind.factory:
      return Icons.factory;
  }
}

/// قائمة المحادثات — تُصفّى وتُعرض حسب [UserRole] (مزارع / تاجر / مصنع).
class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  final _searchCtrl = TextEditingController();
  bool _searchOpen = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final inbox = context.watch<ChatInboxProvider>();
    final role = context.watch<UserProvider>().currentUser?.role;
    final threads = inbox.threadsFor(role);
    final q = _searchCtrl.text.trim().toLowerCase();
    final filtered = threads.where((t) {
      if (q.isEmpty) return true;
      return t.peerName.toLowerCase().contains(q) ||
          t.lastPreview.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        title: _searchOpen
            ? TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
                decoration: const InputDecoration(
                  hintText: 'بحث في المحادثات...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
              )
            : Text(
                l10n.chatsTitle,
                style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
              ),
        actions: [
          IconButton(
            icon: Icon(_searchOpen ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _searchOpen = !_searchOpen;
                if (!_searchOpen) {
                  _searchCtrl.clear();
                }
              });
            },
          ),
        ],
      ),
      body: filtered.isEmpty
          ? const Center(
              child: Text(
                'لا توجد محادثات',
                style: TextStyle(fontFamily: 'Cairo', color: AppColors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final t = filtered[i];
                return Dismissible(
                  key: ValueKey(t.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('حذف المحادثة؟', textAlign: TextAlign.right),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('إلغاء'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('حذف'),
                              ),
                            ],
                          ),
                        ) ??
                        false;
                  },
                  onDismissed: (_) =>
                      context.read<ChatInboxProvider>().deleteThread(t.id),
                  background: Container(
                    color: Colors.red.shade700,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  child: _roleTile(
                    context,
                    role: role,
                    t: t,
                  ),
                );
              },
            ),
    );
  }

  Widget _roleTile(
    BuildContext context, {
    required UserRole? role,
    required ChatThreadModel t,
  }) {
    void openChat() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ChatDetailScreen(threadId: t.id),
        ),
      );
    }

    // فروق العرض: مزارع = عرض سعري + حالة | تاجر = آخر رسالة + تاريخ عرض | مصنع = عقد + توريد قادم
    switch (role) {
      case UserRole.farmer:
        return _FarmerInboxTile(
          t: t,
          peerIcon: _peerKindIcon(t.peerKind),
          onTap: openChat,
        );
      case UserRole.trader:
        return _TraderInboxTile(
          t: t,
          peerIcon: _peerKindIcon(t.peerKind),
          onTap: openChat,
        );
      case UserRole.factory:
        return _FactoryInboxTile(
          t: t,
          peerIcon: _peerKindIcon(t.peerKind),
          onTap: openChat,
        );
      case null:
        return _ChatTile(
          peerName: t.peerName,
          peerIcon: _peerKindIcon(t.peerKind),
          avatarAsset: t.avatarAssetPath ?? 'assets/images/crop_default.png',
          subtitle: t.lastPreview,
          timeLabel: formatChatTimeAr(t.updatedAt),
          unread: t.unreadCount,
          onTap: openChat,
        );
    }
  }
}

// ——— مزارع: تاجر/مصنع فقط + سطر عرض + حالة ———
class _FarmerInboxTile extends StatelessWidget {
  final ChatThreadModel t;
  final IconData peerIcon;
  final VoidCallback onTap;

  const _FarmerInboxTile({
    required this.t,
    required this.peerIcon,
    required this.onTap,
  });

  String _statusLabel() {
    switch (t.offerListStatus) {
      case ThreadOfferListStatus.none:
        return '';
      case ThreadOfferListStatus.pendingReview:
        return 'قيد المراجعة';
      case ThreadOfferListStatus.accepted:
        return 'مقبول';
      case ThreadOfferListStatus.rejected:
        return 'مرفوض';
    }
  }

  Color _statusColor() {
    switch (t.offerListStatus) {
      case ThreadOfferListStatus.pendingReview:
        return Colors.orange.shade800;
      case ThreadOfferListStatus.accepted:
        return Colors.green.shade800;
      case ThreadOfferListStatus.rejected:
        return Colors.red.shade800;
      case ThreadOfferListStatus.none:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final offerLine = t.offerSummaryLine ?? t.lastPreview;
    return _ChatTile(
      peerName: t.peerName,
      peerIcon: peerIcon,
      avatarAsset: t.avatarAssetPath ?? 'assets/images/crop_default.png',
      subtitle: offerLine,
      timeLabel: formatChatTimeAr(t.updatedAt),
      unread: t.unreadCount,
      onTap: onTap,
      statusChip: t.offerListStatus != ThreadOfferListStatus.none
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _statusColor().withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _statusColor().withValues(alpha: 0.4)),
              ),
              child: Text(
                _statusLabel(),
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: _statusColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }
}

// ——— تاجر: مزارعون فقط + آخر رسالة + تاريخ آخر عرض ———
class _TraderInboxTile extends StatelessWidget {
  final ChatThreadModel t;
  final IconData peerIcon;
  final VoidCallback onTap;

  const _TraderInboxTile({
    required this.t,
    required this.peerIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateLine = t.lastOfferSentAt != null
        ? 'آخر عرض: ${formatOfferDateShortAr(t.lastOfferSentAt)}'
        : null;
    return _ChatTile(
      peerName: t.peerName,
      peerIcon: peerIcon,
      avatarAsset: t.avatarAssetPath ?? 'assets/images/crop_default.png',
      subtitle: t.lastPreview,
      timeLabel: formatChatTimeAr(t.updatedAt),
      unread: t.unreadCount,
      onTap: onTap,
      extraLine: dateLine,
    );
  }
}

// ——— مصنع: مزارعون + نوع عقد + موعد توريد ———
class _FactoryInboxTile extends StatelessWidget {
  final ChatThreadModel t;
  final IconData peerIcon;
  final VoidCallback onTap;

  const _FactoryInboxTile({
    required this.t,
    required this.peerIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final kind = t.factoryContractKind ?? '—';
    final next = t.nextSupplyDate != null
        ? 'توريد قادم: ${formatOfferDateShortAr(t.nextSupplyDate)}'
        : null;
    return _ChatTile(
      peerName: t.peerName,
      peerIcon: peerIcon,
      avatarAsset: t.avatarAssetPath ?? 'assets/images/crop_default.png',
      subtitle: 'العقد: $kind${next != null ? ' — $next' : ''}',
      timeLabel: formatChatTimeAr(t.updatedAt),
      unread: t.unreadCount,
      onTap: onTap,
    );
  }
}

class _ChatTile extends StatelessWidget {
  final String peerName;
  final IconData peerIcon;
  final String avatarAsset;
  final String subtitle;
  final String timeLabel;
  final int unread;
  final VoidCallback onTap;
  final Widget? statusChip;
  final String? extraLine;

  const _ChatTile({
    required this.peerName,
    required this.peerIcon,
    required this.avatarAsset,
    required this.subtitle,
    required this.timeLabel,
    required this.unread,
    required this.onTap,
    this.statusChip,
    this.extraLine,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: const Color(0xFFE0E0E0),
                    backgroundImage: AssetImage(avatarAsset),
                  ),
                  Positioned(
                    left: -2,
                    bottom: -2,
                    child: CircleAvatar(
                      radius: 11,
                      backgroundColor: AppColors.primaryGreen,
                      child: Icon(peerIcon, size: 14, color: Colors.white),
                    ),
                  ),
                  if (unread > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2196F3),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Text(
                          unread > 9 ? '9+' : '$unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          timeLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  peerName,
                                  textAlign: TextAlign.right,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    if (extraLine != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        extraLine!,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: Colors.blueGrey.shade600,
                        ),
                      ),
                    ],
                    if (statusChip != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [statusChip!],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
