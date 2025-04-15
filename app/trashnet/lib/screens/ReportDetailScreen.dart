// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:http/http.dart' as http;

// class ReportDetailScreen extends StatelessWidget {
//   final Map<String, dynamic> report;

//   const ReportDetailScreen({Key? key, required this.report}) : super(key: key);

//   String formatDate(String rawDate) {
//     try {
//       final dateTime = DateTime.parse(rawDate);
//       return DateFormat('EEE, MMM d, y - hh:mm a').format(dateTime);
//     } catch (e) {
//       return rawDate;
//     }
//   }

//   Color getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case "pending":
//         return Colors.orange;
//       case "resolved":
//         return Colors.green;
//       case "alerts":
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   Future<void> openMap(String lat, String long) async {
//     final url = "https://www.google.com/maps/search/?api=1&query=$lat,$long";
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       throw 'Could not open the map';
//     }
//   }

//   void _confirmDelete(BuildContext context) {
//     showDialog(
//       context: context,
//       builder:
//           (ctx) => AlertDialog(
//             title: Text("Confirm Delete"),
//             content: Text("Are you sure you want to delete this report?"),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(ctx).pop(),
//                 child: Text("Cancel"),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.of(ctx).pop(); // Close dialog
//                   _deleteReport(context);
//                 },
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                 child: Text("Delete"),
//               ),
//             ],
//           ),
//     );
//   }

//   Future<void> _deleteReport(BuildContext context) async {
//     final reportId = report['_id'];
//     // print("Deleting report with ID: $reportId");

//     try {
//       final response = await http.delete(
//         Uri.parse('http://192.168.248.39:5000/api/dashboard/reports/$reportId'),
//       );

//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Report deleted successfully.")));
//         Navigator.of(context).pop(true); // Send true to indicate deletion
//       } else {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Failed to delete report.")));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error occurred: $e")));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final location = report['location'];
//     final lat = location?['coordinates']?[1]?.toString() ?? '';
//     final long = location?['coordinates']?[0]?.toString() ?? '';

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Report Details", style: GoogleFonts.poppins()),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.delete),
//             onPressed: () => _confirmDelete(context),
//           ),
//         ],
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           _buildInfoCard(
//             icon: Icons.category,
//             title: "Request Type",
//             value: report['request_type'],
//           ),
//           _buildInfoCard(
//             icon: Icons.message,
//             title: "Message",
//             value: report['message'] ?? "N/A",
//           ),
//           _buildInfoCard(
//             icon: Icons.location_on,
//             title: "Address",
//             value: report['address'],
//             trailing:
//                 lat.isNotEmpty && long.isNotEmpty
//                     ? TextButton.icon(
//                       onPressed: () => openMap(lat, long),
//                       icon: Icon(Icons.map),
//                       label: Text("View Map"),
//                     )
//                     : null,
//           ),
//           _buildInfoCard(
//             icon: Icons.person,
//             title: "User Email",
//             value: report['email'],
//           ),
//           _buildInfoCard(
//             icon: Icons.calendar_today,
//             title: "Time",
//             value: formatDate(report['time'] ?? ""),
//           ),
//           _buildStatusCard(report['status']),
//           const SizedBox(height: 20),
//           if (report['imageUrl'] != null && report['imageUrl'] != "")
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Image.network(report['imageUrl']),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoCard({
//     required IconData icon,
//     required String title,
//     required String value,
//     Widget? trailing,
//   }) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: ListTile(
//         leading: Icon(icon, color: Colors.teal),
//         title: Text(
//           title,
//           style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
//         ),
//         subtitle: Text(value, style: GoogleFonts.poppins(fontSize: 14)),
//         trailing: trailing,
//       ),
//     );
//   }

//   Widget _buildStatusCard(String status) {
//     final color = getStatusColor(status);
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: ListTile(
//         leading: Icon(Icons.verified, color: color),
//         title: Text(
//           "Status",
//           style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
//         ),
//         trailing: Chip(
//           label: Text(
//             status.toUpperCase(),
//             style: const TextStyle(color: Colors.white),
//           ),
//           backgroundColor: color,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


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

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text("Confirm Delete"),
            content: Text("Are you sure you want to delete this report?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close dialog
                  _deleteReport(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text("Delete"),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteReport(BuildContext context) async {
    final reportId = report['_id'];
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.248.39:5000/api/dashboard/reports/$reportId'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Report deleted successfully.")));
        Navigator.of(context).pop(true); // Send true to indicate deletion
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to delete report.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error occurred: $e")));
    }
  }

  Future<void> _editReport(BuildContext context) async {
    final requestTypeController = TextEditingController(
      text: report['request_type'],
    );
    final messageController = TextEditingController(text: report['message']);
    final addressController = TextEditingController(text: report['address']);

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text("Edit Report"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: requestTypeController,
                  decoration: InputDecoration(labelText: "Request Type"),
                ),
                TextField(
                  controller: messageController,
                  decoration: InputDecoration(labelText: "Message"),
                ),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: "Address"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _updateReport(
                    context,
                    requestTypeController.text,
                    messageController.text,
                    addressController.text,
                  );
                },
                child: Text("Save Changes"),
              ),
            ],
          ),
    );
  }

  Future<void> _updateReport(
    BuildContext context,
    String requestType,
    String message,
    String address,
  ) async {
    final reportId = report['_id'];

    try {
      final response = await http.put(
        Uri.parse('http://192.168.248.39:5000/api/dashboard/edit_reports/$reportId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'request_type': requestType,
          'message': message,
          'address': address,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Report updated successfully.")));
        Navigator.of(
          context,
        ).pop(true); // Close the screen and refresh the list
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to update report.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error occurred: $e")));
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
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _editReport(context),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
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

