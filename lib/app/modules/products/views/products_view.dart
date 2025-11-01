import 'dart:ui';

import 'package:akbulut_admin/app/product/init/packages.dart';
import 'package:akbulut_admin/app/product/widgets/search_widget.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import '../controller/product_controller.dart';
import '../models/product_model.dart';

class ProductView extends StatefulWidget {
  const ProductView({super.key});

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  final ProductController controller = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(),
      body: Column(
        children: [
          SearchWidget(
            controller: controller.searchController,
            onChanged: controller.onSearchChanged,
            onClear: () {
              controller.onSearchChanged('');
              controller.searchController.clear();
            },
          ),
          _buildWarehouseFilter(context),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              } else if (controller.hasError.value) {
                return Center(child: Text('error_loading_products'.tr));
              } else if (controller.filteredProductList.isEmpty) {
                return Center(child: Text('no_products_found'.tr));
              } else if (controller.isGridView.value) {
                return _buildGridView(controller);
              } else {
                return _buildListView(controller);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseFilter(BuildContext context) {
    // ... Bu kısım aynı kaldı ...
    return Obx(() {
      if (controller.warehouseList.isEmpty) {
        return const SizedBox.shrink();
      }
      return Container(
        height: 50,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ScrollConfiguration(
          behavior: AppScrollBehavior(),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.warehouseList.length,
            itemBuilder: (context, index) {
              final warehouse = controller.warehouseList[index];
              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 16.0 : 4.0, right: 4.0),
                child: Obx(() {
                  return _buildFilterChip(
                    label: warehouse.name,
                    isSelected: controller.selectedWarehouse.value?.id == warehouse.id,
                    onSelected: (_) => controller.selectWarehouse(warehouse),
                  );
                }),
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    // ... Bu kısım aynı kaldı ...
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: ColorConstants.kPrimaryColor2,
      backgroundColor: ColorConstants.whiteColor,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      labelStyle: TextStyle(
        color: isSelected ? ColorConstants.whiteColor : ColorConstants.greyColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected ? Colors.transparent : ColorConstants.greyColor.withOpacity(0.4),
        width: 1.5,
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  AppBar _appBar() {
    // ... Bu kısım aynı kaldı ...
    return AppBar(
      title: Text(
        'products_view'.tr,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: ColorConstants.blackColor),
      ),
      shadowColor: Colors.transparent,
      foregroundColor: Colors.transparent,
      backgroundColor: ColorConstants.kPrimaryColor2.withOpacity(0.05),
      elevation: 0,
      actions: [
        Obx(() => ToggleButtons(
              isSelected: [!controller.isGridView.value, controller.isGridView.value],
              onPressed: (index) => controller.toggleView(),
              borderRadius: BorderRadius.circular(6),
              selectedColor: Colors.white,
              fillColor: ColorConstants.whiteColor,
              borderColor: ColorConstants.blackColor.withOpacity(0.1),
              constraints: const BoxConstraints(
                minHeight: 30.0,
                minWidth: 40.0,
              ),
              children: [
                HugeIcon(icon: HugeIcons.strokeRoundedListView, size: 16, color: ColorConstants.blackColor),
                HugeIcon(icon: HugeIcons.strokeRoundedGridView, size: 16, color: ColorConstants.blackColor),
              ],
            )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ElevatedButton.icon(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedAddCircle, size: 18, color: Colors.black),
            label: Text('add_product'.tr, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shadowColor: Colors.white,
              overlayColor: Colors.white,
              backgroundColor: Colors.white,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListView(ProductController controller) {
    // ... Bu kısım aynı kaldı ...
    return Obx(() => ListView.builder(
          itemCount: controller.filteredProductList.length,
          itemBuilder: (context, index) {
            final product = controller.filteredProductList[index];
            return _buildProductListCard(controller, product);
          },
        ));
  }

  Widget _buildGridView(ProductController controller) {
    // ... Bu kısım aynı kaldı ...
    return Obx(() => GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300,
            childAspectRatio: 2 / 2.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: controller.filteredProductList.length,
          itemBuilder: (context, index) {
            final product = controller.filteredProductList[index];
            return _buildProductGridCard(controller, product);
          },
        ));
  }

  // --- GÜNCELLENEN BÖLÜM: Ürün Liste Kartı ---
  Widget _buildProductListCard(ProductController controller, ProductModel product) {
    return GestureDetector(
      onTap: () {
        // controller.showProductDetailsDialog(product);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              offset: const Offset(0, 2),
              blurRadius: 4,
            )
          ],
        ),
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // --- BURASI DEĞİŞTİRİLDİ: Icon yerine Image.network eklendi ---
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                product.imageUrl, // Modelden gelen dinamik URL
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade100,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade100,
                    child: HugeIcon(icon: HugeIcons.strokeRoundedImageNotFound01, size: 40, color: Colors.grey.shade400),
                  );
                },
              ),
            ),
            // --- DEĞİŞİKLİĞİN SONU ---
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      product.variantName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    ),
                  ),
                  Text(
                    product.code,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _buildStockIndicator(product.stockOnHand, product.unitCode),
          ],
        ),
      ),
    );
  }

  // --- GÜNCELLENEN BÖLÜM: Ürün Izgara Kartı ---
  Widget _buildProductGridCard(ProductController controller, ProductModel product) {
    return GestureDetector(
      onTap: () {
        // controller.showProductDetailsDialog(product);
      },
      child: Card(
        elevation: 1,
        clipBehavior: Clip.antiAlias, // Bu, resmin kartın köşelerinden taşmasını engeller
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: ColorConstants.blackColor.withOpacity(0.1))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              // --- BURASI DEĞİŞTİRİLDİ: Icon yerine Image.network eklendi ---
              child: Image.network(
                product.imageUrl, // Modelden gelen dinamik URL
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade100,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade100,
                    child: Center(child: Icon(HugeIcons.strokeRoundedImageNotFound01, size: 50, color: Colors.grey.shade400)),
                  );
                },
              ),
              // --- DEĞİŞİKLİĞİN SONU ---
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border(
                top: BorderSide(color: ColorConstants.blackColor.withOpacity(0.1)),
              )),
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(product.variantName, style: TextStyle(color: Colors.grey.shade600, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  _buildStockIndicator(product.stockOnHand, product.unitCode, isSmall: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockIndicator(String stock, String unit, {bool isSmall = false}) {
    // ... Bu kısım aynı kaldı ...
    Color color = Colors.green.shade700;
    final text = '${double.parse(stock).toStringAsFixed(1)} $unit';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 8 : 12, vertical: isSmall ? 4 : 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: isSmall ? 14 : 16,
        ),
      ),
    );
  }
}

class AppScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.stylus,
        PointerDeviceKind.mouse,
      };

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
