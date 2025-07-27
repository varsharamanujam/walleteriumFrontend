import 'package:add_to_google_wallet/widgets/add_to_google_wallet_button.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() => runApp(const MaterialApp(home: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: AddToGoogleWalletButton(
            pass: _examplePass,
            onSuccess: () => _showSnackBar(context, 'Success!'),
            onCanceled: () => _showSnackBar(context, 'Action canceled.'),
            onError: (Object error) => _showSnackBar(context, error.toString()),
            locale: const Locale.fromSubtags(
              languageCode: 'fr',
              countryCode: 'FR',
            ),
          ),
        ),
      );

  void _showSnackBar(BuildContext context, String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

final String _passId = const Uuid().v4();
const String _passClass = 'example';
const String _issuerId = '3333000000000000000';
const String _issuerEmail = 'example@example.com';

final String _examplePass = """ 
    {
      "iss": "$_issuerEmail",
      "aud": "google",
      "typ": "savetowallet",
      "origins": [],
      "payload": {
        "genericObjects": [
          {
            "id": "$_issuerId.$_passId",
            "classId": "$_issuerId.$_passClass",
            "genericType": "GENERIC_TYPE_UNSPECIFIED",
            "hexBackgroundColor": "#4285f4",
            "logo": {
              "sourceUri": {
                "uri": "https://storage.googleapis.com/wallet-lab-tools-codelab-artifacts-public/pass_google_logo.jpg"
              }
            },
            "cardTitle": {
              "defaultValue": {
                "language": "en",
                "value": "Google I/O '22 [DEMO ONLY]"
              }
            },
            "subheader": {
              "defaultValue": {
                "language": "en",
                "value": "Attendee"
              }
            },
            "header": {
              "defaultValue": {
                "language": "en",
                "value": "Alex McJacobs"
              }
            },
            "barcode": {
              "type": "QR_CODE",
              "value": "$_passId"
            },
            "heroImage": {
              "sourceUri": {
                "uri": "https://storage.googleapis.com/wallet-lab-tools-codelab-artifacts-public/google-io-hero-demo-only.jpg"
              }
            },
            "textModulesData": [
              {
                "header": "POINTS",
                "body": "1234",
                "id": "points"
              }
            ]
          }
        ]
      }
    }
""";