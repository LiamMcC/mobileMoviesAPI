// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  Timer? _timer;  // Timer instance to control the periodic notifications

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _checkNotificationPermission(); // Request notification permissions on app start
  }

  // Initialize the Flutter Local Notifications plugin
  void _initializeNotifications() {
    print("Initializing notifications...");

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('stack'); // Provide your app icon asset

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    _flutterLocalNotificationsPlugin.initialize(initializationSettings).then((_) {
      print("Notification initialization complete.");
    });
  }

  // Request notification permission for Android 13+
  Future<void> _checkNotificationPermission() async {
    print("Checking notification permission...");

    if (await Permission.notification.isDenied) {
      print("Notification permission is denied. Requesting permission...");
      await Permission.notification.request();
    } else {
      print("Notification permission is already granted.");
    }
  }

  // Schedule a notification every 60 seconds
  void _scheduleNotification() {
    print("Scheduling notification every 20 seconds...");
    const Duration duration = Duration(seconds: 20); // Changed to 20 seconds for testing

    // Start the periodic timer and store the reference in _timer
    _timer = Timer.periodic(duration, (timer) async {
      print("Sending notification...");
      _showNotification();
    });
  }

  // Show the notification
  Future<void> _showNotification() async {
    try {
      print("Preparing notification...");

      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'hello_channel', // Notification channel ID
        'Hello Notifications', // Channel name
        channelDescription: 'Channel for hello notifications every minute',
        importance: Importance.high,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);

      await _flutterLocalNotificationsPlugin.show(
        0, // Notification ID
        'Hello', // Title
        'This is your notification every 20 seconds!', // Message
        notificationDetails,
        payload: 'Hello Notification Payload', // Optional payload
      );

      print("Notification sent successfully.");
    } catch (e) {
      print("Error sending notification: $e");
    }
  }

  // Stop the periodic notifications
  void _stopNotifications() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();  // Cancel the timer
      print("Notifications stopped.");
    } else {
      print("No active timer to stop.");
    }
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Notification Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                print("Button pressed to start notifications.");
                _scheduleNotification(); // Start the timer
              },
              child: const Text('Notify Every 200 Seconds'),
            ),
            const SizedBox(height: 200),
            ElevatedButton(
              onPressed: () {
                print("Button pressed to stop notifications.");
                _stopNotifications(); // Stop the timer
              },
              child: const Text('Stop Notifications'),
            ),
          ],
        ),
      ),
    );
  }
}
