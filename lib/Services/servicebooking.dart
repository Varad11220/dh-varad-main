import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'booking_detail_page.dart';


 // Booked Service pAge ------------------------------------------------------

class ServiceBooking extends StatefulWidget {
  const ServiceBooking({super.key});

  @override
  _ServiceBookingState createState() => _ServiceBookingState();
}

class _ServiceBookingState extends State<ServiceBooking> {
  List<Map<String, dynamic>> bookings =
      []; // List to store all bookings with details
  bool isLoading = true; // Flag to show loading indicator

  // Map for storing specific image URLs for each service provider
  Map<String, String> serviceProviderImageUrls = {
    'Electrician':
    'https://i.pinimg.com/736x/0f/db/ce/0fdbce72cbb55ba6c87495876d70f37e.jpg',
    'Plumber':
    'https://i.pinimg.com/564x/02/29/ed/0229edf9bcf5c77cb8805b16e3ff0f1d.jpg',
    'Househelp':
    'https://www.shutterstock.com/image-vector/professional-cleaner-sanitizing-spray-mop-600nw-2180256097.jpg',
    'Laundry':
    'https://i.pinimg.com/474x/4c/f7/16/4cf716ed6f7c9d93ae1cda74b766ab2b.jpg',
    'Gardner':
    'https://img.freepik.com/premium-vector/cute-old-gardener-cutting-bushes-illustration_96037-487.jpg',
    'Grocery':
    'https://i.pinimg.com/736x/4c/3a/24/4c3a24202ddfba008d8e00c9106e810f.jpg',
    'Bicycle Booking':
    'https://i.pinimg.com/736x/0b/c6/f0/0bc6f0c57f2e87a340dfa0c31c212321.jpg',
    'Local Transport':
    'https://i.pinimg.com/736x/3d/ef/49/3def4991652bffed254fbe6a2193bc43.jpg',
    'Turf & Club':
    'https://i.pinimg.com/736x/ca/a0/27/caa027b7d94ed83ffb9824b8075b3ddc.jpg',
  };

  @override
  void initState() {
    super.initState();
    _fetchBookedServices();
  }

  Future<void> _fetchBookedServices() async {
    final prefs = await SharedPreferences.getInstance();
    final userPhoneNumber = prefs.getString('userPhoneNumber');

    if (userPhoneNumber != null) {
      final databaseRef =
          FirebaseDatabase.instance.ref('serviceBooking/$userPhoneNumber');
      try {
        final snapshot = await databaseRef.get();
        // debugPrint("Firebase Snapshot Value: ${snapshot.value}");

        if (snapshot.exists) {
          final data = snapshot.value as Map<Object?, Object?>?;


          if (data != null) {
            bookings.clear(); // Clear previous data before adding new entries

            // Loop through each booking entry
            for (var entry in data.entries) {
              final booking = entry.value as Map<Object?, Object?>?;

              if (booking != null) {
                // Retrieve bookingTime and cancelBooking
                final bookingTime = booking['bookingTime'] as String?;
                final isCancelled = booking['cancelBooking'] as bool? ?? false;

                if (bookingTime != null) {
                  final serviceProvider =
                      booking['service_provider'] as String?;

                  // Get the specific image URL from the map
                  String imageUrl =
                      serviceProviderImageUrls[serviceProvider ?? ''] ?? '';

                  // Add booking data to the list if all required data is available

                    bookings.add({
                      'bookingDate': booking['bookingDate'],
                      'bookingTime': bookingTime,
                      'serviceTime': booking['serviceTime'],
                      'serviceDate': booking['serviceDate'],
                      'serviceProvider': serviceProvider,
                      'imageUrl': imageUrl, // Use the static image URL
                      'isCancelled':
                          isCancelled, // Include the cancelBooking status
                    });

                }
              }
            }

            bookings.sort((a, b) {
              int getStatusPriority(Map<String, dynamic> booking) {
                final isCancelled = booking['isCancelled'] as bool? ?? false;
                final isPending = booking['isPending'] as bool? ?? false;

                if (isPending) return 0;       // Highest priority
                if (!isCancelled) return 1;    // Confirmed
                return 2;                      // Cancelled
              }

              int statusA = getStatusPriority(a);
              int statusB = getStatusPriority(b);

              if (statusA != statusB) {
                return statusA.compareTo(statusB);
              }

              // Sort by bookingTime if same status
              return a['bookingTime'].compareTo(b['bookingTime']);
            });

            setState(() {
              isLoading = false; // Data fetched, stop loading
            });

            // Log the sorted bookings for debugging
            print("Sorted Bookings: $bookings");
          } else {
            setState(() {
              bookings = [];
              isLoading = false; // No data found, stop loading
            });
          }
        } else {
          setState(() {
            bookings = [];
            isLoading = false; // No data found, stop loading
          });
        }
      } catch (error) {
        setState(() {
          isLoading = false; // Stop loading on error
        });
        print('Error fetching data: $error');
      }
    } else {
      setState(() {
        isLoading = false; // User phone number not found, stop loading
      });
    }
  }

  int _compareStatus(
      bool isCancelledA, bool isPendingA, bool isCancelledB, bool isPendingB) {
    if (isPendingA && !isPendingB) return -1; // A is pending, B is not
    if (!isPendingA && isPendingB) return 1; // B is pending, A is not
    if (isCancelledA && !isCancelledB) return 1; // A is cancelled, B is not
    if (!isCancelledA && isCancelledB) return -1; // B is cancelled, A is not
    return 0; // Both have the same status (either both done or both not cancelled)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator while fetching data
          : bookings.isNotEmpty
              ? ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];

                    return GestureDetector(
                      onTap: () {
                        // Navigate to the detailed booking page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingDetailPage(
                              serviceProvider:
                                  booking['serviceProvider'] as String? ?? '',
                              serviceDate:
                                  booking['serviceDate'] as String? ?? '',
                              serviceTime:
                                  booking['serviceTime'] as String? ?? '',
                              bookingDate:
                                booking['bookingDate'] as String? ?? '',
                              bookingTime:
                                  booking['bookingTime'] as String? ?? '',
                              showCancelButton: true,
                              isCancelled: booking['isCancelled'],
                            ),
                          ),
                        );
                      },
                      child: BookingCard(
                        serviceProvider: booking['serviceProvider'],
                        bookingDate: booking['bookingDate'],
                        bookingTime: booking['bookingTime'],
                        serviceTime: booking['serviceTime'],
                        serviceDate: booking['serviceDate'],
                        imageUrl: booking['imageUrl'],
                        isCancelled: booking[
                            'isCancelled'],
                        index: index,// Use the image URL from bookings
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text(
                    "No bookings yet",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final String serviceProvider;
  final String bookingTime;
  final String bookingDate;
  final String serviceTime;
  final String imageUrl;
  final String serviceDate;
  final bool isCancelled;
  final int index;

  const BookingCard({super.key, 
    required this.serviceProvider,
    required this.bookingTime,
    required this.bookingDate,
    required this.serviceTime,
    required this.imageUrl,
    required this.serviceDate,
    required this.isCancelled,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    DateTime serviceDateTime =
        DateFormat("yyyy-MM-dd HH:mm").parse("$serviceDate $serviceTime");
    DateTime now = DateTime.now();
    bool isPending = now.isBefore(serviceDateTime);
    print(serviceDateTime);
    print(now);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 2,
      color: index % 2 == 0 ? Colors.green[100] : Colors.green[150],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.black, width: 2), // Border color and width
                borderRadius: BorderRadius.circular(10.0), // Border radius
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.5),
                child: Image.network(
                  alignment: Alignment.bottomRight,
                  imageUrl.isEmpty
                      ? 'https://via.placeholder.com/110'
                      : imageUrl,
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      isCancelled
                          ? "Cancelled"
                          : isPending
                              ? "Pending"
                              : "Done",
                      style: TextStyle(
                        color: isCancelled
                            ? Colors.red // Red color for "Cancelled"
                            : isPending
                                ? Colors.green // Green color for "Pending"
                                : Colors.grey, // Grey color for "Done"
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    'Service Provider: $serviceProvider',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Booking Date: $bookingDate'),
                  const SizedBox(height: 8),
                  Text('Service D & T: $serviceDate $serviceTime'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
