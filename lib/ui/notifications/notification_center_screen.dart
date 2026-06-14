import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:my_hostel_app/backend/model/notification_model.dart';
import 'package:my_hostel_app/backend/provider/notification_provider.dart';

class NotificationCenterScreen extends ConsumerWidget {
  final String userId;
  const NotificationCenterScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notifAsync = ref.watch(notificationsProvider(userId));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 1,
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          notifAsync.maybeWhen(
            data: (notifs) {
              final hasUnread = notifs.any((n) => !n.isRead);
              if (!hasUnread) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => _markAllRead(ref, context),
                child: Text(
                  'Mark all read',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: theme.colorScheme.primary,
                  ),
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurface),
            onSelected: (value) {
              if (value == 'clear') _clearAll(ref, context);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Clear all'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: notifAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(error: e.toString()),
        data: (notifs) {
          if (notifs.isEmpty) return const _EmptyState();
          return _NotificationList(
            notifications: notifs,
            userId: userId,
            onTap: (notif) => _onTap(notif, ref, context),
            onDismiss: (notif) => _delete(notif, ref),
          );
        },
      ),
    );
  }

  Future<void> _markAllRead(WidgetRef ref, BuildContext context) async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.markAllAsRead(userId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications marked as read')),
      );
    }
  }

  Future<void> _clearAll(WidgetRef ref, BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear all notifications?'),
        content: const Text('This will permanently delete all notifications.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.clearAll(userId);
    }
  }

  void _onTap(
      NotificationModel notif, WidgetRef ref, BuildContext context) async {
    if (!notif.isRead) {
      await ref.read(notificationRepositoryProvider).markAsRead(userId, notif.id);
    }
    if (!context.mounted) return;

    final data = notif.data;
    final action = data['action'] as String?;

    // Owner notifications carry action='new' (new booking request) or
    // action='cancelled' (booking cancelled by student).
    // All other booking/payment actions are sent to students.
    final isOwnerNotification =
        action == 'new' || action == 'cancelled';

    switch (notif.type) {
      case 'booking':
      case 'payment':
      case 'checkin':
        context.push(isOwnerNotification ? '/owner-bookings' : '/my-bookings');
        break;
      default:
        if (data['hostelId'] != null) {
          context.push('/hostel-details/${data['hostelId']}');
        }
    }
  }

  Future<void> _delete(NotificationModel notif, WidgetRef ref) async {
    await ref.read(notificationRepositoryProvider).delete(userId, notif.id);
  }
}

// ── Notification list ─────────────────────────────────────────────────────────

class _NotificationList extends StatelessWidget {
  final List<NotificationModel> notifications;
  final String userId;
  final void Function(NotificationModel) onTap;
  final void Function(NotificationModel) onDismiss;

  const _NotificationList({
    required this.notifications,
    required this.userId,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    // Group: today, yesterday, earlier
    final today = notifications.where((n) => n.isToday).toList();
    final yesterday = notifications.where((n) => n.isYesterday).toList();
    final earlier = notifications
        .where((n) => !n.isToday && !n.isYesterday)
        .toList();

    return ListView(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      children: [
        if (today.isNotEmpty) ...[
          _SectionHeader(label: 'Today'),
          ...today.map((n) => _NotificationTile(
                notification: n,
                onTap: () => onTap(n),
                onDismiss: () => onDismiss(n),
              )),
        ],
        if (yesterday.isNotEmpty) ...[
          _SectionHeader(label: 'Yesterday'),
          ...yesterday.map((n) => _NotificationTile(
                notification: n,
                onTap: () => onTap(n),
                onDismiss: () => onDismiss(n),
              )),
        ],
        if (earlier.isNotEmpty) ...[
          _SectionHeader(label: 'Earlier'),
          ...earlier.map((n) => _NotificationTile(
                notification: n,
                onTap: () => onTap(n),
                onDismiss: () => onDismiss(n),
              )),
        ],
      ],
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 6.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── Notification tile ─────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final n = notification;

    return Dismissible(
      key: Key(n.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        color: theme.colorScheme.error,
        child: Icon(Icons.delete_outline, color: Colors.white, size: 24.sp),
      ),
      onDismissed: (_) => onDismiss(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: n.isRead
              ? Colors.transparent
              : theme.colorScheme.primary.withValues(alpha: 0.04),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type icon
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: n.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(n.icon, size: 20.sp, color: n.color),
              ),
              SizedBox(width: 12.w),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: n.isRead
                                  ? FontWeight.w400
                                  : FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          n.timeAgo,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color:
                                theme.colorScheme.onSurface.withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      n.body,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Unread dot
              if (!n.isRead) ...[
                SizedBox(width: 8.w),
                Container(
                  width: 8.w,
                  height: 8.w,
                  margin: EdgeInsets.only(top: 6.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64.sp,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
          ),
          SizedBox(height: 16.h),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'You\'ll be notified about bookings,\npayments and updates here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String error;
  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: theme.colorScheme.error),
            SizedBox(height: 16.h),
            Text(
              'Failed to load notifications',
              style: TextStyle(
                fontSize: 15.sp,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
