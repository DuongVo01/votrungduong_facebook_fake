import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; //Import SharedPreferences
import 'package:votrungduong_facebook_fake/utils/auth.dart';  // Import the auth.dart file
import '../services/auth_service.dart';
import 'main_screen.dart';  // Import the main screen to navigate after successful login
import 'package:votrungduong_facebook_fake/screens/admin_screen.dart';
import 'package:votrungduong_facebook_fake/screens/registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController =
  TextEditingController();
  final TextEditingController _passwordController =
  TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  @override
  void initState() {
    super.initState();
    _checkToken(); // Kiểm tra token khi mở màn hình
  }
  // Kiểm tra token trong SharedPreferences
  Future<void> _checkToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token');
    final String? role = prefs.getString('role'); // Lấy vai trò từ SharedPreferences

    if (token != null && role != null) {
      if (role == 'Admin') {
        // Chuyển đến AdminScreen nếu role là Admin
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminScreen()),
        );
      } else if (role == 'User') {
        // Chuyển đến MainScreen nếu role là User
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        // Nếu role không xác định, hiển thị thông báo lỗi (nếu cần)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi xác định quyền. Vui lòng đăng nhập lại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Hàm xử lý đăng nhập
  Future<void> _handleLogin() async {
    if (_usernameController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ thông tin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    // Gọi Auth.login để xử lý đăng nhập
    Map<String, dynamic> result = await Auth.login(
      _usernameController.text,
      _passwordController.text,
    );
    setState(() => _isLoading = false);
    if (result['success'] == true) {
      // Lưu token vào SharedPreferences
      SharedPreferences prefs = await
      SharedPreferences.getInstance();
      await prefs.setString('jwt_token', result['token']); // Lưu token
      String? role = await prefs.getString('role') ?? 'User'; // Lấy vai trò người dùng
      if (role == 'Admin') {
        Navigator.pushReplacement(
          context,
          //Nếu người dùng là admin thì chuyển đến trang admin
          MaterialPageRoute(builder: (context) => const
          AdminScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          //nếu không phải là admin thì chuyển đến trang MainScreen
          MaterialPageRoute(builder: (context) => const
          MainScreen()),
        );
        //có thể xử lý thêm nếu không phải loại người dùng nào thì chuyển đến trang lỗi
      }
    } else {
      // Hiển thị thông báo lỗi
      String errorMessage = result['message'] ?? 'Tên  đăng nhập hoặc mật khẩu không đúng';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const
            EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
                Text(
                  'facebook',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _usernameController,
                  keyboardType:
                  TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Số điện thoại hoặc email',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const
                    EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Mật khẩu',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const
                    EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ?
                        Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword =
                        !_obscurePassword);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null :
                    _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      'Đăng nhập',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // smart_auth............................
                // SizedBox(
                //   height: 50,
                //   child: ElevatedButton(
                //     onPressed: () async {
                //       ScaffoldMessenger.of(context).showSnackBar(
                //         const SnackBar(content: Text('Đang lấy mã OTP...')),
                //       );
                //
                //       final otp = await AuthService().retrieveSmsCode();
                //
                //       if (otp != null) {
                //         _usernameController.text = otp; // Gán OTP vào TextField
                //         ScaffoldMessenger.of(context).showSnackBar(
                //           SnackBar(content: Text('Lấy mã OTP thành công: $otp')),
                //         );
                //       } else {
                //         ScaffoldMessenger.of(context).showSnackBar(
                //           const SnackBar(
                //             content: Text('Không thể lấy mã OTP.'),
                //             backgroundColor: Colors.red,
                //           ),
                //         );
                //       }
                //     },
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.orange,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(12),
                //       ),
                //       elevation: 0,
                //     ),
                //     child: const Text(
                //       'Tự động điền mã OTP',
                //       style: TextStyle(
                //         fontSize: 16,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   ),
                // ),

                const SizedBox(height: 20),
                // Thêm điều hướng đến màn hình đăng ký
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    const Text("Chưa có tài khoản? "),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder:
                              (context) => const RegistrationScreen()),
                        );
                      },
                      child: const Text(
                        'Đăng ký ngay',
                        style: TextStyle(color:
                        Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}