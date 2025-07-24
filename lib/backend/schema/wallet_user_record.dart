import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'util/firestore_util.dart';

class WalletUsersRecord extends FirestoreRecord {
  String get email => _email ?? '';
  bool hasEmail() => _email != null;
  String? _email;

  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;
  String? _displayName;

  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;
  String? _uid;

  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;
  String? _photoUrl;

  DateTime? get lastSeen => _lastSeen;
  bool hasLastSeen() => _lastSeen != null;
  DateTime? _lastSeen;

  bool get onboardingCompleted => _onboardingCompleted ?? false;
  bool hasOnboardingCompleted() => _onboardingCompleted != null;
  bool? _onboardingCompleted;

  String? _persona;
  String get persona => _persona ?? '';

  WalletUsersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _email = snapshotData['email'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _uid = snapshotData['uid'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _lastSeen = snapshotData['last_seen'] as DateTime?;
    _onboardingCompleted = snapshotData['onboarding_completed'] as bool?;
    _persona = snapshotData['persona'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('wallet_user_collection');

  static Stream<WalletUsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => WalletUsersRecord.fromSnapshot(s));

  static Future<WalletUsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => WalletUsersRecord.fromSnapshot(s));

  static WalletUsersRecord fromSnapshot(DocumentSnapshot snapshot) =>
      WalletUsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static WalletUsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      WalletUsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'WalletUsersRecord(email: $email, displayName: $displayName, uid: $uid, photoUrl: $photoUrl, lastSeen: $lastSeen)';
}

Map<String, dynamic> createWalletUsersRecordData({
  String? email,
  String? displayName,
  String? uid,
  String? photoUrl,
  DateTime? lastSeen,
  bool? onboardingCompleted,
  String? persona,
}) {
  final firestoreData = <String, dynamic>{};

  firestoreData['email'] = email;
  firestoreData['display_name'] = displayName;
  firestoreData['uid'] = uid;
  firestoreData['photo_url'] = photoUrl;
  firestoreData['last_seen'] = lastSeen;
  firestoreData['onboarding_completed'] = onboardingCompleted ?? false;
  firestoreData['persona'] = persona;

  return firestoreData;
}