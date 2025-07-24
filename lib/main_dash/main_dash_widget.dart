import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'main_dash_model.dart';
export 'main_dash_model.dart';

// --- FIX START: Added necessary imports ---
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/index.dart';
// --- FIX END ---

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

  // --- FIX START: Added state variables for data fetching ---
  bool _isLoading = true;
  Map<String, dynamic>? _userProfileData;
  // --- FIX END ---

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainDashModel());
    
    // --- FIX START: Call the function to fetch data ---
    _fetchUserProfileData();
    // --- FIX END ---

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  // --- FIX START: Added the data fetching function ---
  Future<void> _fetchUserProfileData() async {
    final user = currentUser;
    if (user == null) {
      context.goNamed(AuthHubScreenWidget.routeName);
      return;
    }

    final docRef =
        FirebaseFirestore.instance.collection('user_profiles').doc(user.uid);
    final docSnapshot = await docRef.get();

    if (mounted) {
      if (docSnapshot.exists) {
        setState(() {
          _userProfileData = docSnapshot.data();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print("Error: User profile not found!");
      }
    }
  }
  // --- FIX END ---

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(64.0),
          child: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            automaticallyImplyLeading: false,
            title: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total asset value',
                  style: FlutterFlowTheme.of(context).labelMedium.override(
                        fontFamily: GoogleFonts.inter().fontFamily,
                        letterSpacing: 0.0,
                      ),
                ),
                Text(
                  '\$244,204',
                  style: FlutterFlowTheme.of(context).displaySmall.override(
                        fontFamily: GoogleFonts.interTight().fontFamily,
                        letterSpacing: 0.0,
                      ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 16.0, 8.0),
                child: FlutterFlowIconButton(
                  borderColor: FlutterFlowTheme.of(context).primary,
                  borderRadius: 12.0,
                  borderWidth: 2.0,
                  buttonSize: 40.0,
                  fillColor: FlutterFlowTheme.of(context).accent1,
                  icon: Icon(
                    Icons.wallet_outlined,
                    color: FlutterFlowTheme.of(context).primaryText,
                    size: 24.0,
                  ),
                  onPressed: () {
                    print('IconButton pressed ...');
                  },
                ),
              ),
            ],
            centerTitle: false,
            elevation: 0.0,
          ),
        ),
        body: SafeArea(
          top: true,
          // --- FIX START: Replaced direct UI with a conditional builder ---
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _userProfileData == null
                  ? Center(child: Text('User profile could not be loaded.'))
                  : _buildDashboardUI(),
          // --- FIX END ---
        ),
      ),
    );
  }

  // --- FIX START: Created a new build method for the main UI ---
  Widget _buildDashboardUI() {
    // Safely get preferred sectors, handling the case where it might be null
    final sectors =
        _userProfileData!['preferred_sectors'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- NEW SECTION: Displaying the fetched onboarding data ---
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Onboarding Profile',
                  style: FlutterFlowTheme.of(context).titleLarge,
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).alternate,
                      width: 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          icon: Icons.trending_up,
                          title: 'Investment Style',
                          value: '${_userProfileData!['investment_style']}',
                        ),
                        const Divider(),
                        _buildDetailRow(
                          icon: Icons.business_center,
                          title: 'Preferred Sectors',
                          value: sectors.join(', '),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // --- END OF NEW SECTION ---

          // --- Your existing UI starts here ---
          Container(
            constraints: BoxConstraints(
              maxWidth: 470.0,
            ),
            decoration: BoxDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            color: FlutterFlowTheme.of(context).primary,
                            size: 24.0,
                          ),
                          RichText(
                            textScaler: MediaQuery.of(context).textScaler,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '2.54%',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily:
                                            GoogleFonts.inter().fontFamily,
                                        color:
                                            FlutterFlowTheme.of(context).primary,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                TextSpan(
                                  text: ' from last week',
                                  style: TextStyle(),
                                )
                              ],
                              style: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: GoogleFonts.inter().fontFamily,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                        ].divide(SizedBox(width: 8.0)),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                        child: Text(
                          'My Portfolio',
                          style: FlutterFlowTheme.of(context)
                              .titleLarge
                              .override(
                                fontFamily:
                                    GoogleFonts.interTight().fontFamily,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                  child: Container(
                    width: double.infinity,
                    height: 190.0,
                    child: CarouselSlider(
                      items: [
                        // Your Carousel items here...
                      ],
                      carouselController: _model.carouselController ??=
                          CarouselSliderController(),
                      options: CarouselOptions(
                        initialPage: 0,
                        viewportFraction: 0.8,
                        disableCenter: true,
                        enlargeCenterPage: true,
                        enlargeFactor: 0.25,
                        enableInfiniteScroll: true,
                        scrollDirection: Axis.horizontal,
                        autoPlay: false,
                        onPageChanged: (index, _) =>
                            _model.carouselCurrentIndex = index,
                      ),
                    ),
                  ),
                ),
                // The rest of your UI (Transaction History, etc.) continues here...
              ],
            ),
          ),
        ],
      ),
    );
  }
  // --- END OF NEW BUILD METHOD ---

  // --- FIX START: Added a helper widget to display data rows ---
  Widget _buildDetailRow(
      {required IconData icon,
      required String title,
      required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: FlutterFlowTheme.of(context).primary, size: 20.0),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FlutterFlowTheme.of(context).bodyLarge,
                ),
                const SizedBox(height: 4.0),
                Text(
                  value,
                  style: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).titleSmallFamily,
                        color: FlutterFlowTheme.of(context).primaryText,
                      ),
                ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: FFButtonWidget(
                  onPressed: () async {
                    // This is the reset logic
                    final user = currentUser;
                    if (user == null) return;

                    // 1. Delete the detailed profile document
                    await FirebaseFirestore.instance
                        .collection('user_profiles')
                        .doc(user.uid)
                        .delete();

                    // 2. Delete the basic wallet user document
                    await FirebaseFirestore.instance
                        .collection('wallet_user_collection')
                        .doc(user.uid)
                        .delete();
                    
                    // 3. Sign the user out
                    await authManager.signOut();

                    // 4. Go back to the login screen
                    if (mounted) {
                      context.goNamed(AuthHubScreenWidget.routeName);
                    }
                  },
                  text: 'Log Out & Reset User',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 40,
                    color: FlutterFlowTheme.of(context).error,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                          color: Colors.white,
                        ),
                    elevation: 2,
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}