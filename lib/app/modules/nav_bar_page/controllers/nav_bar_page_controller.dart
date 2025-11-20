import 'package:akbulut_admin/app/data/services/dahua_service.dart';
import 'package:akbulut_admin/app/modules/attendance_view/controllers/attendance_controller.dart';
import 'package:akbulut_admin/app/modules/attendance_view/views/attendance_view.dart';
import 'package:akbulut_admin/app/modules/expences/views/expences_view.dart';
import 'package:akbulut_admin/app/modules/home/views/home_view.dart';
import 'package:akbulut_admin/app/modules/products/views/products_view.dart';
import 'package:akbulut_admin/app/modules/purchases/views/purchases_view.dart';
import 'package:akbulut_admin/app/modules/sales/views/sales_view.dart';
import 'package:akbulut_admin/app/product/init/packages.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class NavBarPageController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final DahuaService dahuaService = DahuaService();

  var selectedFactoryLocation = 'all'.obs;

  late List<Widget> pages;
  late List<IconData> icons;
  late List<String> titles;

  final List<Widget> _adminPages = [
    HomeView(),
    ProductView(),
    // SalesView(),
    // PurchasesView(),
    // ExpencesView(),
    AttendanceView(),
  ];

  final List<IconData> _adminIcons = [
    IconlyLight.chart,
    IconlyLight.search,
    // IconlyLight.paper,
    // CupertinoIcons.cart_badge_plus,
    // IconlyLight.wallet,
    IconlyLight.user3,
  ];

  final List<String> _adminTitles = [
    'home', 'products',
    // 'sales', 'purchases', 'expences',
    'workers'
  ];

  final List<Widget> _kadrPages = [AttendanceView()];
  final List<IconData> _kadrIcons = [IconlyLight.user3];
  final List<String> _kadrTitles = ['workers'];

  final List<Widget> _satysPages = [
    HomeView(),
    ProductView(),
    SalesView(),
    PurchasesView(),
    ExpencesView(),
  ];

  final List<IconData> _satysIcons = [
    IconlyLight.chart,
    IconlyLight.search,
    IconlyLight.paper,
    CupertinoIcons.cart_badge_plus,
    IconlyLight.wallet,
  ];

  final List<String> _satysTitles = [
    'home',
    'products',
    'sales',
    'purchases',
    'expences'
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeNavigationItems();
  }

  void _initializeNavigationItems() {
    final box = GetStorage();
    final role = box.read('role') ?? 'admin';

    switch (role) {
      case 'admin':
        pages = _adminPages;
        icons = _adminIcons;
        titles = _adminTitles;
        break;
      case 'kadr':
        pages = _kadrPages;
        icons = _kadrIcons;
        titles = _kadrTitles;
        break;
      case 'satys':
        pages = _satysPages;
        icons = _satysIcons;
        titles = _satysTitles;
        break;
      default:
        pages = _adminPages;
        icons = _adminIcons;
        titles = _adminTitles;
    }
  }

  void preloadAttendanceCache() {
    // Find AttendanceController and trigger preload
    try {
      final attendanceController = Get.find<AttendanceController>();
      Future.delayed(const Duration(milliseconds: 100), () {
        attendanceController.preloadAllLocations();
      });
    } catch (e) {
      print('AttendanceController not found yet, will preload later');
    }
  }

  void changeFactoryLocation(String location) {
    selectedFactoryLocation.value = location;

    update();
  }

  void toggleAdmin() {
    _initializeNavigationItems();
    if (selectedIndex.value >= pages.length) {
      selectedIndex.value = 0;
    }
    update();
  }
}
