import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'models/message.dart';
import 'firestore_service.dart';
import 'dashboard.dart';
import 'saved_properties_page.dart';
import 'profile_page.dart';
import 'chat_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatWithUserPage extends StatefulWidget {
  final String userName;
  final String userId;

  const ChatWithUserPage(
      {super.key, required this.userName, required this.userId});

  @override
  _ChatWithUserPageState createState() => _ChatWithUserPageState();
}

class _ChatWithUserPageState extends State<ChatWithUserPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  int _selectedIndex = 1;

  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }
    await _recorder!.openRecorder();
  }

  Future<void> _sendMessage(String message) async {
    if (message.isEmpty) return;

    String currentUserId = _auth.currentUser!.uid;

    Message newMessage = Message(
      senderId: currentUserId,
      receiverId: widget.userId,
      message: message,
      timestamp: Timestamp.now(),
    );

    await _firestoreService.sendMessage(newMessage);
    _messageController.clear();
  }

  Future<void> _recordVoiceMessage() async {
    Directory tempDir = await getTemporaryDirectory();
    String path = '${tempDir.path}/temp_voice_message.aac';

    if (_isRecording) {
      await _recorder!.stopRecorder();
      setState(() {
        _isRecording = false;
      });

      File voiceMessageFile = File(path);
      String fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.aac';
      String downloadUrl = await _uploadFile(voiceMessageFile, fileName);
      _sendMessage(downloadUrl);
    } else {
      await _recorder!.startRecorder(toFile: path);
      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      String downloadUrl = await _uploadFile(imageFile, fileName);
      _sendMessage(downloadUrl);
    }
  }

  Future<void> _pickVideo() async {
    final pickedFile =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      File videoFile = File(pickedFile.path);
      String fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      String downloadUrl = await _uploadFile(videoFile, fileName);
      _sendMessage(downloadUrl);
    }
  }

  Future<String> _uploadFile(File file, String fileName) async {
    Reference storageRef =
        FirebaseStorage.instance.ref().child('chat_files/$fileName');
    UploadTask uploadTask = storageRef.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    String currentUserId = _auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat with ${widget.userName}',
          style: const TextStyle(fontFamily: 'Hind'),
        ),
        backgroundColor: const Color(0xFF0A4DA0),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream:
                  _firestoreService.getMessages(currentUserId, widget.userId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isCurrentUser = message.senderId == currentUserId;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      alignment: isCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: isCurrentUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isCurrentUser
                                  ? const Color(0xFF0A4DA0)
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: message.message.contains('http')
                                ? message.message.endsWith('.aac')
                                    ? IconButton(
                                        icon: const Icon(Icons.play_arrow,
                                            color: Colors.white),
                                        onPressed: () {
                                          // Play the audio
                                        },
                                      )
                                    : message.message.endsWith('.mp4')
                                        ? GestureDetector(
                                            onTap: () {
                                              // Play the video
                                            },
                                            child: const Icon(
                                                Icons.video_library,
                                                color: Colors.white),
                                          )
                                        : Image.network(message.message)
                                : Text(
                                    message.message,
                                    style: TextStyle(
                                        color: isCurrentUser
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('h:mm a')
                                .format(message.timestamp.toDate()),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic,
                      color:
                          _isRecording ? Colors.red : const Color(0xFF0A4DA0)),
                  onPressed: _recordVoiceMessage,
                ),
                IconButton(
                  icon: const Icon(Icons.image, color: Color(0xFF0A4DA0)),
                  onPressed: _pickImage,
                ),
                IconButton(
                  icon: const Icon(Icons.videocam, color: Color(0xFF0A4DA0)),
                  onPressed: _pickVideo,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Color(0xFF0A4DA0)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF0A4DA0)),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF0A4DA0)),
                  onPressed: () => _sendMessage(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return GNav(
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

  @override
  void dispose() {
    _recorder!.closeRecorder();
    _messageController.dispose();
    super.dispose();
  }
}
