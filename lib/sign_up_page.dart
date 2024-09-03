import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dashboard.dart';
import 'firestore_service.dart';

class SignUpPage extends StatefulWidget {
  final String email;

  const SignUpPage({super.key, required this.email});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController bioController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  File? _profileImage;

  final FirestoreService firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    emailController.text = widget.email;
  }

  Future<void> _signUp() async {
    if (formKey.currentState!.validate()) {
      try {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        final user = credential.user;
        if (user != null) {
          String? profileImageUrl;
          if (_profileImage != null) {
            profileImageUrl = await _uploadProfileImage(user.uid);
          }

          final userData = {
            'name': nameController.text,
            'bio': bioController.text,
            'email': user.email,
            'profileImageUrl': profileImageUrl,
          };

          await firestoreService.addUser(userData, user.uid);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Dashboard()),
          );
        }
      } on FirebaseAuthException catch (e) {
        _handleFirebaseAuthException(e);
      } catch (e) {
        _showToast(e.toString());
      }
    } else {
      _showToast('Please fill out all fields');
    }
  }

  Future<String?> _uploadProfileImage(String uid) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$uid.jpg');
      await ref.putFile(_profileImage!);
      return await ref.getDownloadURL();
    } catch (e) {
      _showToast('Failed to upload profile image');
      return null;
    }
  }

  void _handleFirebaseAuthException(FirebaseAuthException e) {
    String errorMsg;
    if (e.code == 'weak-password') {
      errorMsg = 'The password provided is too weak.';
    } else if (e.code == 'email-already-in-use') {
      errorMsg = 'The email is already in use.';
    } else {
      errorMsg = 'An error occurred. Please try again.';
    }
    _showToast(errorMsg);
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      const Text(
                        'Congratulations',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Hind Jalandhar',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'on verifying the email belongs to you',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Hind Jalandhar',
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 50),
                      const Text(
                        'Sign up',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Hind Jalandhar',
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'We need something more',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Hind Jalandhar',
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _pickProfileImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                          child: _profileImage == null
                              ? const Icon(Icons.person,
                                  size: 50, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _pickProfileImage,
                        child: const Text('Select Profile Image',
                            style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: nameController,
                                keyboardType: TextInputType.name,
                                decoration: InputDecoration(
                                  labelText: 'Name',
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.person_outline),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                                style: const TextStyle(
                                  fontFamily: 'Hind Jalandhar',
                                  color: Color(0xFF22215B),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: emailController,
                                readOnly: true,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.email_outlined),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  } else if (!_isValidEmail(value)) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                                style: const TextStyle(
                                  fontFamily: 'Hind Jalandhar',
                                  color: Color(0xFF22215B),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: passwordController,
                                keyboardType: TextInputType.visiblePassword,
                                obscureText: !_passwordVisible,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _passwordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _passwordVisible = !_passwordVisible;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  return null;
                                },
                                style: const TextStyle(
                                  fontFamily: 'Hind Jalandhar',
                                  color: Color(0xFF22215B),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: confirmPasswordController,
                                keyboardType: TextInputType.visiblePassword,
                                obscureText: !_confirmPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _confirmPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _confirmPasswordVisible =
                                            !_confirmPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  } else if (value != passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                                style: const TextStyle(
                                  fontFamily: 'Hind Jalandhar',
                                  color: Color(0xFF22215B),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: bioController,
                                keyboardType: TextInputType.multiline,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  labelText: 'Bio',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.info_outline),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a bio';
                                  }
                                  return null;
                                },
                                style: const TextStyle(
                                  fontFamily: 'Hind Jalandhar',
                                  color: Color(0xFF22215B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF315EE7),
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
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isValidEmail(String email) {
    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regExp = RegExp(pattern);
    return regExp.hasMatch(email);
  }
}
