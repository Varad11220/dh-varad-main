import 'package:flutter/material.dart';
import 'package:dh/Registeration/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'VillaBooking/homescreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Handle FCM when app is in background/terminated
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background Message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Setup local notifications for foreground FCM
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String? role = prefs.getString('role');

  // If user is admin, initialize FCM

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: widget.isLoggedIn
          ? const CarouselScreen()
          : const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignupScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Image.asset('assets/doodle_splash.png')),
    );
  }
}

Future<void> setupFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request notification permissions (important for iOS)
  await messaging.requestPermission();

  // Get the FCM device token (optional: send to server)
  String? token = await messaging.getToken();
  print('FCM Token: $token');

  // Store token in Firebase Realtime Database
  if (token != null) {
    try {
      final DatabaseReference database = FirebaseDatabase.instance.ref();
      final tokensRef = database.child('admin_tokens');

      // Get existing tokens to check for duplicates and determine next token number
      final DataSnapshot snapshot = await tokensRef.get();
      int tokenCount = 0;
      bool tokenExists = false;

      if (snapshot.exists && snapshot.value is Map) {
        Map<dynamic, dynamic> tokensMap = snapshot.value as Map;
        tokenCount = tokensMap.length;

        // Check if token already exists
        tokenExists = tokensMap.values.contains(token);
      }

      // Only add token if it doesn't already exist
      if (!tokenExists) {
        // Add token with sequential numbering
        final tokenRef = tokensRef.child('token${tokenCount + 1}');
        await tokenRef.set(token);
        print('Token stored successfully in Firebase database!');
      } else {
        print('Token already exists in database, not adding duplicate.');
      }
    } catch (e) {
      print('Error storing token in Firebase: $e');
    }
  }

  // Foreground handler
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        0,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'message_channel',
            'Admin Messages',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  });
}
