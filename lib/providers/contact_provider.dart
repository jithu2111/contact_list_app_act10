import 'package:flutter/material.dart';
import '../models/contact_model.dart';
import '../services/contact_service.dart';

/// State management layer for contacts using ChangeNotifier
/// This provider handles UI events and manages the state of contacts
/// It separates business logic from UI components
class ContactProvider extends ChangeNotifier {
  final ContactService _contactService;
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  bool _isLoading = false;
  String _searchQuery = '';

  ContactProvider(this._contactService);

  // Getters
  List<Contact> get contacts => _searchQuery.isEmpty ? _contacts : _filteredContacts;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  /// Insert a new contact
  Future<void> insertContact(String name, int age) async {
    try {
      _isLoading = true;
      notifyListeners();

      final contact = Contact(name: name, age: age);
      final id = await _contactService.insertContact(contact);
      debugPrint('Inserted contact with ID: $id');

      // Refresh the contact list
      await loadContacts();
    } catch (e) {
      debugPrint('Error inserting contact: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all contacts from the database
  Future<void> loadContacts() async {
    try {
      _isLoading = true;
      notifyListeners();

      _contacts = await _contactService.getAllContacts();

      // Re-apply search filter if there's an active search
      if (_searchQuery.isNotEmpty) {
        _filteredContacts = _contacts.where((contact) {
          final nameMatch = contact.name.toLowerCase().contains(_searchQuery.toLowerCase());
          final ageMatch = contact.age.toString().contains(_searchQuery);
          return nameMatch || ageMatch;
        }).toList();
      }

      debugPrint('Loaded ${_contacts.length} contacts');

      // Print all contacts for debugging
      if (_contacts.isNotEmpty) {
        debugPrint('All contacts:');
        for (final contact in _contacts) {
          debugPrint(contact.toString());
        }
      }
    } catch (e) {
      debugPrint('Error loading contacts: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Query a specific contact by ID
  Future<void> queryContactById(int id) async {
    try {
      final contact = await _contactService.getContactById(id);
      if (contact != null) {
        debugPrint('Found contact by ID $id: $contact');
      } else {
        debugPrint('No contact found with ID: $id');
      }
    } catch (e) {
      debugPrint('Error querying contact by ID: $e');
      rethrow;
    }
  }

  /// Update an existing contact
  Future<void> updateContact(int id, String name, int age) async {
    try {
      _isLoading = true;
      notifyListeners();

      final contact = Contact(id: id, name: name, age: age);
      final rowsAffected = await _contactService.updateContact(contact);
      debugPrint('Updated $rowsAffected row(s)');

      // Refresh the contact list
      await loadContacts();
    } catch (e) {
      debugPrint('Error updating contact: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a specific contact by ID
  Future<void> deleteContact(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final rowsDeleted = await _contactService.deleteContact(id);
      debugPrint('Deleted $rowsDeleted row(s) with ID: $id');

      // Refresh the contact list
      await loadContacts();
    } catch (e) {
      debugPrint('Error deleting contact: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete all contacts from the database
  Future<void> deleteAllContacts() async {
    try {
      _isLoading = true;
      notifyListeners();

      final rowsDeleted = await _contactService.deleteAllContacts();
      debugPrint('Deleted all contacts: $rowsDeleted row(s) removed');

      // Clear the local list and refresh
      _contacts = [];
      await loadContacts();
    } catch (e) {
      debugPrint('Error deleting all contacts: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get the total count of contacts
  Future<int> getContactCount() async {
    try {
      final count = await _contactService.getContactCount();
      debugPrint('Total contact count: $count');
      return count;
    } catch (e) {
      debugPrint('Error getting contact count: $e');
      rethrow;
    }
  }

  /// Search contacts by name or age
  void searchContacts(String query) {
    _searchQuery = query.trim();

    if (_searchQuery.isEmpty) {
      _filteredContacts = [];
      notifyListeners();
      return;
    }

    // Filter contacts by name (case-insensitive) or age
    _filteredContacts = _contacts.where((contact) {
      final nameMatch = contact.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final ageMatch = contact.age.toString().contains(_searchQuery);
      return nameMatch || ageMatch;
    }).toList();

    debugPrint('Search query: "$_searchQuery" - Found ${_filteredContacts.length} matches');
    notifyListeners();
  }

  /// Clear search query and show all contacts
  void clearSearch() {
    _searchQuery = '';
    _filteredContacts = [];
    notifyListeners();
  }
}