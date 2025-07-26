import 'dart:async';
import 'package:collection/collection.dart' as collection;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:walleterium/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class UploadedFilesRecord extends FirestoreRecord {
  UploadedFilesRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "download_url" field
  String? _downloadUrl;
  String get downloadUrl => _downloadUrl ?? '';
  bool hasDownloadUrl() => _downloadUrl != null;

  // "uploader_uid" field
  String? _uploaderUid;
  String get uploaderUid => _uploaderUid ?? '';
  bool hasUploaderUid() => _uploaderUid != null;

  // "uploaded_at" field
  DateTime? _uploadedAt;
  DateTime? get uploadedAt => _uploadedAt;
  bool hasUploadedAt() => _uploadedAt != null;

  // "file_type" field
  String? _fileType;
  String get fileType => _fileType ?? '';
  bool hasFileType() => _fileType != null;

  void _initializeFields() {
    _downloadUrl = snapshotData['download_url'] as String?;
    _uploaderUid = snapshotData['uploader_uid'] as String?;
    _uploadedAt = snapshotData['uploaded_at'] as DateTime?;
    _fileType = snapshotData['file_type'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('uploaded_files');

  static UploadedFilesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      UploadedFilesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UploadedFilesRecord getDocumentFromData(
          Map<String, dynamic> data, DocumentReference reference) =>
      UploadedFilesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UploadedFilesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UploadedFilesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUploadedFilesRecordData({
  String? downloadUrl,
  String? uploaderUid,
  DateTime? uploadedAt,
  String? fileType,
}) {
  final firestoreData = <String, dynamic>{
    if (downloadUrl != null) 'download_url': downloadUrl,
    if (uploaderUid != null) 'uploader_uid': uploaderUid,
    if (uploadedAt != null) 'uploaded_at': uploadedAt,
    if (fileType != null) 'file_type': fileType,
  };

  return firestoreData;
}

class UploadedFilesRecordDocumentEquality
    implements collection.Equality<UploadedFilesRecord> {
  const UploadedFilesRecordDocumentEquality();

  @override
  bool equals(UploadedFilesRecord? e1, UploadedFilesRecord? e2) {
    return e1?.downloadUrl == e2?.downloadUrl &&
        e1?.uploaderUid == e2?.uploaderUid &&
        e1?.uploadedAt == e2?.uploadedAt &&
        e1?.fileType == e2?.fileType;
  }

  @override
  int hash(UploadedFilesRecord? e) {
    return const collection.ListEquality()
        .hash([e?.downloadUrl, e?.uploaderUid, e?.uploadedAt, e?.fileType]);
  }

  @override
  bool isValidKey(Object? o) => o is UploadedFilesRecord;
}

