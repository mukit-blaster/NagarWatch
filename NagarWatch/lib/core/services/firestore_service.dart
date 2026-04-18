import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

class FirestoreService {
  static FirestoreService? _instance;
  static FirestoreService get instance => _instance ??= FirestoreService._();
  FirestoreService._();

  late FirebaseFirestore _db;

  FirebaseFirestore get db => _db;

  /// Initialize Firebase and Firestore with offline persistence enabled
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      _db = FirebaseFirestore.instance;

      // Enable offline persistence
      await _db.disableNetwork();
      await _db.enableNetwork();
      _db.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      print('✓ Firestore initialized with offline persistence enabled');
    } catch (e) {
      print('✗ Firestore initialization failed: $e');
      rethrow;
    }
  }

  /// Get collection reference with automatic type conversion
  CollectionReference<T> getCollection<T>(
    String path, {
    required T Function(Map<String, dynamic> data, String documentId) fromJson,
  }) {
    return _db.collection(path).withConverter<T>(
          fromFirestore: (snap, _) => fromJson(snap.data() ?? {}, snap.id),
          toFirestore: (obj, _) =>
              obj is Map<String, dynamic> ? obj : (obj as dynamic).toMap(),
        );
  }

  /// Real-time stream for collection with optional filters
  Stream<List<T>> streamCollection<T>(
    String collectionPath, {
    required T Function(Map<String, dynamic> data, String documentId) fromJson,
    List<QueryConstraint>? where,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    Query query = _db.collection(collectionPath);

    // Apply where conditions
    if (where != null) {
      for (final constraint in where) {
        query = constraint.apply(query);
      }
    }

    // Apply ordering
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    // Apply limit
    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final raw = doc.data();
        final data = raw is Map<String, dynamic>
            ? raw
            : Map<String, dynamic>.from(raw as Map);
        return fromJson(data, doc.id);
      }).toList();
    });
  }

  /// One-time fetch for collection
  Future<List<T>> fetchCollection<T>(
    String collectionPath, {
    required T Function(Map<String, dynamic> data, String documentId) fromJson,
    List<QueryConstraint>? where,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    Query query = _db.collection(collectionPath);

    if (where != null) {
      for (final constraint in where) {
        query = constraint.apply(query);
      }
    }

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final raw = doc.data();
      final data = raw is Map<String, dynamic>
          ? raw
          : Map<String, dynamic>.from(raw as Map);
      return fromJson(data, doc.id);
    }).toList();
  }

  /// Get single document
  Future<T?> getDocument<T>(
    String collectionPath,
    String documentId, {
    required T Function(Map<String, dynamic> data, String documentId) fromJson,
  }) async {
    try {
      final doc = await _db.collection(collectionPath).doc(documentId).get();
      if (!doc.exists) return null;
      return fromJson(doc.data() ?? {}, doc.id);
    } catch (e) {
      print('Error fetching document: $e');
      return null;
    }
  }

  /// Create document
  Future<T> createDocument<T>(
    String collectionPath,
    Map<String, dynamic> data, {
    required T Function(Map<String, dynamic> data, String documentId) fromJson,
  }) async {
    try {
      final docRef = await _db.collection(collectionPath).add(data);
      return fromJson(data, docRef.id);
    } catch (e) {
      print('Error creating document: $e');
      rethrow;
    }
  }

  /// Update document
  Future<void> updateDocument(
    String collectionPath,
    String documentId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _db.collection(collectionPath).doc(documentId).update(updates);
    } catch (e) {
      print('Error updating document: $e');
      rethrow;
    }
  }

  /// Delete document
  Future<void> deleteDocument(
    String collectionPath,
    String documentId,
  ) async {
    try {
      await _db.collection(collectionPath).doc(documentId).delete();
    } catch (e) {
      print('Error deleting document: $e');
      rethrow;
    }
  }

  /// Batch operations
  Future<void> batch(Future<void> Function(WriteBatch batch) operation) async {
    try {
      final batch = _db.batch();
      await operation(batch);
      await batch.commit();
    } catch (e) {
      print('Error in batch operation: $e');
      rethrow;
    }
  }
}

/// Query constraint wrapper
class QueryConstraint {
  final String field;
  final dynamic value;
  final String operator; // '==', '<', '<=', '>', '>=', 'array-contains', 'in'

  QueryConstraint({
    required this.field,
    required this.value,
    required this.operator,
  });

  Query apply(Query query) {
    switch (operator) {
      case '==':
        return query.where(field, isEqualTo: value);
      case '<':
        return query.where(field, isLessThan: value);
      case '<=':
        return query.where(field, isLessThanOrEqualTo: value);
      case '>':
        return query.where(field, isGreaterThan: value);
      case '>=':
        return query.where(field, isGreaterThanOrEqualTo: value);
      case 'array-contains':
        return query.where(field, arrayContains: value);
      case 'in':
        return query.where(field, whereIn: value as List);
      default:
        return query;
    }
  }
}
