import 'package:akbulut_admin/app/modules/nav_bar_page/controllers/nav_bar_page_controller.dart';
import 'package:akbulut_admin/app/product/init/packages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class DrawerButtonMine extends StatelessWidget {
  const DrawerButtonMine({required this.onTap, required this.index, required this.selectedIndex, required this.showIconOnly, required this.icon, required this.title, required this.isCollapsed});
  final bool showIconOnly;
  final int index;
  final int selectedIndex;
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final bool isCollapsed;
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(left: 12, right: 12, top: 12),
        width: Get.size.width,
        child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                shadowColor: Colors.transparent,
                backgroundColor: selectedIndex == index ? ColorConstants.kPrimaryColor2 : ColorConstants.kPrimaryColor2.withOpacity(.05),
                side: BorderSide(color: selectedIndex == index ? ColorConstants.kPrimaryColor2 : ColorConstants.kPrimaryColor2.withOpacity(.1), width: 1),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: isCollapsed ? 2 : 10)),
            child: showIconOnly
                ? Padding(
                    padding: const EdgeInsets.only(left: 8, right: 4),
                    child: Icon(
                      icon,
                      color: selectedIndex == index ? Colors.white : Colors.black,
                    ),
                  )
                : Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 4),
                        child: Icon(
                          icon,
                          color: selectedIndex == index ? Colors.white : Colors.black,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12, right: 4),
                          child: Text(
                            title.tr,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: selectedIndex == index ? Colors.white : Colors.black, fontSize: 16, fontWeight: selectedIndex == index ? FontWeight.bold : FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  )));
  }
}

class LanguageButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      width: Get.size.width,
      child: ElevatedButton(
        onPressed: () {
          print("Current locale: ${Get.locale}");
          Get.dialog(LanguageDialog());
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          backgroundColor: ColorConstants.kPrimaryColor2.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 8, right: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  Get.locale!.languageCode == 'tm'
                      ? 'assets/image/tm.png'
                      : Get.locale!.languageCode == 'ru'
                          ? 'assets/image/ru.png'
                          : 'assets/image/en.png',
                  width: 25,
                  height: 25,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 4),
                child: Text(
                  Get.locale!.languageCode == 'tm'
                      ? 'Türkmen dili'
                      : Get.locale!.languageCode == 'ru'
                          ? 'Rus dili'
                          : 'Iňlis dili',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LanguageDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'choose_language'.tr,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LanguageTile(
            locale: Locale('tk', 'TM'),
            langName: 'Türkmen dili',
            flagAsset: 'assets/image/tm.png',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: LanguageTile(
              locale: Locale('ru', 'RU'),
              langName: 'Rus dili',
              flagAsset: 'assets/image/ru.png',
            ),
          ),
          LanguageTile(
            locale: Locale('en', 'US'),
            langName: 'Iňlis dili',
            flagAsset: 'assets/image/en.png',
          ),
        ],
      ),
    );
  }
}

class LanguageTile extends StatelessWidget {
  final Locale locale;
  final String langName;
  final String flagAsset;

  const LanguageTile({
    required this.locale,
    required this.langName,
    required this.flagAsset,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Get.updateLocale(locale);
        Get.back();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      selectedColor: ColorConstants.kPrimaryColor2.withOpacity(0.1),
      tileColor: ColorConstants.kPrimaryColor2.withOpacity(0.1),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.asset(
          flagAsset,
          width: 30,
          height: 30,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        langName,
        style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w400),
      ),
    );
  }
}

class FactoryLocationButton extends GetView<NavBarPageController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12).copyWith(bottom: 0),
      width: Get.size.width,
      child: ElevatedButton(
        onPressed: () {
          Get.dialog(FactoryLocationDialog());
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          backgroundColor: ColorConstants.kPrimaryColor2.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: Icon(HugeIcons.strokeRoundedFactory, color: Colors.black),
            ),
            Expanded(
              child: Obx(() => Text(
                    controller.selectedFactoryLocation.value.tr,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class FactoryLocationDialog extends GetView<NavBarPageController> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'change_factory_location'.tr,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FactoryLocationTile(index: '1', location: 'all'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: FactoryLocationTile(index: '2', location: 'main_office'),
          ),
          FactoryLocationTile(index: '3', location: 'factory1'),
        ],
      ),
    );
  }
}

class FactoryLocationTile extends GetView<NavBarPageController> {
  final String location;
  final String index;

  const FactoryLocationTile({required this.location, required this.index});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        controller.changeFactoryLocation(location);
        Get.back();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      selectedColor: ColorConstants.kPrimaryColor2.withOpacity(0.1),
      tileColor: ColorConstants.kPrimaryColor2.withOpacity(0.1),
      title: Text(
        location.tr,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
      ),
    );
  }
}
