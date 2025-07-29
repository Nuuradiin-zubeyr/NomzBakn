import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static const String _notificationsKey = 'notifications';
  static const String _unreadCountKey = 'unread_notifications_count';

  // Add a new notification
  static Future<void> addNotification({
    required String title,
    required String message,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing notifications
    final notificationsJson = prefs.getStringList(_notificationsKey) ?? [];
    
    // Create new notification
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
      'data': data,
    };
    
    // Add to beginning of list (most recent first)
    notificationsJson.insert(0, notification.toString());
    
    // Save notifications
    await prefs.setStringList(_notificationsKey, notificationsJson);
    
    // Update unread count
    await _updateUnreadCount();
  }

  // Get all notifications
  static Future<List<NotificationItem>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getStringList(_notificationsKey) ?? [];
    
    return notificationsJson.map((json) {
      // Parse the notification from string
      final cleanJson = json.replaceAll('{', '').replaceAll('}', '');
      final parts = cleanJson.split(', ');
      
      final id = parts[0].split(': ')[1];
      final title = parts[1].split(': ')[1];
      final message = parts[2].split(': ')[1];
      final type = parts[3].split(': ')[1];
      final timestamp = parts[4].split(': ')[1];
      final isRead = parts[5].split(': ')[1] == 'true';
      
      return NotificationItem(
        id: id,
        title: title,
        message: message,
        type: _parseNotificationType(type),
        timestamp: DateTime.parse(timestamp),
        isRead: isRead,
      );
    }).toList();
  }

  // Mark notification as read
  static Future<void> markAsRead(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getStringList(_notificationsKey) ?? [];
    
    for (int i = 0; i < notificationsJson.length; i++) {
      if (notificationsJson[i].contains('id: $id')) {
        // Update the isRead status
        notificationsJson[i] = notificationsJson[i].replaceAll('isRead: false', 'isRead: true');
        break;
      }
    }
    
    await prefs.setStringList(_notificationsKey, notificationsJson);
    await _updateUnreadCount();
  }

  // Mark all notifications as read
  static Future<void> markAllAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getStringList(_notificationsKey) ?? [];
    
    for (int i = 0; i < notificationsJson.length; i++) {
      notificationsJson[i] = notificationsJson[i].replaceAll('isRead: false', 'isRead: true');
    }
    
    await prefs.setStringList(_notificationsKey, notificationsJson);
    await _updateUnreadCount();
  }

  // Get unread count
  static Future<int> getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_unreadCountKey) ?? 0;
  }

  // Clear all notifications
  static Future<void> clearAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationsKey);
    await prefs.setInt(_unreadCountKey, 0);
  }

  // Update unread count
  static Future<void> _updateUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getStringList(_notificationsKey) ?? [];
    
    int unreadCount = 0;
    for (final notification in notificationsJson) {
      if (notification.contains('isRead: false')) {
        unreadCount++;
      }
    }
    
    await prefs.setInt(_unreadCountKey, unreadCount);
  }

  // Parse notification type from string
  static NotificationType _parseNotificationType(String type) {
    switch (type) {
      case 'success':
        return NotificationType.success;
      case 'warning':
        return NotificationType.warning;
      case 'error':
        return NotificationType.error;
      case 'info':
        return NotificationType.info;
      default:
        return NotificationType.info;
    }
  }

  // Add transaction notification
  static Future<void> addTransactionNotification({
    required String type, // 'send' or 'receive'
    required double amount,
    required String recipientOrSender,
    String? note,
  }) async {
    final now = DateTime.now();
    final formattedDate = '${now.day}/${now.month}/${now.year}';
    final formattedTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    final title = type == 'send' 
        ? 'Money Sent Successfully'
        : 'Money Received';
    
    final message = type == 'send'
        ? 'You sent \$${amount.toStringAsFixed(2)} to $recipientOrSender${note != null ? ' - $note' : ''}'
        : 'You received \$${amount.toStringAsFixed(2)} from $recipientOrSender${note != null ? ' - $note' : ''}';
    
    final notificationType = type == 'send' 
        ? NotificationType.success 
        : NotificationType.info;
    
    await addNotification(
      title: title,
      message: message,
      type: notificationType,
      data: {
        'transactionType': type,
        'amount': amount,
        'recipientOrSender': recipientOrSender,
        'note': note,
        'transactionDate': formattedDate,
        'transactionTime': formattedTime,
        'fullTimestamp': now.toIso8601String(),
      },
    );
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });
}

enum NotificationType {
  success,
  warning,
  error,
  info,
} 