// lib/main_dash/main_dash_widget.dart

import 'package:add_to_google_wallet/widgets/add_to_google_wallet_button.dart';
import 'package:uuid/uuid.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Added import
import 'package:file_picker/file_picker.dart'; // Added import
import 'package:firebase_storage/firebase_storage.dart'; // Added import
import 'main_dash_model.dart';
export 'main_dash_model.dart';
import 'dart:io';
import 'notification_card_widget.dart';
import 'transaction/transaction_list_screen.dart'; // For actionable notification navigation
import '/auth/firebase_auth/auth_util.dart';
import '/index.dart';
import '/backend/backend.dart';
import 'package:walleterium/feature1/settings_screen.dart'; // Ensure this import is correct
import 'package:walleterium/feature1/budget_goals_screen.dart'; // BudgetGoalsScreen is parked
// <<< ADDED: For jsonEncode
// <<< ADDED: For NumberFormat

class MainDashWidget extends StatefulWidget {
  const MainDashWidget({super.key});

  static String routeName = 'MainDash';
  static String routePath = '/mainDash';

  @override
  State<MainDashWidget> createState() => _MainDashWidgetState();
}

class _MainDashWidgetState extends State<MainDashWidget> {
  late MainDashModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = true;
  WalletUsersRecord? _walletUser;
  List<UserAccountsRecord> _accounts = [];
  List<UserAssetsRecord> _assets = []; // Your assets list

  // --- GOOGLE WALLET SPECIFIC VARIABLES ---
  final String _passId = const Uuid().v4(); // Unique ID for this pass
  // IMPORTANT: Replace with your actual Issuer ID
  final String _issuerId = 'YOUR_ISSUER_ID'; // <<< REPLACE WITH YOUR ISSUER ID
  // IMPORTANT: Replace with your Service Account's email from the JSON key
  final String _serviceAccountEmail = 'YOUR_SERVICE_ACCOUNT_EMAIL@your-project-id.iam.gserviceaccount.com'; // <<< REPLACE WITH YOUR SERVICE ACCOUNT EMAIL
  // This is the Class ID you must create in Google Wallet Console (e.g., 'asset_pass' or 'total_assets')
  final String _passClass = 'total_assets'; // <<< You might need to create this class in the Wallet Console

  // Variable to hold the entire content of your Service Account JSON key file
  // This variable is still needed for _passPayload, but not passed directly to the button widget
  late String _serviceAccountKeyJson; // Will be loaded in initState

  // --- Getter for the pass payload - NOW DYNAMIC WITH ASSETS ---
  String get _passPayload {
    // Calculate total assets from the fetched _assets list
    final double totalAssets = _assets.fold(0.0, (sum, asset) => sum + asset.currentValue);
    final formattedAssets = NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(totalAssets);

    final payloadMap = {
      "iss": _serviceAccountEmail,
      "aud": "google",
      "typ": "savetowallet",
      "origins": [],
      "payload": {
        "genericObjects": [
          {
            "id": "$_issuerId.$_passId",
            "classId": "$_issuerId.$_passClass",
            "genericType": "GENERIC_TYPE_UNSPECIFIED",
            "hexBackgroundColor": "#34A853", // Green for assets
            "logo": {
              "sourceUri": {
                "uri": "https://storage.googleapis.com/wallet-lab-tools-codelab-artifacts-public/pass_google_logo.jpg"
              }
            },
            "cardTitle": {
              "defaultValue": {
                "language": "en",
                "value": "My Total Assets" // Title of the pass
              }
            },
            "subheader": {
              "defaultValue": {
                "language": "en",
                "value": "Current Value" // Subheader
              }
            },
            "header": {
              "defaultValue": {
                "language": "en",
                "value": formattedAssets // Display the total assets here
              }
            },
            "barcode": {
              "type": "QR_CODE",
              "value": _passId // Barcode value
            },
            "heroImage": {
              "sourceUri": {
                "uri": "https://storage.googleapis.com/wallet-lab-tools-codelab-artifacts-public/google-io-hero-demo-only.jpg" // Placeholder hero image
              }
            },
            "textModulesData": [
              {
                "header": "Asset Breakdown",
                "body": "Details of your investments.", // You could add more dynamic details here
                "id": "asset_details"
              },
              {
                "header": "Last Updated",
                "body": DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now()),
                "id": "last_updated"
              }
            ]
          }
        ]
      }
    };
    return jsonEncode(payloadMap);
  }

  void _showSnackBar(BuildContext context, String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  // Sample notification JSONs for demonstration
  final List<Map<String, dynamic>> _sampleNotifications = [
    {
      'text': 'Your portfolio grew by 5% this week!',
      'icon': 'success',
      'details': 'Check out the new assets added to your portfolio. Tap to view more.'
    },
    {
      'text': 'Scheduled maintenance on 28th July',
      'icon': 'warning',
      'details': 'Some features may be unavailable during 2am-4am IST.'
    },
    {
      'text': 'Verify your email address',
      'icon': 'info',
      'details': 'Please verify your email to unlock all features.'
    },
    {
      'text': 'View sample transactions',
      'icon': 'info',
      'details': 'Tap to view the transaction list UI example.',
      'action': 'show_transactions',
    },
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainDashModel());
    _loadServiceAccountKey(); // Call this to load the key
    _fetchDashboardData();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  // Function to load the service account key
  Future<void> _loadServiceAccountKey() async {
    try {
      // IMPORTANT: Replace the entire placeholder string below with the EXACT content
      // of your downloaded Service Account JSON key file.
      const String keyJsonString = '''
      {
        "type": "service_account",
        "project_id": "YOUR_PROJECT_ID",
        "private_key_id": "YOUR_PRIVATE_KEY_ID",
        "private_key": "-----BEGIN PRIVATE KEY-----\\nYOUR_PRIVATE_KEY_CONTENT\\n-----END PRIVATE KEY-----\\n",
        "client_email": "YOUR_SERVICE_ACCOUNT_EMAIL@your-project-id.iam.gserviceaccount.com",
        "client_id": "YOUR_CLIENT_ID",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/YOUR_SERVICE_ACCOUNT_EMAIL%40your-project-id.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com"
      }
      ''';
      
      setState(() {
        _serviceAccountKeyJson = keyJsonString;
      });
      print('MainDashWidget: Google Wallet Service Account Key loaded successfully.');
    } catch (e) {
      print('MainDashWidget: Error loading service account key: $e');
      _showSnackBar(context, 'Error loading Wallet API key.');
    }
  }


  Future<void> _fetchDashboardData() async {
    print('MainDashWidget: _fetchDashboardData called.');
    final user = currentUser;
    if (user == null) {
      print('MainDashWidget: currentUser is null, redirecting to AuthHubScreen.');
      context.goNamed(AuthHubScreenWidget.routeName);
      return;
    }
    print('MainDashWidget: currentUser is not null. UID: ${user.uid}');

    try {
      final accountsFuture = UserAccountsRecord.collection.where('user_id', isEqualTo: user.uid).get();
      final assetsFuture = UserAssetsRecord.collection.where('user_id', isEqualTo: user.uid).get();
      final walletUserFuture = WalletUsersRecord.collection.doc(user.uid).get();
      
      final results = await Future.wait([
        accountsFuture,
        assetsFuture,
        walletUserFuture,
      ]);

      final accountsSnapshot = results[0] as QuerySnapshot<Map<String, dynamic>>;
      final assetsSnapshot = results[1] as QuerySnapshot<Map<String, dynamic>>;
      final walletUserSnapshot = results[2] as DocumentSnapshot<Map<String, dynamic>>;

      if (mounted) {
        setState(() {
          _accounts = accountsSnapshot.docs
              .map((doc) => UserAccountsRecord.fromSnapshot(doc))
              .toList();
          _accounts.sort((a, b) => a.accountName.compareTo(b.accountName));

          _assets = assetsSnapshot.docs
              .map((doc) => UserAssetsRecord.fromSnapshot(doc))
              .toList();
          
          if(walletUserSnapshot.exists) {
            _walletUser = WalletUsersRecord.fromSnapshot(walletUserSnapshot);
            print('MainDashWidget: WalletUser data fetched. Onboarding completed: ${_walletUser?.onboardingCompleted}');
          } else {
            print('MainDashWidget: WalletUser document does not exist for UID: ${user.uid}');
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      print('MainDashWidget: Failed to fetch dashboard data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load dashboard data.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        automaticallyImplyLeading: false,
        title: _isLoading ? Container() : _buildWelcomeHeader(),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.black,
            ),
            tooltip: 'Settings',
            onPressed: () async {
              final user = currentUser;
              if (user == null) {
                print('User is null, cannot open settings.');
                return;
              }
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    displayName: _walletUser?.displayName ?? user.displayName ?? '',
                    email: user.email ?? '',
                  ),
                ),
              );

              if (result != null && result is Map<String, dynamic> && result.containsKey('displayName')) {
                _fetchDashboardData();
              }
            },
          ),
        ],
        centerTitle: false,
        elevation: 0.0,
      ),
      body: SafeArea(
        top: true,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _walletUser == null
                ? const Center(child: Text('User data could not be loaded.'))
                : _buildDashboardUI(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return _buildUploadOptionsSheet(context);
            },
          );
        },
        backgroundColor: FlutterFlowTheme.of(context).primary,
        child: const Icon(Icons.upload_file, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // REMOVED: IconButton for BudgetGoalsScreen
            IconButton(
              icon: const Icon(Icons.edit_note),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BudgetGoalsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(width: 48), // The space for the FAB
            IconButton(
              icon: const Icon(Icons.smart_toy),
              onPressed: () {
                Navigator.pushNamed(context, '/ai_coach');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOptionsSheet(BuildContext context) {
    return Container(
      child: Wrap(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Upload Image (Gallery)'),
            onTap: () async {
              Navigator.pop(context);
              final ImagePicker picker = ImagePicker();
              final XFile? imageFile = await picker.pickImage(source: ImageSource.gallery);
              if (imageFile != null) {
                print('Image selected from gallery: ${imageFile.path}');
                final downloadUrl = await uploadFileToFirebaseStorage(
                  context: context,
                  filePath: imageFile.path,
                  fileName: imageFile.name,
                  fileType: 'image',
                );
                if (downloadUrl != null) {
                  await saveUploadedFileMetadata(
                    context: context,
                    downloadUrl: downloadUrl,
                    fileType: 'image',
                  );
                  print('Image has been successfully uploaded.');
                }
              } else {
                print('Image upload cancelled.');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.video_library),
            title: const Text('Upload Video (Gallery)'),
            onTap: () async {
              Navigator.pop(context);
              final ImagePicker picker = ImagePicker();
              final XFile? videoFile = await picker.pickVideo(source: ImageSource.gallery);
              if (videoFile != null) {
                print('Video selected from gallery: ${videoFile.path}');
                final downloadUrl = await uploadFileToFirebaseStorage(
                  context: context,
                  filePath: videoFile.path,
                  fileName: videoFile.name,
                  fileType: 'video',
                );
                if (downloadUrl != null) {
                  await saveUploadedFileMetadata(
                    context: context,
                    downloadUrl: downloadUrl,
                    fileType: 'video',
                  );
                  print('Video has been successfully uploaded.');
                }
              } else {
                print('Video recording cancelled.');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Capture Image (Camera)'),
            onTap: () async {
              Navigator.pop(context);
              final ImagePicker picker = ImagePicker();
              final XFile? imageFile = await picker.pickImage(source: ImageSource.camera);
              if (imageFile != null) {
                print('Image captured: ${imageFile.path}');
                final downloadUrl = await uploadFileToFirebaseStorage(
                  context: context,
                  filePath: imageFile.path,
                  fileName: imageFile.name,
                  fileType: 'image',
                );
                if (downloadUrl != null) {
                  await saveUploadedFileMetadata(
                    context: context,
                    downloadUrl: downloadUrl,
                    fileType: 'image',
                  );
                  print('Image has been successfully uploaded.');
                }
              } else {
                print('Image capture cancelled.');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.videocam),
            title: const Text('Record Video (Camera)'),
            onTap: () async {
              Navigator.pop(context);
              final ImagePicker picker = ImagePicker();
              final XFile? videoFile = await picker.pickVideo(source: ImageSource.camera);
              if (videoFile != null) {
                print('Video recorded: ${videoFile.path}');
                final downloadUrl = await uploadFileToFirebaseStorage(
                  context: context,
                  filePath: videoFile.path,
                  fileName: videoFile.name,
                  fileType: 'video',
                );
                if (downloadUrl != null) {
                  await saveUploadedFileMetadata(
                    context: context,
                    downloadUrl: downloadUrl,
                    fileType: 'video',
                  );
                  print('Video has been successfully uploaded.');
                }
              } else {
                print('Video recording cancelled.');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Upload PDF (File Picker)'),
            onTap: () async {
              Navigator.pop(context);
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf'],
              );
              if (result != null) {
                print('PDF selected: ${result.files.single.path}');
                final downloadUrl = await uploadFileToFirebaseStorage(
                  context: context,
                  filePath: result.files.single.path!,
                  fileName: result.files.single.name,
                  fileType: 'pdf',
                );
                if (downloadUrl != null) {
                  await saveUploadedFileMetadata(
                    context: context,
                    downloadUrl: downloadUrl,
                    fileType: 'pdf',
                  );
                  print('PDF has been successfully uploaded.');
                }
              } else {
                print('PDF upload cancelled.');
              }
            },
          ),
        ],
      ),
    );
  }

  final RegExp _personaRegex = RegExp(
    r'\b(aggressive investor|long-term investor|tech professional|visionary|budgetor)\b',
    caseSensitive: false,
  );

  Widget _buildWelcomeHeader() {
    String personaTitle = "Investor";
    final userPersona = _walletUser?.persona;
    if (userPersona != null && userPersona.isNotEmpty) {
      final match = _personaRegex.firstMatch(userPersona);
      if (match != null) {
        final foundTitle = match.group(0)!;
        personaTitle = foundTitle[0].toUpperCase() + foundTitle.substring(1);
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hey ${_walletUser?.displayName ?? 'User'}!',
          style: FlutterFlowTheme.of(context).headlineSmall,
        ),
        Text(
          'The $personaTitle',
          style: FlutterFlowTheme.of(context).labelMedium,
        ),
      ],
    );
  }

  Widget _buildDashboardUI() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(child: _buildAvailableBalanceCard()),
                Expanded(child: _buildAssetsCard()),
              ],
            ),
          ),
          // --- RE-ADD THE WALLET BUTTON HERE ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Column(
              children: [
                // Show loading indicator or the button based on key availability
                if (mounted && (_serviceAccountKeyJson.isNotEmpty ?? false))
                  AddToGoogleWalletButton(
                    pass: _passPayload, // Pass the dynamically generated payload for visual rendering
                    // serviceAccountKey: _serviceAccountKeyJson, // Pass the loaded key directly
                    onSuccess: () {
                      _showSnackBar(context, 'Total Assets Pass added to Wallet successfully!');
                      print('Google Wallet: Total Assets Pass added successfully.'); // Log success
                    },
                    onCanceled: () {
                      _showSnackBar(context, 'Add Total Assets Pass to Wallet action canceled.');
                      print('Google Wallet: Total Assets Pass action canceled by user.'); // Log canceled
                    },
                    onError: (Object error) {
                      _showSnackBar(context, 'Error adding Total Assets Pass to Wallet: ${error.toString()}');
                      print('Google Wallet: Total Assets Pass Error - ${error.toString()}'); // Log error
                    },
                    locale: const Locale.fromSubtags(
                      languageCode: 'en',
                      countryCode: 'US',
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(7.0),
                    child: CircularProgressIndicator(), // Show loading while key loads
                  ),
              ],
            ),
          ),
          // --- END RE-ADDED WALLET BUTTON ---
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 0.0, 0.0),
            child: Text(
              'My Accounts',
              style: FlutterFlowTheme.of(context).titleLarge,
            ),
          ),
          _buildAccountsCarousel(),
          // _buildResetUserButton(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            child: _buildNotificationsStack(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsStack() {
    if (_sampleNotifications.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: _sampleNotifications.map((json) {
        if (json['action'] == 'show_transactions') {
          return NotificationCardWidget(
            data: json,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TransactionListScreen(),
                ),
              );
            },
          );
        } else {
          return NotificationCardWidget(data: json);
        }
      }).toList(),
    );
  }
  
  Widget _buildAvailableBalanceCard() {
    final double totalBalance = _accounts.fold(0.0, (sum, account) => sum + account.currentBalance);
    final formattedBalance = NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(totalBalance);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          context.pushNamed(AllTransactionsScreen.routeName);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available Balance',
                style: FlutterFlowTheme.of(context).labelLarge,
              ),
              const SizedBox(height: 8),
              Text(
                formattedBalance,
                style: FlutterFlowTheme.of(context).titleLarge,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssetsCard() {
    final double totalAssets = _assets.fold(0.0, (sum, asset) => sum + asset.currentValue);
    final formattedAssets = NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(totalAssets);
    
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      color: const Color(0xFFE8F5E9),
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          print('Assets card tapped!');
          context.pushNamed(WealthHubScreen.routeName);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assets',
                style: FlutterFlowTheme.of(context).labelLarge.override(
                      fontFamily: 'Inter',
                      color: FlutterFlowTheme.of(context).success,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                formattedAssets,
                style: FlutterFlowTheme.of(context).titleLarge.override(
                      fontFamily: 'Inter',
                      color: FlutterFlowTheme.of(context).success,
                    ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountsCarousel() {
    if (_accounts.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
      child: SizedBox(
        width: double.infinity,
        height: 170.0,
        child: CarouselSlider.builder(
          itemCount: _accounts.length,
          itemBuilder: (context, index, realIndex) {
            final account = _accounts[index];
            return _buildAccountCard(account);
          },
          carouselController: _model.carouselController ??= CarouselSliderController(),
          options: CarouselOptions(
            initialPage: 0,
            viewportFraction: 0.9,
            disableCenter: false,
            enlargeCenterPage: true,
            enlargeFactor: 0.25,
            enableInfiniteScroll: false,
            scrollDirection: Axis.horizontal,
            autoPlay: false,
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard(UserAccountsRecord account) {
    final balance = NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(account.currentBalance);
    final color = colorFromHex(account.accountColor) ?? FlutterFlowTheme.of(context).primary;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: () {
          print('${account.accountName} card tapped!');
          
          if (account.accountType == 'Capital') {
            context.pushNamed(AllTransactionsScreen.routeName);
          } else {
            context.pushNamed(
              SpendingAnalyzerScreen.routeName,
              pathParameters: {
                'accountId': account.reference.id,
              },
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                blurRadius: 4,
                color: Color(0x33000000),
                offset: Offset(0, 2),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                account.accountType.toUpperCase(),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Inter',
                      color: Colors.white.withOpacity(0.8),
                      letterSpacing: 1.2,
                    ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.accountName,
                    style: FlutterFlowTheme.of(context).headlineSmall.override(
                          fontFamily: 'Inter',
                          color: Colors.white,
                        ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      balance,
                      style: FlutterFlowTheme.of(context).titleLarge.override(
                            fontFamily: 'Inter',
                            color: Colors.white.withOpacity(0.9),
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildResetUserButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FFButtonWidget(
        onPressed: () async {
          final user = currentUser;
          if (user == null) return;
          
          bool? confirm = await showDialog<bool>(
            context: context,
            builder: (alertDialogContext) {
              return AlertDialog(
                title: const Text('Confirm Reset'),
                content: const Text('Are you sure you want to log out and delete all your data? This cannot be undone.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(alertDialogContext, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(alertDialogContext, true),
                    child: const Text('Reset'),
                  ),
                ],
              );
            },
          );

          if (confirm != true) return;

          final batch = FirebaseFirestore.instance.batch();

          final accountsSnapshot = await FirebaseFirestore.instance.collection('user_accounts').where('user_id', isEqualTo: user.uid).get();
          for (var doc in accountsSnapshot.docs) {
            batch.delete(doc.reference);
          }

          final assetsSnapshot = await FirebaseFirestore.instance.collection('user_assets').where('user_id', isEqualTo: user.uid).get();
          for (var doc in assetsSnapshot.docs) {
            batch.delete(doc.reference);
          }
          
          final walletUserRef = FirebaseFirestore.instance.collection('wallet_user_collection').doc(user.uid);
          batch.delete(walletUserRef);

          await batch.commit();
          await authManager.signOut();

          if (mounted) {
            context.goNamed(AuthHubScreenWidget.routeName);
          }
        },
        text: 'Log Out & Reset User',
        options: FFButtonOptions(
          width: double.infinity,
          height: 40,
          color: FlutterFlowTheme.of(context).error,
          textStyle: FlutterFlowTheme.of(context)
              .titleSmall
              .override(
                fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                color: Colors.white,
              ),
          elevation: 2,
          borderSide: const BorderSide(
            color: Colors.transparent,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

Future<String?> uploadFileToFirebaseStorage({
  required BuildContext context,
  required String filePath,
  required String fileName,
  required String fileType,
}) async {
  final user = currentUser;
  if (user == null) {
    print('Error: User is not logged in.');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You must be logged in to upload files.')),
    );
    return null;
  }

  final file = File(filePath);
  final storageRef = FirebaseStorage.instance
      .ref()
      .child('uploads')
      .child(user.uid!)
      .child(fileType)
      .child(fileName);

  try {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Uploading $fileName...')),
    );

    final uploadTask = storageRef.putFile(file);
    final snapshot = await uploadTask.whenComplete(() => {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    
    print('File uploaded successfully: $downloadUrl');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Upload successful!')),
    );
    
    return downloadUrl;
  } on FirebaseException catch (e) {
    print('Error uploading file to Firebase Storage: ${e.message}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error uploading file: ${e.code}')),
    );
    return null;
  }
}

Future<void> saveUploadedFileMetadata({
  required BuildContext context,
  required String downloadUrl,
  required String fileType,
}) async {
  final user = currentUser;
  if (user == null) return;

  try {
    await FirebaseFirestore.instance.collection('uploaded_files').add({
      'user_id': user.uid,
      'download_url': downloadUrl,
      'file_type': fileType,
      'uploaded_at': FieldValue.serverTimestamp(),
    });
    print('File metadata saved to Firestore.');
  } catch (e) {
    print('Error saving metadata to Firestore: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not save file details.')),
    );
  }
}

Color? colorFromHex(String? hexColor) {
  if (hexColor == null) return null;
  final hexCode = hexColor.replaceAll('#', '');
  if (hexCode.length == 6) {
    return Color(int.parse('FF$hexCode', radix: 16));
  }
  return null;
}