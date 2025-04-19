import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../email_sender.dart';

class VillaBooking extends StatefulWidget {
  final String villaName;
  final String villaNumber;
  final String villaSize;
  final String villaPrice;
  final String userPhoneNumber;
  final String role;

  const VillaBooking({
    super.key,
    required this.villaName,
    required this.villaNumber,
    required this.villaSize,
    required this.villaPrice,
    required this.role,
    required this.userPhoneNumber,
  });

  @override
  State<VillaBooking> createState() => _VillaBookingState();
}

class _VillaBookingState extends State<VillaBooking> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  String userPhoneNumber = "0";

  double? _subtotal;
  double? _gstAmount;
  double? _totalCost;
  int? _numberOfNights;

  @override
  void initState() {
    super.initState();
    _initializeSharedPreferences();
    }

  Future<void> _initializeSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? userPhoneNumbertemp = prefs.getString('userPhoneNumber');
    if (userPhoneNumbertemp != null) {
      setState(() {
        userPhoneNumber = userPhoneNumbertemp;
      });
    }
  }


  void _calculateCost() {
    if (_startDateController.text.isNotEmpty && _endDateController.text.isNotEmpty) {
      DateTime startDate = DateFormat('yyyy-MM-dd').parse(_startDateController.text);
      DateTime endDate = DateFormat('yyyy-MM-dd').parse(_endDateController.text);

      if (endDate.isAfter(startDate) || endDate.isAtSameMomentAs(startDate)) {
        setState(() {
          _numberOfNights = endDate.difference(startDate).inDays + 1;
          double pricePerNight = double.parse(widget.villaPrice);
          _subtotal = _numberOfNights! * pricePerNight;
          _gstAmount = _subtotal! * 0.18; // Assuming 18% GST
          _totalCost = _subtotal! + _gstAmount!;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End date must be after or same as start date.')),
        );
      }
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
      _calculateCost();
    }
  }

  bool _isLoading = false;

  Future<void> _storeBookingData() async{

    setState(() {
      _isLoading = true; // Show progress indicator
    });

    final DatabaseReference reference2 = FirebaseDatabase.instance.ref("villas").child(widget.villaNumber);
    final DatabaseReference reference = FirebaseDatabase.instance.ref();
    final DatabaseReference reference3 = FirebaseDatabase.instance.ref("userdata");

    final villaStatus = {
      widget.villaNumber:{
        "renterContact": _contactController.text,
        "entryDate": _startDateController.text,
        "existDate": _endDateController.text,
      }
    };

    final bookingData = {
      "renterDetails":
      {
        "renterName": _nameController.text,
        "renterEmail": _emailController.text,
        "renterContact": _contactController.text,
      },
      "villaDetails":
      {
        "villaName": widget.villaName,
        "villaNumber": widget.villaNumber,
        "villaSize": widget.villaSize,
        "villaPrice": widget.villaPrice,
      },
      "date":
      {
        "entryDate": _startDateController.text,
        "existDate": _endDateController.text,
        "numberOfNights": _numberOfNights,
      },
      "cost":
      {
        "subCost": _subtotal,
        "gstCost": _gstAmount,
        "totalCost": _totalCost,
      }
    };

    final userBookingData = {
      "renterDetails":
      {
        "renterName": _nameController.text,
        "renterEmail": _emailController.text,
        "renterContact": _contactController.text,
      },
      "villaDetails":
      {
        "villaName": widget.villaName,
        "villaNumber": widget.villaNumber,
        "villaSize": widget.villaSize,
        "villaPrice": widget.villaPrice,
      },
      "date":
      {
        "entryDate": _startDateController.text,
        "existDate": _endDateController.text,
        "numberOfNights": _numberOfNights,
      },
      "cost":
      {
        "subCost": _subtotal,
        "gstCost": _gstAmount,
        "totalCost": _totalCost,
      },
      "isUserCheckIn":"yes",
    };

    try{
      DateTime now = DateTime.now();
      String currentDate = DateFormat('dd-MM-yyyy').format(now);
      String currentTime = DateFormat('hh:mm a').format(now);

      await reference.child("villaRenters").child(widget.userPhoneNumber).child(_contactController.text).push().set(bookingData);

      await reference2.child('available').set(villaStatus);
      
      await reference3.child(_contactController.text).child("userBookedVillas").push().set(userBookingData);

      await sendBookingEmail(
          recipient: _emailController.text,
          bookingDate: currentDate,
          bookingTime: currentTime,
          villaBookedDate: _startDateController.text,
          villaExistDate: _endDateController.text,
          villaName: widget.villaName,
          villaNumber: widget.villaNumber,
          villaSize: widget.villaSize,
          villaPrice: widget.villaPrice,
          userPhoneNumber: _contactController.text,
          brokerPhoneNumber: userPhoneNumber,
          renterName: _nameController.text,
          numberOfNights: _numberOfNights?.toString() ?? "0",
          subtotal: _subtotal?.toString() ?? "0",
          gst: _gstAmount?.toString() ?? "0",
          totalAmount: _totalCost?.toString() ?? "0",

      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data Saved Successfully")
        ),
      );
      _nameController.clear();
      _contactController.clear();
      _emailController.clear();
      _startDateController.clear();
      _endDateController.clear();
      _isLoading = false;

      setState(() {
        _subtotal = null;
        _gstAmount = null;
        _totalCost = null;
        _numberOfNights = null;
        _isLoading = false;
      });

      Navigator.pop(context);

    }
    catch (e){
      setState(() {
        _subtotal = null;
        _gstAmount = null;
        _totalCost = null;
        _numberOfNights = null;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error storing booking: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book ${widget.villaName}"),
        backgroundColor: Colors.lightGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Villa Image
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/hone.jpg'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              // Villa Details
              const Text(
                "Villa Details",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              Text("Name: ${widget.villaName}", style: const TextStyle(fontSize: 16)),
              Text("Number: ${widget.villaNumber}", style: const TextStyle(fontSize: 16)),
              Text("Size: ${widget.villaSize} BHK", style: const TextStyle(fontSize: 16)),
              Text("Price: Rs ${widget.villaPrice} / night", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              const Divider(),
              const Text(
                "Your Details",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              // Form Fields
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Your Name",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email Address",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Contact field
                    TextFormField(
                      controller: _contactController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Contact Number (+91 format)",
                        border: OutlineInputBorder(),
                        prefixText: "+91 ",
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        String formattedValue = value?.replaceAll("+91 ", "") ?? "";
                        if (formattedValue.isEmpty) {
                          return 'Please enter your contact number';
                        }
                        if (!RegExp(r'^\d{10}$').hasMatch(formattedValue)) {
                          return 'Please enter a valid 10-digit number';
                        }
                        return null;
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Start Date field
                    TextFormField(
                      controller: _startDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "Start Date",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () => _selectDate(_startDateController),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a start date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    // End Date field
                    TextFormField(
                      controller: _endDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "End Date",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () => _selectDate(_endDateController),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an end date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Costing Section
                    if (_subtotal != null && _gstAmount != null && _totalCost != null)
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.only(top: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Booking Summary",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Number of Nights:"),
                                  Text("$_numberOfNights", style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Subtotal (Rs):"),
                                  Text(_subtotal!.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("GST (18%):"),
                                  Text(_gstAmount!.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Total Cost:",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Rs ${_totalCost!.toStringAsFixed(2)}",
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    // Book Now Button
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                            setState(() {
                              _isLoading = true;
                            });

                            showLoadingPopup(context); // Show popup

                            await _storeBookingData(); // Your function

                            Navigator.pop(context); // Dismiss popup after done

                            setState(() {
                              _isLoading = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            backgroundColor: Colors.green.shade700, // Active Green
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            shadowColor: Colors.black54,
                            elevation: 6, // Subtle shadow for 3D effect
                          ),
                          child: const Text(
                            'Book Now',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
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
      ),
    );
  }

  void showLoadingPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/loading.json',
                    width: 150,
                    height: 150,
                    repeat: true,
                    errorBuilder: (context, error, stackTrace) => const CircularProgressIndicator(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Booking in progress...",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}
