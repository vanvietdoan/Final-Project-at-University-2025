import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/notify.dart';
import '../services/notify_sevice.dart';

class NotificationButton extends StatefulWidget {
  final int userId;

  const NotificationButton({super.key, required this.userId});

  @override
  State<NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<NotificationButton> {
  final NotifyService _notifyService = NotifyService();
  List<Notify> _notifications = [];
  bool _isLoadingNotifications = false;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoadingNotifications = true;
    });
    try {
      final notifications = await _notifyService.getNotifyByUser(widget.userId);
      setState(() {
        _notifications = notifications;
        _unreadCount = notifications.where((n) => !n.isRead).length;
        _isLoadingNotifications = false;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading notifications: $e');
      }
      setState(() {
        _isLoadingNotifications = false;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final unreadNotifications =
          _notifications.where((n) => !n.isRead).toList();
      for (var notification in unreadNotifications) {
        await _notifyService.markAsRead(notification.notifyId);
      }
      await _loadNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã đánh dấu tất cả thông báo đã đọc')),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error marking all notifications as read: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra khi đánh dấu thông báo')),
        );
      }
    }
  }

  Future<void> _deleteNotification(Notify notification) async {
    try {
      await _notifyService.deleteNotification(notification.notifyId);

      // Cập nhật UI ngay lập tức
      setState(() {
        _notifications.removeWhere((n) => n.notifyId == notification.notifyId);
        _unreadCount = _notifications.where((n) => !n.isRead).length;
      });

      // Hiển thị thông báo thành công
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa thông báo'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Chỉ đóng dialog xác nhận
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xóa thông báo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAsRead(Notify notification) async {
    if (!notification.isRead) {
      try {
        await _notifyService.markAsRead(notification.notifyId);
        setState(() {
          final index = _notifications.indexWhere(
            (n) => n.notifyId == notification.notifyId,
          );
          if (index != -1) {
            _notifications[index] = Notify(
              notifyId: notification.notifyId,
              title: notification.title,
              content: notification.content,
              createdAt: notification.createdAt,
              updatedAt: notification.updatedAt,
              isRead: true,
            );
          }
        });
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error marking notification as read: $e');
        }
      }
    }
  }

  void _showNotificationList() {
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Thông báo'),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Đóng'),
                      ),
                    ],
                  ),
                  content: SizedBox(
                    width: double.maxFinite,
                    child:
                        _isLoadingNotifications
                            ? const Center(child: CircularProgressIndicator())
                            : _notifications.isEmpty
                            ? const Center(
                              child: Text('Không có thông báo nào'),
                            )
                            : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _notifications.length,
                              itemBuilder: (context, index) {
                                final notification = _notifications[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          notification.isRead
                                              ? Colors.grey
                                              : Colors.blue,
                                      child: const Icon(
                                        Icons.notifications,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(
                                      notification.title,
                                      style: TextStyle(
                                        fontWeight:
                                            notification.isRead
                                                ? FontWeight.normal
                                                : FontWeight.bold,
                                        color:
                                            notification.isRead
                                                ? Colors.grey[600]
                                                : Colors.black,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          notification.content,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatDate(notification.createdAt),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (!notification.isRead)
                                          IconButton(
                                            icon: const Icon(
                                              Icons.check,
                                              color: Colors.green,
                                            ),
                                            onPressed: () async {
                                              await _markAsRead(notification);
                                              setDialogState(
                                                () {},
                                              ); // Cập nhật UI của dialog
                                            },
                                            tooltip: 'Đánh dấu đã đọc',
                                          ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed:
                                              () => _showDeleteConfirmation(
                                                notification,
                                              ),
                                          tooltip: 'Xóa thông báo',
                                        ),
                                      ],
                                    ),
                                    onTap: () async {
                                      await _showNotificationDetail(
                                        notification,
                                      );
                                      setDialogState(
                                        () {},
                                      ); // Cập nhật UI của dialog sau khi xem chi tiết
                                    },
                                  ),
                                );
                              },
                            ),
                  ),
                ),
          ),
    );
  }

  Future<void> _showNotificationDetail(Notify notification) async {
    if (!notification.isRead) {
      await _markAsRead(notification);
      // Cập nhật UI ngay lập tức sau khi đánh dấu đã đọc
      setState(() {
        final index = _notifications.indexWhere(
          (n) => n.notifyId == notification.notifyId,
        );
        if (index != -1) {
          _notifications[index] = Notify(
            notifyId: notification.notifyId,
            title: notification.title,
            content: notification.content,
            createdAt: notification.createdAt,
            updatedAt: notification.updatedAt,
            isRead: true,
          );
          _unreadCount = _notifications.where((n) => !n.isRead).length;
        }
      });
    }

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(notification.title),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    notification.content,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _formatDate(notification.createdAt),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }

  void _showDeleteConfirmation(Notify notification) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: const Text('Bạn có chắc chắn muốn xóa thông báo này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context); // Đóng dialog xác nhận
                  await _deleteNotification(notification);
                },
                child: const Text('Xóa'),
              ),
            ],
          ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.green),
          onPressed: _showNotificationList,
        ),
        if (_notifications.any((n) => !n.isRead))
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '${_notifications.where((n) => !n.isRead).length}',
                style: const TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
