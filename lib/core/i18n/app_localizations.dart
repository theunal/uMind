import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'tr': {
      'appTitle': 'uMind',
      'appTagline': 'Görsel IQ Testi',
      'startButton': 'Teste Başla',
      'levelSelect': 'Seviye Seçimi',
      'level': 'Seviye',
      'score': 'Puan',
      'tests': 'Test',
      'best': 'En İyi',
      'questionProgress': '{current}/{total}',
      'chooseAnswer': 'Doğru cevabı seçin',
      'correct': 'Doğru',
      'wrong': 'Yanlış',
      'nextLevel': 'Sonraki Seviye',
      'retry': 'Tekrar Dene',
      'levelComplete': 'Seviye Tamamlandı!',
      'pointsEarned': 'puan kazandınız',
      'settings': 'Ayarlar',
      'locked': 'Kilitli',
      'disclaimer':
          'Bu test eğlence ve pratik amaçlıdır. Klinik bir IQ testi değildir.',
      'congratulations': 'Tebrikler!',
      'levelLocked': 'Bu seviye kilitli',
    },
    'en': {
      'appTitle': 'uMind',
      'appTagline': 'Visual IQ Test',
      'startButton': 'Start Test',
      'levelSelect': 'Level Selection',
      'level': 'Level',
      'score': 'Score',
      'tests': 'Tests',
      'best': 'Best',
      'questionProgress': '{current}/{total}',
      'chooseAnswer': 'Choose the correct answer',
      'correct': 'Correct',
      'wrong': 'Wrong',
      'nextLevel': 'Next Level',
      'retry': 'Try Again',
      'levelComplete': 'Level Complete!',
      'pointsEarned': 'points earned',
      'settings': 'Settings',
      'locked': 'Locked',
      'disclaimer':
          'This test is for entertainment and practice purposes. It is not a clinical IQ test.',
      'congratulations': 'Congratulations!',
      'levelLocked': 'This level is locked',
    },
  };

  String _translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  String get appTitle => _translate('appTitle');
  String get appTagline => _translate('appTagline');
  String get startButton => _translate('startButton');
  String get levelSelect => _translate('levelSelect');
  String get level => _translate('level');
  String get score => _translate('score');
  String get tests => _translate('tests');
  String get best => _translate('best');
  String get chooseAnswer => _translate('chooseAnswer');
  String get correct => _translate('correct');
  String get wrong => _translate('wrong');
  String get nextLevel => _translate('nextLevel');
  String get retry => _translate('retry');
  String get levelComplete => _translate('levelComplete');
  String get pointsEarned => _translate('pointsEarned');
  String get settings => _translate('settings');
  String get locked => _translate('locked');
  String get disclaimer => _translate('disclaimer');
  String get congratulations => _translate('congratulations');
  String get levelLocked => _translate('levelLocked');

  String questionProgress(int current, int total) {
    return _translate('questionProgress')
        .replaceAll('{current}', current.toString())
        .replaceAll('{total}', total.toString());
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['tr', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
