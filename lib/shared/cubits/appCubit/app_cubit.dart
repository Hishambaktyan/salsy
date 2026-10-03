import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:inventory_sales_manager/modules/sales_screen.dart';
import '../../../modules/home_screen.dart';
import '../../../modules/settings_screen.dart';
import '../../../modules/statistics_screen.dart';
import '../../../modules/products_screen.dart';
import '../../networks/local/cache_helper.dart';
import '../../networks/local/db_helper.dart';
import '../../styles/colors.dart';
import 'app_states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(InitThemeState()) ;

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  final List<Widget> screens = [
    HomeScreen(),
    ProductsScreen(),
    SalesScreen(),
    StatisticsScreen(),
    SettingsScreen()
  ];

  bool isDark = false;

  void changeIndex(int value) {
    currentIndex = value;
    emit(ChangeNavBarState());
  }

  void changeTheme({bool? fromShared}) {
    if (fromShared != null) {
      isDark = fromShared;
    } else {
      isDark = !isDark;
    }

    CacheHelper.saveData(key: 'isDark', value: isDark);

    emit(ChangeThemeState());
  }

  Locale currentLocale = const Locale('en');

  String get language => currentLocale.languageCode;

  void changeLanguage(String languageCode) {
    currentLocale = Locale(languageCode);

    CacheHelper.saveData(
      key: 'languageCode',
      value: languageCode,
    );

    emit(ChangeLanguageState());
  }

  void getSavedLanguage() {
    final languageCode = CacheHelper.getData(key: 'languageCode');

    if (languageCode != null) {
      currentLocale = Locale(languageCode);
      emit(ChangeLanguageState());
    }
  }
}

