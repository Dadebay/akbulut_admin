import 'dart:convert';

import 'package:akbulut_admin/app/modules/login_view/views/login_view.dart';
import 'package:akbulut_admin/app/modules/nav_bar_page/views/nav_bar_page_view.dart';
import 'package:akbulut_admin/app/product/constants/theme_contants.dart';
import 'package:akbulut_admin/app/product/init/app_start_init.dart';
import 'package:akbulut_admin/app/product/init/packages.dart';
import 'package:akbulut_admin/app/product/init/translations.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStartInit.init();
  initializeDateFormatting('en');
  initializeDateFormatting('tk');
  initializeDateFormatting('ru');

  final en = Map<String, String>.from(json.decode(await rootBundle.loadString('assets/translations/en.json')));
  final tk = Map<String, String>.from(json.decode(await rootBundle.loadString('assets/translations/tk.json')));
  final ru = Map<String, String>.from(json.decode(await rootBundle.loadString('assets/translations/ru.json')));

  final allTranslations = {
    'en_US': en,
    'tk_TM': tk,
    'ru_RU': ru,
  };

  runApp(_MyApp(translations: MyTranslations(allTranslations: allTranslations)));
}

class _MyApp extends StatelessWidget {
  _MyApp({super.key, required this.translations});
  final MyTranslations translations;
  final HomeController homeController = Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final token = box.read('token');

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: IconConstants.appName,
      theme: AppThemes.lightTheme,
      fallbackLocale: const Locale('tk', 'TK'),
      locale: const Locale('tk', 'TK'),
      translations: translations,
      defaultTransition: Transition.fadeIn,
      home: token == null ? LoginView() : NavBarPageView(),
    );
  }
}
