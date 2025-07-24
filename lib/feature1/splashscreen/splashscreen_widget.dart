import '/auth/base_auth_user_provider.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:async'; // Import for StreamSubscription
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'splashscreen_model.dart';
export 'splashscreen_model.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:walleterium/backend/schema/wallet_user_record.dart';

class SplashscreenWidget extends StatefulWidget {
  const SplashscreenWidget({super.key});

  static String routeName = 'Splashscreen';
  static String routePath = '/splashscreen';

  @override
  State<SplashscreenWidget> createState() => _SplashscreenWidgetState();
}

class _SplashscreenWidgetState extends State<SplashscreenWidget>
    with TickerProviderStateMixin {
  late SplashscreenModel _model;
  late StreamSubscription<User?> _authSubscription;
  bool _handledNavigation = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SplashscreenModel());

    // --- CORRECTED AUTH LOGIC ---
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) async {
      // Prevent multiple navigations
      if (_handledNavigation) return;
      _handledNavigation = true;

      // Give a moment for the splash screen to display
      await Future.delayed(const Duration(milliseconds: 2000));
      if (!mounted) return;

      if (user == null) {
        // --- NO USER LOGGED IN ---
        context.goNamed(AuthHubScreenWidget.routeName);
      } else {
        // --- USER IS LOGGED IN ---
        final userDocRef = WalletUsersRecord.collection.doc(user.uid);
        final userDocSnapshot = await userDocRef.get();
        bool onboardingComplete = false;

        if (userDocSnapshot.exists) {
          // --- RETURNING USER ---
          await userDocRef.update({
            'last_seen': FieldValue.serverTimestamp(),
            'display_name': user.displayName,
            'photo_url': user.photoURL,
          });
          final data = userDocSnapshot.data() as Map<String, dynamic>?;
          onboardingComplete = data?['onboarding_completed'] ?? false;
        } else {
          // --- BRAND NEW USER ---
          final newWalletUserData = createWalletUsersRecordData(
            uid: user.uid,
            email: user.email,
            displayName: user.displayName,
            photoUrl: user.photoURL,
            lastSeen: DateTime.now(),
            onboardingCompleted: false,
          );
          await userDocRef.set(newWalletUserData);
          onboardingComplete = false;
        }

        if (!mounted) return;

        // Route user based on onboarding status.
        if (onboardingComplete) {
          context.goNamed(MainDashWidget.routeName);
        } else {
          context.goNamed(AIConversationalOnboardingScreenWidget.routeName);
        }
      }
    });
    // --- END OF CORRECTION ---

    animationsMap.addAll({
      'containerOnPageLoadAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 1.ms),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 400.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 400.0.ms,
            begin: Offset(3.0, 3.0),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'containerOnPageLoadAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 300.ms),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 300.0.ms,
            duration: 300.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.bounceOut,
            delay: 300.0.ms,
            duration: 300.0.ms,
            begin: Offset(0.6, 0.6),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'textOnPageLoadAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 350.ms),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 350.0.ms,
            duration: 400.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 350.0.ms,
            duration: 400.0.ms,
            begin: Offset(0.0, 30.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'textOnPageLoadAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 400.ms),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 400.0.ms,
            duration: 400.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 400.0.ms,
            duration: 400.0.ms,
            begin: Offset(0.0, 30.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    // This is the correct place to cancel the subscription
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The build method can remain exactly the same as before.
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                height: 500.0,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2A579A), Color(0xFF152C50)],
                    stops: [0.0, 0.8],
                    begin: AlignmentDirectional(0.0, -1.0),
                    end: AlignmentDirectional(0, 1.0),
                  ),
                ),
                child: Container(
                  width: 100.0,
                  height: 100.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0x00FFFFFF), Colors.white],
                      stops: [0.0, 1.0],
                      begin: AlignmentDirectional(0.0, -1.0),
                      end: AlignmentDirectional(0, 1.0),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 139.6,
                        height: 139.6,
                        decoration: BoxDecoration(
                          color: Color(0xCCFFFFFF),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(60.0),
                              bottomRight: Radius.circular(60.0),
                              topLeft: Radius.circular(60.0),
                              topRight: Radius.circular(60.0),
                            ),
                            child: Image.asset(
                              'assets/images/Gemini_Generated_Image_xzd6l3xzd6l3xzd6.png',
                              width: 100.0,
                              height: 100.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ).animateOnPageLoad(
                          animationsMap['containerOnPageLoadAnimation2']!),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 44.0, 0.0, 0.0),
                        child: Text(
                          'Walleterium Imperium',
                          style: FlutterFlowTheme.of(context)
                              .displaySmall
                              .override(
                                fontFamily: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600,
                                ).fontFamily,
                                color: Color(0xFF101213),
                                fontSize: 30.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                              ),
                        ).animateOnPageLoad(
                            animationsMap['textOnPageLoadAnimation1']!),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            44.0, 8.0, 44.0, 0.0),
                        child: Text(
                          'Getting things ready...',
                          textAlign: TextAlign.center,
                          style:
                              FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w500,
                                    ).fontFamily,
                                    color: Color(0xFF57636C),
                                    fontSize: 14.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ).animateOnPageLoad(
                            animationsMap['textOnPageLoadAnimation2']!),
                      ),
                    ],
                  ),
                ),
              ).animateOnPageLoad(
                  animationsMap['containerOnPageLoadAnimation1']!),
            ),
          ],
        ),
      ),
    );
  }
}