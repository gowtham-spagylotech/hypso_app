import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:hypso/configs/config.dart';

class LanguageCubit extends Cubit<Locale> {
  LanguageCubit() : super(AppLanguage.defaultLanguage);

  ///On Change Language
  void onUpdate(Locale locale) {
    emit(locale);

    ///Preference save
    Preferences.setString(
      Preferences.language,
      locale.languageCode,
    );
  }
}
