import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _currentAddressController =
      TextEditingController();
  final TextEditingController _permanentAddressController =
      TextEditingController();

  bool _isEditing = false;
  bool _isSaving = false;
  String? _profileImageUrl;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _currentAddressController.dispose();
    _permanentAddressController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = doc.data();
    if (data == null) return;
    setState(() {
      _nameController.text =
          (data['name'] as String?) ?? user.displayName ?? '';
      _phoneController.text = (data['phone'] as String?) ?? '';
      _currentAddressController.text =
          (data['currentAddress'] as String?) ?? '';
      _permanentAddressController.text =
          (data['permanentAddress'] as String?) ?? '';
      _profileImageUrl = data['profileImage'] as String?;
    });
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) {
        return;
      }
      setState(() {
        _imageFile = File(picked.path);
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Unable to access gallery.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong picking image.')),
      );
    }
  }

  Future<String?> _uploadImage(User user) async {
    if (_imageFile == null) return _profileImageUrl;
    final ref = FirebaseStorage.instance.ref().child(
      'profileImages/${user.uid}.jpg',
    );
    await ref.putFile(_imageFile!);
    return ref.getDownloadURL();
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      final url = await _uploadImage(user);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'currentAddress': _currentAddressController.text.trim(),
        'permanentAddress': _permanentAddressController.text.trim(),
        'profileImage': url,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (_nameController.text.trim().isNotEmpty) {
        await user.updateDisplayName(_nameController.text.trim());
      }
      if (url != null) {
        await user.updatePhotoURL(url);
      }

      if (!mounted) return;
      setState(() {
        _profileImageUrl = url;
        _isEditing = false;
        _imageFile = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Failed to update profile.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.teal,
        actions: [
          TextButton.icon(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            icon: Icon(
              _isEditing ? Icons.close : Icons.edit,
              color: Colors.white,
            ),
            label: Text(
              _isEditing ? 'Cancel' : 'Edit',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (_profileImageUrl != null
                                ? NetworkImage(_profileImageUrl!)
                                : user?.photoURL != null
                                ? NetworkImage(user!.photoURL!)
                                : null)
                            as ImageProvider?,
                  child:
                      (_imageFile == null &&
                          _profileImageUrl == null &&
                          user?.photoURL == null)
                      ? const Icon(Icons.person, size: 70, color: Colors.teal)
                      : null,
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: InkWell(
                      onTap: _pickImage,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.teal,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              user?.email ?? 'No email',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 20),
            _isEditing ? _buildEditForm() : _buildProfileDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _profileRow(
          'Name',
          _nameController.text.isEmpty ? 'Not provided' : _nameController.text,
        ),
        _profileRow(
          'Phone',
          _phoneController.text.isEmpty
              ? 'Not provided'
              : _phoneController.text,
        ),
        _profileRow(
          'Current Address',
          _currentAddressController.text.isEmpty
              ? 'Not provided'
              : _currentAddressController.text,
        ),
        _profileRow(
          'Permanent Address',
          _permanentAddressController.text.isEmpty
              ? 'Not provided'
              : _permanentAddressController.text,
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Name cannot be empty';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone_iphone),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Phone number cannot be empty';
              }
              if (value.length < 10) {
                return 'Enter a valid phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _currentAddressController,
            decoration: const InputDecoration(
              labelText: 'Current Address',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Current address is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _permanentAddressController,
            decoration: const InputDecoration(
              labelText: 'Permanent Address',
              prefixIcon: Icon(Icons.home_work_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Permanent address is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _isSaving ? null : _saveProfile,
              icon: const Icon(Icons.cloud_upload_outlined),
              label: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }
}
