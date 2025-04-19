import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../VillaBooking/villa_details_page.dart';
import '../Navigation/basescaffold.dart';
import "dart:ui";

class CarouselScreen extends StatefulWidget {
  const CarouselScreen({super.key});

  @override
  _CarouselScreenState createState() => _CarouselScreenState();
}

class _CarouselScreenState extends State<CarouselScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String searchQuery = "";

  bool _isSearchFocused = false;

  final List<String> imageUrls = [
    'assets/hone.jpg',
    'assets/home.jpg',
    'assets/htwo.jpg',
  ];

  String userPhoneNumber = "0";
  String role = "user";
  List<String> selectedFilters = []; // 🔹 Store selected filters

  final DatabaseReference reference = FirebaseDatabase.instance.ref('villas');
  List<Map<dynamic, dynamic>> villaList = []; // ✅ Define villaList here

  @override
  void initState() {
    super.initState();
    _initializeSharedPreferences();

    // 🔹 Add listener for search bar focus
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose(); // ✅ Properly dispose of FocusNode
    super.dispose();
  }

  Future<void> _initializeSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? userPhoneNumbertemp = prefs.getString('userPhoneNumber');
    String? userRole = prefs.getString('role');
    if (userRole != null && userPhoneNumbertemp != null) {
      setState(() {
        userPhoneNumber = userPhoneNumbertemp;
        role = userRole;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return BaseScaffold(
      title: "Home",
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Carousel Slider
            // 🔹 StreamBuilder to fetch villa data before the carousel
            StreamBuilder(
              stream: reference.onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (!snapshot.hasData ||
                    snapshot.data?.snapshot.value == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                var data = snapshot.data!.snapshot.value;
                List<Map<dynamic, dynamic>> villaList = [];

                if (data is Map<dynamic, dynamic>) {
                  villaList = data.values
                      .map((villa) => villa as Map<dynamic, dynamic>)
                      .toList();
                } else if (data is List) {
                  villaList = data
                      .where((villa) => villa != null)
                      .map((villa) => villa as Map<dynamic, dynamic>)
                      .toList();
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: CarouselSlider(
                        items: villaList.map((villa) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                margin:
                                const EdgeInsets.symmetric(horizontal: 5),
                                width: 300,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: const DecorationImage(
                                    image: AssetImage(
                                        'assets/htwo.jpg'), // Replace with villa image
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    // Gradient Overlay for Better Text Visibility
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.4),
                                            Colors.transparent
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Villa Name & Price (Bottom Left)
                                    Positioned(
                                      bottom: 10,
                                      left: 10,
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text("Luxury Villa " +
                                            villa['villaName'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "\u20B9${double.tryParse(villa['villaPrice'].toString()) ?? 0} / night",
                                            style: const TextStyle(
                                              color: Colors.greenAccent,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),

                                    // Ratings (Bottom Right)
                                    Positioned(
                                      bottom: 10,
                                      right: 10,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          // Star Rating Icons
                                          Row(
                                            children: List.generate(5, (index) {
                                              return Icon(
                                                index < (double.tryParse(villa['villaRating'].toString())?.toInt() ?? 0)
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                color: Colors.amber,
                                                size: 18,
                                              );
                                            }),
                                          ),

                                          const SizedBox(width: 5), // Space between stars and text

                                          // Rating Text
                                          Text(
                                            '${(double.tryParse(villa['villaRating'].toString()) ?? 0).toStringAsFixed(1)}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }).toList(),
                        options: CarouselOptions(
                          height: 200,
                          enlargeCenterPage: true,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 3),
                          viewportFraction: 0.8,
                          aspectRatio: 2.0,
                          initialPage: 0,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // 🔹 Search Bar
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: TextField(
                  focusNode: _searchFocusNode,
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search luxury villas...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? GestureDetector(
                      onTap: () {
                        setState(() {
                          _searchController.clear();
                          searchQuery = "";
                          _searchFocusNode.unfocus();
                        });
                      },
                      child: const Icon(Icons.close),
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                  onTapOutside: (event) {
                    _searchFocusNode.unfocus();
                  },
                ),
              ),
            ),

            // 🔹 Filter Chips (1BHK, 2BHK, etc..)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ["1BHK", "2BHK", "3BHK", "4BHK", "5BHK"]
                      .map((category) => _buildFilterChip(category))
                      .toList(),
                ),
              ),
            ),

            // 🔹 Featured Villas Title
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                "Featured Villas",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            // 🔹 StreamBuilder to fetch and filter Villas
            StreamBuilder(
              stream: reference.onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                var data = snapshot.data!.snapshot.value;
                List<Map<dynamic, dynamic>> villaList = [];

                if (data is Map<dynamic, dynamic>) {
                  villaList = data.values
                      .map((villa) => villa as Map<dynamic, dynamic>)
                      .where((villa) {
                    // Normalize villa size (remove spaces)
                    String formattedVillaSize = villa['villaSize'].toString().replaceAll(" ", "").toLowerCase();

                    // Convert price to string for searching
                    String villaPrice = villa['villaPrice'].toString().toLowerCase();

                    // Normalize selected filters to match villa sizes
                    List<String> normalizedFilters = selectedFilters.map((filter) => filter.replaceAll(" ", "").toLowerCase()).toList();

                    return (
                        villa['villaName'].toString().toLowerCase().contains(searchQuery) ||
                            formattedVillaSize.contains(searchQuery) ||
                            villaPrice.contains(searchQuery)
                    ) &&
                        (selectedFilters.isEmpty || normalizedFilters.contains(formattedVillaSize));
                  }).toList();
                } else if (data is List) {
                  villaList = data
                      .where((villa) => villa != null)
                      .map((villa) => villa as Map<dynamic, dynamic>)
                      .where((villa) {
                    // Normalize villa size (remove spaces)
                    String formattedVillaSize = villa['villaSize'].toString().replaceAll(" ", "").toLowerCase();

                    // Convert price to string for searching
                    String villaPrice = villa['villaPrice'].toString().toLowerCase();

                    // Normalize selected filters
                    List<String> normalizedFilters = selectedFilters.map((filter) => filter.replaceAll(" ", "").toLowerCase()).toList();

                    return (
                        villa['villaName'].toString().toLowerCase().contains(searchQuery) ||
                            formattedVillaSize.contains(searchQuery) ||
                            villaPrice.contains(searchQuery)
                    ) &&
                        (selectedFilters.isEmpty || normalizedFilters.contains(formattedVillaSize));
                  }).toList();
                }

                return villaList.isNotEmpty
                    ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: villaList.length,
                        itemBuilder: (context, index) {
                          var villa = villaList[index];
                          return _buildVillaCard(villa);
                        },
                      );
                    },
                  ),
                )
                    : const Center(
                  child: Text(
                    "No villas found",
                    style: TextStyle(fontSize: 16),
                  ),
                );
              },
            ),


          ],
        ),
      ),
    );
  }

  // 🔹 Function to Build Filter Chip

  Widget _buildFilterChip(String category) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(category),
        selected: selectedFilters.contains(category),
        onSelected: (bool selected) {
          setState(() {
            selected
                ? selectedFilters.add(category)
                : selectedFilters.remove(category);
          });
        },
      ),
    );
  }

  // 🔹 Function to Build Villa Card
  Widget _buildVillaCard(Map<dynamic, dynamic> villa) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: villa['villaStatus'] == "on"
            ? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VillaDetailsPage(
                villaName: villa['villaName'],
                villaNumber: villa['villaNumber'],
                villaSize: villa['villaSize'],
                villaPrice: villa['villaPrice'],
                villaOwner: villa['villaOwner'],
                villaStatus: villa['villaStatus'],
                userPhoneNumber: userPhoneNumber,
                role: role,

              ),
            ),
          );
        }
            : null,
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                double imageHeight = constraints.maxWidth * 0.64;
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ Image Section
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(15)),
                            child: Image.asset(
                              'assets/hone.jpg', // Replace with actual villa image
                              height: imageHeight,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // ⭐ Rating Badge (Top Right)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 5,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 14),
                                  const SizedBox(width: 3),
                                  Text(
                                    villa['villaRating'].toString(),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ✅ Details Section
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Villa Name + BHK Type
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    villa['villaName'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow
                                        .ellipsis, // Prevents overflow
                                    maxLines: 1,
                                  ),
                                ),
                                // 🌟 Show BHK Type
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          villa['villaSize'] ?? "N/A",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )),
                              ],
                            ),

                            const SizedBox(height: 8),

                            Row(
                              children: [
                                const Icon(Icons.ac_unit,
                                    color: Colors.green, size: 16),
                                const SizedBox(width: 5),
                                const Icon(Icons.wifi,
                                    color: Colors.green, size: 16),
                                const SizedBox(width: 5),
                                const Icon(Icons.pool,
                                    color: Colors.green, size: 16),
                                const SizedBox(
                                  width: 50,
                                ),
                                Text(
                                  villa['villaStatus'] ?? "N/A",
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 255, 17, 17),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 5),

                            // Price Section
                            Row(
                              children: [
                                Text(
                                  "\u20B9${villa['villaPrice']}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Text(
                                  "per night",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            //  ✅ blur effect & disable overlay of villastatus os not "on"
            if (villa['villaStatus'] != "on")
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: BackdropFilter(
                    filter:
                    ImageFilter.blur(sigmaX: 1, sigmaY: 1), // Blur effect
                    child: Container(
                      color: Colors.black.withOpacity(0.7), // Light overlay
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
