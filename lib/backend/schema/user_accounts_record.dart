import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'util/firestore_util.dart';

class UserAccountsRecord extends FirestoreRecord {
  UserAccountsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // Fields
  String? _userId;
  String get userId => _userId ?? '';

  String? _accountName;
  String get accountName => _accountName ?? '';

  String? _accountType;
  String get accountType => _accountType ?? '';

  double? _currentBalance;
  double get currentBalance => _currentBalance ?? 0.0;

  String? _accountColor;
  String get accountColor => _accountColor ?? '';

  void _initializeFields() {
    _userId = snapshotData['user_id'] as String?;
    _accountName = snapshotData['account_name'] as String?;
    _accountType = snapshotData['account_type'] as String?;
    
    final balanceValue = snapshotData['current_balance'];
    _currentBalance = (balanceValue is num) ? balanceValue.toDouble() : 0.0;
    
    _accountColor = snapshotData['account_color'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('user_accounts');

  static Stream<UserAccountsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UserAccountsRecord.fromSnapshot(s));

  static Future<UserAccountsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UserAccountsRecord.fromSnapshot(s));

  static UserAccountsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      UserAccountsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );
}