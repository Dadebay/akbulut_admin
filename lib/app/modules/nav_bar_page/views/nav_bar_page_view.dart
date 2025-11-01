import 'package:akbulut_admin/app/modules/nav_bar_page/controllers/nav_bar_page_controller.dart';
import 'package:akbulut_admin/app/product/init/packages.dart';
import 'package:akbulut_admin/app/product/widgets/drawer_button.dart';
import 'package:get/get.dart';

class NavBarPageView extends GetView<NavBarPageController> {
  @override
  final NavBarPageController controller = Get.put(NavBarPageController());

  NavBarPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: MediaQuery.of(context).size.width < 600 ? 70 : 220,
            child: _DrawerView(isCollapsed: MediaQuery.of(context).size.width < 600 ? true : false),
            decoration: BoxDecoration(
              color: Colors.white70,
              border: Border(
                right: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
          ),
          Expanded(
            child: Obx(() => controller.pages[controller.selectedIndex.value]),
          ),
        ],
      ),
    );
  }
}

class _DrawerView extends GetView<NavBarPageController> {
  final bool isCollapsed;

  const _DrawerView({required this.isCollapsed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          flex: 3,
          child: _Header(),
        ),
        Padding(
          padding: context.padding.low,
          child: Divider(color: Colors.grey.shade300, thickness: 2),
        ),
        Expanded(
          flex: 17,
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(controller.pages.length, (index) {
                final isSelected = controller.selectedIndex.value == index;
                final icon = controller.icons[index];
                final title = controller.titles[index];

                return Obx(() => DrawerButtonMine(
                      onTap: () {
                        controller.selectedIndex.value = index;
                      },
                      index: index,
                      selectedIndex: controller.selectedIndex.value,
                      showIconOnly: isCollapsed,
                      icon: icon,
                      title: title,
                      isCollapsed: MediaQuery.of(context).size.width < 600 ? true : false,
                    ));
              }),
            ),
          ),
        ),
        const Spacer(),
        FactoryLocationButton(),
        LanguageButton(),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        IconConstants.appName,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: ColorConstants.kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 28),
      ),
    );
  }
}
