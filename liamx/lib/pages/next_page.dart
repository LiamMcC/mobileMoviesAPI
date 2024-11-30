import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class NextPage extends StatefulWidget {
  const NextPage({super.key});

  @override
  State<NextPage> createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  List<Contact> contacts = []; // To hold the list of contacts
  bool isLoading = true; // Loading indicator

  @override
  void initState() {
    super.initState();
    fetchContacts(); // Fetch contacts when the page initializes
  }

  Future<void> fetchContacts() async {
    // Check and request permission
    if (await Permission.contacts.request().isGranted) {
      // Fetch contacts from the device
      Iterable<Contact> deviceContacts = await ContactsService.getContacts();
      setState(() {
        contacts = deviceContacts.toList();
        isLoading = false;
      });
    } else {
      // Handle permission denial
      setState(() {
        isLoading = false;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission to access contacts was denied')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : contacts.isEmpty
              ? const Center(child: Text('No contacts found'))
              : ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return ListTile(
                      title: Text(contact.displayName ?? 'No Name'),
                      subtitle: Text(contact.phones?.isNotEmpty == true
                          ? contact.phones!.first.value ?? ''
                          : 'No phone number'),
                      leading: CircleAvatar(
                        child: Text(
                          (contact.displayName?.isNotEmpty == true
                                  ? contact.displayName![0]
                                  : '?')
                              .toUpperCase(),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
