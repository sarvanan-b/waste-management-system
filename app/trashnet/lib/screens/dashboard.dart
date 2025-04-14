import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trashnet/screens/ReportListScreen.dart';

class DashboardData {
  final String totalReports;
  final String pending;
  final String recycled;
  final String alerts;

  DashboardData({
    required this.totalReports,
    required this.pending,
    required this.recycled,
    required this.alerts,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalReports: json['totalReports'].toString(),
      pending: json['pending'].toString(),
      recycled: json['recycled'].toString(),
      alerts: json['alerts'].toString(),
    );
  }
}

Future<DashboardData> fetchDashboardData() async {
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('user_email');

  if (email == null) {
    throw Exception('User email not found in SharedPreferences');
  }

  final response = await http.get(
    Uri.parse(
      'http://192.168.248.39:5000/api/dashboard/user/email?email=$email',
    ),
  );

  if (response.statusCode == 200) {
    return DashboardData.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load dashboard data');
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<DashboardData> dashboardFuture;

  @override
  void initState() {
    super.initState();
    dashboardFuture = fetchDashboardData();
  }

  void _navigateToReportList(String type) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReportListScreen(type: type)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe3f2fd), Color(0xFFffffff)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0, left: 16, right: 16),
          child: FutureBuilder<DashboardData>(
            future: dashboardFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData) {
                return const Center(child: Text("No dashboard data found."));
              }

              final data = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, User! 👋",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Manage waste efficiently with TrashNet.",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      children: [
                        _buildDashboardCard(
                          "Total Reports",
                          data.totalReports,
                          Icons.description,
                          Colors.blue,
                          "all",
                        ),
                        _buildDashboardCard(
                          "Pending",
                          data.pending,
                          Icons.pending_actions,
                          Colors.orange,
                          "pending",
                        ),
                        _buildDashboardCard(
                          "Recycled",
                          data.recycled,
                          Icons.recycling,
                          Colors.green,
                          "resolved",
                        ),
                        _buildDashboardCard(
                          "Alerts",
                          data.alerts,
                          Icons.warning,
                          Colors.red,
                          "alerts",
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String type,
  ) {
    return GestureDetector(
      onTap: () => _navigateToReportList(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
