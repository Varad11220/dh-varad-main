import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
// import 'package:flutter_sms/flutter_sms.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import the Fluttertoast package
import 'package:http/http.dart' as http;
import 'dart:convert';

class FoodBillSummaryPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final DateTime? date;
  final TimeOfDay? time;
  final String selectedFoodType;
  String? villaName;

  FoodBillSummaryPage({
    super.key,
    required this.cartItems,
    this.date,
    this.time,
    required this.villaName,
    required this.selectedFoodType,
  });

  @override
  _FoodBillSummaryPageState createState() => _FoodBillSummaryPageState();
}

class _FoodBillSummaryPageState extends State<FoodBillSummaryPage> {
  String? userPhoneNumber;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeSharedPreferences();
  }

  Future<void> _initializeSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userPhoneNumber = prefs.getString('userPhoneNumber');
    });
  }

  Future<bool> _isPermissionGranted() async =>
      await Permission.sms.status.isGranted;

  // Future<void> _sendMessage(String phoneNumber, String message) async {
  //   try {
  //     String result = await sendSMS(
  //       message: message,
  //       recipients: [phoneNumber],
  //     );
  //
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       if (result == "SMS Sent!") {
  //         Fluttertoast.showToast(
  //           msg: "SMS Sent: Your order has been placed!",
  //           toastLength: Toast.LENGTH_LONG,
  //           gravity: ToastGravity.BOTTOM,
  //           backgroundColor: Colors.green,
  //           textColor: Colors.white,
  //           fontSize: 16.0,
  //         );
  //       } else {
  //         Fluttertoast.showToast(
  //           msg: "Failed to send SMS",
  //           toastLength: Toast.LENGTH_LONG,
  //           gravity: ToastGravity.BOTTOM,
  //           backgroundColor: Colors.red,
  //           textColor: Colors.white,
  //           fontSize: 16.0,
  //         );
  //       }
  //     });
  //   } catch (e) {
  //     Fluttertoast.showToast(
  //       msg: "Error: ${e.toString()}",
  //       toastLength: Toast.LENGTH_LONG,
  //       gravity: ToastGravity.BOTTOM,
  //       backgroundColor: Colors.red,
  //       textColor: Colors.white,
  //       fontSize: 16.0,
  //     );
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    // Initialize totalCost
    double totalCost = 0;

    // Calculate totalCost
    for (var item in widget.cartItems) {
      totalCost +=
          double.parse(item['price'].replaceAll('₹ ', '')) * item['quantity'];
    }

    // Calculate GST and grand total
    const double gstPercentage = 0.18; // 18%
    double gstAmount = totalCost * gstPercentage;
    double grandTotal = totalCost + gstAmount;

    // Format the booking date and time
    String formattedDate = widget.date != null
        ? DateFormat('yMMMMd').format(widget.date!)
        : 'No date selected';
    String formattedTime =
    widget.time != null ? widget.time!.format(context) : 'No time selected';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bill Summary',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Delivery Time',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '$formattedDate at $formattedTime', // Display formatted date and time
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(
                  width: 20,
                ),
                const Text(
                  "Diliver On :- ",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.villaName ?? 'No Villa Selected',
                  textAlign: TextAlign.end, // Align villa name to the end
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis, // Handle overflow gracefully
                  maxLines: 1,
                ),
              ],
            ),
            Text(
              widget.selectedFoodType == '1'
                  ? 'Food Booking Type :- Dining'
                  : 'Food Booking Type :- Home Delivery',
              style: TextStyle(
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Order Summary',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Billing Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Individual items
                  ...widget.cartItems.map((item) {
                    return Column(
                      children: [
                        buildBillingDetail(
                          item['title'],
                          item['quantity'],
                          double.parse(item['price'].replaceAll('₹ ', '')) *
                              item['quantity'],
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  }),
                  const Divider(),
                  // Total Price
                  buildBillingDetail('Total', 0, grandTotal, isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Proceed to Payment Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isProcessing
                    ? null // Disable the button when processing
                    : () async {
                  setState(() {
                    isProcessing = true; // Disable the button
                  });

                  try {
                    if (userPhoneNumber == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('User phone number not found')),
                      );
                      return;
                    }

                    final dateTime = DateFormat('yyyy-MM-dd-HH:mm')
                        .format(DateTime.now());
                    final deldate =
                    DateFormat('yyyy-MM-dd').format(DateTime.now());
                    final countRef =
                    FirebaseDatabase.instance.ref('food/count');
                    final countSnapshot = await countRef.get();

                    int orderCount = countSnapshot.value as int;

                    final databaseRef = FirebaseDatabase.instance
                        .ref('foodOrders/$userPhoneNumber')
                        .child(dateTime);
                    await databaseRef.set({
                      'orderDetails': widget.cartItems
                          .map((item) => {
                        'title': item['title'],
                        'quantity': item['quantity'],
                        'price': item['price'],
                      })
                          .toList(),
                      'orderTime': dateTime,
                      'totalCost': totalCost,
                      'gstAmount': gstAmount,
                      'grandTotal': grandTotal,
                      'deliveryDate': deldate,
                      'deliveryTime': formattedTime,
                      'status': "1",
                      'count': orderCount,
                      'villaName': widget.villaName,
                      'selectedFoodType': widget.selectedFoodType,
                      // }).then((_) async {
                      //   if (await _isPermissionGranted()) {
                      //     _sendMessage(
                      //       userPhoneNumber!,
                      //       "Your total bill is ₹ ${grandTotal.toStringAsFixed(2)}",
                      //     );
                      //   } else {
                      //     Fluttertoast.showToast(
                      //       msg: "SMS permission not granted!",
                      //       toastLength: Toast.LENGTH_LONG,
                      //       gravity: ToastGravity.BOTTOM,
                      //       backgroundColor: Colors.red,
                      //       textColor: Colors.white,
                      //       fontSize: 16.0,
                      //     );
                      //   }
                    });

                    await countRef.set(orderCount + 1);

                    final url = Uri.parse(
                        'https://notify-p8xg.onrender.com/send');
                    final villa = widget.villaName;

                    // Fix the date/time parsing issue
                    String formatteddatetime;
                    try {
                      // If we have a valid date and time from the widget
                      if (widget.date != null && widget.time != null) {
                        // Create a DateTime that combines the date and time
                        final DateTime combinedDateTime = DateTime(
                          widget.date!.year,
                          widget.date!.month,
                          widget.date!.day,
                          widget.time!.hour,
                          widget.time!.minute,
                        );
                        // Format it directly in the desired output format
                        formatteddatetime = DateFormat("MMM d, h:mm a")
                            .format(combinedDateTime);
                      } else {
                        // Fallback if date or time is missing
                        formatteddatetime =
                        "$formattedDate at $formattedTime";
                      }
                    } catch (e) {
                      // If any parsing error occurs, use a simple fallback
                      formatteddatetime =
                      "$formattedDate at $formattedTime";
                    }

                    final msg =
                        "Food delivery request from $villa for $formatteddatetime";
                    final td = {
                      'title': "🔔 Food Service Alert",
                      'body': msg
                    };
                    try {
                      final response = await http.post(
                        url,
                        headers: {'Content-Type': 'application/json'},
                        body: json.encode(td),
                      );
                      if (response.statusCode == 200) {
                        print('Title and Body sent successfully!');
                      } else {
                        print(
                            'Failed to send Title and Body: ${response.body}');
                      }
                    } catch (e) {
                      print('Error: $e');
                    }

                    Navigator.popUntil(context, (route) => route.isFirst);
                  } catch (e) {
                    Fluttertoast.showToast(
                      msg: "An error occurred: $e",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  } finally {
                    setState(() {
                      isProcessing = false; // Enable the button
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Colors.lightGreen[400],
                ),
                child: isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Place my order',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for displaying billing items
  Widget buildBillingDetail(String item, int quantity, double price,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isTotal ? item : '$item (x$quantity)',
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '₹${price.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
