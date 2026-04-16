import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationPage extends StatefulWidget {
  final String userId;
  final String userRole; // "principal" | "coordinator" | "student"

  const NotificationPage({
    super.key,
    required this.userId,
    required this.userRole,
  });

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final String baseUrl = "https://placemate-backend-coral.vercel.app";
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/notifications/${widget.userId}"),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        setState(() {
          notifications = data;
          isLoading = false;
        });
        // Mark all as read
        await http.patch(
          Uri.parse("$baseUrl/notifications/${widget.userId}/mark-read"),
        );
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: _clearAll,
              child: Text(
                "Clear all",
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchNotifications,
        child: notifications.isEmpty
            ? _emptyState(theme)
            : SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome badge (only for new accounts)
              _welcomeBadge(theme),
              const SizedBox(height: 24),
              Text(
                "Recent Activity",
                style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...notifications.map(
                      (n) => _notificationCard(theme, n)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _clearAll() async {
    try {
      await http.delete(
        Uri.parse("$baseUrl/notifications/${widget.userId}/clear"),
      );
      setState(() => notifications = []);
    } catch (_) {}
  }

  Widget _emptyState(ThemeData theme) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
          child: Column(
            children: [
              Icon(Icons.notifications_none_outlined,
                  size: 72,
                  color: theme.colorScheme.primary.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text(
                "All caught up!",
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "No notifications yet. You'll be notified about\nimportant updates here.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _welcomeBadge(ThemeData theme) {
    // Only show if there's a "welcome" type notification
    final hasWelcome = notifications.any(
            (n) => (n['type'] ?? '') == 'welcome');
    if (!hasWelcome) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.celebration_outlined, color: Colors.green),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "You're all set! Your journey starts here.",
              style: TextStyle(
                  color: Colors.green, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _notificationCard(ThemeData theme, dynamic n) {
    final type = (n['type'] ?? 'info').toString();
    final isUnread = !(n['isRead'] ?? false);
    final time = _formatTime(n['createdAt']);

    // Map type → icon + color
    final config = _typeConfig(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread
            ? theme.colorScheme.primary.withOpacity(0.04)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: isUnread
            ? Border.all(
            color: theme.colorScheme.primary.withOpacity(0.12))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: config['color'].withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(config['icon'],
                color: config['color'], size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        n['title'] ?? "Notification",
                        style: TextStyle(
                          fontWeight: isUnread
                              ? FontWeight.bold
                              : FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  n['message'] ?? "",
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: TextStyle(
                    color: theme.hintColor.withOpacity(0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _typeConfig(String type) {
    switch (type) {
      case 'application':
        return {'icon': Icons.send_rounded, 'color': Colors.blueAccent};
      case 'placement':
        return {
          'icon': Icons.business_center_rounded,
          'color': Colors.purple
        };
      case 'welcome':
        return {
          'icon': Icons.celebration_outlined,
          'color': Colors.green
        };
      case 'security':
        return {
          'icon': Icons.shield_outlined,
          'color': Colors.orange
        };
      case 'risk':
        return {
          'icon': Icons.warning_amber_rounded,
          'color': Colors.redAccent
        };
      default:
        return {
          'icon': Icons.notifications_outlined,
          'color': Colors.teal
        };
    }
  }

  String _formatTime(dynamic createdAt) {
    if (createdAt == null) return "Recently";
    try {
      final dt = DateTime.parse(createdAt.toString()).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return "Just now";
      if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
      if (diff.inHours < 24) return "${diff.inHours}h ago";
      return "${diff.inDays}d ago";
    } catch (_) {
      return "Recently";
    }
  }
}