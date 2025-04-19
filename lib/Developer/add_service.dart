import 'dart:io';
import 'package:dh/Navigation/basescaffold.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';

class AddService extends StatefulWidget {
  const AddService({super.key});

  @override
  State<AddService> createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
  final TextEditingController _serviceNameController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final DatabaseReference dbRef =
  FirebaseDatabase.instance.ref("assets").child("images");

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        print("Image picked: ${pickedFile.path}");
      } else {
        print("No image selected");
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _uploadService() async {
    try {
      await Firebase.initializeApp();  // Ensure Firebase is initialized
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child('images/$fileName.jpg');

      UploadTask uploadTask = storageRef.putFile(_image!);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => print("Upload Complete"));

      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("Image uploaded: $downloadUrl");

      await dbRef.child(_serviceNameController.text).set({
        "name": _serviceNameController.text,
        "url": downloadUrl,
      });

      print("Service added successfully!");
    } catch (e) {
      print("Upload failed: $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Add Service',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _serviceNameController,
              decoration: const InputDecoration(
                labelText: "Service Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _image != null
                ? Image.file(_image!, height: 150)
                : const Text("No image selected"),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Pick Image"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadService,
              child: const Text("Add Service"),
            ),
          ],
        ),
      ),
    );
  }
}
