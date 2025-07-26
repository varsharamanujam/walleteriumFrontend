import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'util/firestore_util.dart';

class UserAssetsRecord extends FirestoreRecord {
  UserAssetsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // Fields
  String? _userId;
  String get userId => _userId ?? '';

  String? _assetName;
  String get assetName => _assetName ?? '';
  
  String? _assetType;
  String get assetType => _assetType ?? '';

  double? _currentValue;
  double get currentValue => _currentValue ?? 0.0;

  void _initializeFields() {
    _userId = snapshotData['user_id'] as String?;
    _assetName = snapshotData['asset_name'] as String?;
    _assetType = snapshotData['asset_type'] as String?;
    
    // --- FIX: Safely parse the value as a number ---
    final value = snapshotData['current_value'];
    _currentValue = (value is num) ? value.toDouble() : 0.0;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('user_assets');

  static Stream<UserAssetsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UserAssetsRecord.fromSnapshot(s));

  static Future<UserAssetsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UserAssetsRecord.fromSnapshot(s));

  static UserAssetsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      UserAssetsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );
}