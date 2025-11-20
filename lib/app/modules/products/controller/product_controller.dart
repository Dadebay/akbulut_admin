import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/data/services/api_service.dart';
import '../models/product_model.dart';

class ProductController extends GetxController {
  var isGridView = false.obs;
  var isLoading = true.obs;
  var hasError = false.obs;

  final productList = <ProductModel>[].obs;
  final allProductList = <ProductModel>[].obs;
  final filteredProductList = <ProductModel>[].obs;

  // --- KATEGORİ DEĞİŞKENLERİ AMBAR DEĞİŞKENLERİ İLE DEĞİŞTİRİLDİ ---
  final warehouseList = <WarehouseModel>[].obs;
  final selectedWarehouse = Rxn<WarehouseModel>();
  final warehouseProductCounts = <int, int>{}.obs;
  final availableCategories = <String>[].obs;
  final selectedCategory = Rxn<String>();
  
  // Product Type Filter
  final selectedProductType = Rxn<String>();

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

  void fetchWarehousesAndProducts() async {
    print('🚀 [Init] Starting initialization...');
    warehouseList.assignAll([
      WarehouseModel(id: -1, name: 'HEMMESI'),
      WarehouseModel(id: 201, name: 'ANEW BAZA'),
      WarehouseModel(id: 90, name: 'SEH AMMAR'),
      WarehouseModel(id: 71, name: 'LEBAP'),
      WarehouseModel(id: 81, name: 'MARY'),
    ]);

    // Tüm ürünleri bir kez çek (search için)
    print('🚀 [Init] Fetching all products first...');
    await fetchAllProducts();
    print('🚀 [Init] All products fetched: ${allProductList.length}');

    // Varsayılan olarak ilk ambarı seçili hale getiriyoruz.
    if (warehouseList.isNotEmpty) {
      print('🚀 [Init] Selecting first warehouse: ${warehouseList.first.name}');
      selectWarehouse(warehouseList.first);
    }
  }

  // Tüm ürünleri çeken metot (search için)
  Future<void> fetchAllProducts() async {
    try {
      print('📦 [FetchAllProducts] Fetching ALL products from ALL warehouses...');
      
      // Tüm warehouse'ların ürünlerini çek ve birleştir
      List<ProductModel> allProducts = [];
      final warehouseIds = [201, 90, 71, 81]; // ANEW BAZA, SEH AMMAR, LEBAP, MARY
      
      for (var warehouseId in warehouseIds) {
        try {
          print('📦 [FetchAllProducts] Fetching from warehouse: $warehouseId');
          final products = await _apiService.getProductsFromSqlServer(warehouseId: warehouseId);
          allProducts.addAll(products);
          print('📦 [FetchAllProducts] Added ${products.length} products from warehouse $warehouseId');
        } catch (e) {
          print('📦 [FetchAllProducts] Error fetching warehouse $warehouseId: $e');
        }
      }
      
      allProductList.assignAll(allProducts);
      print('📦 [FetchAllProducts] ✅ Total loaded: ${allProductList.length} products from all warehouses');
    } catch (e) {
      print('📦 [FetchAllProducts] ERROR: $e');
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
      // NOT: allProductList'i güncelleme! O tüm warehouse'lar için tutulmalı (search için)
      
      // Kategorileri güncelle
      if (searchController.text.isEmpty) {
        _updateCategoriesForCurrentWarehouse();
      }
      
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
    selectedCategory.value = null;
    selectedProductType.value = null;
    // Seçilen ambara göre ürünleri yeniden getiriyoruz.
    // fetchProducts içinde zaten kategoriler güncelleniyor, burada tekrar çağırmaya gerek yok
    fetchProducts(warehouseId: warehouse?.id);
  }

  void _updateCategoriesForCurrentWarehouse() {
    if (selectedWarehouse.value == null) return;
    
    // productList zaten seçili warehouse için filtrelenmiş ürünleri içeriyor
    // Bu yüzden direkt productList kullanıyoruz, allProductList'e gerek yok
    _updateAvailableCategories(productList);
  }

  void onSearchChanged(String query) {
    final lowerCaseQuery = query.toLowerCase();
    print('🔍 [Search] Query: "$query"');
    print('🔍 [Search] Searching in ALL warehouses (${allProductList.length} products)');
    print('🔍 [Search] Current warehouse: ${selectedWarehouse.value?.name}');

    if (lowerCaseQuery.isEmpty) {
      // Arama kutusu boşsa, filtrelenmiş listeyi ana listeyle eşitle.
      if (selectedCategory.value != null) {
        // Kategori seçiliyse sadece o kategorideki ürünleri göster
        final filtered = productList.where((product) {
          return product.stockGroupCode == selectedCategory.value;
        }).toList();
        filteredProductList.assignAll(filtered);
      } else {
        filteredProductList.assignAll(productList);
      }
      warehouseProductCounts.clear();
      // Kategorileri temizleme, warehouse'daki tüm kategorileri göster
      _updateCategoriesForCurrentWarehouse();
    } else {
      // TÜM ürünler üzerinden arama yap (allProductList)
      // CODE, NAME ve VNAME alanlarında arama yap
      final allFiltered = allProductList.where((product) {
        final codeMatch = product.code.toLowerCase().contains(lowerCaseQuery);
        final nameMatch = product.name.toLowerCase().contains(lowerCaseQuery);
        final variantMatch = product.variantName.toLowerCase().contains(lowerCaseQuery);

        return codeMatch || nameMatch || variantMatch;
      }).toList();

      print('🔍 [Search] Found ${allFiltered.length} products matching "$query"');
      if (allFiltered.isEmpty) {
        print('🔍 [Search] No products found! Checking first 3 products in allProductList:');
        allProductList.take(3).forEach((p) {
          print('   - CODE: ${p.code}, NAME: ${p.name}, VNAME: ${p.variantName}');
        });
      }

      // Kategorileri güncelle
      _updateAvailableCategories(allFiltered);

      // Warehouse ve kategori filtresi uygula
      _applyFilters(allFiltered);
      _calculateWarehouseProductCounts(allFiltered);
    }
  }

  void _updateAvailableCategories(List<ProductModel> filteredProducts) {
    final categories = filteredProducts
        .map((product) => product.stockGroupCode)
        .where((code) => code.isNotEmpty)
        .toSet()
        .toList();
    categories.sort();
    availableCategories.assignAll(categories);
  }

  void _applyFilters(List<ProductModel> allFiltered) {
    var filtered = allFiltered.where((product) {
      // Warehouse filtresi
      final warehouseMatch = selectedWarehouse.value?.id == -1 ||
          product.warehouseNumber == selectedWarehouse.value?.id;

      // Product Type filtresi
      final productTypeMatch = selectedProductType.value == null ||
          product.code.startsWith(selectedProductType.value!);

      // Kategori filtresi
      final categoryMatch = selectedCategory.value == null ||
          product.stockGroupCode == selectedCategory.value;

      return warehouseMatch && productTypeMatch && categoryMatch;
    }).toList();

    filteredProductList.assignAll(filtered);
  }

  void selectCategory(String? category) {
    selectedCategory.value = category;
    _applyAllFilters();
  }

  void selectProductType(String? productType) {
    selectedProductType.value = productType;
    _applyAllFilters();
  }

  void _applyAllFilters() {
    if (searchController.text.isEmpty) {
      var filtered = productList.where((product) {
        // Product Type filtresi
        final productTypeMatch = selectedProductType.value == null ||
            product.code.startsWith(selectedProductType.value!);
        
        // Kategori filtresi
        final categoryMatch = selectedCategory.value == null ||
            product.stockGroupCode == selectedCategory.value;

        return productTypeMatch && categoryMatch;
      }).toList();
      
      filteredProductList.assignAll(filtered);
    } else {
      // Search varsa normal akışı çalıştır
      onSearchChanged(searchController.text);
    }
  }

  void _calculateWarehouseProductCounts(List<ProductModel> filteredProducts) {
    warehouseProductCounts.clear();

    for (var warehouse in warehouseList) {
      if (warehouse.id == -1) {
        warehouseProductCounts[warehouse.id] = filteredProducts.length;
      } else {
        final count = filteredProducts.where((product) => product.warehouseNumber == warehouse.id).length;
        warehouseProductCounts[warehouse.id] = count;
      }
    }
  }

  void toggleView() {
    isGridView.value = !isGridView.value;
  }
}
