import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bottom_navigation.dart';
import 'home_screen.dart';
import 'notice_screen.dart';
import 'dart:io';
import '../colors.dart'; // Import your colors file
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Function(Map<String, dynamic>) onProfileUpdated; // Add callback

  const ProfileScreen({Key? key, this.userData, required this.onProfileUpdated}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 1;
  File? _profileImage;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _roomNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.userData != null) {
      _usernameController.text = widget.userData!['username'] ?? '';
      _emailController.text = widget.userData!['email'] ?? '';
      _phoneNumberController.text = widget.userData!['phoneNumber'] ?? '';
      _roomNumberController.text = widget.userData!['roomNumber'] ?? '';
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _roomNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateProfile() async {
    // Get the updated profile information
    final String username = _usernameController.text;
    final String email = _emailController.text;
    final String phoneNumber = _phoneNumberController.text;
    final String roomNumber = _roomNumberController.text;

    // Call the backend function to update the profile
    await updateProfileBackend(username, email, phoneNumber, roomNumber, _profileImage);

    // Update the userData map and pass it back to the HomeScreen
    Map<String, dynamic> updatedUserData = {
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'roomNumber': roomNumber,
      if (_profileImage != null) 'profileImage': await _uploadProfileImage(_profileImage!),
    };
    widget.onProfileUpdated(updatedUserData);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile updated successfully'),
        backgroundColor: AppColors.backlight,
      ),
    );

    // Optionally, navigate to another screen after updating the profile
    // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => NextScreen()));
  }

  Future<void> updateProfileBackend(String username, String email, String phoneNumber, String roomNumber, File? profileImage) async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Update the profile information in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'username': username,
        'email': email,
        'phoneNumber': phoneNumber,
        'roomNumber': roomNumber,
        if (profileImage != null) 'profileImage': await _uploadProfileImage(profileImage)
      });
    }
  }

  Future<String> _uploadProfileImage(File profileImage) async {
    // Implement your logic to upload the profile image to Firebase Storage
    // and return the download URL of the uploaded image
    // This is a placeholder implementation, you'll need to replace it with actual upload logic
    return 'https://example.com/profileImage.jpg';
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 0) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen(userData: widget.userData)));
      } else if (index == 2) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => NoticeScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          'Profile',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textBlack),
        ),
        centerTitle: true,

      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : (widget.userData != null && widget.userData!['profileImage'] != null
                      ? NetworkImage(widget.userData!['profileImage'])
                      : AssetImage('assets/images/userAvatar.jpg')) as ImageProvider,
                ),
                SizedBox(height: 10),
                Text(
                  widget.userData?['username'] ?? 'User',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textBlack),
                ),
                GestureDetector(
                  onTap: () => _showImageSourceActionSheet(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 5),
                      Text('Change Profile Picture'),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField(controller: _usernameController, labelText: 'Username'),
                SizedBox(height: 10),
                _buildTextField(controller: _emailController, labelText: 'Email'),
                SizedBox(height: 10),
                _buildTextField(controller: _phoneNumberController, labelText: 'Phone number'),
                SizedBox(height: 10),
                _buildTextField(controller: _roomNumberController, labelText: 'Room Number', readOnly: true),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.textBlack,
                    backgroundColor: AppColors.backgroundColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    minimumSize: const Size(100, 40),
                  ),
                  onPressed: _updateProfile,
                  child: Text('Update'),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTap,
        context: context,
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String labelText, bool readOnly = false, Widget? suffixIcon}) {
    return TextField(
      controller: controller,
      readOnly: readOnly, // Make the TextField read-only
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: AppColors.textBlack, fontSize: 16, fontWeight: FontWeight.bold,),
        filled: true,
        fillColor: AppColors.LightGray41,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(10.0),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
