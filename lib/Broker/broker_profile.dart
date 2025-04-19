import 'dart:io';
import 'package:dh/Navigation/basescaffold.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Registeration/signin.dart';

class BrokerProfile extends StatefulWidget {
  final String userPhoneNumber;

  const BrokerProfile({super.key, required this.userPhoneNumber});

  @override
  State<BrokerProfile> createState() => _BrokerProfileState();
}

class _BrokerProfileState extends State<BrokerProfile> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref('userdata');

  String? userEmail;
  String? userName;
  String? profileImageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final snapshot = await _database.child(widget.userPhoneNumber).get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          userEmail = data['email'] ?? 'Email not available';
          userName = data['username'] ?? 'Username not available';
          profileImageUrl = data['profileImage'] ?? "";
        });
      } else {
        _showSnackBar("User data not found");
      }
    } catch (e) {
      _showSnackBar("Error fetching data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating, // Ensures it appears in front
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _editProfile() {
    TextEditingController nameController = TextEditingController(text: userName);
    TextEditingController emailController = TextEditingController(text: userEmail);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _resetPassword,
                icon: const Icon(Icons.lock),
                label: const Text("Change Password"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await _database.child(widget.userPhoneNumber).update({
                "username": nameController.text,
                "email": emailController.text,
              });
              setState(() {
                userName = nameController.text;
                userEmail = emailController.text;
              });
              Navigator.pop(context);
              _showSnackBar("Profile updated successfully");
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _resetPassword() {
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false; // State variable for loading indicator

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Reset Password"),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "New Password",
                        prefixIcon: Icon(Icons.lock),
                        errorMaxLines: 2, // Allows wrapping to the next line
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password cannot be empty";
                        }
                        if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$')
                            .hasMatch(value)) {
                          return "Password must contain 1 uppercase letter, 1 lowercase letter, 1 digit & 1 symbol.";
                        }
                        return null;
                      },
                    ),

                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Confirm Password",
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value != passwordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                    if (formKey.currentState!.validate()) {
                      setState(() => isLoading = true); // Start loading

                      await _database.child(widget.userPhoneNumber).update({
                        "password": passwordController.text,
                      });

                      setState(() => isLoading = false); // Stop loading
                      Navigator.pop(context);

                      // Showing snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Password reset successfully"),
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text("Reset"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        profileImageUrl = pickedFile.path;
      });

      await _database.child(widget.userPhoneNumber).update({
        "profileImage": profileImageUrl,
      });

      _showSnackBar("Profile picture updated successfully!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Profile',
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.green)
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                    ? FileImage(File(profileImageUrl!))
                    : const AssetImage('assets/profile.jpg') as ImageProvider,
                backgroundColor: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 15),

            // User Info Container
            Container(
              width: MediaQuery.of(context).size.width * 0.9, // Adjust width
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    spreadRadius: 2,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _infoTile(Icons.person, userName ?? "Username not available"),
                  _infoTile(Icons.email, userEmail ?? "Email not available"),
                  _infoTile(Icons.phone, widget.userPhoneNumber),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _profileButton("Edit Profile", Icons.edit, _editProfile),
            const SizedBox(height: 10),
            _logoutButton(),
          ],
        ),
      ),
    );
  }


  Widget _infoTile(IconData icon, String text) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _profileButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Colors.black),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: Colors.green),
      label: Text(text, style: const TextStyle(fontSize: 16, fontWeight:
      FontWeight.bold,color: Colors.green)),
    );
  }

  Widget _logoutButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // Background remains white
        foregroundColor: Colors.black, // Text and icon color set to red
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Colors.black), // Optional red border
      ),
      onPressed: () => _showLogoutDialog(context),
      icon: const Icon(Icons.logout, color: Colors.red, size: 20),
      label: const Text("Log Out",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.setString('userPhoneNumber', "");
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
          (Route<dynamic> route) => false,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: Colors.lightGreen, width: 2),
          ),
          title: const Text(
            'Confirm Log Out',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
          content: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Are you sure you want to log out?',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          contentPadding: const EdgeInsets.only(top: 16.0, left: 24.0, right: 24.0),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cancel Button
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.lightGreen[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Log Out Button
                Expanded(
                  child: TextButton(
                    onPressed: () => _logout(context),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.redAccent[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                      child: Text(
                        'Log Out',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

}
