import 'package:dh/Navigation/basescaffold.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../VillaBooking/renters_villa_booked.dart';

class UserHistory extends StatefulWidget {
  const UserHistory({super.key});

  @override
  State<UserHistory> createState() => _UserHistoryState();
}

class _UserHistoryState extends State<UserHistory> {

  final DatabaseReference reference = FirebaseDatabase.instance.ref("villaRenters");

  String userPhoneNumber = "0";
  String role = "user";

  @override
  void initState() {
    super.initState();
    _initializeSharedPreferences();
  }

  Future<void> _initializeSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? userPhoneNumbertemp = prefs.getString('userPhoneNumber');
    String? userRole = prefs.getString('role');
    if (userRole != null && userPhoneNumbertemp != null) {
      setState(() {
        userPhoneNumber = userPhoneNumbertemp;
        role = userRole;
      });
    }
    await Future.delayed(const Duration(seconds: 2));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'User History',
      body: userPhoneNumber == "0"
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            FirebaseAnimatedList(
              query: reference.child(userPhoneNumber),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, snapshot, animation, index) {

                Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.values.length,
                  itemBuilder: (context, i) {
                    Map<dynamic, dynamic> bookingData = data.values.toList()[i];

                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingDetailsPage(bookingData: bookingData, role: role,),
                        ),
                      ),
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow("Name:", bookingData["renterDetails"]["renterName"], icon: Icons.person),
                              _buildDetailRow("Contact:", bookingData["renterDetails"]["renterContact"], icon: Icons.phone),
                              _buildDetailRow("Total Cost:", "₹${bookingData["cost"]["totalCost"]}", icon: Icons.monetization_on),
                              _buildDetailRow("Entry Date:", bookingData["date"]['entryDate'], icon: Icons.calendar_today),
                              _buildDetailRow("Exist Time:", bookingData["date"]['existDate'], icon: Icons.calendar_today),
                            ],
                          )

                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.green, size: 20), // Themed icons
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green, // Green color theme
              ),
            ),
          ),
          Flexible(
            child: Text(
              value.toString(),
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }



// Show full details in a popup
  // void _showDetailsPopup(BuildContext context, Map<dynamic, dynamic> bookingData) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text("Booking Details"),
  //         content: SingleChildScrollView(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               const Divider(color: Colors.grey),
  //               _buildDetailRow("Entry Date:", bookingData["date"]["entryDate"]),
  //               _buildDetailRow("Exit Date:", bookingData["date"]["existDate"]),
  //               _buildDetailRow("Number of Nights", bookingData["date"]["numberOfNights"]),
  //               const Divider(color: Colors.grey),
  //               _buildDetailRow("GST Cost:", bookingData["cost"]["gstCost"]),
  //               _buildDetailRow("Sub Cost:", bookingData["cost"]["subCost"]),
  //               _buildDetailRow("Total Cost:", bookingData["cost"]["totalCost"]),
  //               const Divider(color: Colors.grey),
  //               const Text(
  //                 "Villa Details",
  //                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  //               ),
  //               _buildDetailRow("Name:", bookingData["villaDetails"]["villaName"]),
  //               _buildDetailRow("Size:", bookingData["villaDetails"]["villaSize"]),
  //               _buildDetailRow("Price:", bookingData["villaDetails"]["villaPrice"]),
  //               _buildDetailRow("Number:", bookingData["villaDetails"]["villaNumber"]),
  //               const Divider(color: Colors.grey),
  //               const Text(
  //                 "Renter Details",
  //                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  //               ),
  //               _buildDetailRow("Name:", bookingData["renterDetails"]["renterName"]),
  //               _buildDetailRow("Email:", bookingData["renterDetails"]["renterEmail"]),
  //               _buildDetailRow("Contact:", bookingData["renterDetails"]["renterContact"]),
  //             ],
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             child: const Text("Close"),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
