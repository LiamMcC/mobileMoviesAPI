// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _PreferencesPageState createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  final TextEditingController _nameController = TextEditingController();
  String _savedName = '';

  // Function to load saved data from SharedPreferences
  Future<void> _loadName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedName = prefs.getString('user_name') ?? 'No name saved';
    });
  }

  // Function to save data to SharedPreferences
  Future<void> _saveName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text);
    _loadName();  // Reload the saved name after saving

    // Show a Thank You message after saving the name
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thank you! Your name has been saved.')),
    );
  }

  // Function to clear the saved name
  Future<void> _clearName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');  // Remove the saved name
    _loadName();  // Reload the saved name (it will be empty)

    // Show a confirmation message
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Name has been cleared.')),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadName();  // Load the saved name when the page is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preferences Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saved Name: $_savedName',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Enter your name',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveName,
              child: const Text('Save Name'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _clearName,
              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(56, 72, 218, 1)),
              child: const Text('Clear Data'),
            ),
          ],
        ),
      ),
    );
  }
}
