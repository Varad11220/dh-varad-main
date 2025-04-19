import 'package:dh/VillaBooking/villa_details_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Developer/edit_villa.dart';
import '../Navigation/basescaffold.dart';

class VillaOwnerHome extends StatefulWidget {
  const VillaOwnerHome({super.key});

  @override
  State<VillaOwnerHome> createState() => _VillaOwnerHomeState();
}

class _VillaOwnerHomeState extends State<VillaOwnerHome> {
  final DatabaseReference reference = FirebaseDatabase.instance.ref('villas');

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
  }

  @override
  Widget build(BuildContext context) {
    if (userPhoneNumber == "0") {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    Query query = reference.orderByChild('villaOwner').equalTo(userPhoneNumber);

    return BaseScaffold(
      title: 'Our Villa',
      body:
        StreamBuilder(
          stream: query.onValue,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              return const Center(child: CircularProgressIndicator());
            }

            // Handling Firebase Data
            var data = snapshot.data!.snapshot.value;
            List<Map<dynamic, dynamic>> villaList = [];

            if (data is Map<dynamic, dynamic>) {
              villaList = data.values
                  .map((e) => Map<dynamic, dynamic>.from(e))
                  .toList();
            } else if (data is List) {
              villaList = data
                  .where((e) => e != null)
                  .map((e) => Map<dynamic, dynamic>.from(e as Map))
                  .toList();
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                double screenWidth = constraints.maxWidth;

                // Determine the number of columns dynamically
                int crossAxisCount = screenWidth > 1200
                    ? 4
                    : screenWidth > 800
                    ? 3
                    : 2;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount, // Responsive column count
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.6, // Maintain aspect ratio
                  ),
                  itemCount: villaList.length,
                  itemBuilder: (context, index) {
                    Map<dynamic, dynamic> villa = villaList[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VillaDetailsPage(
                              villaName: villa['villaName'],
                              villaNumber: villa['villaNumber'],
                              villaSize: villa['villaSize'],
                              villaPrice: villa['villaPrice'],
                              villaOwner: villa['villaOwner'],
                              villaStatus: villa['villaStatus'],
                              userPhoneNumber: userPhoneNumber,
                              role: role,

                            ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15)),
                              child: Image.asset(
                                'assets/hone.jpg',
                                height: 130,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          villa['villaName'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.blueAccent,
                                          borderRadius:
                                          BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          villa['villaSize'] ?? "N/A",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.ac_unit,
                                              color: Colors.green, size: 18),
                                          SizedBox(width: 5),
                                          Icon(Icons.wifi,
                                              color: Colors.green, size: 18),
                                          SizedBox(width: 5),
                                          Icon(Icons.pool,
                                              color: Colors.green, size: 18),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "\u20B9${villa['villaPrice']}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      const Text(
                                        "per night",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  const Text(
                                    "Lonavala",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 10), // Spacer

                                  Align(
                                    alignment: Alignment.center,
                                    child: SizedBox(
                                      width: double.infinity, // Adjust the button width properly
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditVilla(
                                                villaNumber: villa['villaNumber'],
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 8), // Adjust padding
                                          backgroundColor: Colors.blue.shade700,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10), // Less rounded corners
                                          ),
                                          elevation: 5, // Reduce elevation slightly
                                        ),
                                        child: const Text(
                                          "Edit Villa",
                                          style: TextStyle(
                                            fontSize: 12, // Increase font size for better visibility
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),


                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),

    );
  }
}
