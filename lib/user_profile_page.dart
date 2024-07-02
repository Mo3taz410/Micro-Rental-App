import 'package:flutter/material.dart';
import 'models/app_user.dart';
import 'chat_with_user_page.dart';

class UserProfilePage extends StatelessWidget {
  final AppUser user;

  const UserProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildUserInfo('Name:', user.name),
            const SizedBox(height: 20),
            _buildUserInfo('Email:', user.email),
            const SizedBox(height: 20),
            _buildUserInfo('Bio:', user.bio),
            const SizedBox(height: 20),
            _buildChatButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(String title, String info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          info,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildChatButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatWithUserPage(
                userName: user.name,
                userId: user.id,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Text('Chat with User'),
        ),
      ),
    );
  }
}
