import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'firestore_service.dart';
import 'models/app_user.dart';
import 'dart:io';

class UpdateProfilePage extends StatefulWidget {
  final AppUser user;

  const UpdateProfilePage({super.key, required this.user});

  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  late TextEditingController nameController;
  late TextEditingController bioController;
  File? _profileImage;
  bool _isLoading = false;

  String? originalName;
  String? originalBio;
  String? originalProfileImageUrl;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    bioController = TextEditingController(text: widget.user.bio);

    originalName = widget.user.name;
    originalBio = widget.user.bio;
    originalProfileImageUrl = widget.user.profileImageUrl;
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> _updateUserProfile() async {
    // Check if any changes have been made
    if (nameController.text == originalName &&
        bioController.text == originalBio &&
        _profileImage == null) {
      _showToast("No changes detected.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String? profileImageUrl;
      if (_profileImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${user.uid}.jpg');
        await ref.putFile(_profileImage!);
        profileImageUrl = await ref.getDownloadURL();
      }

      final updatedUser = AppUser(
        id: widget.user.id,
        name: nameController.text,
        email: user.email!, // use the current email from FirebaseAuth
        bio: bioController.text,
        profileImageUrl: profileImageUrl ?? widget.user.profileImageUrl,
      );

      await FirestoreService().updateUser(updatedUser.toMap(), user.uid);

      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context);
    }
  }

  Future<void> _pickProfileImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D47A1),
              Color(0xFF1976D2),
              Color(0xFF42A5F5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 30),
                              _buildProfileCard(),
                              const SizedBox(height: 30),
                              _buildUpdateButton(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _profileImage != null
                  ? FileImage(_profileImage!)
                  : widget.user.profileImageUrl != null
                      ? NetworkImage(widget.user.profileImageUrl!)
                          as ImageProvider
                      : null,
              child:
                  _profileImage == null && widget.user.profileImageUrl == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
            ),
            TextButton(
              onPressed: _pickProfileImage,
              child: const Text(
                'Select Profile Image',
                style: TextStyle(
                  color: Color(0xFF1976D2),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
                height: 20), // Add space between image and text fields
            _buildTextField(
              controller: nameController,
              label: 'Name',
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: bioController,
              label: 'Bio',
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF1976D2)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Color(0xFF1976D2)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1976D2)),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
    );
  }

  Widget _buildUpdateButton() {
    return ElevatedButton(
      onPressed: _updateUserProfile,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontFamily: 'Hind',
          fontSize: 18,
        ),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text('Update Profile'),
    );
  }
}
