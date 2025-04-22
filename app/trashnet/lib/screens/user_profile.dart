import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'dart:convert';

class User {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String profileImage;

  User({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.profileImage,
  });
}

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  File? _image;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  bool isEditing = false;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('user_email') ?? '';

    if (email.isNotEmpty) {
      var response = await http.get(
        Uri.parse(
          "http://192.168.248.39:5000/api/users/get_profile?email=$email",
        ),
      );

      if (response.statusCode == 200) {
        var userData = jsonDecode(response.body);

        setState(() {
          currentUser = User(
            name: userData['name'],
            email: userData['email'],
            phone: userData['phone'],
            address: userData['address'],
            profileImage: userData['profileImage'],
          );

          nameController.text = currentUser!.name;
          emailController.text = currentUser!.email;
          phoneController.text = currentUser!.phone;
          addressController.text = currentUser!.address;
        });

        // Save profile image to shared preferences
        await prefs.setString('user_profile_image', currentUser!.profileImage);
      } else {
        print("Failed to load user data: ${response.statusCode}");
      }
    }
  }

  Future<void> updateProfileToBackend({
    required String name,
    required String email,
    required String phone,
    required String address,
    File? profileImage,
  }) async {
    var uri = Uri.parse("http://192.168.248.39:5000/api/users/profile");
    var request = http.MultipartRequest("PUT", uri);

    request.fields['name'] = name;
    request.fields['phone'] = phone;
    request.fields['email'] = email;
    request.fields['address'] = address;

    if (profileImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'profileImage',
          profileImage.path,
          filename: path.basename(profileImage.path),
        ),
      );
    }

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(responseBody);
      var newProfileImage = jsonResponse['profileImage'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile_image', newProfileImage);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Profile updated successfully")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update profile")));
      print("Response body: $responseBody");
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _showImagePreview() {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child:
                    _image != null
                        ? Image.file(_image!)
                        : Image.network(
                          currentUser!.profileImage,
                          fit: BoxFit.cover,
                        ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          currentUser == null
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(height: 50),
                    Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: _showImagePreview,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.blueAccent,
                                  width: 3,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                    offset: Offset(2, 4),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage:
                                    _image != null
                                        ? FileImage(_image!)
                                        : currentUser!.profileImage.isNotEmpty
                                        ? NetworkImage(
                                              currentUser!.profileImage,
                                            )
                                            as ImageProvider
                                        : AssetImage(
                                          "assets/images/profile.jpg",
                                        ),
                                child:
                                    _image == null &&
                                            currentUser!.profileImage.isEmpty
                                        ? Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Colors.white,
                                        )
                                        : null,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.blue,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 25),
                    _buildProfileDetail("Full Name", nameController, isEditing),
                    _buildProfileDetail("Email", emailController, false),
                    _buildProfileDetail("Phone", phoneController, isEditing),
                    _buildProfileDetail(
                      "Address",
                      addressController,
                      isEditing,
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () async {
                        if (isEditing) {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setString(
                            'user_name',
                            nameController.text,
                          );
                          await prefs.setString(
                            'user_email',
                            emailController.text,
                          );
                          await prefs.setString('phone', phoneController.text);
                          await prefs.setString(
                            'address',
                            addressController.text,
                          );

                          await updateProfileToBackend(
                            name: nameController.text,
                            email: emailController.text,
                            phone: phoneController.text,
                            address: addressController.text,
                            profileImage: _image,
                          );

                          setState(() {
                            isEditing = false;
                          });
                        } else {
                          setState(() => isEditing = true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEditing ? Colors.green : Colors.blue,
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        isEditing ? "Save Changes" : "Edit Profile",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildProfileDetail(
    String label,
    TextEditingController controller,
    bool isEditing,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child:
            isEditing
                ? TextField(
                  controller: controller,
                  style: GoogleFonts.poppins(fontSize: 16),
                  decoration: InputDecoration(
                    labelText: label,
                    border: InputBorder.none,
                  ),
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      controller.text,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
