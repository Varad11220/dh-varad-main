

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RentersVillaBooked extends StatefulWidget {
  const RentersVillaBooked({super.key});

  @override
  State<RentersVillaBooked> createState() => _RentersVillaBookedState();
}

class _RentersVillaBookedState extends State<RentersVillaBooked> {
  final DatabaseReference reference = FirebaseDatabase.instance.ref("userdata");
  final DatabaseReference reference2 = FirebaseDatabase.instance.ref("villaRenters");

  String? dataisfetching = "";
  bool isLoading = true;
  String brokerNumber = '';
  final TextEditingController brokerController = TextEditingController();

  String userPhoneNumber = "0";
  String role = "user";

  @override
  void initState() {
    super.initState();
    _initializeSharedPreferences();
  }

  Future<void> _initializeSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? userPhoneNumberTemp = prefs.getString('userPhoneNumber');
    String? userRole = prefs.getString('role');
    if (userRole != null && userPhoneNumberTemp != null) {
      setState(() {
        userPhoneNumber = userPhoneNumberTemp;
        role = userRole;
      });
    }
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (role != "admin")
                _buildUserData(),
                 if (role == "admin")
                _buildAdminData(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminData() {
    return FutureBuilder(
      future: reference2.once(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          DataSnapshot? dataSnapshot = snapshot.data?.snapshot;

          if (dataSnapshot?.value == null) {
            debugPrint("Firebase Data: No data found.");
            return const Center(child: Text("No data found."));
          }

          Map<dynamic, dynamic> brokers = dataSnapshot?.value as Map<dynamic, dynamic>;
          List<Map<dynamic, dynamic>> allBookings = [];

          brokers.forEach((brokerPhone, users) {
            Map<dynamic, dynamic> usersMap = users as Map<dynamic, dynamic>;
            usersMap.forEach((userPhone, userBookings) {
              Map<dynamic, dynamic> bookingsMap = userBookings as Map<dynamic, dynamic>;
              bookingsMap.forEach((bookingId, bookingData) {
                allBookings.add({
                  "brokerPhone": brokerPhone,
                  "userPhone": userPhone,
                  "bookingId": bookingId,
                  ...bookingData,
                });
              });
            });
          });

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allBookings.length,
            itemBuilder: (context, index) {
              Map<dynamic, dynamic> booking = allBookings[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4, // Adds shadow for a modern look
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Villa Booked: ${booking["villaDetails"]["villaName"]}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green, // Green theme applied
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 18, color: Colors.green),
                          const SizedBox(width: 6),
                          Text(
                            "Broker: ${booking["brokerPhone"]}",
                            style: const TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 18, color: Colors.green),
                          const SizedBox(width: 6),
                          Text(
                            "User: ${booking["userPhone"]}",
                            style: const TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingDetailsPage(bookingData: booking, role: role),
                            ),
                          ),
                          icon: const Icon(Icons.arrow_forward, color: Colors.white),
                          label: const Text("View Details"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Green theme applied
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );


            },
          );
        } else {
          return const Center(child: Text("No data available."));
        }
      },
    );
  }

  Widget _buildUserData() {
    return FirebaseAnimatedList(
      query: reference.child(userPhoneNumber).child("userBookedVillas"),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, snapshot, animation, index) {
        if (!snapshot.exists || snapshot.value == null) {
          debugPrint("No data found in Firebase!");
          return const Center(child: Text("No bookings found"));
        }

        debugPrint("Raw Firebase Data: ${snapshot.value}");

        Map<dynamic, dynamic> bookingData = snapshot.value as Map<dynamic, dynamic>;

        // Extract necessary details
        String villaName = bookingData["villaDetails"]["villaName"] ?? "Unknown Villa";
        String renterName = bookingData["renterDetails"]["renterName"] ?? "Unknown";
        String renterContact = bookingData["renterDetails"]["renterContact"]?.toString() ?? "N/A";
        String entryDate = bookingData["date"]["entryDate"] ?? "Unknown";
        String exitDate = bookingData["date"]["existDate"] ?? "Unknown";
        int totalCost = bookingData["cost"]["totalCost"] ?? 0;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          elevation: 4, // Adds a slight shadow for depth
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0), // Add padding for better spacing
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Villa Name (Bold and Highlighted)
                Text(
                  villaName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 6), // Space between elements

                // Renter Name
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.grey, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      "Renter: $renterName",
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),

                // Contact Number
                Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.green, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      "Contact: $renterContact",
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Dates Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.blue, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          "Entry: $entryDate",
                          style: const TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.exit_to_app, color: Colors.red, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          "Exit: $exitDate",
                          style: const TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Cost
                Text(
                  "Total Cost: ₹$totalCost",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(height: 8),

                // View Details Button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                    label: const Text(
                      "View Details",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingDetailsPage(bookingData: bookingData, role : role),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );

      },
    );

  }
}

class BookingDetailsPage extends StatelessWidget {
  final Map<dynamic, dynamic> bookingData;

  final String role;

  const BookingDetailsPage({super.key, required this.bookingData, required this.role});

  Future<void> _checkingOut(BuildContext context) async {
    final DatabaseReference reference2 = FirebaseDatabase.instance
        .ref("villas")
        .child(bookingData["villaDetails"]["villaNumber"]);

    final DatabaseReference reference3 = FirebaseDatabase.instance
        .ref("userdata")
        .child(bookingData["renterDetails"]["renterContact"]).child("userBookedVillas");

    reference3.once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {

        Map<dynamic, dynamic> bookings = event.snapshot.value as Map<dynamic, dynamic>;

        bookings.forEach((key, value) {

          if (value["isUserCheckIn"] == "yes") { // Find the correct booking
            reference3.child(key).update({
              "isUserCheckIn": "no",
            }).then((_) {
              print("Updated isUserCheckIn to 'no' for booking: $key");
            }).catchError((error) {
              print("Failed to update booking: $error");
            });
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Checkout Successful"),
                  content: const Text("You have successfully checked out."),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the popup
                      },
                      child: const Text("OK"),
                    ),
                  ],
                );
              },
            );
          }
          else{
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Already Checked Out"),
                  content: const Text("You have already checked out from this booking."),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text("OK"),
                    ),
                  ],
                );
              },
            );
          }
        });
      } else {
        print("No bookings found for this user.");
      }
    });

    final villaStatus = {
      bookingData["villaDetails"]["villaNumber"]: {
        "renterContact": "",
        "entryDate": "",
        "existDate": "",
      }
    };

    await reference2.child('available').set(villaStatus);

    // Show a confirmation popup after checkout
    if (context.mounted) {  // Ensure the widget is still mounted

    }
  }


  @override
  Widget build(BuildContext context) {

    bool isUserCheckedOut = bookingData["isUserCheckIn"] == "yes";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Details"),
        backgroundColor: const Color(0xFF228B22), // Earth tone - Forest Green
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(13.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Villa Details",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF228B22)),
            ),
            const Divider(),
            _buildDetailRow("Name:", bookingData["villaDetails"]["villaName"]),
            _buildDetailRow("Size:", bookingData["villaDetails"]["villaSize"]),
            _buildDetailRow("Price:", bookingData["villaDetails"]["villaPrice"]),
            _buildDetailRow("Number:", bookingData["villaDetails"]["villaNumber"]),

            const SizedBox(height: 20),
            const Text(
              "Renter Details",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF228B22)),
            ),
            const Divider(),
            _buildDetailRow("Name:", bookingData["renterDetails"]["renterName"]),
            _buildDetailRow("Email:", bookingData["renterDetails"]["renterEmail"]),
            _buildDetailRow("Contact:", bookingData["renterDetails"]["renterContact"]),

            const SizedBox(height: 20),
            const Text(
              "Cost Details",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF228B22)),
            ),
            const Divider(),
            _buildDetailRow("GST Cost:", bookingData["cost"]["gstCost"]),
            _buildDetailRow("Sub Cost:", bookingData["cost"]["subCost"]),
            _buildDetailRow("Total Cost:", bookingData["cost"]["totalCost"]),

            const SizedBox(height: 20),
            const Text(
              "Date Details",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF228B22)),
            ),
            const Divider(),
            _buildDetailRow("Entry Date:", bookingData["date"]["entryDate"]),
            _buildDetailRow("Exit Date:", bookingData["date"]["existDate"]),
            _buildDetailRow("Number of Nights:", bookingData["date"]["numberOfNights"]),
            SizedBox(height: 20,),

            role != "broker" ?
            ElevatedButton(
              onPressed: () => _checkingOut(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                backgroundColor: Colors.green.shade700, // Attractive orange color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                elevation: 6, // Subtle shadow for a 3D effect
                shadowColor: Colors.black54,
              ),
              child: Center(
                child: const Text(
                  "Check Out",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.white, // White text for contrast
                  ),
                ),
              ),
            ) : SizedBox.shrink(),

          ],
        ),
      ),
    );
  }

  // Helper method to build each row with the label and value
  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.brown, // Earth-tone color for label
            ),
          ),
          Flexible(
            child: Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.black87, // Dark text for readability
                fontSize: 16,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
