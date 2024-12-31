import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  // Hàm xử lý đăng xuất
  Future<void> _logout(BuildContext context) async {
    // Xóa thông tin trong SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Xóa toàn bộ dữ liệu đã lưu

    // Điều hướng về màn hình đăng nhập và xóa lịch sử điều hướng
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Hiển thị hộp thoại xác nhận trước khi đăng xuất
              final bool? confirmLogout = await _showConfirmLogoutDialog(context);
              if (confirmLogout == true) {
                _logout(context); // Gọi hàm đăng xuất
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome, Admin!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }

  // Hộp thoại xác nhận đăng xuất
  Future<bool?> _showConfirmLogoutDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Hủy
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Xác nhận
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }
}