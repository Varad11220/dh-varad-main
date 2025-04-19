import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Services/booking_detail_page.dart';
import '../Services/servicebooking.dart';

class AdminAllBooking extends StatefulWidget {
  const AdminAllBooking({super.key});

  @override
  _AdminAllBookingState createState() => _AdminAllBookingState();
}

class _AdminAllBookingState extends State<AdminAllBooking> {
  List<Map<String, dynamic>> allBookings = []; // List to store all bookings
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
    _fetchAllBookings();
  }

  Future<void> _fetchAllBookings() async {
    try {
      final databaseRef = FirebaseDatabase.instance.ref('serviceBooking');
      final snapshot = await databaseRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<Object?, Object?>?;

        if (data != null) {
          allBookings.clear(); // Clear previous data before adding new entries

          // Loop through each user's bookings
          for (var userEntry in data.entries) {
            final userPhoneNumber = userEntry.key as String?;
            final userBookings = userEntry.value as Map<Object?, Object?>?;

            if (userPhoneNumber != null && userBookings != null) {
              // Loop through each booking for the current user
              for (var bookingEntry in userBookings.entries) {
                final booking = bookingEntry.value as Map<Object?, Object?>?;
                // print("Booking for $userPhoneNumber: $booking");

                if (booking != null) {
                  // Retrieve bookingTime and cancelBooking
                  final bookingTime = booking['bookingTime'] as String?;
                  final isCancelled =
                      booking['cancelBooking'] as bool? ?? false;

                  if (bookingTime != null) {
                    final serviceProvider =
                        booking['service_provider'] as String?;

                    // Get the specific image URL from the map
                    String imageUrl =
                        serviceProviderImageUrls[serviceProvider ?? ''] ?? '';

                      allBookings.add({
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
            }
          }

          // Sort allBookings by status and bookingTime
          allBookings.sort((a, b) {
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

          // Log the allBookings for debugging
          print("allBookings: $allBookings");
        } else {
          setState(() {
            allBookings = [];
            isLoading = false; // No data found, stop loading
          });
        }
      } else {
        setState(() {
          allBookings = [];
          isLoading = false; // No data found, stop loading
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false; // Stop loading on error
      });
      print('Error fetching data: $error');
    }
  }

// Helper function to compare statuses
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
                  CircularProgressIndicator(), // Show loading indicator while fetching data
            )
          : allBookings.isNotEmpty
              ? ListView.builder(
                  itemCount: allBookings.length,
                  itemBuilder: (context, index) {
                    final booking = allBookings[index];

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
                              showCancelButton: false,
                              isCancelled: true,
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
                    "No bookings available",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
    );
  }
}
