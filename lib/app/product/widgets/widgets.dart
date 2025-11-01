import 'package:akbulut_admin/app/product/init/packages.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class CustomWidgets {
  static Center spinKit() {
    return Center(child: Lottie.asset(IconConstants.loading, width: 150, height: 150, animate: true));
  }

  static Center noImage() {
    return Center(
        child: Text(
      'noImage'.tr,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white, fontSize: 25),
    ));
  }

  static Center emptyData() {
    return Center(
        child: Text(
      "noProduct".tr,
      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 20),
    ));
  }

  static SnackbarController showSnackBar(String title, String subtitle, Color color) {
    if (SnackbarController.isSnackbarBeingShown) {
      SnackbarController.cancelAllSnackbars();
    }
    return Get.snackbar(
      title,
      subtitle,
      snackStyle: SnackStyle.FLOATING,
      titleText: title == ''
          ? const SizedBox.shrink()
          : Text(
              title.tr,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
      messageText: Text(
        subtitle.tr,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: color,
      borderRadius: 20.0,
      duration: const Duration(milliseconds: 1000),
      margin: const EdgeInsets.all(8),
    );
  }

  static Center errorFetchData(BuildContext context) {
    return Center(
        child: Padding(
      padding: context.padding.normal,
      child: Column(
        children: [
          Lottie.asset(IconConstants.noData, width: WidgetSizes.size256.value, height: WidgetSizes.size256.value, animate: true),
          Padding(
            padding: context.padding.verticalNormal,
            child: Text(
              "Data not found",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.general.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            "If you want to see the data please check your internet connection",
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.general.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w500, fontSize: 20, color: ColorConstants.greyColor),
          ),
        ],
      ),
    ));
  }

  static Widget counter(int index) {
    return Container(
      width: 40,
      padding: EdgeInsets.only(right: 10),
      alignment: Alignment.center,
      child: Text(
        index.toString(),
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}

extension StringCasingExtension on String {
  String toTitleCase() {
    if (isEmpty) {
      return this;
    }
    return split(' ').map((word) {
      if (word.isEmpty) {
        return '';
      }
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
