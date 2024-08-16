import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import Font Awesome

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  void _launchPhone() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: '+962779845778',
    );

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contact Us',
          style: TextStyle(fontFamily: 'Hind'),
        ),
        backgroundColor: const Color(0xFF0A4DA0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Hind',
                color: Color(0xFF1A1E25),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'If you have any questions or concerns, please reach out to us at:',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Hind',
                color: Color(0xFF7D7F88),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: const Color(0xFFF5F5F5),
              child: const Padding(
                padding: EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        FaIcon(FontAwesomeIcons.solidEnvelope,
                            color: Color(0xFF0A4DA0)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Email: microrental.hu@gmail.com',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Hind',
                              color: Color(0xFF0A4DA0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        FaIcon(FontAwesomeIcons.phone,
                            color: Color(0xFF0A4DA0)),
                        SizedBox(width: 10),
                        Text(
                          'Phone: +962 77984 5778',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Hind',
                            color: Color(0xFF0A4DA0),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        FaIcon(FontAwesomeIcons.locationDot,
                            color: Color(0xFF0A4DA0)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Address: HU uni, Zarqaa, Jordan',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Hind',
                              color: Color(0xFF0A4DA0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _launchPhone,
                  icon: const FaIcon(FontAwesomeIcons.phone, size: 16),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Call Support',
                      style: TextStyle(fontFamily: 'Hind'),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF0A4DA0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
