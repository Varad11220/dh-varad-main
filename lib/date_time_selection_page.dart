import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting the date
import 'package:shared_preferences/shared_preferences.dart';
import 'Services/electrician_booking.dart'; // Import the booking page
import 'Services/service_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DateTimeSelectionPage extends StatefulWidget {
  final String serviceName;
  final String serviceImagePath;
  final List<ServiceItem> selectedServices;
  final int totalCharge;

  const DateTimeSelectionPage({
    super.key,
    required this.serviceName,
    required this.serviceImagePath,
    required this.selectedServices,
    required this.totalCharge,
  });

  @override
  _DateTimeSelectionPageState createState() => _DateTimeSelectionPageState();
}

class _DateTimeSelectionPageState extends State<DateTimeSelectionPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? userPhoneNumber;
  bool isLoading = false;


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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  Future<void> _confirmBooking() async {

    if (userPhoneNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User phone number not found')),
      );
      return;
    }

    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both date and time.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final selectedDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final dateTimeNow = DateTime.now();
    final dateTime = DateFormat('yyyy-MM-dd-HH:mm').format(DateTime.now());
    final dateTimeString = DateFormat('yyyy-MM-dd-HH:mm').format(dateTimeNow);

    final databaseRef = FirebaseDatabase.instance
        .ref('serviceBooking/$userPhoneNumber')
        .child(dateTime);
    try {
      await databaseRef.set({
        'service_provider': widget.serviceName,
        'serviceTime': DateFormat('HH:mm').format(selectedDateTime),
        'serviceDate': DateFormat('yyyy-MM-dd').format(selectedDateTime),
        'bookingTime': DateFormat('HH:mm').format(dateTimeNow),
        'bookingDate': DateFormat('yyyy-MM-dd').format(dateTimeNow),
        'userPhoneNumber': userPhoneNumber,
        'cancelBooking': false,
      });

      final url = Uri.parse('https://notify-p8xg.onrender.com/send');
      final serv = widget.serviceName;
      String fdatetime = DateFormat("MMM d, h:mm a").format(selectedDateTime);
      final msg =
          "User $userPhoneNumber has requested for $serv Service for $fdatetime";
      final td = {'title': "🔔 Service Alert", 'body': msg};
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(td),
        );
        if (response.statusCode == 200) {
          print('Title and Body sent successfully!');
        } else {
          print('Failed to send Title and Body: ${response.body}');
        }
      } catch (e) {
        print('Error: $e');
      }

      print("Data inserted successfully!");
    } catch (error) {
      print("Firebase error: $error");
    }

    setState(() {
      isLoading = false;
    });

    showDialog(
      context: context,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pop(); // Close the dialog first
          Future.delayed(const Duration(milliseconds: 100), () {
            Navigator.of(context).pop(); // Then pop the booking page
          });
          Future.delayed(const Duration(milliseconds: 100), () {
            Navigator.of(context).pop(); // Then pop the booking page
          });
        });

        return AlertDialog(
          title: const Text('Booking Confirmed!'),
          content: const Text('Your booking has been successfully submitted.'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Select Date & Time",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Picker
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                leading:
                    const Icon(Icons.calendar_today, color: Colors.lightGreen),
                title: Text(
                  selectedDate == null
                      ? 'Select Date'
                      : DateFormat('yyyy-MM-dd').format(selectedDate!),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onTap: () => _selectDate(context),
              ),
            ),
            const SizedBox(height: 16),
            // Time Picker
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                leading:
                    const Icon(Icons.access_time, color: Colors.lightGreen),
                title: Text(
                  selectedTime == null
                      ? 'Select Time'
                      : selectedTime!.format(context),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onTap: () => _selectTime(context),
              ),
            ),
            const SizedBox(height: 32),
            // Confirm Booking Button
            Center(
              child: ElevatedButton(
                onPressed: isLoading ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen, // Background color
                  foregroundColor: Colors.white, // Text color
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Book Now',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
