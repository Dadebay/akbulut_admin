import 'package:akbulut_admin/app/product/init/packages.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget({super.key, this.onChanged, this.onClear, required this.controller});
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: ListTile(
        leading: const Icon(
          IconlyLight.search,
          color: Colors.black,
        ),
        minTileHeight: 50,
        title: TextField(
            controller: controller,
            style: TextStyle(color: ColorConstants.blackColor, fontSize: 16, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
                hintText: 'search'.tr,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0), // İç dikey boşluğu ayarlar
                hintStyle: TextStyle(color: ColorConstants.greyColor, fontSize: 14),
                border: InputBorder.none),
            onChanged: onChanged),
        contentPadding: EdgeInsets.only(left: 15, top: 0, bottom: 0),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: ColorConstants.greyColor.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(10),
        ),
        trailing: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
              icon: Icon(
                CupertinoIcons.xmark_circle,
                color: ColorConstants.greyColor,
              ),
              onPressed: onClear),
        ),
      ),
    );
  }
}
