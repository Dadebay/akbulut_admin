// ignore_for_file: file_names, must_be_immutable

import 'package:get/get.dart';
import 'package:akbulut_admin/app/product/init/packages.dart';

class AgreeButton extends StatelessWidget {
  final Function() onTap;
  final String text;
  final bool? showBorder;

  AgreeButton({required this.onTap, required this.text, this.showBorder});
  final HomeController homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: animatedContaner(context));
  }

  Widget animatedContaner(BuildContext context) {
    return Obx(() {
      return AnimatedContainer(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: showBorder == true ? Colors.transparent : ColorConstants.kPrimaryColor2, border: Border.all(color: ColorConstants.kPrimaryColor2)),
        margin: context.padding.onlyTopNormal,
        padding: context.padding.normal.copyWith(top: 15, bottom: 15),
        width: Get.size.width,
        duration: const Duration(milliseconds: 800),
        alignment: Alignment.center,
        child: Text(
          text.tr,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.general.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: 20, color: showBorder == true ? ColorConstants.kPrimaryColor2 : Colors.white),
        ),
      );
    });
  }
}
