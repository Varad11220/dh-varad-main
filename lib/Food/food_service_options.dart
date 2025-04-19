import 'package:flutter/material.dart';
import 'package:dh/Food/food_menu_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food 😋',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const FoodServiceOption(),
    );
  }
}

class FoodServiceOption extends StatefulWidget {
  const FoodServiceOption({super.key});

  @override
  _FoodServiceOptionState createState() => _FoodServiceOptionState();
}

class _FoodServiceOptionState extends State<FoodServiceOption> {
  String _selectedOption = 'Dining In';
  String? selectedFoodType;

  void _selectOption(String option, {bool navigate1 = false, bool navigate2 = false}) {
    setState(() {
      _selectedOption = option;
    });

    if (navigate1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FoodMenuPage(selectedFoodType: '1',)),
      );
    }
    if(navigate2){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FoodMenuPage(selectedFoodType: '2',)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text(
          'Food 😋',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        // decoration: const BoxDecoration(
        //   gradient: LinearGradient(
        //     colors: [
        //       Color(0XFFDCEDC8),
        //       Color(0XFF388E3C)
        //     ], // Light Green to Dark Green
        //     begin: Alignment.topLeft,
        //     end: Alignment.bottomRight,
        //   ),
        // ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text('Choose Your Option', style: _headerTextStyle),
            const SizedBox(height: 8),
            const Text(
              "Welcome to Food Booking Section, Whether you're dining in, ordering for home delivery we've got you covered.",
              textAlign: TextAlign.justify,
              style: _subHeaderTextStyle,
            ),
            const SizedBox(height: 40),
            _buildOptionButton(
                'Dining In',
                Icons.restaurant,
                _selectedOption == 'Dining In',
                    () => _selectOption('Dining In', navigate1: true, navigate2: false)),
            const SizedBox(height: 20),
            _buildOptionButton(
                'Doorstep Delivery',
                Icons.delivery_dining,
                _selectedOption == 'Doorstep Delivery',
                    () => _selectOption('Doorstep Delivery', navigate2: true, navigate1: false)),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
      String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
              colors: [Colors.green[800]!, Colors.green[500]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight)
              : LinearGradient(
              colors: [Colors.white, Colors.grey[300]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: isSelected ? Colors.black26 : Colors.black12,
                offset: const Offset(0, 4),
                blurRadius: 8)
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          splashColor: Colors.greenAccent[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.black54),
              const SizedBox(width: 10),
              Text(label,
                  style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

// Extracted text styles for cleaner code
const TextStyle _headerTextStyle =
TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.brown);
const TextStyle _subHeaderTextStyle =
TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.brown);
