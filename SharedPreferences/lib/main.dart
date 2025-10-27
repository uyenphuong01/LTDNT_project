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
  double _fontSize = 16.0; // Thêm biến font size

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    _loadFontSize(); // Thêm hàm load font size
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

  // 🔹 Tải font size từ SharedPreferences
  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    final fontSize = prefs.getDouble('fontSize') ?? 16.0;
    if (mounted) {
      setState(() {
        _fontSize = fontSize;
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

  // 🔹 Cho phép SettingsScreen thay đổi font size
  void updateFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', size);
    if (mounted) {
      setState(() {
        _fontSize = size;
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
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        home: const AuthWrapper(),
      ),
    );
  }

  // 🔹 Xây dựng Light Theme với font size
  ThemeData _buildLightTheme() {
    final baseTheme = ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      appBarTheme: const AppBarTheme(
        color: Color.fromARGB(255, 188, 114, 114),
        foregroundColor: Colors.white,
      ),
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
          .copyWith(secondary: Colors.blueAccent),
    );

    return baseTheme.copyWith(
      textTheme: _buildTextTheme(baseTheme.textTheme),
    );
  }

  // 🔹 Xây dựng Dark Theme với font size
  ThemeData _buildDarkTheme() {
    final baseTheme = ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: const Color.fromARGB(255, 30, 31, 38),
      appBarTheme: const AppBarTheme(
        color: Color.fromARGB(255, 192, 178, 178),
        foregroundColor: Colors.white,
      ),
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ).copyWith(secondary: Colors.lightBlueAccent),
    );

    return baseTheme.copyWith(
      textTheme: _buildTextTheme(baseTheme.textTheme),
    );
  }

  // 🔹 Xây dựng TextTheme với font size động
  TextTheme _buildTextTheme(TextTheme baseTextTheme) {
    double scaleFactor = _fontSize / 16.0; // Scale factor based on default 16.0

    return baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontSize: (baseTextTheme.displayLarge?.fontSize ?? 96.0) * scaleFactor,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontSize: (baseTextTheme.displayMedium?.fontSize ?? 60.0) * scaleFactor,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontSize: (baseTextTheme.displaySmall?.fontSize ?? 48.0) * scaleFactor,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontSize: (baseTextTheme.headlineMedium?.fontSize ?? 34.0) * scaleFactor,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontSize: (baseTextTheme.headlineSmall?.fontSize ?? 24.0) * scaleFactor,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize: (baseTextTheme.titleLarge?.fontSize ?? 20.0) * scaleFactor,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontSize: (baseTextTheme.titleMedium?.fontSize ?? 16.0) * scaleFactor,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontSize: (baseTextTheme.titleSmall?.fontSize ?? 14.0) * scaleFactor,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontSize: (baseTextTheme.bodyLarge?.fontSize ?? 16.0) * scaleFactor,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize: (baseTextTheme.bodyMedium?.fontSize ?? 14.0) * scaleFactor,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontSize: (baseTextTheme.bodySmall?.fontSize ?? 12.0) * scaleFactor,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontSize: (baseTextTheme.labelLarge?.fontSize ?? 14.0) * scaleFactor,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontSize: (baseTextTheme.labelSmall?.fontSize ?? 10.0) * scaleFactor,
      ),
    );
  }
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