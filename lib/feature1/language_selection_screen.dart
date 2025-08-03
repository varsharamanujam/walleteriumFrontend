
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walleterium/l10n/manual_localizations.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final Function(Locale) onLanguageSelected;

  const LanguageSelectionScreen({Key? key, required this.onLanguageSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ManualLocalizations.of(context).selectLanguage),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(ManualLocalizations.of(context).english),
            onTap: () => _selectLanguage(context, 'en'),
          ),
          ListTile(
            title: Text(ManualLocalizations.of(context).spanish),
            onTap: () => _selectLanguage(context, 'es'),
          ),
          // Add more languages here
        ],
      ),
    );
  }

  void _selectLanguage(BuildContext context, String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    onLanguageSelected(Locale(languageCode));
  }
}
