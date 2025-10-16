import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/database_helper.dart';
import 'services/contact_service.dart';
import 'providers/contact_provider.dart';

// Global database helper instance
final dbHelper = DatabaseHelper();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the database
  await dbHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap the app with ChangeNotifierProvider for state management
    return ChangeNotifierProvider(
      create: (_) => ContactProvider(ContactService(dbHelper)),
      child: MaterialApp(
        title: 'Contact List App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact List App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _insert(context),
              child: const Text('Insert Contact'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _query(context),
              child: const Text('Query All Contacts'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _queryById(context),
              child: const Text('Query by ID'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _update(context),
              child: const Text('Update Contact'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _delete(context),
              child: const Text('Delete Contact'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _deleteAll(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete All Contacts'),
            ),
          ],
        ),
      ),
    );
  }

  // Insert a new contact
  void _insert(BuildContext context) async {
    final provider = Provider.of<ContactProvider>(context, listen: false);
    await provider.insertContact('Bob', 23);
  }

  // Query all contacts
  void _query(BuildContext context) async {
    final provider = Provider.of<ContactProvider>(context, listen: false);
    await provider.loadContacts();
  }

  // Query contact by ID (demonstrates the new queryById function)
  void _queryById(BuildContext context) async {
    final provider = Provider.of<ContactProvider>(context, listen: false);
    // Query contact with ID 1
    await provider.queryContactById(1);
  }

  // Update an existing contact
  void _update(BuildContext context) async {
    final provider = Provider.of<ContactProvider>(context, listen: false);
    await provider.updateContact(1, 'Mary', 32);
  }

  // Delete a contact by ID
  void _delete(BuildContext context) async {
    final provider = Provider.of<ContactProvider>(context, listen: false);
    final count = await provider.getContactCount();
    if (count > 0) {
      // Delete the contact with the highest ID (last inserted)
      await provider.deleteContact(count);
    } else {
      debugPrint('No contacts to delete');
    }
  }

  // Delete all contacts (demonstrates the new deleteAll function)
  void _deleteAll(BuildContext context) async {
    final provider = Provider.of<ContactProvider>(context, listen: false);
    await provider.deleteAllContacts();
  }
}