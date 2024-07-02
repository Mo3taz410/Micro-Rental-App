import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'models/message.dart';
import 'firestore_service.dart';
import 'dashboard.dart';
import 'saved_properties_page.dart';
import 'profile_page.dart';
import 'chat_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

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

  @override
  Widget build(BuildContext context) {
    String currentUserId = _auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.userName}'),
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
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
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
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
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

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
