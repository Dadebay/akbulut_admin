import 'dart:convert';

import 'package:akbulut_admin/app/product/init/packages.dart';
import 'package:http/http.dart' as http;

import '../../modules/products/models/product_model.dart';

class ApiService {
  static const String _baseUrl = ApiConstants.serverBaseUrl;

  // --- BU METODU GÜNCELLEYİN ---
  // Metot artık opsiyonel bir 'warehouseId' parametresi alıyor.
  Future<List<ProductModel>> getProductsFromSqlServer({int? warehouseId}) async {
    // 1. Adım: URL'yi dinamik olarak oluşturuyoruz.
    final Uri url;
    if (warehouseId != null) {
      // Eğer bir warehouseId gönderilmişse, onu query parametresi olarak URL'ye ekliyoruz.
      // Örnek: http://<sunucu_adresi>/api/products?ammarNo=90
      url = Uri.parse('$_baseUrl/api/products?ammarNo=$warehouseId');
    } else {
      // Eğer warehouseId gönderilmemişse, varsayılan olarak parametresiz istek atıyoruz.
      url = Uri.parse('$_baseUrl/api/products');
    }

    // (Gereksiz print satırlarını temizledim, bir tane yeterli)
    print('SQL Server\'dan ürünler isteniyor: $url');

    try {
      // 2. Adım: Dinamik olarak oluşturulan URL'ye GET isteği gönderiyoruz.
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        final List<ProductModel> products = body.map((dynamic item) => ProductModel.fromJson(item as Map<String, dynamic>)).toList();
        return products;
      } else {
        print('Sunucu hatası: ${response.statusCode}');
        print('Sunucu yanıtı: ${response.body}');
        throw Exception('Ürünler yüklenemedi. Durum Kodu: ${response.statusCode}');
      }
    } catch (e) {
      print('Ürünleri çekerken hata oluştu: $e');
      throw Exception('Ürünler yüklenirken bir hata oluştu: $e');
    }
  }
}
