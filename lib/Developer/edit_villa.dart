import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class EditVilla extends StatefulWidget {
  final String villaNumber;

  const EditVilla({super.key, required this.villaNumber});

  @override
  State<EditVilla> createState() => _EditVillaState();
}

class _EditVillaState extends State<EditVilla> {
  final TextEditingController _villaName = TextEditingController();
  final TextEditingController _villaSize = TextEditingController();
  final TextEditingController _villaPrice = TextEditingController();
  final TextEditingController _villaOwner = TextEditingController();

  final DatabaseReference reference = FirebaseDatabase.instance.ref();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVillaDetails();
  }

  Future<void> _fetchVillaDetails() async {
    try {
      DatabaseEvent event =
      await reference.child("villas").child(widget.villaNumber).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<String, dynamic> data =
        Map<String, dynamic>.from(snapshot.value as Map);

        setState(() {
          _villaName.text = data["villaName"] ?? "";
          _villaSize.text = data["villaSize"] ?? "";
          _villaPrice.text = data["villaPrice"] ?? "";
          _villaOwner.text = data["villaOwner"] ?? "";
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Villa not found")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch villa data!")),
      );
      Navigator.pop(context);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateVilla() async {
    try {
      await reference.child("villas").child(widget.villaNumber).update({
        "villaName": _villaName.text,
        "villaSize": _villaSize.text,
        "villaPrice": _villaPrice.text,
        "villaOwner": _villaOwner.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Villa Updated Successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to Update Villa!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E1C8), // Earthy beige background
      appBar: AppBar(
        title: Text(
          "Edit Villa - ${widget.villaNumber}",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6D4C41), // Deep earthy brown
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4CAF50), // Earthy green
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildTextField(_villaName, "Villa Name", Icons.business),
            const SizedBox(height: 20),
            _buildTextField(_villaSize, "Villa Size (BHK)", Icons.house),
            const SizedBox(height: 20),
            _buildTextField(_villaPrice, "Villa Price", Icons.price_change),
            const SizedBox(height: 20),
            _buildTextField(_villaOwner, "Owner Name", Icons.person),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _updateVilla,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50), // Earthy green
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded button
                ),
              ),
              child: const Text(
                "Update Villa",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white, // White input fields for contrast
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), // Rounded corners
          borderSide: BorderSide.none,
        ),
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6D4C41)), // Brown icon
        labelStyle: const TextStyle(color: Color(0xFF6D4C41)), // Brown text
      ),
    );
  }
}
