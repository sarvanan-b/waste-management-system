import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart'; // For smooth transition

class Alert {
  final String title;
  final String description;
  final String date;
  final String type; // "Pickup" or "Issue"
  final String status; // "Pending" or "Resolved"

  Alert({
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    required this.status,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Alert> alerts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDummyAlerts();
  }

  Future<void> loadDummyAlerts() async {
    await Future.delayed(Duration(seconds: 1)); // simulate network delay
    setState(() {
      alerts = [
        Alert(
          title: "Pickup Scheduled",
          description: "Your waste pickup is scheduled for tomorrow at 9 AM.",
          date: "21 April 2025",
          type: "Pickup",
          status: "Pending",
        ),
        Alert(
          title: "Overflow Detected",
          description:
              "A waste container in your area is full and requires urgent action.",
          date: "20 April 2025",
          type: "Issue",
          status: "Pending",
        ),
        Alert(
          title: "Pickup Completed",
          description:
              "Your last waste pickup was successfully completed. Thank you!",
          date: "18 April 2025",
          type: "Pickup",
          status: "Resolved",
        ),
        Alert(
          title: "Maintenance Notice",
          description:
              "Waste processing facility will be under maintenance today.",
          date: "19 April 2025",
          type: "Issue",
          status: "Resolved",
        ),
      ];
      isLoading = false;
    });
  }

  Color getAlertColor(Alert alert) {
    if (alert.type == "Issue") {
      return Colors.redAccent.shade100;
    } else {
      return Colors.greenAccent.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: loadDummyAlerts,
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: OpenContainer(
                        closedElevation: 0,
                        transitionType: ContainerTransitionType.fade,
                        openBuilder:
                            (context, _) => AlertDetailScreen(alert: alert),
                        closedBuilder:
                            (context, openContainer) => GestureDetector(
                              onTap: openContainer,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: getAlertColor(alert),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 15,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 28,
                                    child: Icon(
                                      alert.type == "Pickup"
                                          ? Icons.local_shipping_rounded
                                          : Icons.warning_rounded,
                                      color:
                                          alert.type == "Pickup"
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  ),
                                  title: Text(
                                    alert.title,
                                    style: GoogleFonts.poppins(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 4),
                                      Text(
                                        alert.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            alert.date,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          Chip(
                                            label: Text(
                                              alert.status,
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            backgroundColor:
                                                alert.status == "Pending"
                                                    ? Colors.orange
                                                    : Colors.blue,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}

class AlertDetailScreen extends StatelessWidget {
  final Alert alert;

  const AlertDetailScreen({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(alert.title),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 18),
                    SizedBox(width: 8),
                    Text(alert.date, style: GoogleFonts.poppins(fontSize: 14)),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  alert.description,
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
                Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Chip(
                    label: Text(
                      alert.status,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor:
                        alert.status == "Pending" ? Colors.orange : Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
