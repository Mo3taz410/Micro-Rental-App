import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:micro_rental_project/chat_page.dart';
import 'package:micro_rental_project/dashboard.dart';
import 'package:micro_rental_project/profile_page.dart';
import 'package:micro_rental_project/saved_properties_page.dart';
import 'package:micro_rental_project/user_profile_page.dart';
import 'package:micro_rental_project/models/app_user.dart';
import 'chat_with_user_page.dart';

class PropertyDetailsPage extends StatefulWidget {
  final Map<String, dynamic> property;
  final bool isLessor;

  const PropertyDetailsPage({
    super.key,
    required this.property,
    required this.isLessor,
  });

  @override
  _PropertyDetailsPageState createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  AppUser? owner;

  @override
  void initState() {
    super.initState();
    _fetchOwnerData();
  }

  Future<void> _fetchOwnerData() async {
    try {
      if (widget.property.containsKey('ownerId') &&
          widget.property['ownerId'] != null) {
        var userId = widget.property['ownerId'];
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        if (userDoc.exists) {
          var ownerData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            owner = AppUser.fromMap(userId, ownerData);
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching owner details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Property Details',
            style: TextStyle(fontFamily: 'Hind'),
          ),
          backgroundColor: const Color(0xFF0A4DA0),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (owner == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Property Details',
            style: TextStyle(fontFamily: 'Hind'),
          ),
          backgroundColor: const Color(0xFF0A4DA0),
        ),
        body: const Center(
          child: Text(
            'Owner details are missing.',
            style: TextStyle(fontFamily: 'Hind'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.property['name'] ?? 'Property Details',
          style: const TextStyle(fontFamily: 'Hind'),
        ),
        backgroundColor: const Color(0xFF0A4DA0),
      ),
      body: SingleChildScrollView(
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
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          widget.property['images'][index],
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
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: const Color(0xFFF5F5F5),
              child: ListTile(
                contentPadding: const EdgeInsets.all(15),
                title: Text(
                  'Owner: ${owner!.name}',
                  style: const TextStyle(
                    fontFamily: 'Hind',
                    fontSize: 16,
                    color: Color(0xFF1A1E25),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserProfilePage(user: owner!)),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.property['description'] ?? 'No description available',
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Hind',
                color: Color(0xFF1A1E25),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '\$${widget.property['price']}/month',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Hind',
                color: Color(0xFF1A1E25),
              ),
            ),
            const SizedBox(height: 20),
            if (!widget.isLessor)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatWithUserPage(
                          userName: owner!.name,
                          userId: owner!.id,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF0D47A1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Text(
                      'Chat with Owner',
                      style: TextStyle(
                        fontFamily: 'Hind',
                      ),
                    ),
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
      backgroundColor: const Color(0xFF0A4DA0), // Dark blue for nav background
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
