import 'package:flutter/material.dart';

class ManualLocalizations {
  ManualLocalizations(this.locale);

  final Locale locale;

  static ManualLocalizations of(BuildContext context) {
    return Localizations.of<ManualLocalizations>(context, ManualLocalizations)!;
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'selectLanguage': 'Select Language',
      'english': 'English',
      'spanish': 'Spanish',
    },
    'es': {
      'selectLanguage': 'Seleccione el idioma',
      'english': 'Inglés',
      'spanish': 'Español',
    },
  };

  String get selectLanguage {
    return _localizedValues[locale.languageCode]!['selectLanguage']!;
  }

  String get english {
    return _localizedValues[locale.languageCode]!['english']!;
  }

  String get spanish {
    return _localizedValues[locale.languageCode]!['spanish']!;
  }
}

class ManualLocalizationsDelegate extends LocalizationsDelegate<ManualLocalizations> {
  const ManualLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<ManualLocalizations> load(Locale locale) async {
    return ManualLocalizations(locale);
  }

  @override
  bool shouldReload(ManualLocalizationsDelegate old) => false;
}
