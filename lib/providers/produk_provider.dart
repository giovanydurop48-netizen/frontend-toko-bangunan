import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/produk_model.dart';
import '../services/api_services.dart';

class ProdukProvider extends ChangeNotifier {
  List<ProdukModel> _produkList = [];
  List<ProdukModel> _filteredList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProdukModel> get produkList => _filteredList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProduk() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/produk');
      final resData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        List<dynamic> data = [];

        if (resData is Map<String, dynamic> && resData.containsKey('data')) {
          data = resData['data'];
        } else if (resData is List) {
          data = resData;
        }

        _produkList = data.map((json) => ProdukModel.fromJson(json)).toList();
        _filteredList = List.from(_produkList);
      } else {
        _errorMessage = (resData is Map && resData.containsKey('message'))
            ? resData['message']
            : 'Gagal memuat produk (Status: ${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan saat memuat data produk: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fungsi pencarian produk (disesuaikan dengan panggilan di pos_screen.dart)
  void cariProduk(String query) {
    if (query.isEmpty) {
      _filteredList = List.from(_produkList);
    } else {
      _filteredList = _produkList
          .where((produk) =>
              produk.namaProduk.toLowerCase().contains(query.toLowerCase()) ||
              produk.kodeProduk.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  // Alias untuk kompatibilitas
  void searchProduk(String query) => cariProduk(query);
}
