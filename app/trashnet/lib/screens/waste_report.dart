// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:path/path.dart' as path;
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';

// class WasteReportScreen extends StatefulWidget {
//   const WasteReportScreen({super.key});

//   @override
//   _WasteReportScreenState createState() => _WasteReportScreenState();
// }

// class _WasteReportScreenState extends State<WasteReportScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController _locationController = TextEditingController();
//   final TextEditingController _notesController = TextEditingController();

//   String? selectedWasteType;
//   String? urgency;
//   double? latitude;
//   double? longitude;
//   File? _selectedImage;

//   final List<String> wasteTypes = [
//     "Organic Waste",
//     "Recyclable Waste",
//     "General Waste",
//     "Hazardous Waste",
//     "Bulk Waste",
//   ];

//   @override
//   void dispose() {
//     _locationController.dispose();
//     _notesController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     final pickedFile = await ImagePicker().pickImage(source: source);

//     if (pickedFile != null) {
//       final compressed = await _compressImage(File(pickedFile.path));
//       setState(() {
//         _selectedImage = compressed;
//       });
//     }
//   }

//   Future<File?> _compressImage(File file) async {
//     final dir = await Directory.systemTemp.createTemp();
//     final targetPath =
//         '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

//     final result = await FlutterImageCompress.compressAndGetFile(
//       file.absolute.path,
//       targetPath,
//       quality: 60,
//     );

//     return result != null ? File(result.path) : null;
//   }

//   Future<void> _getLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       _showSnackbar('Location services are disabled');
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         _showSnackbar('Location permission denied');
//         return;
//       }
//     }

//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );

//     latitude = position.latitude;
//     longitude = position.longitude;

//     List<Placemark> placemarks = await placemarkFromCoordinates(
//       latitude!,
//       longitude!,
//     );
//     if (placemarks.isNotEmpty) {
//       Placemark place = placemarks.first;
//       setState(() {
//         _locationController.text =
//             "${place.street}, ${place.locality}, ${place.administrativeArea}";
//       });
//     }
//   }

//   void _showSnackbar(String message) {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text(message)));
//   }

//   Future<void> _submitReport() async {
//     if (!_formKey.currentState!.validate()) return;

//     final confirm = await showDialog<bool>(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text("Confirm Submission"),
//             content: const Text(
//               "Are you sure you want to submit this waste report?",
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(false),
//                 child: const Text("Cancel"),
//               ),
//               ElevatedButton(
//                 onPressed: () => Navigator.of(context).pop(true),
//                 child: const Text("Submit"),
//               ),
//             ],
//           ),
//     );

//     if (confirm != true) return;

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userEmail = prefs.getString("user_email") ?? "";

//       final uri = Uri.parse("http://192.168.248.39:5000/api/waste/submit");
//       final request =
//           http.MultipartRequest("POST", uri)
//             ..fields['email'] = userEmail
//             ..fields['request_type'] = selectedWasteType!
//             ..fields['address'] = _locationController.text
//             ..fields['message'] = _notesController.text;

//       if (latitude != null && longitude != null) {
//         request.fields['location[type]'] = 'Point';
//         request.fields['location[coordinates][0]'] = longitude.toString();
//         request.fields['location[coordinates][1]'] = latitude.toString();
//       }

//       if (_selectedImage != null) {
//         request.files.add(
//           await http.MultipartFile.fromPath(
//             'image',
//             _selectedImage!.path,
//             filename: path.basename(_selectedImage!.path),
//           ),
//         );
//       }

//       final response = await request.send();

//       if (response.statusCode == 201) {
//         _showSnackbar("Request submitted successfully!");
//         _clearForm();
//       } else {
//         _showSnackbar("Submission failed! Try again.");
//       }
//     } catch (e) {
//       print("Error: $e");
//       _showSnackbar("Something went wrong!");
//     }
//   }

//   void _clearForm() {
//     setState(() {
//       selectedWasteType = null;
//       _locationController.clear();
//       _notesController.clear();
//       urgency = null;
//       _selectedImage = null;
//       latitude = null;
//       longitude = null;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
     
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               _buildDropdown(),
//               const SizedBox(height: 20),
//               _buildLocationInput(),
//               const SizedBox(height: 10),
//               if (latitude != null && longitude != null)
//                 Text(
//                   "Latitude: $latitude, Longitude: $longitude",
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: Colors.grey[700],
//                   ),
//                 ),
//               const SizedBox(height: 20),
//               _buildImagePicker(),
//               const SizedBox(height: 20),
//               _buildUrgencySelector(),
//               const SizedBox(height: 20),
//               _buildNotesField(),
//               const SizedBox(height: 25),
//               _buildSubmitButton(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDropdown() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("Waste Type", style: GoogleFonts.poppins(fontSize: 16)),
//         DropdownButtonFormField<String>(
//           value: selectedWasteType,
//           items:
//               wasteTypes
//                   .map(
//                     (type) => DropdownMenuItem(value: type, child: Text(type)),
//                   )
//                   .toList(),
//           onChanged: (value) => setState(() => selectedWasteType = value),
//           decoration: const InputDecoration(
//             border: OutlineInputBorder(),
//             contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
//           ),
//           validator: (value) => value == null ? "Select a type" : null,
//         ),
//       ],
//     );
//   }

//   Widget _buildLocationInput() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("Location", style: GoogleFonts.poppins(fontSize: 16)),
//         TextFormField(
//           readOnly: true,
//           controller: _locationController,
//           decoration: InputDecoration(
//             border: const OutlineInputBorder(),
//             hintText: "Enter location or use GPS",
//             suffixIcon: IconButton(
//               icon: const Icon(Icons.my_location),
//               onPressed: _getLocation,
//             ),
//             contentPadding: const EdgeInsets.symmetric(
//               vertical: 15,
//               horizontal: 10,
//             ),
//           ),
//           validator:
//               (value) =>
//                   value == null || value.isEmpty ? "Enter location" : null,
//         ),
//       ],
//     );
//   }

//  Widget _buildImagePicker() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("Upload Photo", style: GoogleFonts.poppins(fontSize: 16)),
//         Row(
//           children: [
//             ElevatedButton.icon(
//               onPressed: () => _pickImage(ImageSource.camera),
//               icon: const Icon(Icons.camera_alt),
//               label: const Text("Camera"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor:
//                     Colors.green, // Use backgroundColor instead of primary
//                 foregroundColor:
//                     Colors.white, // Use foregroundColor instead of onPrimary
//               ),
//             ),
//             const SizedBox(width: 15),
//             ElevatedButton.icon(
//               onPressed: () => _pickImage(ImageSource.gallery),
//               icon: const Icon(Icons.photo),
//               label: const Text("Gallery"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor:
//                     Colors.blue, // Use backgroundColor instead of primary
//                 foregroundColor:
//                     Colors.white, // Use foregroundColor instead of onPrimary
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 15),
//         if (_selectedImage != null)
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: Image.file(
//               _selectedImage!,
//               width: 120,
//               height: 120,
//               fit: BoxFit.cover,
//             ),
//           ),
//       ],
//     );
//   }


//   Widget _buildUrgencySelector() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("Urgency Level", style: GoogleFonts.poppins(fontSize: 16)),
//         Row(
//           children: [
//             Expanded(
//               child: RadioListTile<String>(
//                 title: const Text("Urgent"),
//                 value: "Urgent",
//                 groupValue: urgency,
//                 onChanged: (value) => setState(() => urgency = value),
//               ),
//             ),
//             Expanded(
//               child: RadioListTile<String>(
//                 title: const Text("Scheduled"),
//                 value: "Scheduled",
//                 groupValue: urgency,
//                 onChanged: (value) => setState(() => urgency = value),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildNotesField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("Additional Notes", style: GoogleFonts.poppins(fontSize: 16)),
//         TextFormField(
//           controller: _notesController,
//           maxLines: 3,
//           decoration: const InputDecoration(
//             border: OutlineInputBorder(),
//             hintText: "Any extra details...",
//             contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSubmitButton() {
//     return ElevatedButton(
//       onPressed: _submitReport,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.blue,
//         padding: const EdgeInsets.symmetric(vertical: 15),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//       child: Text(
//         "Submit Report",
//         style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
//       ),
//     );
//   }
// }


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class WasteReportScreen extends StatefulWidget {
  const WasteReportScreen({super.key});

  @override
  _WasteReportScreenState createState() => _WasteReportScreenState();
}

class _WasteReportScreenState extends State<WasteReportScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? selectedWasteType;
  String? urgency;
  double? latitude;
  double? longitude;
  File? _selectedImage;

  final List<String> wasteTypes = [
    "Organic Waste",
    "Recyclable Waste",
    "General Waste",
    "Hazardous Waste",
    "Bulk Waste",
  ];

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      final compressed = await _compressImage(File(pickedFile.path));
      setState(() {
        _selectedImage = compressed;
      });
    }
  }

  Future<File?> _compressImage(File file) async {
    final dir = await Directory.systemTemp.createTemp();
    final targetPath =
        '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 60,
    );

    return result != null ? File(result.path) : null;
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackbar('Location services are disabled');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackbar('Location permission denied');
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    latitude = position.latitude;
    longitude = position.longitude;

    List<Placemark> placemarks = await placemarkFromCoordinates(
      latitude!,
      longitude!,
    );
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      setState(() {
        _locationController.text =
            "${place.street}, ${place.locality}, ${place.administrativeArea}";
      });
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Confirm Submission"),
            content: const Text(
              "Are you sure you want to submit this waste report?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Submit"),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString("user_email") ?? "";

      final uri = Uri.parse("http://192.168.248.39:5000/api/waste/submit");
      final request =
          http.MultipartRequest("POST", uri)
            ..fields['email'] = userEmail
            ..fields['request_type'] = selectedWasteType!
            ..fields['address'] = _locationController.text
            ..fields['message'] = _notesController.text;

      if (latitude != null && longitude != null) {
        request.fields['location[type]'] = 'Point';
        request.fields['location[coordinates][0]'] = longitude.toString();
        request.fields['location[coordinates][1]'] = latitude.toString();
      }

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
        _showSnackbar("Request submitted successfully!");
        _clearForm();
      } else {
        _showSnackbar("Submission failed! Try again.");
      }
    } catch (e) {
      print("Error: $e");
      _showSnackbar("Something went wrong!");
    }
  }

  void _clearForm() {
    setState(() {
      selectedWasteType = null;
      _locationController.clear();
      _notesController.clear();
      urgency = null;
      _selectedImage = null;
      latitude = null;
      longitude = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildDropdown(),
              const SizedBox(height: 20),
              _buildLocationInput(),
              const SizedBox(height: 10),
              if (latitude != null && longitude != null)
                Text(
                  "Latitude: $latitude, Longitude: $longitude",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              const SizedBox(height: 20),
              _buildImagePicker(),
              const SizedBox(height: 20),
              _buildUrgencySelector(),
              const SizedBox(height: 20),
              _buildNotesField(),
              const SizedBox(height: 25),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Waste Type", style: GoogleFonts.poppins(fontSize: 16)),
        DropdownButtonFormField<String>(
          value: selectedWasteType,
          items:
              wasteTypes
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
          onChanged: (value) => setState(() => selectedWasteType = value),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          ),
          validator: (value) => value == null ? "Select a type" : null,
        ),
      ],
    );
  }

  Widget _buildLocationInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Location", style: GoogleFonts.poppins(fontSize: 16)),
        TextFormField(
          readOnly: true,
          controller: _locationController,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: "Enter location or use GPS",
            suffixIcon: IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: _getLocation,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 10,
            ),
          ),
          validator:
              (value) =>
                  value == null || value.isEmpty ? "Enter location" : null,
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Upload Photo", style: GoogleFonts.poppins(fontSize: 16)),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text("Camera"),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.blue, // Use backgroundColor instead of primary
                foregroundColor:
                    Colors.white, // Use foregroundColor instead of onPrimary
              ),
            ),
            const SizedBox(width: 15),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo),
              label: const Text("Gallery"),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.blue, // Use backgroundColor instead of primary
                foregroundColor:
                    Colors.white, // Use foregroundColor instead of onPrimary
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        if (_selectedImage != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              _selectedImage!,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
      ],
    );
  }


  Widget _buildUrgencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Urgency Level", style: GoogleFonts.poppins(fontSize: 16)),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text("Urgent"),
                value: "Urgent",
                groupValue: urgency,
                onChanged: (value) => setState(() => urgency = value),
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text("Scheduled"),
                value: "Scheduled",
                groupValue: urgency,
                onChanged: (value) => setState(() => urgency = value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Additional Notes", style: GoogleFonts.poppins(fontSize: 16)),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Any extra details...",
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitReport,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        "Submit Report",
        style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
