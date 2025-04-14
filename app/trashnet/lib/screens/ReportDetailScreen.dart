// report_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportDetailScreen extends StatelessWidget {
  final Map<String, dynamic> report;

  const ReportDetailScreen({Key? key, required this.report}) : super(key: key);

  String formatDate(String rawDate) {
    try {
      final dateTime = DateTime.parse(rawDate);
      return DateFormat('EEE, MMM d, y - hh:mm a').format(dateTime);
    } catch (e) {
      return rawDate;
    }
  }

  Color getStatusColor(String status) {
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

  Future<void> openMap(String lat, String long) async {
    final url = "https://www.google.com/maps/search/?api=1&query=$lat,$long";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not open the map';
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = report['location'];
    final lat = location?['coordinates']?[1]?.toString() ?? '';
    final long = location?['coordinates']?[0]?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text("Report Details", style: GoogleFonts.poppins()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(
            icon: Icons.category,
            title: "Request Type",
            value: report['request_type'],
          ),
          _buildInfoCard(
            icon: Icons.message,
            title: "Message",
            value: report['message'] ?? "N/A",
          ),
          _buildInfoCard(
            icon: Icons.location_on,
            title: "Address",
            value: report['address'],
            trailing:
                lat.isNotEmpty && long.isNotEmpty
                    ? TextButton.icon(
                      onPressed: () => openMap(lat, long),
                      icon: Icon(Icons.map),
                      label: Text("View Map"),
                    )
                    : null,
          ),
          _buildInfoCard(
            icon: Icons.person,
            title: "User Email",
            value: report['email'],
          ),
          _buildInfoCard(
            icon: Icons.calendar_today,
            title: "Time",
            value: formatDate(report['time'] ?? ""),
          ),
          _buildStatusCard(report['status']),
          const SizedBox(height: 20),
          if (report['imageUrl'] != null && report['imageUrl'] != "")
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(report['imageUrl']),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    Widget? trailing,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(value, style: GoogleFonts.poppins(fontSize: 14)),
        trailing: trailing,
      ),
    );
  }

  Widget _buildStatusCard(String status) {
    final color = getStatusColor(status);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.verified, color: color),
        title: Text(
          "Status",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        trailing: Chip(
          label: Text(
            status.toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: color,
        ),
      ),
    );
  }
}
