import '../models/contact_model.dart';
import 'database_helper.dart';

/// Service layer for contact-related database operations
/// This layer abstracts database operations and provides a clean API
/// for the rest of the application to interact with contact data
class ContactService {
  final DatabaseHelper _dbHelper;

  ContactService(this._dbHelper);

  /// Insert a new contact into the database
  /// Returns the ID of the newly inserted contact
  Future<int> insertContact(Contact contact) async {
    final id = await _dbHelper.insert(contact.toMap());
    return id;
  }

  /// Query all contacts from the database
  /// Returns a list of Contact objects
  Future<List<Contact>> getAllContacts() async {
    final rows = await _dbHelper.queryAllRows();
    return rows.map((row) => Contact.fromMap(row)).toList();
  }

  /// Query a specific contact by ID
  /// Returns a Contact object if found, null otherwise
  Future<Contact?> getContactById(int id) async {
    final row = await _dbHelper.queryById(id);
    if (row != null) {
      return Contact.fromMap(row);
    }
    return null;
  }

  /// Update an existing contact in the database
  /// Returns the number of rows affected (should be 1 if successful)
  Future<int> updateContact(Contact contact) async {
    if (contact.id == null) {
      throw ArgumentError('Contact must have an ID to be updated');
    }
    return await _dbHelper.update(contact.toMap());
  }

  /// Delete a specific contact by ID
  /// Returns the number of rows deleted (should be 1 if successful)
  Future<int> deleteContact(int id) async {
    return await _dbHelper.delete(id);
  }

  /// Delete all contacts from the database
  /// Returns the number of rows deleted
  Future<int> deleteAllContacts() async {
    return await _dbHelper.deleteAll();
  }

  /// Get the total count of contacts in the database
  /// Returns the number of contact records
  Future<int> getContactCount() async {
    return await _dbHelper.queryRowCount();
  }
}