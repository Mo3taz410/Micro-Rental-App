import 'package:flutter/material.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedOpacity({required Widget child}) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Opacity(
          opacity: _animation.value,
          child: child,
        );
      },
    );
  }

  Widget _buildAnimatedTranslate(
      {required Widget child, double offset = 50.0}) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0.0, offset * (1.0 - _animation.value)),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top),
            _buildAnimatedTranslate(
              offset: 100.0,
              child: Image.asset(
                'images/Screenshot 2024-04-14 053956.png',
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.3,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnimatedOpacity(
                    child: Text(
                      'Welcome to',
                      style: TextStyle(
                        fontSize: 25,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Hind',
                        color: Colors.black.withOpacity(0.5),
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 5,
                            offset: const Offset(1, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildAnimatedOpacity(
                    child: const Text(
                      'Micro Rental',
                      style: TextStyle(
                        fontSize: 45,
                        color: Color(0xFF22215B),
                        fontFamily: 'Hind Jalandhar',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildAnimatedOpacity(
                    child: const Text(
                      'Find the tenant, list your property in just a simple steps, in your hand.',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Hind',
                        color: Color(0xFF7D7F88),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildAnimatedOpacity(
                    child: const Text(
                      'You are one step away.',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Hind',
                        color: Color(0xFF7D7F88),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A4DA0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                        minimumSize:
                            Size(MediaQuery.of(context).size.width * 0.8, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _buildAnimatedTranslate(
                        child: const Text(
                          'Get started',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Hind Jalandhar',
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
