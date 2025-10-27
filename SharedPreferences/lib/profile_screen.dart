import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'dart:ui';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfileScreen({super.key, required this.userData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Map<String, dynamic> displayData;
  bool _isLoggingOut = false;
  bool _isEditing = false;
  
  // Controllers for editing
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _processInitialData();
    print("ProfileScreen được khởi tạo với UID: ${widget.userData['uid']}");
  }
  
  void _processInitialData() {
    displayData = Map<String, dynamic>.from(widget.userData);
    
    // Initialize controllers with current data
    _fullNameController.text = displayData['full_name'] ?? '';
    _classController.text = displayData['class'] ?? '';
    _studentIdController.text = displayData['student_id'] ?? '';
    
    // Xử lý timestamp nếu có
    final createdAt = displayData['created_at'];
    if (createdAt is Timestamp) {
      displayData['createdAt'] = createdAt.toDate().toString().split('.')[0];
    } else {
      displayData['createdAt'] = displayData['created_at']?.toString() ?? "Không xác định";
    }
  }

  /// 🔹 Đăng xuất
  Future<void> _logout() async {
    if (_isLoggingOut) return;
    
    setState(() {
      _isLoggingOut = true;
    });

    try {
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool('isLoggedIn', false); 
      await prefs.remove('currentUserUsername'); 

      print("Đăng xuất thành công");

      if (!mounted) return;
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
      
    } catch (e) {
      print("Lỗi khi đăng xuất: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi đăng xuất: $e")),
        );
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }
  
  /// 🔹 Chuyển đến trang Settings
  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  /// 🔹 Cập nhật thông tin sinh viên
  Future<void> _updateProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final updatedData = {
        'full_name': _fullNameController.text.trim(),
        'class': _classController.text.trim(),
        'student_id': _studentIdController.text.trim(),
        'updated_at': Timestamp.now(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(updatedData);

      setState(() {
        displayData.addAll(updatedData);
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật thông tin thành công")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi cập nhật: $e")),
      );
    }
  }

  /// 🔹 Bật/tắt chế độ chỉnh sửa
  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset controllers khi thoát chế độ chỉnh sửa
        _fullNameController.text = displayData['full_name'] ?? '';
        _classController.text = displayData['class'] ?? '';
        _studentIdController.text = displayData['student_id'] ?? '';
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _classController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Hồ sơ sinh viên",
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
            fontSize: theme.textTheme.titleLarge?.fontSize,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.close : Icons.edit, 
              color: theme.appBarTheme.foregroundColor,
            ),
            onPressed: _toggleEdit,
            tooltip: _isEditing ? "Hủy" : "Chỉnh sửa",
          ),
          IconButton(
            icon: Icon(
              Icons.settings, 
              color: theme.appBarTheme.foregroundColor,
            ),
            onPressed: _navigateToSettings,
            tooltip: "Cài đặt",
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _isEditing ? _buildSaveButton() : null,
    );
  }

  Widget _buildBody() {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildBackgroundImage(),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: _buildProfileCard(),
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundImage() {
    try {
      return Image.asset(
        'assets/images/2.jpg',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.blueGrey.shade900,
            child: Center(
              child: Icon(Icons.school, size: 100, color: Colors.white54),
            ),
          );
        },
      );
    } catch (e) {
      return Container(
        color: Colors.blueGrey.shade900,
        child: Center(
          child: Icon(Icons.school, size: 100, color: Colors.white54),
        ),
      );
    }
  }

  Widget _buildProfileCard() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAvatar(),
          const SizedBox(height: 20),
          
          // Hiển thị Họ tên
          _isEditing ? _buildEditField("Họ và tên", _fullNameController) : _buildInfoText(
            displayData['full_name'] ?? 'Chưa cập nhật',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ) ?? TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Hiển thị Email (không thể chỉnh sửa)
          _buildInfoText(
            displayData['email'] ?? 'No email',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontStyle: FontStyle.italic,
            ) ?? TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              fontStyle: FontStyle.italic,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Thông tin chi tiết
          _buildInfoSection(),
          
          const SizedBox(height: 25),
          
          // Nút đăng xuất (chỉ hiện khi không chỉnh sửa)
          if (!_isEditing) _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white.withOpacity(0.2),
          child: ClipOval(
            child: Image.asset(
              'assets/images/avatar.png',
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                );
              },
            ),
          ),
        ),
        if (_isEditing)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.edit, size: 16, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoSection() {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Lớp
        _isEditing 
            ? _buildEditField("Lớp", _classController)
            : _buildInfoRow("Lớp", displayData['class'] ?? 'Chưa cập nhật'),
        
        const SizedBox(height: 12),
        
        // Mã số sinh viên
        _isEditing 
            ? _buildEditField("Mã số sinh viên", _studentIdController)
            : _buildInfoRow("MSSV", displayData['student_id'] ?? 'Chưa cập nhật'),
        
        const SizedBox(height: 12),
        
        // Ngày tạo (chỉ hiển thị)
        _buildInfoRow("Ngày tạo", displayData['createdAt']),
        
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildEditField(String label, TextEditingController controller) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label:",
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w600,
          ) ?? TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: TextField(
            controller: controller,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white) ?? 
                  TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: InputBorder.none,
              hintText: "Nhập $label...",
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.5),
              ) ?? TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildInfoRow(String title, dynamic value, {bool showFull = true}) {
    final theme = Theme.of(context);
    final displayValue = showFull ? value : _truncateText(value.toString(), 20);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$title:",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w600,
              ) ?? TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              displayValue?.toString() ?? "-",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.85),
              ) ?? TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText(String text, {TextStyle? style}) {
    return Text(
      text,
      style: style,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLogoutButton() {
    final theme = Theme.of(context);
    
    return ElevatedButton.icon(
      onPressed: _isLoggingOut ? null : _logout,
      icon: _isLoggingOut
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.logout, color: Colors.black87),
      label: Text(
        _isLoggingOut ? "Đang đăng xuất..." : "Đăng xuất",
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ) ?? TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.85),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return FloatingActionButton(
      onPressed: _updateProfile,
      backgroundColor: Colors.green,
      child: Icon(Icons.check, color: Colors.white),
    );
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}