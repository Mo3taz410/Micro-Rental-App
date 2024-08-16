import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:micro_rental_project/models/property.dart';
import 'package:micro_rental_project/firestore_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'profile_page.dart';
import 'property_details_page.dart';
import 'saved_properties_page.dart';
import 'chat_page.dart';
import 'lessor_property_details_page.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _currentIndex = 0;
  bool _isRenter = true;
  bool _isLoading = true;
  String _locationMessage = '';
  String _selectedCity = 'Amman';
  final List<File> _selectedImages = [];
  final List<String> _cities = [
    "Amman",
    "Irbid",
    "Zarqa",
    "Mafraq",
    "Ajloun",
    "Jerash",
    "Madaba",
    "Balqa",
    "Karak",
    "Tafileh",
    "Maan",
    "Aqaba"
  ];

  final TextEditingController _propertyNameController = TextEditingController();
  final TextEditingController _propertyDescriptionController =
      TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
    _fetchLocation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _propertyNameController.dispose();
    _propertyDescriptionController.dispose();
    _priceController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    var status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        Placemark place = placemarks[0];
        if (mounted) {
          setState(() {
            _locationMessage = "${place.locality}";
            _isLoading = false;
          });
        }
      } catch (e) {
        print('Error fetching location: $e');
        if (mounted) {
          setState(() {
            _locationMessage = 'Location not fetched';
            _isLoading = false;
          });
        }
      }
    } else if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) {
        setState(() {
          _locationMessage = 'Location permissions are denied';
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _isFavorite(String propertyId) async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      var doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('favorites')
          .doc(propertyId)
          .get();
      return doc.exists;
    }
    return false;
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  Widget _buildRenterUI() {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('properties')
          .where('location', isEqualTo: _selectedCity)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        var properties = snapshot.data!.docs.map((doc) {
          return Property.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();

        if (properties.isEmpty) {
          return const Center(child: Text('No properties found in this city.'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Properties in your selected city',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Hind',
              ),
            ),
            const SizedBox(height: 10),
            CarouselSlider.builder(
              itemCount: properties.length,
              itemBuilder: (context, index, realIdx) {
                var property = properties[index];

                return FutureBuilder<bool>(
                  future: _isFavorite(property.id),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    bool isFavorite = snapshot.data!;

                    return GestureDetector(
                      onTap: () async {
                        var propertyMap = property.toMap();
                        propertyMap['id'] = property.id; // Add this line
                        if (property.ownerId == currentUser!.uid) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LessorPropertyDetailsPage(
                                property: propertyMap,
                              ),
                            ),
                          );
                        } else {
                          if (propertyMap['owner'] == null) {
                            try {
                              DocumentSnapshot ownerSnapshot =
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(property.ownerId)
                                      .get();
                              Map<String, dynamic>? ownerData =
                                  ownerSnapshot.data() as Map<String, dynamic>?;
                              if (ownerData != null) {
                                propertyMap['owner'] = ownerData;
                              }
                            } catch (e) {
                              print('Error fetching owner details: $e');
                            }
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PropertyDetailsPage(
                                property: propertyMap,
                                isLessor: false,
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white, // Light gray color
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ),
                                  child: property.images.isNotEmpty
                                      ? Image.network(
                                          property.images[0],
                                          height: 175,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(Icons.error);
                                          },
                                        )
                                      : const Icon(Icons.image_not_supported,
                                          size: 150),
                                ),
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (currentUser != null) {
                                        if (isFavorite) {
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(currentUser.uid)
                                              .collection('favorites')
                                              .doc(property.id)
                                              .delete();
                                          _showToast('Removed from favorites');
                                        } else {
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(currentUser.uid)
                                              .collection('favorites')
                                              .doc(property.id)
                                              .set(property.toMap());
                                          _showToast('Added to favorites');
                                        }

                                        setState(() {});
                                      }
                                    },
                                    child: Icon(
                                      isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                property.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                property.price != null
                                    ? '\$${property.price}/month'
                                    : 'Price not available',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF7D7F88), // Neutral color
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                property.ownerName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF7D7F88), // Neutral color
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              options: CarouselOptions(
                height: 300,
                enlargeCenterPage: true,
                enableInfiniteScroll: true,
                autoPlay: true,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLessorUI() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'List Your Property',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Hind',
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Property Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      controller: _propertyNameController,
                      style: const TextStyle(
                        fontFamily: 'Hind',
                        color: Color(0xFF1A1E25),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Price/month',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      controller: _priceController,
                      style: const TextStyle(
                        fontFamily: 'Hind',
                        color: Color(0xFF1A1E25),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      value: _selectedCity,
                      onChanged: (String? newValue) {
                        if (mounted) {
                          setState(() {
                            _selectedCity = newValue!;
                          });
                        }
                      },
                      items:
                          _cities.map<DropdownMenuItem<String>>((String city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(
                            city,
                            style: const TextStyle(
                              fontFamily: 'Hind',
                              color: Color(0xFF1A1E25),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Property Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      controller: _propertyDescriptionController,
                      style: const TextStyle(
                        fontFamily: 'Hind',
                        color: Color(0xFF1A1E25),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _pickAndUploadPictures();
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Upload Pictures'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade800,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_selectedImages.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      _selectedImages[index],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      if (mounted) {
                                        setState(() {
                                          _selectedImages.removeAt(index);
                                        });
                                      }
                                    },
                                    child: const CircleAvatar(
                                      backgroundColor: Colors.red,
                                      child: Icon(Icons.close,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          _listProperty();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade800,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text('List Property'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadPictures() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles.length >= 3 && pickedFiles.length <= 10) {
      if (mounted) {
        setState(() {
          _selectedImages.clear();
          _selectedImages
              .addAll(pickedFiles.map((file) => File(file.path)).toList());
        });
      }
    } else {
      _showToast('Please select between 3 and 10 images.');
    }
  }

  Future<void> _listProperty() async {
    if (_selectedImages.length < 3 || _selectedImages.length > 10) {
      _showToast('Please select between 3 and 10 images.');
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (!userDoc.exists) return;

      final ownerName = userDoc['name'];

      List<String> imageUrls = [];
      for (var image in _selectedImages) {
        String imageUrl = await FirestoreService().uploadImage(image);
        imageUrls.add(imageUrl);
      }

      final property = Property(
        id: '',
        name: _propertyNameController.text,
        description: _propertyDescriptionController.text,
        price: double.parse(_priceController.text),
        images: imageUrls,
        location: _selectedCity,
        ownerId: currentUser.uid,
        ownerName: ownerName,
      );

      await FirestoreService().addProperty(property.toMap());

      _showToast('Property listed successfully!');

      _propertyNameController.clear();
      _propertyDescriptionController.clear();
      _priceController.clear();
      if (mounted) {
        setState(() {
          _selectedImages.clear();
        });
      }
    } catch (e) {
      _showToast('Failed to list property: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Dashboard',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF0A4DA0),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (mounted) {
                          setState(() {
                            _isRenter = true;
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isRenter
                              ? const Color(0xFF1976D2)
                              : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'I need to rent',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Hind',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (mounted) {
                          setState(() {
                            _isRenter = false;
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: !_isRenter
                              ? const Color(0xFF1976D2)
                              : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'I want to list',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Hind',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isRenter) ...[
                const Text(
                  'Your current location',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Hind',
                    color: Color(0xFF7D7F88),
                  ),
                ),
                _isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        _locationMessage.isNotEmpty
                            ? _locationMessage
                            : 'Location not fetched',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Hind',
                          color: Color(0xFF1A1E25),
                        ),
                      ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select City',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCity,
                  items: _cities.map((String city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (mounted) {
                      setState(() {
                        _selectedCity = newValue!;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),
                _buildRenterUI(),
              ] else ...[
                _buildLessorUI(),
              ],
            ],
          ),
        ),
        bottomNavigationBar: GNav(
          backgroundColor: const Color(0xFF0A4DA0),
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
          selectedIndex: _currentIndex,
          onTabChange: (index) {
            if (mounted) {
              setState(() {
                _currentIndex = index;
              });
            }
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
      ),
    );
  }
}
