import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  String errorMessage = "";
  bool isLogin = true;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// 🔹 Sửa lỗi: Truyền email/username vào hàm để lưu trữ
  Future<void> _saveLoginState(String email, String username, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', email);
    await prefs.setString('authToken', token);
    
    // 💡 Sửa: Lưu USERNAME (thay vì email) vào khóa 'currentUserUsername'
    await prefs.setString('currentUserUsername', username); 
  }

  /// 🔹 Đăng nhập người dùng
  // 🔹 Sửa hàm loginUser()
Future<void> loginUser() async {
  final email = usernameController.text.trim();
  final password = passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    setState(() => errorMessage = "⚠️ Vui lòng nhập đầy đủ Email và Mật khẩu");
    return;
  }

  setState(() {
    isLoading = true;
    errorMessage = "";
  });

  try {
    final userCred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCred.user!;
    final token = await user.getIdToken() ?? "";

    // Lấy thêm thông tin Firestore
    final doc = await _firestore.collection('users').doc(user.uid).get();
    final userData = doc.data() ?? {};
    
    final usernameToSave = userData['username'] ?? user.email ?? 'user';

    // 🔹 Lưu trạng thái đăng nhập
    await _saveLoginState(email, usernameToSave, token);

    // 💡 QUAN TRỌNG: Không cần chuyển trang thủ công
    // AuthWrapper sẽ tự động phát hiện đăng nhập và chuyển đến ProfileScreen
    print("✅ Đăng nhập thành công, AuthWrapper sẽ tự chuyển trang");

  } on FirebaseAuthException catch (e) {
    setState(() {
      isLoading = false;
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        errorMessage = "❌ Email hoặc mật khẩu không đúng.";
      } else {
        errorMessage = "⚠️ Lỗi đăng nhập: ${e.message}";
      }
    });
  } catch (e) {
    setState(() {
      errorMessage = "Lỗi đăng nhập không xác định: $e";
      isLoading = false;
    });
  }
}

// 🔹 Tương tự cho registerUser()
Future<void> registerUser() async {
  final email = usernameController.text.trim();
  final password = passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    setState(() => errorMessage = "⚠️ Vui lòng nhập đầy đủ Email và Mật khẩu");
    return;
  }
  if (password.length < 6) {
    setState(() => errorMessage = "⚠️ Mật khẩu phải có ít nhất 6 ký tự");
    return;
  }

  setState(() {
    isLoading = true;
    errorMessage = "";
  });

  try {
    final userCred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCred.user!;
    final token = await user.getIdToken() ?? "";
    final newUsername = user.email!.split('@').first;

    final userData = {
      'email': user.email,
      'username': newUsername,
      'created_at': Timestamp.now(),
    };

    await _firestore.collection('users').doc(user.uid).set(userData);
    
    // 🔹 Lưu trạng thái đăng nhập
    await _saveLoginState(email, newUsername, token);

    // 💡 QUAN TRỌNG: Không cần chuyển trang thủ công
    print("✅ Đăng ký thành công, AuthWrapper sẽ tự chuyển trang");

  } on FirebaseAuthException catch (e) {
    setState(() {
      isLoading = false;
      if (e.code == 'email-already-in-use') {
        errorMessage = "❌ Email đã được sử dụng.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "❌ Định dạng Email không hợp lệ.";
      } else {
        errorMessage = "⚠️ Lỗi đăng ký: ${e.message}";
      }
    });
  } catch (e) {
    setState(() {
      errorMessage = "Lỗi đăng ký không xác định: $e";
      isLoading = false;
    });
  }
}
  
  // ------------------ UI ------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/2.jpg', fit: BoxFit.cover),
          // BackdropFilter(
          //   filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          //   child: Container(color: Colors.black.withOpacity(0.3)),
          // ),
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : _buildLoginCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        key: ValueKey(isLogin),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isLogin ? "Welcome Back!" : "Join Us!",
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 8,
                    color: Colors.black54,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: usernameController,
              decoration: _inputDecoration('Email', Icons.person),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: _inputDecoration('Password', Icons.lock),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : (isLogin ? loginUser : registerUser),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.85),
                foregroundColor: Colors.black87,
                padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.black87,
                        strokeWidth: 3,
                      ),
                    )
                  : Text(
                      isLogin ? "Log In" : "Sign Up",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin;
                  errorMessage = "";
                  usernameController.clear();
                  passwordController.clear();
                });
              },
              child: Text(
                isLogin
                    ? "Chưa có tài khoản? Đăng ký ngay"
                    : "Đã có tài khoản? Đăng nhập",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.8)),
      filled: true,
      fillColor: Colors.black.withOpacity(0.3),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.4), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.white, width: 1),
      ),
    );
  }
}