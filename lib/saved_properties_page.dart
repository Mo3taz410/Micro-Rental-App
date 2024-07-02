import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'dashboard.dart';
import 'chat_page.dart';
import 'profile_page.dart';
import 'property_details_page.dart';
import 'lessor_property_details_page.dart';

class SavedPropertiesPage extends StatelessWidget {
  const SavedPropertiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    var currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Properties'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .collection('favorites')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No saved properties.'));
          }

          var properties = snapshot.data!.docs;

          return ListView.builder(
            itemCount: properties.length,
            itemBuilder: (context, index) {
              var property = properties[index].data() as Map<String, dynamic>;
              property['id'] =
                  properties[index].id; // Add the property ID to the map

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.lightBlueAccent,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: property['images'] != null &&
                          property['images'].isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            property['images'][0],
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error);
                            },
                          ),
                        )
                      : const Icon(Icons.image_not_supported),
                  title: Text(
                    property['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text('\$${property['price']}/month'),
                  onTap: () async {
                    try {
                      var ownerId = property['ownerId'];
                      if (ownerId == currentUser.uid) {
                        // Navigate to LessorPropertyDetailsPage if the current user is the owner
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LessorPropertyDetailsPage(
                              property: property,
                            ),
                          ),
                        );
                      } else {
                        // Fetch owner data if the current user is not the owner
                        DocumentSnapshot ownerSnapshot = await FirebaseFirestore
                            .instance
                            .collection('users')
                            .doc(ownerId)
                            .get();
                        Map<String, dynamic>? ownerData =
                            ownerSnapshot.data() as Map<String, dynamic>?;

                        if (ownerData != null) {
                          property['owner'] = ownerData;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PropertyDetailsPage(
                                property: property,
                                isLessor: false,
                              ),
                            ),
                          );
                        } else {
                          throw Exception('Owner data is null');
                        }
                      }
                    } catch (e) {
                      print('Error fetching owner details: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Failed to load property details. Please try again.')),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: GNav(
        backgroundColor: Colors.white,
        color: Colors.black,
        activeColor: Colors.lightBlueAccent,
        tabBackgroundColor: Colors.grey.shade800,
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
        selectedIndex: 2,
        onTabChange: (index) {
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
}
