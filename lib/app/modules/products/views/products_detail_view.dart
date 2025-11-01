// import 'package:akbulut_admin/app/modules/products/controller/product_controller.dart';
// import 'package:akbulut_admin/app/product/init/packages.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:hugeicons/hugeicons.dart';

// class ProductDetailView extends GetView<ProductController> {
//   const ProductDetailView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       child: Container(
//         width: MediaQuery.of(context).size.width * 0.7,
//         padding: const EdgeInsets.all(24.0),
//         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
//         child: Obx(() {
//           if (controller.currentProduct.value == null) {
//             return const Center(child: Text('Ürün bulunamadı.'));
//           }
//           return Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(controller.currentProduct.value?.name ?? 'Ürün Detayı', style: Theme.of(context).textTheme.headlineSmall),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => Get.back(),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(flex: 2, child: _buildImageGallery()),
//                       const SizedBox(width: 24),
//                       Expanded(flex: 3, child: Obx(() => controller.isEditMode.value ? _buildProductForm() : _buildProductInfo())),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               _buildActionButtons(),
//             ],
//           );
//         }),
//       ),
//     );
//   }

//   Widget _buildActionButtons() {
//     return Obx(() {
//       if (controller.isEditMode.value) {
//         return Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             TextButton(
//               child: const Text('Vazgeç'),
//               onPressed: controller.cancelEdit,
//             ),
//             const SizedBox(width: 16),
//             ElevatedButton.icon(
//               icon: controller.isSaving.value ? const SizedBox.shrink() : HugeIcon(icon: HugeIcons.strokeRoundedSaveEnergy01, color: Colors.white),
//               label: Text(controller.isSaving.value ? 'Kaydediliyor...' : 'Değişiklikleri Kaydet'),
//               onPressed: controller.isSaving.value ? null : controller.saveChanges,
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
//                 backgroundColor: ColorConstants.kPrimaryColor,
//                 foregroundColor: Colors.white,
//               ),
//             ),
//           ],
//         );
//       } else {
//         return Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             TextButton.icon(
//               icon: HugeIcon(icon: HugeIcons.strokeRoundedDelete02, color: Colors.red.shade700),
//               label: const Text('Sil', style: TextStyle(color: Colors.red)),
//               onPressed: controller.deleteProduct,
//             ),
//             const SizedBox(width: 16),
//             ElevatedButton.icon(
//               icon: HugeIcon(icon: HugeIcons.strokeRoundedEdit01, color: Colors.white),
//               label: const Text('Düzenle'),
//               onPressed: controller.toggleEditMode,
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
//                 backgroundColor: ColorConstants.kPrimaryColor,
//                 foregroundColor: Colors.white,
//               ),
//             ),
//           ],
//         );
//       }
//     });
//   }

//   Widget _buildImageGallery() {
//     // final images = controller.currentProduct.value;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         AspectRatio(
//           aspectRatio: 1,
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: Colors.grey.shade300),
//               color: Colors.grey.shade100,
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(16),
//               child: Obx(() => Image.network(
//                     controller.selectedImageUrl.value,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.image_not_supported, size: 50)),
//                   )),
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//         SizedBox(
//           height: 80,
//           // child: ListView.builder(
//           //   scrollDirection: Axis.horizontal,
//           //   itemCount: images.length,
//           //   itemBuilder: (context, index) {
//           //     final imageUrl = images[index];
//           //     return Obx(() {
//           //       final isSelected = controller.selectedImageUrl.value == imageUrl;
//           //       return GestureDetector(
//           //         onTap: () => controller.selectImage(imageUrl),
//           //         child: Container(
//           //           width: 80,
//           //           margin: const EdgeInsets.only(right: 12),
//           //           decoration: BoxDecoration(
//           //             borderRadius: BorderRadius.circular(8),
//           //             border: Border.all(
//           //               color: isSelected ? ColorConstants.kPrimaryColor : Colors.grey.shade300,
//           //               width: isSelected ? 3 : 1,
//           //             ),
//           //           ),
//           //           child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(imageUrl, fit: BoxFit.cover)),
//           //         ),
//           //       );
//           //     });
//           //   },
//           // ),
//         ),
//       ],
//     );
//   }

//   Widget _buildProductInfo() {
//     final product = controller.currentProduct.value!;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildInfoRow(label: 'Ürün Adı', value: product.name, icon: HugeIcons.strokeRoundedShoppingBag01),
//         // _buildInfoRow(label: 'Açıklama', value: product.description, icon: HugeIcons.strokeRoundedLegalDocument01),
//         // _buildInfoRow(label: 'Fiyat', value: '\$${product.price.toStringAsFixed(2)}', icon: HugeIcons.strokeRoundedDollar01),
//         // _buildInfoRow(label: 'Stok Adedi', value: product.stockLeft.toString(), icon: HugeIcons.strokeRoundedCube),
//         // _buildInfoRow(label: 'Kategori', value: product.category?.name ?? '-', icon: HugeIcons.strokeRoundedTag01),
//       ],
//     );
//   }

//   Widget _buildInfoRow({required String label, required String value, required IconData icon}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 20.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: Colors.grey.shade600, size: 20),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
//                 const SizedBox(height: 4),
//                 Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProductForm() {
//     return Column(
//       children: [
//         _buildTextField(controller: controller.nameController, label: 'Ürün Adı', icon: HugeIcons.strokeRoundedShoppingBag01),
//         _buildTextField(controller: controller.descriptionController, label: 'Açıklama', icon: HugeIcons.strokeRoundedLegalDocument01, maxLines: 4),
//         Row(
//           children: [
//             Expanded(child: _buildTextField(controller: controller.priceController, label: 'Fiyat (\$)', icon: HugeIcons.strokeRoundedDollar01, keyboardType: TextInputType.number)),
//             const SizedBox(width: 16),
//             Expanded(child: _buildTextField(controller: controller.stockController, label: 'Stok Adedi', icon: HugeIcons.strokeRoundedCube, keyboardType: TextInputType.number)),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, int maxLines = 1, TextInputType? keyboardType}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 20.0),
//       child: TextField(
//         controller: controller,
//         maxLines: maxLines,
//         keyboardType: keyboardType,
//         decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), alignLabelWithHint: true),
//       ),
//     );
//   }
// }
