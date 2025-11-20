import 'package:akbulut_admin/app/product/init/packages.dart'; // ApiConstants için

/// API'den gelen ürün verilerini temsil eden model sınıfı.
class ProductModel {
  final int sref;
  final String code; // Bu alan resim adı için kullanılacak (örn: 150.109.0017)
  final String name;
  final String variantCode;
  final String variantName;
  final String stockGroupCode;
  final String specialCode;
  final String stockOnHand;
  final int warehouseNumber;
  final DateTime? lastTransactionDate;
  final String unitCode;
  final String unitName;
  final String barcode;

  ProductModel({
    required this.sref,
    required this.code,
    required this.name,
    required this.variantCode,
    required this.variantName,
    required this.stockGroupCode,
    required this.specialCode,
    required this.stockOnHand,
    required this.warehouseNumber,
    this.lastTransactionDate,
    required this.unitCode,
    required this.unitName,
    required this.barcode,
  });

  // --- YENİ EKLENEN KISIM: Resim URL'sini oluşturan yardımcı ---
  /// Ürünün resim URL'sini dinamik olarak oluşturur.
  String get imageUrl {
    if (variantName.isNotEmpty) {
      return '${ApiConstants.serverBaseUrl}/images/${variantName.toUpperCase()}.png';
    } else if (code.isNotEmpty) {
      return '${ApiConstants.serverBaseUrl}/images/${code.toUpperCase()}.png';
    }
    return '';
  }
  // --- YENİ EKLENEN KISMIN SONU ---

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    try {
      return ProductModel(
        sref: json['SREF'] as int? ?? 0,
        // SQL'den gelen 'CODE' alanını modeldeki 'code' alanına atıyoruz.
        code: json['CODE'] as String? ?? 'Kod Yok',
        name: json['NAME'] as String? ?? 'İsim Yok',
        variantCode: json['VCODE'] as String? ?? '',
        variantName: json['VNAME'] as String? ?? '',
        stockGroupCode: json['STGRPCODE'] as String? ?? '',
        specialCode: json['SPECODE'] as String? ?? '',
        stockOnHand: (json['ONHAND']?.toString() ?? '0'),
        warehouseNumber: json['AMMARNO'] as int? ?? 0,
        lastTransactionDate: json['LASTTRDATE'] != null ? DateTime.tryParse(json['LASTTRDATE'] as String) : null,
        unitCode: json['BRMCODE'] as String? ?? '',
        unitName: json['BRMNAME'] as String? ?? '',
        barcode: json['BARCODE'] as String? ?? 'Barkod Yok',
      );
    } catch (e) {
      debugPrint('ProductModel.fromJson HATA: $e');
      debugPrint('Sorunlu JSON verisi: $json');
      return ProductModel.error();
    }
  }

  factory ProductModel.error() {
    return ProductModel(
      sref: 0,
      code: 'Hata',
      name: 'Veri Okunamadı',
      variantCode: '',
      variantName: '',
      stockGroupCode: '',
      specialCode: '',
      stockOnHand: '0',
      warehouseNumber: 0,
      lastTransactionDate: null,
      unitCode: '',
      unitName: '',
      barcode: '',
    );
  }
}

// lib/app/modules/products/models/warehouse_model.dart
class WarehouseModel {
  final int id;
  final String name;

  WarehouseModel({required this.id, required this.name});
}
