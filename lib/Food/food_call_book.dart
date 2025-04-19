import 'package:dh/Food/food_service_options.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Navigation/basescaffold.dart'; // Import url_launcher package

class FoodCallBookPage extends StatelessWidget {
  final String imageUrl =
      'https://i.pinimg.com/564x/4a/d4/12/4ad412860acfa0d7429942e463a7f65e.jpg';
  final String _phoneNumber = '+91 8669727126';

  const FoodCallBookPage({super.key});

  Future<void> _makePhoneCall() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: _phoneNumber,
    );

    if (!await launchUrl(launchUri)) {
      throw Exception('Could not launch $launchUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: "Food Details",
      body: Center(
        child: Card(
          elevation: 5,
          margin: const EdgeInsets.all(16.0),
          color: Colors.lightGreen[400],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: Colors.grey,
                    width: 3.0,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.network(
                    imageUrl,
                    height: 300, // Increased height for a larger image
                    width: double.infinity, // Full width
                    fit: BoxFit.cover, // Cover the container
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'What do you like to do ?',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: _makePhoneCall,
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        backgroundColor: Colors.green, // Set button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        shadowColor: Colors.greenAccent,
                        elevation: 5,
                      ),
                      child: const Text('Call', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to FoodMenuPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const FoodServiceOption()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        backgroundColor: Colors.redAccent, // Set button color
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(30), // Rounded corners
                        ),
                        shadowColor: Colors.redAccent, // Shadow color
                        elevation: 5, // Elevation
                      ),
                      child: const Text('Book', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 150),
            ],
          ),
        ),
      ),
    );
  }
}
