import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  String _selectedLanguage = 'English';
  bool _notificationsEnabled = true;
  bool _isSavingAccount = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;

  @override
  void initState() {
    super.initState();
    _hydrateFromFirebase();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _hydrateFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _emailController.text = user.email ?? '';
    _phoneController.text = user.displayName ?? '';

    final profile = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (!profile.exists) return;
    final data = profile.data() ?? {};
    setState(() {
      _selectedLanguage = (data['language'] as String?) ?? _selectedLanguage;
      _notificationsEnabled =
          (data['notificationsEnabled'] as bool?) ?? _notificationsEnabled;
      _phoneController.text =
          (data['phone'] as String?) ?? _phoneController.text;
    });
  }

  void _changeLanguage(String? value) {
    if (value == null) return;
    setState(() => _selectedLanguage = value);
    _persistPreferences();
  }

  void _toggleNotifications(bool value) {
    setState(() => _notificationsEnabled = value);
    _persistPreferences();
  }

  Future<void> _persistPreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'language': _selectedLanguage,
      'notificationsEnabled': _notificationsEnabled,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferences synced to Firebase')),
    );
  }

  Future<void> _saveAccount() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active user session found.')),
      );
      return;
    }

    setState(() => _isSavingAccount = true);

    try {
      final currentPassword = _currentPasswordController.text.trim();
      final newPassword = _newPasswordController.text.trim();
      final newEmail = _emailController.text.trim();
      final phone = _phoneController.text.trim();

      if ((newEmail != user.email || newPassword.isNotEmpty) &&
          currentPassword.isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-password',
          message: 'Please enter your current password to update credentials.',
        );
      }

      if ((newEmail != user.email || newPassword.isNotEmpty) &&
          currentPassword.isNotEmpty) {
        final credential = EmailAuthProvider.credential(
          email: user.email ?? newEmail,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
      }

      if (newEmail.isNotEmpty && newEmail != user.email) {
        await user.updateEmail(newEmail);
      }

      if (newPassword.isNotEmpty) {
        await user.updatePassword(newPassword);
        _newPasswordController.clear();
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': newEmail,
        'phone': phone,
        'language': _selectedLanguage,
        'notificationsEnabled': _notificationsEnabled,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _currentPasswordController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account details updated in Firebase')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Failed to update account.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingAccount = false);
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('General'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Language',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedLanguage,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.language),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'English',
                          child: Text('English'),
                        ),
                        DropdownMenuItem(
                          value: 'Bangla',
                          child: Text('Bangla'),
                        ),
                      ],
                      onChanged: _changeLanguage,
                    ),
                    const SizedBox(height: 24),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      secondary: Icon(
                        _notificationsEnabled
                            ? Icons.notifications_active
                            : Icons.notifications_off,
                        color: Colors.teal,
                      ),
                      title: const Text(
                        'Notifications',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        _notificationsEnabled
                            ? 'You will receive service alerts and updates'
                            : 'Notifications are turned off',
                      ),
                      value: _notificationsEnabled,
                      onChanged: _toggleNotifications,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Account'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email cannot be empty';
                          }
                          if (!RegExp(r'^\\S+@\\S+\\.\\S+$').hasMatch(value)) {
                            return 'Enter a valid email address';
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
                          prefixIcon: Icon(Icons.phone_android),
                          border: OutlineInputBorder(),
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
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrentPassword,
                        decoration: InputDecoration(
                          labelText: 'Current Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureCurrentPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () => setState(
                              () => _obscureCurrentPassword =
                                  !_obscureCurrentPassword,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        decoration: InputDecoration(
                          labelText: 'New Password (optional)',
                          prefixIcon: const Icon(Icons.lock_reset),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () => setState(
                              () => _obscureNewPassword = !_obscureNewPassword,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _isSavingAccount ? null : _saveAccount,
                          icon: const Icon(Icons.save_alt),
                          label: _isSavingAccount
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text('Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const Text(
                'Logout',
                style: TextStyle(color: Colors.redAccent),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
