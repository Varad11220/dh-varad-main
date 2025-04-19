import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendBookingEmail({
  required String recipient,
  required String bookingDate,
  required String bookingTime,
  required String villaBookedDate,
  required String villaExistDate,
  required String villaName,
  required String villaNumber,
  required String villaSize,
  required String villaPrice,
  required String userPhoneNumber,
  required String brokerPhoneNumber,
  required String renterName,
  required String numberOfNights,
  required String subtotal,
  required String gst,
  required String totalAmount,
}) async {
  final url = Uri.parse('https://emailer-8uqe.onrender.com/send-booking-email');

  final data = {
    'recipient': recipient,
    'bookingDate': bookingDate,
    'bookingTime': bookingTime,
    'villaBookedDate': villaBookedDate,
    'villaExistDate': villaExistDate,
    'subtotal': subtotal,
    'gst': gst,
    'totalAmount': totalAmount,
    'villaName': villaName,
    'villaNumber': villaNumber,
    'villaSize': villaSize,
    'villaPrice': villaPrice,
    'userPhoneNumber': userPhoneNumber,
    'brokerPhoneNumber': brokerPhoneNumber,
    'renterName': renterName,
    'numberOfNights': numberOfNights,
  };

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      print('Email sent successfully!');
    } else {
      print('Failed to send email: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}