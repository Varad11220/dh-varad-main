import 'package:flutter/material.dart';

class FoodCartPage extends StatefulWidget {
  const FoodCartPage({super.key});

  @override
  _FoodCartPageState createState() => _FoodCartPageState();
}

class _FoodCartPageState extends State<FoodCartPage> {
  List<Map<String, dynamic>> cartItems = []; // Initialize your cart items here
  bool isCartActive = false; // Track if the cart has items

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: Colors.redAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? const Center(
                    child: Text(
                      'Your cart is empty.',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 8.0,
                        ),
                        child: Dismissible(
                          key: Key('${item['title']}_$index'),
                          direction: DismissDirection.horizontal,
                          onDismissed: (direction) {
                            final removedItem = cartItems[index];
                            setState(() {
                              cartItems.removeAt(index);
                              isCartActive =
                                  cartItems.isNotEmpty; // Update isCartActive
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${removedItem['title']} removed from cart!'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          background: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Container(
                              color: Colors.redAccent,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                          ),
                          child: Card(
                            child: ListTile(
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(item['title'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text('${item['price']} x ${item['quantity']}',
                                      style: const TextStyle(color: Colors.green)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Add the "Proceed for Booking" button here
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle:
                      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text('Proceed for Booking'),
              ),
            ),
          ),
        ],
      ),
    );
  
  
  }
}
