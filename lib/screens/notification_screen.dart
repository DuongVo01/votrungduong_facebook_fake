import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Danh sách thông báo
  final List<Map<String, dynamic>> notifications = [
    {
      'icon': Icons.person,
      'title': 'John Doe liked your post.',
      'time': '2 hours ago',
    },
    {
      'icon': Icons.group,
      'title': 'You have been added to the group "Flutter Devs".',
      'time': '1 day ago',
    },
    {
      'icon': Icons.shopping_cart,
      'title': 'Your Marketplace order has been shipped.',
      'time': '3 days ago',
    },
    {
      'icon': Icons.event,
      'title': 'Event "Flutter Meetup" starts tomorrow.',
      'time': '5 days ago',
    },
    {
      'icon': Icons.comment,
      'title': 'Anna commented on your post.',
      'time': '1 week ago',
    },
  ];

  // Hàm để xóa thông báo
  void _deleteNotification(int index) {
    setState(() {
      notifications.removeAt(index); // Xóa thông báo tại chỉ mục index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: Colors.black)),
    backgroundColor: Colors.white,
    elevation: 2,
    iconTheme: const IconThemeData(color: Colors.black),
    centerTitle: true,
    ),
    body: ListView.separated(
    itemCount: notifications.length,
    itemBuilder: (context, index) {
    final notification = notifications[index];
    return Card(
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    elevation: 4,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    ),
    child: ListTile(
    contentPadding: const EdgeInsets.all(12),
    leading: CircleAvatar(
    backgroundColor: Colors.blue[100],
    child: Icon(notification['icon'] as IconData, color: Colors.blue),
    ),
    title: Text(
    notification['title'] as String,
    style: const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    color: Colors.black87,
    ),
    ),
    subtitle: Text(
    notification['time'] as String,
    style: const TextStyle(
    fontSize: 12,
    color: Colors.grey,
    ),
    ),
    trailing: IconButton(
    icon: const Icon(Icons.more_horiz, color: Colors.grey),
    onPressed: () {
    // Hiển thị menu chọn để xóa thông báo
    showDialog(
    context: context,builder: (context) {
      return AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text('Are you sure you want to delete this notification?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () {
              // Xóa thông báo khi nhấn "Delete"
              _deleteNotification(index);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
    );
    },
    ),
    ),
    );
    },
      separatorBuilder: (context, index) {
        return const Divider(
          color: Colors.grey,
          height: 1,
          indent: 72, // Indent to avoid divider touching avatar
        );
      },
    ),
    );
  }
}