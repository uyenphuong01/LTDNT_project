// settings_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  String _selectedLanguage = 'Vietnamese';
  final List<String> _availableLanguages = ['Vietnamese', 'English', 'French', 'Japanese', 'Chinese', 'Korean'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _biometricEnabled = prefs.getBool('biometric') ?? false;
      _selectedLanguage = prefs.getString('language') ?? _availableLanguages.first;
    });
  }

  Future<void> _setTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    setState(() => _isDarkMode = isDark);
    ThemeManager.of(context).setTheme(isDark);
    _showSnackBar(isDark ? "Đã bật chế độ tối 🌙" : "Đã tắt chế độ tối ☀️");
  }

  Future<void> _setNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', enabled);
    setState(() => _notificationsEnabled = enabled);
    _showSnackBar(enabled ? "Đã bật thông báo 🔔" : "Đã tắt thông báo 🔕");
  }


  Future<void> _setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    setState(() => _selectedLanguage = lang);
    _showSnackBar("Đã đổi ngôn ngữ: $lang");
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }




  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor?.withOpacity(0.1) ?? Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
        trailing: trailing,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cài đặt", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 PHẦN GIAO DIỆN
            _buildSectionTitle("Giao diện"),
            _buildSettingItem(
              icon: Icons.dark_mode,
              title: "Chế độ tối",
              subtitle: _isDarkMode ? "Đang bật" : "Đang tắt",
              iconColor: Colors.purple,
              trailing: Switch(
                value: _isDarkMode,
                activeColor: theme.primaryColor,
                onChanged: _setTheme,
              ),
            ),

            _buildSettingItem(
              icon: Icons.language,
              title: "Ngôn ngữ",
              subtitle: "Hiện tại: $_selectedLanguage",
              iconColor: Colors.blue,
              trailing: DropdownButton<String>(
                underline: const SizedBox(),
                value: _selectedLanguage,
                items: _availableLanguages.map((lang) {
                  return DropdownMenuItem(
                    value: lang,
                    child: Text(lang, style: theme.textTheme.bodyMedium),
                  );
                }).toList(),
                onChanged: (value) => value != null ? _setLanguage(value) : null,
              ),
            ),

            const SizedBox(height: 20),


            // 🔹 NÚT ĐẶT LẠI
            Center(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  _loadSettings();
                  _showSnackBar("Đã đặt lại tất cả cài đặt");
                },
                icon: const Icon(Icons.restore),
                label: const Text("Đặt lại cài đặt"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 20),
            
            // 🔹 GHI CHÚ
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.amber.shade700, size: 18),
                      const SizedBox(width: 8),
                      const Text("Ghi chú", style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Các thay đổi về ngôn ngữ sẽ được áp dụng sau khi khởi động lại ứng dụng. "
                    "Chế độ tối sẽ thay đổi ngay lập tức.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}