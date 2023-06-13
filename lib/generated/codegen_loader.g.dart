// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader{
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String,dynamic> en = {
    "NegizgiBet": "Home Page",
    "Paraqsha": "Profile",
    "Shygu": "Log Out",
    "QawQury": "Create Community",
    "Qat": "Members",
    "Kir":"Joined",
    "Qawat": "Community name"
};
static const Map<String,dynamic> ru = {
  "NegizgiBet": "Negizgi Bet",
  "Paraqsha": "Paraqsha",
  "Shygu": "Shygu",
  "QawQury": "Qauymdastyq quru",
  "Qat": "qatysushy",
  "Kir":"Kiryldi",
  "Qawat": "Qauymdastyq aty"

};
  static const Map<String,dynamic> de = {
  "NegizgiBet": "Главная страница",
  "Paraqsha": "Профиль",
  "Shygu": "Выйти",
  "QawQury": "Создать сообщество",
  "Qat": "Участников",
    "Qawat": "Имя сообщества"

  };
static const Map<String, Map<String,dynamic>> mapLocales = {"en": en, "ru": ru,"de":de};
}
