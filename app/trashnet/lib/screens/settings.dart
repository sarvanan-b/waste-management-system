import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.lock_rounded,
            title: "Change Password",
            subtitle: "Update your password for security",
            onTap: () {
              _showChangePasswordDialog(context);
            },
          ),
          Divider(),
          _buildSettingsTile(
            context,
            icon: Icons.notifications_active_rounded,
            title: "Notifications",
            subtitle: "Manage push notifications",
            trailing: Switch(
              value: true,
              onChanged: (bool value) {},
              activeColor: Colors.blueAccent,
            ),
          ),
          Divider(),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline_rounded,
            title: "About",
            subtitle: "Version 1.0.0",
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          Divider(),
          SizedBox(height: 20),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    void Function()? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade700,
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: Icon(Icons.logout_rounded, color: Colors.white),
        label: Text(
          "Logout",
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
        ),
        onPressed: () {
          _showLogoutDialog(context);
        },
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) async {
    TextEditingController oldPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();

    // Get email from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString("user_email") ?? "";

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              "Change Password",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: oldPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Old Password",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "New Password",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text(
                  "Cancel",
                  style: GoogleFonts.poppins(color: Colors.grey.shade700),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
                child: Text(
                  "Change",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                onPressed: () {
                  final oldPass = oldPasswordController.text.trim();
                  final newPass = newPasswordController.text.trim();

                  if (oldPass.isEmpty || newPass.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please fill in both fields")),
                    );
                  } else {
                    changePassword(context, email, oldPass, newPass);
                  }
                },
              ),
            ],
          ),
    );
  }


  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              "Logout",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              "Are you sure you want to logout?",
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            actions: [
              TextButton(
                child: Text(
                  "Cancel",
                  style: GoogleFonts.poppins(color: Colors.grey.shade700),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                ),
                child: Text(
                  "Logout",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                onPressed: () {
                  logout(context); // 👈 THIS LINE
                },
              ),
            ],
          ),
    );
  }


  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              "About TrashNet",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              "TrashNet is an advanced waste management system for reporting and optimizing waste collection.",
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            actions: [
              TextButton(
                child: Text(
                  "Close",
                  style: GoogleFonts.poppins(color: Colors.blueAccent),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  Future<void> changePassword(
    BuildContext context,
    String email,
    String oldPassword,
    String newPassword,
  ) async {
    final url = Uri.parse(
      // 'http://127.0.0.1:5000/api/settings/change-password',
      'http://192.168.248.39:5000/api/settings/change-password',
    ); // 🔁 Change if hosted
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "oldPassword": oldPassword,
          "newPassword": newPassword,
        }),
      );

      final resData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Password changed successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resData["message"] ?? "Failed to change password"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}


void logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // Remove all saved user data

  // Navigate to login screen
  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
}
