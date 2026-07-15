import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/errors/app_exception.dart';

class MealService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  static const Duration _timeout = Duration(seconds: 15);

  /// Mendeteksi apakah error adalah akibat tidak ada koneksi internet.
  bool _isNetworkError(dynamic e) {
    return e is SocketException ||
        e is HttpException ||
        (e is Exception && e.toString().contains('SocketException'));
  }

  /// Wrapper untuk melakukan HTTP GET dengan timeout dan error mapping.
  Future<http.Response> _get(Uri uri) async {
    try {
      return await http.get(uri).timeout(_timeout);
    } on SocketException {
      throw AppException.noInternet();
    } on HttpException {
      throw AppException.noInternet();
    } on Exception catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw AppException.timeout('MealDB');
      }
      if (_isNetworkError(e)) {
        throw AppException.noInternet();
      }
      throw AppException.mealDbFailed(e.toString());
    }
  }

  /// Mencari daftar resep berdasarkan nama.
  Future<List<dynamic>> searchMealsByName(String name) async {
    try {
      final response = await _get(
        Uri.parse('$_baseUrl/search.php?s=${Uri.encodeComponent(name)}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['meals'] ?? [];
      } else {
        throw AppException.mealDbFailed('Status ${response.statusCode}');
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException.mealDbFailed(e.toString());
    }
  }

  /// Mencari ID resep berdasarkan nama.
  Future<String?> searchMealIdByName(String name) async {
    try {
      final response = await _get(
        Uri.parse('$_baseUrl/search.php?s=${Uri.encodeComponent(name)}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic>? meals = data['meals'];
        if (meals != null && meals.isNotEmpty) {
          final firstMeal = meals.first as Map<String, dynamic>;
          return firstMeal['idMeal'] as String?;
        }
        return null;
      } else {
        throw AppException.mealDbFailed('Status ${response.statusCode}');
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException.mealDbFailed(e.toString());
    }
  }

  /// Mengambil detail resep berdasarkan ID.
  Future<Map<String, dynamic>?> lookupMealById(String id) async {
    try {
      final response = await _get(
        Uri.parse('$_baseUrl/lookup.php?i=$id'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic>? meals = data['meals'];
        if (meals != null && meals.isNotEmpty) {
          return meals.first as Map<String, dynamic>;
        }
        return null;
      } else {
        throw AppException.mealDbFailed('Status ${response.statusCode}');
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException.mealDbFailed(e.toString());
    }
  }
}
