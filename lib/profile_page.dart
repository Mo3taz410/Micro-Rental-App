import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import Font Awesome
import 'models/app_user.dart';
import 'login_page.dart';
import 'update_profile_page.dart';
import 'dashboard.dart';
import 'chat_page.dart';
import 'saved_properties_page.dart';
import 'your_properties_page.dart';
import 'contact_us_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 3;
  User? user = FirebaseAuth.instance.currentUser;

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
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Hind Jalandhar',
                  ),
                ),
                centerTitle: true,
              ),
              Expanded(
                child: user == null
                    ? const Center(
                        child: Text(
                          'No user logged in',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Hind Jalandhar',
                          ),
                        ),
                      )
                    : StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(user!.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error: ${snapshot.error}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }
                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return const Center(
                              child: Text(
                                'User data not found',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'Hind Jalandhar',
                                ),
                              ),
                            );
                          }

                          var userData =
                              snapshot.data!.data() as Map<String, dynamic>;
                          var appUser =
                              AppUser.fromMap(snapshot.data!.id, userData);

                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _buildProfileCard(appUser),
                                  const SizedBox(height: 20),
                                  _buildActionButtons(appUser),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: GNav(
        backgroundColor: const Color(0xFF0A4DA0), // Updated to match the design
        color: Colors.white70,
        activeColor: Colors.white,
        tabBackgroundColor: const Color(0xFF1976D2),
        iconSize: 24,
        padding: const EdgeInsets.fromLTRB(18, 18, 10, 18),
        gap: 8,
        tabs: const [
          GButton(
            icon: Icons.home_outlined,
            text: 'Home',
          ),
          GButton(
            icon: Icons.chat_bubble_outline,
            text: 'Chat',
          ),
          GButton(
            icon: Icons.favorite_border,
            text: 'Saved',
          ),
          GButton(
            icon: Icons.person_outline,
            text: 'Profile',
          ),
        ],
        selectedIndex: _selectedIndex,
        onTabChange: (index) {
          if (!mounted) return;
          setState(() {
            _selectedIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Dashboard()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ChatPage()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const SavedPropertiesPage()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
              break;
            default:
              break;
          }
        },
      ),
    );
  }

  Widget _buildProfileCard(AppUser appUser) {
    return Card(
      color: const Color(0xFFF5F5F5), // Light gray color for the card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: appUser.profileImageUrl != null
                  ? NetworkImage(appUser.profileImageUrl!)
                  : null,
              child: appUser.profileImageUrl == null
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            const SizedBox(height: 20),
            Text(
              appUser.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Hind Jalandhar',
                color: Color(0xFF22215B),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              appUser.email,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontFamily: 'Hind Jalandhar',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              appUser.bio,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontFamily: 'Hind Jalandhar',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(AppUser appUser) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateProfilePage(user: appUser),
                ),
              );
            },
            icon: const FaIcon(
              FontAwesomeIcons.userEdit,
              size: 18, // Adjust size for better alignment
            ),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Update your Information',
                style: TextStyle(
                  fontFamily: 'Hind Jalandhar',
                  fontSize: 16, // Adjust font size for consistency
                ),
              ),
            ),
            style: ElevatedButton.styleFrom(
              alignment:
                  Alignment.centerLeft, // Align content to the center left
              padding: const EdgeInsets.symmetric(
                  vertical: 15, horizontal: 20), // Adjust padding
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF0D47A1), // Dark blue for buttons
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactUsPage()),
              );
            },
            icon: const FaIcon(
              FontAwesomeIcons.phone,
              size: 18, // Adjust size for better alignment
            ),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Contact Us',
                style: TextStyle(
                  fontFamily: 'Hind Jalandhar',
                  fontSize: 16, // Adjust font size for consistency
                ),
              ),
            ),
            style: ElevatedButton.styleFrom(
              alignment:
                  Alignment.centerLeft, // Align content to the center left
              padding: const EdgeInsets.symmetric(
                  vertical: 15, horizontal: 20), // Adjust padding
              foregroundColor: Colors.white,
              backgroundColor:
                  const Color(0xFF1B5E20), // Dark green for consistency
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        YourPropertiesPage(userId: user!.uid)),
              );
            },
            icon: const FaIcon(
              FontAwesomeIcons.home,
              size: 18, // Adjust size for better alignment
            ),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Your Properties',
                style: TextStyle(
                  fontFamily: 'Hind Jalandhar',
                  fontSize: 16, // Adjust font size for consistency
                ),
              ),
            ),
            style: ElevatedButton.styleFrom(
              alignment:
                  Alignment.centerLeft, // Align content to the center left
              padding: const EdgeInsets.symmetric(
                  vertical: 15, horizontal: 20), // Adjust padding
              foregroundColor: Colors.white,
              backgroundColor:
                  const Color(0xFF0D47A1), // Dark blue for consistency
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.warning,
                title: 'Confirm Log Out',
                desc: 'Are you sure you want to log out?',
                btnCancelOnPress: () {},
                btnOkOnPress: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },
              ).show();
            },
            icon: const FaIcon(
              FontAwesomeIcons.signOutAlt,
              size: 18, // Adjust size for better alignment
            ),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Log Out',
                style: TextStyle(
                  fontFamily: 'Hind Jalandhar',
                  fontSize: 16, // Adjust font size for consistency
                ),
              ),
            ),
            style: ElevatedButton.styleFrom(
              alignment:
                  Alignment.centerLeft, // Align content to the center left
              padding: const EdgeInsets.symmetric(
                  vertical: 15, horizontal: 20), // Adjust padding
              foregroundColor: Colors.white,
              backgroundColor:
                  const Color(0xFFC62828), // Dark red for Log Out button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
