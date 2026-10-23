import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';

class CustomLanguage {
  static changeLanguage(BuildContext context, String langCode) {
    switch (langCode) {
      case 'en':
        context.setLocale(Locale('en'));
        break;
      case 'ta':
        context.setLocale(Locale('ta'));
        break;
    }
  }
}
