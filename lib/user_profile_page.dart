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
        title: Text(
          user.name,
          style: const TextStyle(fontFamily: 'Hind'),
        ),
        backgroundColor: const Color(0xFF0A4DA0),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            _buildProfilePicture(),
            const SizedBox(height: 30),
            _buildUserInfo('Name', user.name),
            const SizedBox(height: 20),
            _buildUserInfo('Email', user.email),
            const SizedBox(height: 20),
            _buildUserInfo(
                'Bio', user.bio.isNotEmpty ? user.bio : 'No bio available'),
            const SizedBox(height: 40),
            _buildChatButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return CircleAvatar(
      radius: 60,
      backgroundImage: user.profileImageUrl != null
          ? NetworkImage(user.profileImageUrl!)
          : null,
      child: user.profileImageUrl == null
          ? const Icon(Icons.person, size: 60, color: Colors.white)
          : null,
      backgroundColor: const Color(0xFF0A4DA0), // Consistent background color
    );
  }

  Widget _buildUserInfo(String title, String info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Align center
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Hind',
            color: Color(0xFF1A1E25),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          info,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Hind',
            color: Color(0xFF7D7F88),
          ),
          textAlign: TextAlign.center, // Ensure text is centered
        ),
      ],
    );
  }

  Widget _buildChatButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
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
          backgroundColor: const Color(0xFF0D47A1), // Consistent button color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Text(
            'Chat with ${user.name}',
            style: const TextStyle(
              fontFamily: 'Hind',
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
