import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'models/message.dart';

class FirestoreService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadImage(File file) async {
    String fileName =
        'property_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      UploadTask uploadTask = _storage.ref(fileName).putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      _logError("Failed to upload image", e);
      _showToast("Failed to upload image: $e");
      rethrow;
    }
  }

  Future<void> addUser(Map<String, dynamic> userData, String userId) async {
    try {
      await _firestore.collection('users').doc(userId).set(userData);
      _showToast("User profile created successfully!");
    } catch (e) {
      _logError("Failed to create user profile", e);
      _showToast("Failed to create user profile: $e");
      rethrow;
    }
  }

  Future<void> updateUser(Map<String, dynamic> userData, String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update(userData);
      _showToast("Profile updated successfully!");
    } catch (e) {
      _logError("Failed to update user profile", e);
      _showToast("Failed to update user profile: $e");
      rethrow;
    }
  }

  Future<void> addProperty(Map<String, dynamic> propertyData) async {
    try {
      await _firestore.collection('properties').add(propertyData);
      _showToast("Property listed successfully!");
    } catch (e) {
      _logError("Failed to list property", e);
      _showToast("Failed to list property: $e");
      rethrow;
    }
  }

  Future<void> sendMessage(Message message) async {
    try {
      String chatId = _getChatId(message.senderId, message.receiverId);
      await _firestore.collection('chats').doc(chatId).set({
        'participants': [message.senderId, message.receiverId]
      }, SetOptions(merge: true));
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toMap());
    } catch (e) {
      _logError("Failed to send message", e);
      _showToast("Failed to send message: $e");
      rethrow;
    }
  }

  Stream<List<Message>> getMessages(String senderId, String receiverId) {
    String chatId = _getChatId(senderId, receiverId);
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList());
  }

  String _getChatId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode
        ? '${user1}_$user2'
        : '${user2}_$user1';
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _logError(String message, dynamic error) {
    print("$message: $error");
  }
}
