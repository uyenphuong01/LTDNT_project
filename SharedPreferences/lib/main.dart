import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Lỗi khi khởi tạo Firebase: $e");
  }

  runApp(const MyApp());
}

class ThemeManager extends InheritedWidget {
  final _MyAppState data;

  const ThemeManager({
    required this.data,
    required Widget child,
    super.key,
  }) : super(child: child);

  static _MyAppState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeManager>()!.data;
  }

  @override
  bool updateShouldNotify(ThemeManager oldWidget) => true;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  // Tải theme từ SharedPreferences
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    if (mounted) {
      setState(() {
        _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      });
    }
  }

  void setTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    if (mounted) {
      setState(() {
        _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemeManager(
      data: this,
      child: MaterialApp(
        title: 'Student App',
        debugShowCheckedModeBanner: false,
        themeMode: _themeMode,
        theme: _lightTheme,
        darkTheme: _darkTheme,
        home: const AuthWrapper(),
      ),
    );
  }

  // Light Theme
  final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    appBarTheme: const AppBarTheme(
      color: Color.fromARGB(255, 188, 114, 114),
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
        .copyWith(secondary: Colors.blueAccent),
  );

  // Dark Theme
  final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: const Color.fromARGB(255, 30, 31, 38),
    appBarTheme: const AppBarTheme(
      color: Color.fromARGB(255, 50, 55, 65),
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.blue,
      brightness: Brightness.dark,
    ).copyWith(secondary: Colors.lightBlueAccent),
  );
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<Map<String, dynamic>?> _fetchUserData(User user) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (!doc.exists) {
        print("Không tìm thấy dữ liệu người dùng trong Firestore");
        // Trả về dữ liệu cơ bản từ Firebase Auth nếu không có trong Firestore
        return {
          'uid': user.uid,
          'email': user.email,
          'username': user.email?.split('@').first ?? 'User',
          'token': await user.getIdToken() ?? "",
        };
      }
      
      final userData = doc.data()!;
      userData['uid'] = user.uid;
      userData['email'] = user.email;
      userData['token'] = await user.getIdToken() ?? "";
      userData['username'] = userData['username'] ?? user.email?.split('@').first ?? 'User';

      return userData;

    } catch (e) {
      print("Lỗi tải dữ liệu Firestore: $e");
      // Trả về dữ liệu cơ bản ngay cả khi có lỗi
      return {
        'uid': user.uid,
        'email': user.email,
        'username': user.email?.split('@').first ?? 'User',
        'token': await user.getIdToken() ?? "",
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Đang chờ kết nối 
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text("Đang kiểm tra đăng nhập..."),
                ],
              ),
            ),
          );
        }
        
        // 2. Đã có người dùng đăng nhập
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          
          // Tải dữ liệu từ Firestore dựa trên UID
          return FutureBuilder<Map<String, dynamic>?>(
            future: _fetchUserData(user),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text("Đang tải dữ liệu người dùng..."),
                      ],
                    ),
                  ),
                );
              }
              
              // Luôn chuyển đến ProfileScreen nếu đã đăng nhập
              // ngay cả khi có lỗi Firestore (vẫn có dữ liệu cơ bản từ Auth)
              if (userSnapshot.hasData || userSnapshot.hasError) {
                final userData = userSnapshot.data ?? {
                  'uid': user.uid,
                  'email': user.email,
                  'username': user.email?.split('@').first ?? 'User',
                };
                return ProfileScreen(userData: userData);
              }

              return const LoginScreen();
            },
          );
        }
        
        // 3. Chưa có người dùng đăng nhập
        return const LoginScreen();
      },
    );
  }
}