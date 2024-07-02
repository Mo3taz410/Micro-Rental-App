import 'package:flutter/material.dart';
import 'models/property.dart';
import 'edit_property_page.dart';
import 'dashboard.dart';
import 'saved_properties_page.dart';
import 'profile_page.dart';
import 'chat_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LessorPropertyDetailsPage extends StatefulWidget {
  final Map<String, dynamic> property;

  const LessorPropertyDetailsPage({super.key, required this.property});

  @override
  _LessorPropertyDetailsPageState createState() =>
      _LessorPropertyDetailsPageState();
}

class _LessorPropertyDetailsPageState extends State<LessorPropertyDetailsPage> {
  int _selectedIndex = 3;
  Map<String, dynamic>? _ownerData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOwnerData();
  }

  Future<void> _fetchOwnerData() async {
    try {
      DocumentSnapshot ownerSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.property['ownerId'])
          .get();
      setState(() {
        _ownerData = ownerSnapshot.data() as Map<String, dynamic>?;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching owner details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Property propertyModel =
        Property.fromMap(widget.property['id'], widget.property);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.property['name'] ?? 'Property Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditPropertyPage(property: propertyModel),
                ),
              ).then((updatedProperty) {
                if (updatedProperty != null) {
                  // Handle the updated property if necessary
                }
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.property['images'] != null &&
                      widget.property['images'].isNotEmpty)
                    SizedBox(
                      height: 250,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.property['images'].length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15.0),
                              child: Image.network(
                                widget.property['images'][index] ?? '',
                                fit: BoxFit.cover,
                                width: 300,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 20),
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Colors.lightBlueAccent,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.description, color: Colors.blue),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  widget.property['description'] ??
                                      'No description available',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.monetization_on,
                                  color: Colors.green),
                              const SizedBox(width: 10),
                              Text(
                                '\$${widget.property['price'] ?? '0'}/month',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.person, color: Colors.orange),
                              const SizedBox(width: 10),
                              Text(
                                'Owner: ${_ownerData?['name'] ?? 'Unknown'}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return GNav(
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
      selectedIndex: _selectedIndex,
      onTabChange: (index) {
        setState(() {
          _selectedIndex = index;
        });
        _navigateToPage(index);
      },
    );
  }

  void _navigateToPage(int index) {
    Widget page;
    switch (index) {
      case 0:
        page = const Dashboard();
        break;
      case 1:
        page = const ChatPage();
        break;
      case 2:
        page = const SavedPropertiesPage();
        break;
      case 3:
        page = const ProfilePage();
        break;
      default:
        return;
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => page));
  }
}
