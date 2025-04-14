import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class WasteReportScreen extends StatefulWidget {
  const WasteReportScreen({super.key});

  @override
  _WasteReportScreenState createState() => _WasteReportScreenState();
}

class _WasteReportScreenState extends State<WasteReportScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedWasteType;
  String location = "Select Location";
  File? _selectedImage;
  String? urgency;
  double? latitude;
  double? longitude;
  TextEditingController notesController = TextEditingController();

  final List<String> wasteTypes = [
    "Organic Waste",
    "Recyclable Waste",
    "General Waste",
    "Hazardous Waste",
    "Bulk Waste",
  ];

  void _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Location services are disabled')));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Location permission denied')));
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    latitude = position.latitude;
    longitude = position.longitude;

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      setState(() {
        location =
            "${place.street}, ${place.locality}, ${place.administrativeArea}";
      });
    }
  }

  void _submitReport() async {
    if (_formKey.currentState!.validate()) {
      try {
        final uri = Uri.parse("http://192.168.248.39:5000/api/waste/submit");
        final request = http.MultipartRequest("POST", uri);

        request.fields['wasteType'] = selectedWasteType!;
        request.fields['location'] = location;
        request.fields['urgency'] = urgency ?? "";
        request.fields['notes'] = notesController.text;
        request.fields['latitude'] = latitude?.toString() ?? '';
        request.fields['longitude'] = longitude?.toString() ?? '';

        if (_selectedImage != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'image',
              _selectedImage!.path,
              filename: path.basename(_selectedImage!.path),
            ),
          );
        }

        final response = await request.send();

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Waste report submitted successfully!")),
          );
          setState(() {
            selectedWasteType = null;
            location = "Select Location";
            _selectedImage = null;
            urgency = null;
            latitude = null;
            longitude = null;
            notesController.clear();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Submission failed! Try again.")),
          );
        }
      } catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Something went wrong!")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text("Waste Type", style: GoogleFonts.poppins(fontSize: 16)),
              DropdownButtonFormField<String>(
                value: selectedWasteType,
                items:
                    wasteTypes
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                onChanged: (value) => setState(() => selectedWasteType = value),
                decoration: InputDecoration(border: OutlineInputBorder()),
                validator: (value) => value == null ? "Select a type" : null,
              ),
              SizedBox(height: 16),

              Text("Location", style: GoogleFonts.poppins(fontSize: 16)),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(text: location),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter location or use GPS",
                  suffixIcon: IconButton(
                    icon: Icon(Icons.my_location),
                    onPressed: _getLocation,
                  ),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? "Enter location"
                            : null,
              ),
              SizedBox(height: 8),
              if (latitude != null && longitude != null)
                Text(
                  "Latitude: $latitude, Longitude: $longitude",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              SizedBox(height: 16),

              Text("Upload Photo", style: GoogleFonts.poppins(fontSize: 16)),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: Icon(Icons.camera_alt),
                    label: Text("Camera"),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: Icon(Icons.photo),
                    label: Text("Gallery"),
                  ),
                ],
              ),
              SizedBox(height: 10),
              _selectedImage != null
                  ? Image.file(_selectedImage!, width: 100, height: 100)
                  : Container(),
              SizedBox(height: 16),

              Text("Urgency Level", style: GoogleFonts.poppins(fontSize: 16)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text("Urgent"),
                      value: "Urgent",
                      groupValue: urgency,
                      onChanged: (value) => setState(() => urgency = value),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text("Scheduled"),
                      value: "Scheduled",
                      groupValue: urgency,
                      onChanged: (value) => setState(() => urgency = value),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              Text(
                "Additional Notes",
                style: GoogleFonts.poppins(fontSize: 16),
              ),
              TextFormField(
                controller: notesController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Any extra details...",
                ),
                maxLines: 3,
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Submit Report",
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
