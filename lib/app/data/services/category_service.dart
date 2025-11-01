
import 'dart:convert';
import 'package:akbulut_admin/app/product/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import '../../modules/products/models/category_model.dart';

class CategoryService {
  static const String _baseUrl = ApiConstants.proxyApiBaseUrl;


  Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('${_baseUrl}app_categories'));

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        if (responseData is Map<String, dynamic>) {
          final List<dynamic> categoryData = responseData['data'];
          if (categoryData.isNotEmpty) {
            return categoryData.map((item) => Category.fromJson(item as Map<String, dynamic>)).toList();
          }
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }
}
