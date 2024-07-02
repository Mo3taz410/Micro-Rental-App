import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lessor_property_details_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'dashboard.dart';
import 'chat_page.dart';
import 'saved_properties_page.dart';
import 'profile_page.dart';

class YourPropertiesPage extends StatelessWidget {
  final String userId;

  const YourPropertiesPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Properties'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('properties')
            .where('ownerId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var properties = snapshot.data!.docs;

          if (properties.isEmpty) {
            return const Center(child: Text('No properties found.'));
          }

          return ListView.builder(
            itemCount: properties.length,
            itemBuilder: (context, index) {
              var property = properties[index].data() as Map<String, dynamic>;
              property['id'] = properties[index].id;

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
                  subtitle: Text(
                      '${property['location']} - \$${property['price']}/month'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LessorPropertyDetailsPage(property: property),
                      ),
                    );
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
        selectedIndex: 3,
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
}
