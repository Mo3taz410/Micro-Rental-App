import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'sign_up_page.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();
  String? _emailError;
  String? _verificationCodeError;
  bool _isSendingCode = false;
  String? _verificationCode;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _resetFields();
  }

  void _resetFields() {
    _emailController.clear();
    _verificationCodeController.clear();
    _emailError = null;
    _verificationCodeError = null;
    _isSendingCode = false;
    _verificationCode = null;
    _isVerified = false;
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
        title: const Text('Email Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                height: 200,
                child: Image.asset(
                  'images/Screenshot 2024-04-16 005811.png',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 75),
              const Padding(
                padding: EdgeInsets.only(right: 40.0),
                child: Text(
                  'VERIFY THROUGH EMAIL',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildEmailTextField(),
              const SizedBox(height: 20),
              _buildVerificationCodeRow(),
              if (_isSendingCode) const SizedBox(height: 10),
              _buildSendingCodeText(),
              const SizedBox(height: 20),
              _buildVerifyButton(),
              _buildVerificationSuccessText(),
              const SizedBox(height: 100),
              _buildNextButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        border: const OutlineInputBorder(),
        errorText: _emailError,
      ),
      validator: (value) {
        if (value!.isEmpty) {
          setState(() {
            _emailError = 'Please enter your email';
          });
          return null;
        }
        return null;
      },
    );
  }

  Widget _buildVerificationCodeRow() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: TextFormField(
            controller: _verificationCodeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Enter code',
              border: const OutlineInputBorder(),
              errorText: _verificationCodeError,
            ),
            onChanged: (_) {
              setState(() {
                _verificationCodeError = null;
              });
            },
            validator: (value) {
              if (value!.isEmpty) {
                setState(() {
                  _verificationCodeError = 'Please enter verification code';
                });
                return null;
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _isSendingCode ? null : _sendCode,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF315EE7),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Hind',
              fontSize: 18,
            ),
            minimumSize: const Size(150, 50),
          ),
          child: _isSendingCode
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Get code'),
        ),
      ],
    );
  }

  Widget _buildSendingCodeText() {
    return Visibility(
      visible: _isSendingCode,
      child: const Text(
        'Sending verification code...',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _verifyCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF315EE7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Hind',
                fontSize: 18,
              ),
              minimumSize: const Size(150, 50),
            ),
            child: const Text('Verify'),
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationSuccessText() {
    return Visibility(
      visible: _isVerified && _verificationCodeError == null,
      child: const Column(
        children: [
          SizedBox(height: 20),
          Text(
            'Verification successful!',
            style: TextStyle(color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      onPressed: () {
        if (_isVerified && _verificationCodeError == null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignUpPage(email: _emailController.text),
            ),
          );
        } else {
          _showToast("Please verify your email first");
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF315EE7),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Hind',
          fontSize: 18,
        ),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text('Next'),
    );
  }

  void _sendCode() async {
    if (!_isValidEmail(_emailController.text)) {
      _showToast("Please enter a valid email");
      return;
    }

    setState(() {
      _isSendingCode = true;
    });

    const String username = 'microrental.hu@gmail.com';
    const String password = 'iiezaxctqskiwmfw';

    final smtpServer = gmail(username, password);

    final random = Random();
    _verificationCode = (100000 + random.nextInt(900000)).toString();

    final message = Message()
      ..from = const Address(username, 'Micro Rental')
      ..recipients.add(_emailController.text)
      ..subject = 'Verification Code'
      ..text = 'Your verification code is: $_verificationCode';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: $sendReport');
      _showToast('Verification code sent.');
    } on MailerException catch (e) {
      print('Message not sent: ${e.message}');
      _showToast('Failed to send verification code.');
    } finally {
      setState(() {
        _isSendingCode = false;
      });
    }
  }

  void _verifyCode() {
    if (_verificationCodeController.text.isEmpty) {
      setState(() {
        _verificationCodeError = 'Please enter verification code';
      });
      return;
    }
    if (_verificationCodeController.text != _verificationCode) {
      setState(() {
        _verificationCodeError = 'Invalid verification code';
      });
      return;
    }
    setState(() {
      _verificationCodeError = null;
      _isVerified = true;
    });
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
