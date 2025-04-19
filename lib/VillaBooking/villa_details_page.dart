import 'package:dh/Developer/edit_villa.dart';
import 'package:dh/VillaBooking/villa_Images.dart';
import 'package:dh/VillaBooking/villa_booking.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VillaDetailsPage extends StatefulWidget {
  final String villaName;
  final String villaNumber;
  final String villaSize;
  final String villaPrice;
  final String villaOwner;
  final String villaStatus;
  final String role;
  final String userPhoneNumber;

  const VillaDetailsPage({
    super.key,
    required this.villaName,
    required this.villaNumber,
    required this.villaSize,
    required this.villaPrice,
    required this.villaOwner,
    required this.villaStatus,

    required this.role,
    required this.userPhoneNumber,
  });

  @override
  State<VillaDetailsPage> createState() => _VillaDetailsPageState();
}

class _VillaDetailsPageState extends State<VillaDetailsPage> {
  final DatabaseReference reference = FirebaseDatabase.instance.ref('villas');

  String? isVillaAvailable = "";
  String? villaOwner;

  Future<void> _updatingVillaStatus(String currentStatus) async {
    try {
      String newStatus = currentStatus == "on" ? "off" : "on";
      await reference
          .child(widget.villaNumber)
          .update({'villaStatus': newStatus});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Villa ${newStatus == 'on' ? 'Activated' : 'Deactivated'}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Status Not Updated")),
      );
    }
  }

  Stream<String?> _getVillaStatusStream() {
    return reference
        .child(widget.villaNumber)
        .child('villaStatus')
        .onValue
        .map((event) {
      return event.snapshot.value as String?;
    });
  }

  @override
  void initState() {
    super.initState();
    _getExistDateStream().listen((value) {
      setState(() {
        tempAvailable = value == null || value.isEmpty ? "available" : "Booked";
      });
    });
  }

  // make a call part ----------------
  final String _phoneNumber = '+91 8669727126';

  String? tempAvailable;

  Future<void> _makePhoneCall() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: _phoneNumber,
    );

    if (!await launchUrl(launchUri)) {
      throw Exception('Could not launch $launchUri');
    }
  }

  Stream<String?> _getExistDateStream() {
    return reference
        .child(widget.villaNumber)
        .child('available')
        .child(widget.villaNumber)
        .child('existDate')
        .onValue
        .map((event) {
      return (event.snapshot.value as String?);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(""),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Image.asset(
              'assets/hone.jpg',
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 180, // Adjust position as needed
              left: 18, // Adjust position as needed
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Villa Name
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      "Luxury Villa " + widget.villaName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Star Rating
                  Row(
                    children: [
                      StreamBuilder<double?>(
                        stream: _getVillaRatingStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text(
                              'Loading...',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            );
                          }

                          if (snapshot.hasError || !snapshot.hasData) {
                            return const Text(
                              'N/A',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            );
                          }

                          double rating = snapshot.data!;
                          int fullStars = rating.floor();
                          bool hasHalfStar = (rating - fullStars) >= 0.5;
                          int emptyStars =
                              5 - fullStars - (hasHalfStar ? 1 : 0);

                          return Row(
                            children: [
                              ...List.generate(
                                  fullStars,
                                      (index) => const Icon(Icons.star,
                                      color: Colors.amber, size: 21)),
                              if (hasHalfStar)
                                const Icon(Icons.star_half,
                                    color: Colors.amber, size: 21),
                              ...List.generate(
                                  emptyStars,
                                      (index) => const Icon(Icons.star_border,
                                      color: Colors.amber, size: 21)),
                              const SizedBox(width: 5),
                              Text(
                                rating.toStringAsFixed(1),
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 250),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StreamBuilder<String?>(
                        stream: _getExistDateStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            tempAvailable = "";
                            return const CircularProgressIndicator();
                          }

                          if (snapshot.hasError) {
                            tempAvailable = "";
                            return const Text('Error loading exist date');
                          }

                          final existDate = snapshot.data;
                          if (existDate == null || existDate.isEmpty) {
                            tempAvailable = "available";
                            return const Text(
                              'Available',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.green),
                            );
                          } else {
                            tempAvailable = "Booked";
                            return Text(
                              'Status: $existDate (Booked)',
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.red),
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 15),
// Villa Details
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoRow(Icons.home,
                                'Villa Number: ${widget.villaNumber}'),
                            _infoRow(Icons.bedroom_parent,
                                'Size: ${widget.villaSize}'),
                            _infoRow(
                                Icons.monetization_on,
                                'Price: Rs ${widget.villaPrice} / night',
                                Colors.green.shade800),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
// Description
                      Text(
                        '🏡 About the Villa',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'This villa is located in a serene area surrounded by nature. It offers a luxurious experience with high-end amenities, modern interiors, and breathtaking views.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        '🌟 Facilities & Amenities',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _facilityChip(Icons.wifi, 'High-Speed WiFi'),
                          _facilityChip(Icons.local_cafe, 'Breakfast Included'),
                          _facilityChip(Icons.pool, 'Private Pool'),
                          _facilityChip(Icons.spa, 'Spa & Wellness'),
                          _facilityChip(Icons.king_bed, 'Luxury Double Bed'),
                          _facilityChip(Icons.directions_bike, 'Cycle Ride'),
                          _facilityChip(Icons.emoji_nature, 'Lake View'),
                          _facilityChip(Icons.chair, 'Outdoor Seating'),
                        ],
                      ),

                      const SizedBox(height: 30),
                      (widget.role == "broker") ||
                              (widget.role == "developer" ||
                                  widget.role == "admin")
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: SizedBox(
                                width: double.infinity, // Full width button
                                child: ElevatedButton(
                                  onPressed: tempAvailable == "available"
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  VillaBooking(
                                                villaName: widget.villaName,
                                                villaNumber: widget.villaNumber,
                                                villaSize: widget.villaSize,
                                                villaPrice: widget.villaPrice,
                                                role: widget.role,
                                                userPhoneNumber:
                                                    widget.userPhoneNumber,
                                              ),
                                            ),
                                          );
                                        }
                                      : null, // Disable button if not available

                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    backgroundColor: tempAvailable ==
                                            "available"
                                        ? Colors.green.shade700 // Active Green
                                        : Colors.grey.shade400, // Disabled Gray
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    shadowColor: Colors.black54,
                                    elevation: 6, // Subtle shadow for 3D effect
                                  ),

                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Icon(Icons.calendar_today, color: Colors.white, size: 24),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Book Now',
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : StreamBuilder<String?>(
                              stream: _getVillaStatusStream(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }

                                if (snapshot.hasError || !snapshot.hasData) {
                                  return const Text(
                                      'Error loading villa status');
                                }

                                final currentStatus = snapshot.data;

                                return (widget.role == "owner" &&
                                        widget.userPhoneNumber ==
                                            widget.villaOwner)
                                    ? Padding(
                                        padding:
                                        const EdgeInsets.symmetric(horizontal: 10),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              _updatingVillaStatus(
                                                  currentStatus!);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 14),
                                              backgroundColor: Colors.green.shade700, // Active Green
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              shadowColor: Colors.black54,
                                              elevation: 6, // Subtle shadow for 3D effect
                                            ),
                                            child: Text(
                                              currentStatus == "on"
                                                  ? 'Deactivate'
                                                  : 'Activate',
                                              style:
                                                  const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Padding(
                                        padding:
                                        const EdgeInsets.symmetric(horizontal: 10),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: _makePhoneCall,
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 14),
                                              backgroundColor: Colors.green.shade500, // Active Green
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              shadowColor: Colors.black54,
                                              elevation: 6, // Subtle shadow for 3D effect
                                            ),
                                            child: const Text(
                                              'Contact Us',
                                              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      );
                              },
                            ),

                      SizedBox(height: 20,),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: widget.role == "developer" || widget.role == "admin"
                              ? ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditVilla(
                                        villaNumber: widget.villaNumber
                                      )
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 90),
                              backgroundColor: Colors.blue.shade700, // Green color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30), // Rounded corners
                              ),
                              shadowColor: Colors.black54,
                              elevation: 8, // Higher elevation for better effect
                            ),
                            child: const Text(
                              "Edit Villa",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: Colors.white, // White text for contrast
                              ),
                            ),
                          )
                              : const SizedBox.shrink(),
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 200,
              right: 16,
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),

                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VillaImages()), // Navigate to NewPage
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        Opacity(
                          opacity: 0.7,
                          child: Image.asset(
                            'assets/hone.jpg',
                            fit: BoxFit.cover,
                            height: double.infinity,
                            width: double.infinity,
                          ),
                        ),
                           Center(
                            child: Text(
                              'See More',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.7),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.green.shade700, size: 22),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _facilityChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.green.shade700, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
  Stream<double?> _getVillaRatingStream() {
    return reference
        .child(widget.villaNumber)
        .child('villaRating')
        .onValue
        .map((event) {
      final rating = event.snapshot.value;
      return rating != null ? double.tryParse(rating.toString()) : null;
    });
  }
}
