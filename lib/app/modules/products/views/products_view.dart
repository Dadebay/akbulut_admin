import 'dart:ui';

import 'package:akbulut_admin/app/product/init/packages.dart';
import 'package:akbulut_admin/app/product/widgets/search_widget.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

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
          _buildStockSummary(),
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

  Widget _buildStockSummary() {
    return Obx(() {
      if (controller.filteredProductList.isEmpty || controller.searchController.text.isEmpty) {
        return const SizedBox.shrink();
      }

      // Stokları birime göre grupla ve topla
      final Map<String, double> stockByUnit = {};

      for (var product in controller.filteredProductList) {
        final unit = product.unitCode.isNotEmpty ? product.unitCode : product.unitName;
        final stock = double.tryParse(product.stockOnHand) ?? 0;

        if (unit.isNotEmpty) {
          stockByUnit[unit] = (stockByUnit[unit] ?? 0) + stock;
        }
      }

      if (stockByUnit.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ColorConstants.kPrimaryColor2.withOpacity(0.1),
              ColorConstants.kPrimaryColor2.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ColorConstants.kPrimaryColor2.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedPackage,
                  size: 20,
                  color: ColorConstants.kPrimaryColor2,
                ),
                const SizedBox(width: 8),
                Text(
                  'Toplam Stok',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.blackColor,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ColorConstants.kPrimaryColor2,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${controller.filteredProductList.length} ürün',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: stockByUnit.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: ColorConstants.kPrimaryColor2.withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatNumber(entry.value),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.kPrimaryColor2,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.greyColor,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
  }

  String _formatNumber(double value) {
    // Sayıyı formatla: 14657.6 -> "14 657.6"
    final parts = value.toStringAsFixed(1).split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '0';

    // Binlik ayırıcı ekle
    String formattedInteger = '';
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        formattedInteger = ' $formattedInteger';
      }
      formattedInteger = integerPart[i] + formattedInteger;
      count++;
    }

    return '$formattedInteger.$decimalPart';
  }

  Widget _buildWarehouseFilter(BuildContext context) {
    return Obx(() {
      if (controller.warehouseList.isEmpty) {
        return const SizedBox.shrink();
      }
      return Container(
        height: 50,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
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
                        final productCount = controller.warehouseProductCounts[warehouse.id];
                        return _buildFilterChip(
                          label: warehouse.name,
                          isSelected: controller.selectedWarehouse.value?.id == warehouse.id,
                          onSelected: (_) => controller.selectWarehouse(warehouse),
                          productCount: productCount,
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
            _buildProductTypeDropdown(),
            _buildCategoryDropdown()
          ],
        ),
      );
    });
  }

  Widget _buildProductTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, left: 8.0),
      child: Obx(() {
        return SizedBox(
          width: 150,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: ColorConstants.whiteColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: ColorConstants.greyColor.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              value: controller.selectedProductType.value,
              hint: Text(
                'Ürün Tipi',
                style: TextStyle(
                  color: ColorConstants.greyColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowDown01,
                size: 16,
                color: ColorConstants.greyColor,
              ),
              underline: const SizedBox(),
              borderRadius: BorderRadius.circular(10),
              dropdownColor: ColorConstants.whiteColor,
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(
                    'Haryt gornusi',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ColorConstants.greyColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                DropdownMenuItem<String>(
                  value: '150.',
                  child: Text(
                    'Çig Mallar (150)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ColorConstants.blackColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DropdownMenuItem<String>(
                  value: '151.',
                  child: Text(
                    'Ýarym Önüm (151)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ColorConstants.blackColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DropdownMenuItem<String>(
                  value: '152.',
                  child: Text(
                    'Önümler (152)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ColorConstants.blackColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DropdownMenuItem<String>(
                  value: '153.',
                  child: Text(
                    'Satylyk Harytlar (153)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ColorConstants.blackColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DropdownMenuItem<String>(
                  value: '255.',
                  child: Text(
                    'Demir Başlar (255)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ColorConstants.blackColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              onChanged: (value) {
                controller.selectProductType(value);
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, left: 8.0),
      child: Obx(() {
        return Container(
          width: 150,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: ColorConstants.whiteColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: ColorConstants.greyColor.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            value: controller.selectedCategory.value,
            hint: Text(
              'Kategori seç',
              style: TextStyle(
                color: ColorConstants.greyColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowDown01,
              size: 16,
              color: ColorConstants.greyColor,
            ),
            underline: const SizedBox(),
            borderRadius: BorderRadius.circular(10),
            dropdownColor: ColorConstants.whiteColor,
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Text(
                  'Haryt Groupları',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ColorConstants.greyColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ...controller.availableCategories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(
                    category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ColorConstants.blackColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ],
            onChanged: (value) {
              controller.selectCategory(value);
            },
          ),
        );
      }),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
    int? productCount,
  }) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (productCount != null && productCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? ColorConstants.whiteColor : ColorConstants.kPrimaryColor2,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                '$productCount',
                style: TextStyle(
                  color: isSelected ? ColorConstants.kPrimaryColor2 : ColorConstants.whiteColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
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
      padding: EdgeInsets.only(left: 16, right: productCount != null && productCount > 0 ? 0 : 10, top: 8, bottom: 8),
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
        SizedBox(
          width: 20,
        )
      ],
    );
  }

  Widget _buildListView(ProductController controller) {
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
        print(product.imageUrl);
        print(product.variantName);
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: SelectableText(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      product.variantName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    ),
                  ),
                  SelectableText(
                    product.code,
                    maxLines: 2,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
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
                  SelectableText(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1),
                  const SizedBox(height: 4),
                  Text(product.variantName, style: TextStyle(color: Colors.grey.shade600, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          product.code,
                          maxLines: 2,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ),
                      _buildStockIndicator(product.stockOnHand, product.unitCode, isSmall: true),
                    ],
                  ),
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
        _formatNumber(double.parse(stock)) + ' ' + unit,
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
