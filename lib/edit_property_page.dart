import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'models/property.dart';
import 'firestore_service.dart';

class EditPropertyPage extends StatefulWidget {
  final Property property;

  const EditPropertyPage({super.key, required this.property});

  @override
  _EditPropertyPageState createState() => _EditPropertyPageState();
}

class _EditPropertyPageState extends State<EditPropertyPage> {
  final TextEditingController _propertyNameController = TextEditingController();
  final TextEditingController _propertyDescriptionController =
      TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final List<File> _selectedImages = [];
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _propertyNameController.text = widget.property.name;
    _propertyDescriptionController.text = widget.property.description;
    _priceController.text = widget.property.price.toString();
  }

  @override
  void dispose() {
    _propertyNameController.dispose();
    _propertyDescriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadPictures() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      if (mounted) {
        setState(() {
          _selectedImages.clear();
          _selectedImages
              .addAll(pickedFiles.map((file) => File(file.path)).toList());
        });
      }
    } else {
      _showToast('No images selected.');
    }
  }

  Future<void> _updateProperty() async {
    if (_propertyNameController.text.isEmpty ||
        _propertyDescriptionController.text.isEmpty ||
        _priceController.text.isEmpty) {
      _showToast('Please fill all fields.');
      return;
    }

    try {
      List<String> imageUrls = widget.property.images;
      if (_selectedImages.isNotEmpty) {
        imageUrls.clear();
        for (var image in _selectedImages) {
          String imageUrl = await _firestoreService.uploadImage(image);
          imageUrls.add(imageUrl);
        }
      }

      final updatedProperty = Property(
        id: widget.property.id,
        name: _propertyNameController.text,
        description: _propertyDescriptionController.text,
        price: double.parse(_priceController.text),
        images: imageUrls,
        location: widget.property.location,
        ownerId: widget.property.ownerId,
        ownerName: widget.property.ownerName,
      );

      await FirebaseFirestore.instance
          .collection('properties')
          .doc(updatedProperty.id)
          .update(updatedProperty.toMap());

      _showToast('Property updated successfully!');
      Navigator.pop(context, updatedProperty);
    } catch (e) {
      _showToast('Failed to update property: $e');
    }
  }

  Future<void> _deleteProperty() async {
    try {
      await FirebaseFirestore.instance
          .collection('properties')
          .doc(widget.property.id)
          .delete();
      _showToast('Property deleted successfully!');
      Navigator.pop(context, true);
    } catch (e) {
      _showToast('Failed to delete property: $e');
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
      appBar: AppBar(
        title: const Text('Edit Property Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmationDialog();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
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
                labelText: 'Price',
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
            SizedBox(
              width: double.infinity,
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
                          child: Image.file(
                            _selectedImages[index],
                            fit: BoxFit.cover,
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
                              child: Icon(Icons.close, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateProperty,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text('Update Property'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      title: 'Delete Property',
      desc: 'Are you sure you want to delete this property?',
      btnCancelOnPress: () {},
      btnOkOnPress: _deleteProperty,
    ).show();
  }
}
