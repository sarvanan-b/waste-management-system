class Alert {
  final String title;
  final String description;
  final String date;
  final String type;
  final String status;

  Alert({
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    required this.status,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      title: json['title'],
      description: json['description'],
      date: json['date'],
      type: json['type'],
      status: json['status'],
    );
  }
}
