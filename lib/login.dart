import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _error = '';
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(username).get();
      if (!doc.exists) {
        setState(() => _error = 'User not found.');
      } else if (doc.data()?['password'] != password) {
        setState(() => _error = 'Incorrect password.');
      } else {
        // Success: check role and navigate accordingly
        final role = doc.data()?['role'] ?? 'user';
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admindashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/options');
        }
      }
    } catch (e) {
      setState(() => _error = 'Login failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            if (_error.isNotEmpty)
              Text(_error, style: TextStyle(color: Colors.red)),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading ? CircularProgressIndicator() : Text('Log In'),
            ),
          ],
        ),
      ),
    );
  }
}