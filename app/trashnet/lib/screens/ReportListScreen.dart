  import 'package:flutter/material.dart';
  import 'package:http/http.dart' as http;
  import 'package:shared_preferences/shared_preferences.dart';
  import 'dart:convert';
  import 'package:trashnet/screens/ReportDetailScreen.dart';
  import 'package:google_fonts/google_fonts.dart';

  class ReportListScreen extends StatefulWidget {
    final String type;

    const ReportListScreen({super.key, required this.type});

    @override
    State<ReportListScreen> createState() => _ReportListScreenState();
  }

  class _ReportListScreenState extends State<ReportListScreen> {
    List<dynamic> reports = [];
    bool isLoading = true;
    String? error;

    @override
    void initState() {
      super.initState();
      fetchReports();
    }

    Future<void> fetchReports() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final email = prefs.getString('user_email');

        if (email == null) {
          setState(() {
            error = "User email not found in SharedPreferences";
            isLoading = false;
          });
          return;
        }

        final response = await http.get(
          Uri.parse(
            'http://192.168.248.39:5000/api/dashboard/reports?email=$email&type=${widget.type}',
          ),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            reports = data;
            isLoading = false;
          });
        } else {
          setState(() {
            error = "Failed to load reports";
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          error = "An error occurred: $e";
          isLoading = false;
        });
      }
    }

    @override
    Widget build(BuildContext context) {
      String screenTitle = _getTitle(widget.type);

      return Scaffold(
        appBar: AppBar(
          title: Text(screenTitle, style: GoogleFonts.poppins()),
          backgroundColor: Colors.blue,
        ),
        body:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                ? Center(child: Text(error!))
                : reports.isEmpty
                ? const Center(child: Text("No reports found."))
                : ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        leading: Icon(
                          Icons.report,
                          color: _getStatusColor(report['status']),
                          size: 40,
                        ),
                        title: Text(
                          report['request_type'],
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "Status: ${report['status']}",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: _getStatusColor(report['status']),
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.teal,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ReportDetailScreen(report: report),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      );
    }

    String _getTitle(String type) {
      switch (type) {
        case "pending":
          return "Pending Reports";
        case "resolved":
          return "Recycled Reports";
        case "alerts":
          return "High Urgency Alerts";
        default:
          return "All Reports";
      }
    }

    Color _getStatusColor(String status) {
      switch (status.toLowerCase()) {
        case "pending":
          return Colors.orange;
        case "resolved":
          return Colors.green;
        case "alerts":
          return Colors.red;
        default:
          return Colors.grey;
      }
    }
  }
