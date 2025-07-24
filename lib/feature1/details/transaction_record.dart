// In lib/backend/schema/transactions_record.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';

class TransactionsRecord extends FirestoreRecord {
  TransactionsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // Fields
  String? _userId;
  String get userId => _userId ?? '';

  String? _accountId;
  String get accountId => _accountId ?? '';

  String? _description;
  String get description => _description ?? '';

  String? _category;
  String get category => _category ?? '';

  String? _type; // 'Income' or 'Expense'
  String get type => _type ?? '';

  double? _amount;
  double get amount => _amount ?? 0.0;

  DateTime? _transactionDate;
  DateTime? get transactionDate => _transactionDate;

  void _initializeFields() {
    _userId = snapshotData['user_id'] as String?;
    _accountId = snapshotData['account_id'] as String?;
    _description = snapshotData['description'] as String?;
    _category = snapshotData['category'] as String?;
    _type = snapshotData['type'] as String?;
    final amountValue = snapshotData['amount'];
    _amount = (amountValue is num) ? amountValue.toDouble() : 0.0;
    _transactionDate = snapshotData['transaction_date'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('transactions');

  static Stream<TransactionsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => TransactionsRecord.fromSnapshot(s));

  static Future<TransactionsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => TransactionsRecord.fromSnapshot(s));

  static TransactionsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      TransactionsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );
}