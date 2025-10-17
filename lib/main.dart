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
      body: Column(
        children: [
          // Search bar section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<ContactProvider>(
              builder: (context, provider, child) {
                return TextField(
                  onChanged: (value) => provider.searchContacts(value),
                  decoration: InputDecoration(
                    hintText: 'Search by name or age...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: provider.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => provider.clearSearch(),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                );
              },
            ),
          ),
          // Buttons section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _insert(context),
                  child: const Text('Insert Contact'),
                ),
                ElevatedButton(
                  onPressed: () => _query(context),
                  child: const Text('Query All'),
                ),
                ElevatedButton(
                  onPressed: () => _queryById(context),
                  child: const Text('Query by ID'),
                ),
                ElevatedButton(
                  onPressed: () => _update(context),
                  child: const Text('Update'),
                ),
                ElevatedButton(
                  onPressed: () => _delete(context),
                  child: const Text('Delete'),
                ),
                ElevatedButton(
                  onPressed: () => _deleteAll(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Delete All'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(thickness: 2),
          // Contacts list section
          Expanded(
            child: Consumer<ContactProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.contacts.isEmpty) {
                  return Center(
                    child: Text(
                      provider.searchQuery.isNotEmpty
                          ? 'No contacts found matching "${provider.searchQuery}"'
                          : 'No contacts found.\nPress "Insert Contact" to add one.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: provider.contacts.length,
                  itemBuilder: (context, index) {
                    final contact = provider.contacts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text('${contact.id}'),
                        ),
                        title: Text(
                          contact.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text('Age: ${contact.age}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteSpecific(context, contact.id!),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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

  // Delete a specific contact (used by the delete icon on each contact)
  void _deleteSpecific(BuildContext context, int id) async {
    final provider = Provider.of<ContactProvider>(context, listen: false);
    await provider.deleteContact(id);
  }
}