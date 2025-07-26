import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service to interact with Google Wallet API and manage passes for the current user.
class GoogleWalletService {
  // Helper: Get Google OAuth2 access token for Wallet API
  Future<String?> getGoogleAccessToken() async {
    final googleSignIn = GoogleSignIn(
      scopes: [
        'https://www.googleapis.com/auth/wallet_object.issuer',
        'email',
      ],
    );
    final account = await googleSignIn.signInSilently() ?? await googleSignIn.signIn();
    final auth = await account?.authentication;
    return auth?.accessToken;
  }
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the current user details from Firebase Auth
  User? get currentUser => _auth.currentUser;

  /// Check if the user has a Google Wallet
  /// This checks if the user is signed in and (in future) will call Google Wallet API.
  Future<bool> hasWallet() async {
    // Step 1: Ensure user is signed in with Google
    final user = currentUser;
    if (user == null) {
      // Not signed in
      return false;
    }
    // Step 2: Get access token
    final accessToken = await getGoogleAccessToken();
    if (accessToken == null) {
      return false;
    }
    // Step 3: Call Google Wallet API to check for generic passes
    final url = Uri.parse('https://walletobjects.googleapis.com/walletobjects/v1/genericObject');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final body = response.body;
      // If there are any objects, user has a wallet
      // (You may want to parse JSON and check for 'resources' or similar key)
      return body.contains('resources');
    } else {
      // If unauthorized or error, treat as no wallet
      return false;
    }
  }

  /// Get access to the user's Google Wallet
  /// Launches the Google Wallet app or web wallet for the user.
  Future<void> accessWallet() async {
    const walletAppUrl = 'https://pay.google.com/gp/w/u/0/home'; // Google Wallet web URL
    // Optionally, you can try to launch the app via intent on Android
    // For now, launch the web wallet
    if (await canLaunchUrl(Uri.parse(walletAppUrl))) {
      await launchUrl(Uri.parse(walletAppUrl), mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch Google Wallet.');
    }
  }

  /// Fetch all passes/cards and their details
  /// This will use Google Wallet API in the future. For now, returns an empty list if signed in.
  Future<List<dynamic>> getAllPasses() async {
    final user = currentUser;
    if (user == null) {
      // Not signed in
      return [];
    }
    final accessToken = await getGoogleAccessToken();
    if (accessToken == null) {
      return [];
    }
    // Call Google Wallet API to fetch generic passes
    final url = Uri.parse('https://walletobjects.googleapis.com/walletobjects/v1/genericObject');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('resources')) {
          final resources = decoded['resources'];
          if (resources is List) {
            return List<Map<String, dynamic>>.from(resources);
          }
        }
        return [];
      } catch (e) {
        print('Error parsing passes: $e');
        return [];
      }
    } else {
      print('Failed to fetch passes: ${response.statusCode} ${response.body}');
      return [];
    }
  }

  /// Post custom passes (receipts, transactions, reminders, etc.)
  /// This will use Google Wallet API in the future. For now, just checks sign-in.
  Future<void> postCustomPass({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('User not signed in.');
    }
    final accessToken = await getGoogleAccessToken();
    if (accessToken == null) {
      throw Exception('Could not get Google access token.');
    }
    // Call Google Wallet API to create a custom pass (genericObject)
    final url = Uri.parse('https://walletobjects.googleapis.com/walletobjects/v1/genericObject');
    // The data map should be structured according to Google Wallet API docs
    // See: https://developers.google.com/wallet/verticals/generic/rest/v1/genericobject
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Pass created successfully
      return;
    } else {
      throw Exception('Failed to create pass: ${response.statusCode} ${response.body}');
    }
  }

  /// Synchronize passes with Firebase if needed
  /// This will use Firestore or Realtime Database in the future. For now, just checks sign-in.
  Future<void> syncPassesWithFirebase() async {
    final user = currentUser;
    if (user == null) {
      throw Exception('User not signed in.');
    }
    // Fetch all passes from Google Wallet
    final passes = await getAllPasses();
    // Store in Firestore under user's UID
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('users').doc(user.uid).set({
      'walletPasses': passes,
      'lastSynced': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return;
  }

  /// Check if passes can be grouped/nested (if supported by Google Wallet)
  /// As of now, Google Wallet does not support true nesting/grouping of passes, but you can use pass classes, labels, or custom fields for organization.
  /// See: https://developers.google.com/wallet/verticals/generic/overview
  Future<bool> canGroupPasses() async {
    // No official grouping/nesting, but can use pass class or custom fields for logical grouping
    return false;
  }
}
