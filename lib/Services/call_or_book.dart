import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'service_item.dart';
import '../date_time_selection_page.dart';


  // CAll Book PAge 2 ---------------------------------------------

class ElectricianPage extends StatefulWidget {
  final String title;
  final String imagePath;
  final List<List<String>> serviceOptions;
  final List<List<int>> servicesCharge;

  const ElectricianPage({
    super.key,
    required this.title,
    required this.imagePath,
    required this.serviceOptions,
    required this.servicesCharge,
  });

  @override
  State<ElectricianPage> createState() => _ElectricianPageState();
}

class _ElectricianPageState extends State<ElectricianPage> {
  final String _phoneNumber = '+91 7506541325';

  Future<void> _makePhoneCall() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: _phoneNumber,
    );

    if (!await launchUrl(launchUri)) {
      throw Exception('Could not launch $launchUri');
    }
  }

  List<ServiceItem> _convertToServiceItems() {
    List<ServiceItem> serviceItems = [];
    for (int i = 0; i < widget.serviceOptions.length; i++) {
      for (int j = 0; j < widget.serviceOptions[i].length; j++) {
        serviceItems.add(ServiceItem(
          name: widget.serviceOptions[i][j],
          price: widget.servicesCharge[i][j],
          imagePath:
          'assets/AC.png', // Use a default image or customize based on service
        ));
      }
    }
    return serviceItems;
  }

  Future<void> _bookService() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'your_selected_service_name', widget.title.toString());

// Convert the service options to ServiceItem and pass it
    List<ServiceItem> selectedServices = _convertToServiceItems();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DateTimeSelectionPage(
          serviceName: widget.title,
          serviceImagePath: widget.imagePath,
          selectedServices: _convertToServiceItems(),
          totalCharge: 99, // Default visiting charge
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(

        child: Card(
          elevation: 5,
          color: Colors.lightGreen[400],
          margin: const EdgeInsets.all(16.0),
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
                    widget.imagePath,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${widget.title} Service',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 8),
              // const Text(
              //   'Visiting charge: Rs 99',
              //   style: TextStyle(
              //     fontSize: 18,
              //     color: Colors.blueGrey,
              //   ),
              // ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _makePhoneCall,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700], // Deep forest green
                      foregroundColor: Colors.white, // White text
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Smooth edges
                      ),
                      elevation: 4, // Slight shadow for depth
                    ),
                    child: const Text(
                      'Call',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _bookService,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[600], // Earthy brown tone
                      foregroundColor: Colors.white, // White text
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4, // Subtle shadow
                    ),
                    child: const Text(
                      'Book',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}