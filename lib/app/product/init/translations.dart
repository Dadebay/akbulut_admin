import 'package:get/get.dart';

class MyTranslations extends Translations {
  final Map<String, Map<String, String>> allTranslations;

  MyTranslations({required this.allTranslations});

  @override
  Map<String, Map<String, String>> get keys => allTranslations;
}
