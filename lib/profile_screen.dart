import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController =
      TextEditingController(text: 'John Doe');
  final TextEditingController emailController =
      TextEditingController(text: 'johndoe@email.com');
  final TextEditingController phoneController =
      TextEditingController(text: '+880123456789');
  bool isEditing = false;

  void _toggleEdit() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void _saveProfile() {
    setState(() {
      isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Profile updated successfully!'),
          duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue[200],
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            Text('Name:', style: TextStyle(fontWeight: FontWeight.bold)),
            isEditing
                ? TextField(controller: nameController)
                : Text(nameController.text),
            const SizedBox(height: 16),
            Text('Email:', style: TextStyle(fontWeight: FontWeight.bold)),
            isEditing
                ? TextField(controller: emailController)
                : Text(emailController.text),
            const SizedBox(height: 16),
            Text('Phone:', style: TextStyle(fontWeight: FontWeight.bold)),
            isEditing
                ? TextField(controller: phoneController)
                : Text(phoneController.text),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isEditing ? _saveProfile : _toggleEdit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isEditing ? 'Save' : 'Edit Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
