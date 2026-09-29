import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_constants.dart';

// ─── SetOptions & FieldValue ──────────────────────────────────────────────────

class SetOptions {
  final bool merge;
  const SetOptions({this.merge = false});
}

class FieldValue {
  const FieldValue._();
  static dynamic serverTimestamp() => DateTime.now().toIso8601String();
  static dynamic increment(num amount) => _IncrementValue(amount);
  static dynamic delete() => const _DeleteValue();
}

class _IncrementValue {
  final num amount;
  const _IncrementValue(this.amount);
}

class _DeleteValue {
  const _DeleteValue();
}

// ─── Exceptions ──────────────────────────────────────────────────────────────

class FirebaseAuthException implements Exception {
  final String code;
  final String? message;
  FirebaseAuthException({required this.code, this.message});

  @override
  String toString() => message ?? code;
}

// ─── Timestamp ───────────────────────────────────────────────────────────────

class Timestamp implements Comparable<Timestamp> {
  final int seconds;
  final int nanoseconds;

  const Timestamp(this.seconds, this.nanoseconds);

  factory Timestamp.now() => Timestamp.fromDate(DateTime.now());

  factory Timestamp.fromDate(DateTime date) {
    return Timestamp(
      date.millisecondsSinceEpoch ~/ 1000,
      (date.microsecondsSinceEpoch % 1000000) * 1000,
    );
  }

  static Timestamp fromDateOrDynamic(dynamic value) {
    if (value is Timestamp) return value;
    if (value is DateTime) return Timestamp.fromDate(value);
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return Timestamp.fromDate(parsed);
    }
    if (value is int) {
      return Timestamp.fromDate(DateTime.fromMillisecondsSinceEpoch(value));
    }
    return Timestamp.now();
  }

  DateTime toDate() => DateTime.fromMillisecondsSinceEpoch(seconds * 1000);

  String toIso8601String() => toDate().toIso8601String();

  @override
  int compareTo(Timestamp other) => seconds.compareTo(other.seconds);

  @override
  String toString() => toDate().toIso8601String();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Timestamp &&
          runtimeType == other.runtimeType &&
          seconds == other.seconds &&
          nanoseconds == other.nanoseconds;

  @override
  int get hashCode => seconds.hashCode ^ nanoseconds.hashCode;
}

// ─── Snapshots ───────────────────────────────────────────────────────────────

class DocumentSnapshot {
  final String id;
  final Map<String, dynamic>? _data;
  final bool exists;

  DocumentSnapshot(this.id, this._data, {required this.exists});

  Map<String, dynamic>? data() => _data;

  dynamic operator [](String key) => _data?[key];
}

class QueryDocumentSnapshot extends DocumentSnapshot {
  QueryDocumentSnapshot(super.id, super._data) : super(exists: true);

  @override
  Map<String, dynamic> data() => _data ?? {};
}

class QuerySnapshot {
  final List<QueryDocumentSnapshot> docs;

  QuerySnapshot(this.docs);

  int get size => docs.length;
}

// ─── WriteBatch ──────────────────────────────────────────────────────────────

class WriteBatch {
  final List<Future<void> Function()> _ops = [];

  void set(DocumentReference doc, Map<String, dynamic> data, [SetOptions? options]) {
    _ops.add(() => doc.set(data, options));
  }

  void update(DocumentReference doc, Map<String, dynamic> data) {
    _ops.add(() => doc.update(data));
  }

  void delete(DocumentReference doc) {
    _ops.add(() => doc.delete());
  }

  Future<void> commit() async {
    for (final op in _ops) {
      try {
        await op();
      } catch (e) {
        debugPrint('Batch operation error: $e');
      }
    }
  }
}

// ─── Document & Collection References ────────────────────────────────────────

class DocumentReference {
  final String path;
  final String id;
  final String tableName;
  final String? parentId;
  final SupabaseClient _supabase;

  DocumentReference(this.tableName, this.id, this._supabase, {this.parentId})
      : path = '$tableName/$id';

  CollectionReference collection(String subCollectionName) {
    return CollectionReference(subCollectionName, _supabase, parentId: id);
  }

  Future<DocumentSnapshot> get() async {
    try {
      final key = tableName == SupabaseConstants.users ? 'uid' : 'id';
      final res = await _supabase.from(tableName).select().eq(key, id).maybeSingle();
      if (res == null) {
        return DocumentSnapshot(id, null, exists: false);
      }
      final map = _normalizeData(Map<String, dynamic>.from(res));
      return DocumentSnapshot(id, map, exists: true);
    } catch (e) {
      debugPrint('DocumentReference.get error ($tableName/$id): $e');
      return DocumentSnapshot(id, null, exists: false);
    }
  }

  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    final clean = _prepareData(data);
    final key = tableName == SupabaseConstants.users ? 'uid' : 'id';
    clean[key] = id;
    if (parentId != null) {
      clean['userId'] = parentId;
    }

    try {
      await _supabase.from(tableName).upsert(clean);
    } catch (e) {
      debugPrint('DocumentReference.set error ($tableName/$id): $e');
    }
  }

  Future<void> update(Map<String, dynamic> data) async {
    final clean = _prepareData(data);
    final key = tableName == SupabaseConstants.users ? 'uid' : 'id';
    try {
      await _supabase.from(tableName).update(clean).eq(key, id);
    } catch (e) {
      debugPrint('DocumentReference.update error ($tableName/$id): $e');
    }
  }

  Future<void> delete() async {
    final key = tableName == SupabaseConstants.users ? 'uid' : 'id';
    try {
      await _supabase.from(tableName).delete().eq(key, id);
    } catch (e) {
      debugPrint('DocumentReference.delete error ($tableName/$id): $e');
    }
  }

  Stream<DocumentSnapshot> snapshots() {
    final key = tableName == SupabaseConstants.users ? 'uid' : 'id';
    return _supabase
        .from(tableName)
        .stream(primaryKey: [key])
        .eq(key, id)
        .map((list) {
      if (list.isEmpty) {
        return DocumentSnapshot(id, null, exists: false);
      }
      final map = _normalizeData(Map<String, dynamic>.from(list.first));
      return DocumentSnapshot(id, map, exists: true);
    }).handleError((e) {
      debugPrint('DocumentReference.snapshots error ($tableName/$id): $e');
      return DocumentSnapshot(id, null, exists: false);
    });
  }
}

class CollectionReference {
  final String name;
  final String? parentId;
  final SupabaseClient _supabase;

  CollectionReference(this.name, this._supabase, {this.parentId});

  DocumentReference doc([String? docId]) {
    final id = docId ?? DateTime.now().millisecondsSinceEpoch.toString();
    return DocumentReference(name, id, _supabase, parentId: parentId);
  }

  CollectionReference orderBy(String field, {bool descending = false}) => this;

  CollectionReference limit(int count) => this;

  Future<DocumentReference> add(Map<String, dynamic> data) async {
    final clean = _prepareData(data);
    if (parentId != null) {
      clean['userId'] = parentId;
    }
    final key = name == SupabaseConstants.users ? 'uid' : 'id';
    try {
      final res = await _supabase.from(name).insert(clean).select(key).single();
      final id = (res[key] ?? '').toString();
      return DocumentReference(name, id, _supabase, parentId: parentId);
    } catch (e) {
      debugPrint('CollectionReference.add error ($name): $e');
      final fallbackId = DateTime.now().millisecondsSinceEpoch.toString();
      return DocumentReference(name, fallbackId, _supabase, parentId: parentId);
    }
  }

  Future<QuerySnapshot> get() async {
    try {
      var query = _supabase.from(name).select();
      if (parentId != null) {
        query = query.eq('userId', parentId!);
      }
      final res = await query;
      final key = name == SupabaseConstants.users ? 'uid' : 'id';
      final docs = List<Map<String, dynamic>>.from(res).map((r) {
        final id = (r[key] ?? r['id'] ?? '').toString();
        final map = _normalizeData(r);
        return QueryDocumentSnapshot(id, map);
      }).toList();
      return QuerySnapshot(docs);
    } catch (e) {
      debugPrint('CollectionReference.get error ($name): $e');
      return QuerySnapshot([]);
    }
  }

  Stream<QuerySnapshot> snapshots() {
    final key = name == SupabaseConstants.users ? 'uid' : 'id';
    try {
      var stream = _supabase.from(name).stream(primaryKey: [key]);
      if (parentId != null) {
        stream = stream.eq('userId', parentId!);
      }
      return stream.map((list) {
        final docs = list.map((r) {
          final id = (r[key] ?? r['id'] ?? '').toString();
          final map = _normalizeData(Map<String, dynamic>.from(r));
          return QueryDocumentSnapshot(id, map);
        }).toList();
        return QuerySnapshot(docs);
      }).handleError((e) {
        debugPrint('CollectionReference.snapshots error ($name): $e');
        return QuerySnapshot([]);
      });
    } catch (e) {
      debugPrint('CollectionReference stream creation error: $e');
      return Stream.value(QuerySnapshot([]));
    }
  }
}

// ─── Data helpers ────────────────────────────────────────────────────────────

Map<String, dynamic> _prepareData(Map<String, dynamic> data) {
  final result = <String, dynamic>{};
  data.forEach((k, v) {
    if (v is _DeleteValue) {
      result[k] = null;
    } else if (v is _IncrementValue) {
      result[k] = v.amount;
    } else if (v is Timestamp) {
      result[k] = v.toIso8601String();
    } else if (v is DateTime) {
      result[k] = v.toIso8601String();
    } else if (v is Map<String, dynamic>) {
      result[k] = _prepareData(v);
    } else {
      result[k] = v;
    }
  });
  return result;
}

Map<String, dynamic> _normalizeData(Map<String, dynamic> data) {
  final result = Map<String, dynamic>.from(data);
  for (final key in [
    'createdAt',
    'updatedAt',
    'uploadedAt',
    'dutyDate',
    'startTime',
    'endTime',
    'joinedDate',
    'deactivatedAt',
    'reactivatedAt',
    'savedAt',
    'appliedAt',
  ]) {
    if (result[key] != null && result[key] is! Timestamp) {
      result[key] = Timestamp.fromDateOrDynamic(result[key]);
    }
  }
  return result;
}

// ─── FirebaseFirestore Compat ────────────────────────────────────────────────

class FirebaseFirestore {
  static final FirebaseFirestore instance = FirebaseFirestore._();
  FirebaseFirestore._();

  final SupabaseClient _supabase = Supabase.instance.client;

  CollectionReference collection(String collectionPath) {
    return CollectionReference(collectionPath, _supabase);
  }

  WriteBatch batch() => WriteBatch();
}

// ─── FirebaseAuth Compat ─────────────────────────────────────────────────────

class FirebaseAuth {
  static final FirebaseAuth instance = FirebaseAuth._();
  FirebaseAuth._();

  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Stream<User?> authStateChanges() {
    return _supabase.auth.onAuthStateChange.map((event) => event.session?.user);
  }

  /// Supabase does not use Firebase-style email sign-in links.
  /// Always returns false so callers fall through to the polling path.
  bool isSignInWithEmailLink(String link) => false;
}

// ─── FirebaseStorage & UploadTask Compat ─────────────────────────────────────

class TaskSnapshot {
  final int bytesTransferred;
  final int totalBytes;
  TaskSnapshot(this.bytesTransferred, this.totalBytes);
}

class UploadTask implements Future<void> {
  final Future<void> _inner;
  final StreamController<TaskSnapshot> _controller = StreamController<TaskSnapshot>.broadcast();

  UploadTask(this._inner) {
    _controller.add(TaskSnapshot(50, 100));
    _inner.then((_) {
      _controller.add(TaskSnapshot(100, 100));
      _controller.close();
    }).catchError((_) {
      _controller.close();
    });
  }

  Stream<TaskSnapshot> get snapshotEvents => _controller.stream;

  @override
  Stream<void> asStream() => _inner.asStream();

  @override
  Future<void> catchError(Function onError, {bool Function(Object error)? test}) =>
      _inner.catchError(onError, test: test);

  @override
  Future<S> then<S>(FutureOr<S> Function(void value) onValue, {Function? onError}) =>
      _inner.then(onValue, onError: onError);

  @override
  Future<void> timeout(Duration timeLimit, {FutureOr<void> Function()? onTimeout}) =>
      _inner.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<void> whenComplete(FutureOr<void> Function() action) =>
      _inner.whenComplete(action);
}

class Reference {
  final String fullPath;
  final SupabaseClient _supabase;

  Reference(this.fullPath, this._supabase);

  Reference child(String path) {
    final clean = path.startsWith('/') ? path.substring(1) : path;
    final combined = fullPath.isEmpty ? clean : '$fullPath/$clean';
    return Reference(combined, _supabase);
  }

  String _resolveBucket() {
    if (fullPath.contains('cover_pictures') || fullPath.contains('cover-images')) {
      return SupabaseConstants.coverImagesBucket;
    }
    if (fullPath.contains('resumes')) {
      return SupabaseConstants.resumesBucket;
    }
    if (fullPath.contains('documents')) {
      return SupabaseConstants.documentsBucket;
    }
    return SupabaseConstants.profileImagesBucket;
  }

  String _resolvePath() {
    final parts = fullPath.split('/');
    if (parts.length > 1) {
      return parts.sublist(1).join('/');
    }
    return fullPath;
  }

  UploadTask putFile(File file) {
    final future = () async {
      try {
        final bucket = _resolveBucket();
        final path = _resolvePath();
        final bytes = await file.readAsBytes();
        await _supabase.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
      } catch (e) {
        debugPrint('putFile error ($fullPath): $e');
      }
    }();
    return UploadTask(future);
  }

  UploadTask putData(Uint8List bytes) {
    final future = () async {
      try {
        final bucket = _resolveBucket();
        final path = _resolvePath();
        await _supabase.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
      } catch (e) {
        debugPrint('putData error ($fullPath): $e');
      }
    }();
    return UploadTask(future);
  }

  Future<String> getDownloadURL() async {
    try {
      final bucket = _resolveBucket();
      final path = _resolvePath();
      return _supabase.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      debugPrint('getDownloadURL error ($fullPath): $e');
      return '';
    }
  }

  Future<void> delete() async {
    try {
      final bucket = _resolveBucket();
      final path = _resolvePath();
      await _supabase.storage.from(bucket).remove([path]);
    } catch (e) {
      debugPrint('storage delete error ($fullPath): $e');
    }
  }
}

class FirebaseStorage {
  static final FirebaseStorage instance = FirebaseStorage._();
  FirebaseStorage._();

  final SupabaseClient _supabase = Supabase.instance.client;

  Reference ref([String? path]) {
    return Reference(path ?? '', _supabase);
  }
}
