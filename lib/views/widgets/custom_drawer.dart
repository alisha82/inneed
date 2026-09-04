import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inneed/views/Auth/login_screen.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  File? _imageFile;
  String _fullName = 'Loading...';
  String _email = '';
  String _phone = 'Not available';
  String _location = 'Lahore, Pakistan';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // for fetching exact fields from firebase
  void _loadUserData() async {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      setState(() {
        _email = currentUser.email ?? '';
      });

      try {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

          setState(() {
            _fullName = data['fullName'] ?? currentUser.displayName ?? 'User';
            _phone = data['phone'] ?? 'Not available';
          });
        } else {
          setState(() {
            _fullName = currentUser.displayName ?? 'User';
          });
        }
      } catch (e) {
        setState(() {
          _fullName = currentUser.displayName ?? 'User';
        });
      }
    } else {
      setState(() {
        _fullName = 'Guest User';
        _email = 'Not logged in';
        _phone = '';
      });
    }
  }

  // Edit Name Dialog
  void _editNameDialog() {
    TextEditingController nameController = TextEditingController(text: _fullName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Full Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: "Enter new name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935)),
            onPressed: () async {
              String newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                User? user = _auth.currentUser;
                if (user != null) {
                  await _firestore.collection('users').doc(user.uid).update({
                    'fullName': newName,
                  });
                  setState(() {
                    _fullName = newName;
                  });
                }
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Edit Phone Dialog
  void _editPhoneDialog() {
    TextEditingController phoneController = TextEditingController(
      text: _phone == 'Not available' ? '' : _phone,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Phone Number'),
        content: TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: "Enter new phone number"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935)),
            onPressed: () async {
              String newPhone = phoneController.text.trim();
              if (newPhone.isNotEmpty) {
                User? user = _auth.currentUser;
                if (user != null) {
                  await _firestore.collection('users').doc(user.uid).update({
                    'phone': newPhone,
                  });
                  setState(() {
                    _phone = newPhone;
                  });
                }
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Gallery se image select karne ke liye
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = _auth.currentUser;

    return Drawer(
      backgroundColor: const Color(0xFFFFFBFB),
      child: Column(
        children: [
          // Top Red Header Section with Avatar & Camera Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 24, left: 16, right: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFE53935), // Red Theme Color
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (currentUser?.photoURL != null
                          ? NetworkImage(currentUser!.photoURL!)
                          : null) as ImageProvider?,
                      child: (_imageFile == null && currentUser?.photoURL == null)
                          ? const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey,
                      )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300, width: 1.5),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Color(0xFFE53935),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _editNameDialog,
                      child: const Icon(Icons.edit, size: 16, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Body Details List (Phone, Email, Current Location)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              children: [
                ListTile(
                  leading: const Icon(Icons.phone_outlined, color: Color(0xFFE53935)),
                  title: const Text(
                    'Phone',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  subtitle: Text(
                    _phone,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, size: 18, color: Colors.black54),
                    onPressed: _editPhoneDialog,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.email_outlined, color: Color(0xFFE53935)),
                  title: const Text(
                    'Email',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  subtitle: Text(
                    _email.isNotEmpty ? _email : 'Not available',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined, color: Color(0xFFE53935)),
                  title: const Text(
                    'Current Location',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  subtitle: Text(
                    _location,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Sign Out Section
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFE53935)),
              title: const Text(
                'Sign Out',
                style: TextStyle(
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onTap: () async {
                await _auth.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                        (route) => false,
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}