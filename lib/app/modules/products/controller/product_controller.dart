import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/data/services/api_service.dart';
import '../models/product_model.dart';

class ProductController extends GetxController {
  var isGridView = false.obs;
  var isLoading = true.obs;
  var hasError = false.obs;

  final productList = <ProductModel>[].obs;
  final filteredProductList = <ProductModel>[].obs;

  // --- KATEGORİ DEĞİŞKENLERİ AMBAR DEĞİŞKENLERİ İLE DEĞİŞTİRİLDİ ---
  final warehouseList = <WarehouseModel>[].obs;
  final selectedWarehouse = Rxn<WarehouseModel>();

  final ApiService _apiService = ApiService();
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchWarehousesAndProducts();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // YENİ: Ambar listesini dolduran ve ilk ürünleri çeken metot
  void fetchWarehousesAndProducts() {
    // Resimdeki 'YES' olan ambarları listeye ekliyoruz.
    warehouseList.assignAll([
      WarehouseModel(id: -1, name: 'HEMMESI'),
      WarehouseModel(id: 0, name: 'MERKEZ'),
      WarehouseModel(id: 1, name: 'YADA'),
      WarehouseModel(id: 31, name: 'ATAK'),
      WarehouseModel(id: 71, name: 'LB'),
      WarehouseModel(id: 81, name: 'MR'),
      WarehouseModel(id: 90, name: 'SEH AMMAR'),
      WarehouseModel(id: 91, name: 'ÖNÜMÇILIK'),
      WarehouseModel(id: 201, name: 'ANEW BAZA'),
      WarehouseModel(id: 301, name: 'WOOD'),
    ]);
    // Varsayılan olarak ilk ambarı seçili hale getiriyoruz.
    if (warehouseList.isNotEmpty) {
      selectWarehouse(warehouseList.first);
    }
  }

  // GÜNCELLENDİ: Metot artık 'warehouseId' parametresi alıyor
  Future<void> fetchProducts({int? warehouseId}) async {
    try {
      isLoading(true);
      hasError(false);
      // ApiService'e seçilen ambarın ID'sini gönderiyoruz.
      final products = await _apiService.getProductsFromSqlServer(warehouseId: warehouseId);
      productList.assignAll(products);
      // Arama filtresini de güncel ürün listesine göre sıfırlıyoruz.
      onSearchChanged(searchController.text);
    } catch (e) {
      hasError(true);
      print(e);
    } finally {
      isLoading(false);
    }
  }

  // YENİ: Ambar seçildiğinde bu metot çalışacak
  void selectWarehouse(WarehouseModel? warehouse) {
    selectedWarehouse.value = warehouse;
    // Seçilen ambara göre ürünleri yeniden getiriyoruz.
    fetchProducts(warehouseId: warehouse?.id);
  }

  void onSearchChanged(String query) {
    final lowerCaseQuery = query.toLowerCase();

    if (lowerCaseQuery.isEmpty) {
      // Arama kutusu boşsa, filtrelenmiş listeyi ana listeyle eşitle.
      filteredProductList.assignAll(productList);
    } else {
      // Ana listeyi filtrele.
      final filtered = productList.where((product) {
        // Her alan için null kontrolü yapıyoruz. `?.` operatörü,
        // solundaki değer null ise sağındaki işlemi yapmaz ve çökmez.
        final nameMatch = product.name.toLowerCase().contains(lowerCaseQuery) ?? false;
        final variantMatch = product.variantName.toLowerCase().contains(lowerCaseQuery) ?? false;
        final codeMatch = product.code.toLowerCase().contains(lowerCaseQuery) ?? false;

        return nameMatch || variantMatch || codeMatch;
      }).toList(); // Filtreleme sonucunu bir listeye çeviriyoruz.

      filteredProductList.assignAll(filtered);
    }
  }

  void toggleView() {
    isGridView.value = !isGridView.value;
  }
}
