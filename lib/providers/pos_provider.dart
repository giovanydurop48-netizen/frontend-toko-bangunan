import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_toko_bangunan/models/produk_model.dart';
import 'package:frontend_toko_bangunan/services/api_services.dart';

class ItemKeranjang {
  final ProdukModel produk;
  int jumlah;

  ItemKeranjang({required this.produk, this.jumlah = 1});

  double get subtotal => produk.hargaJual * jumlah;
}

class PosProvider with ChangeNotifier {
  final List<ItemKeranjang> _keranjang = [];
  double _diskonPersen = 0.0;
  bool _isProcessing = false;
  String? _errorMessage;

  List<ItemKeranjang> get keranjang => _keranjang;
  int get totalItemJenis => _keranjang.length;
  int get totalSemuaQty => _keranjang.fold(0, (sum, item) => sum + item.jumlah);
  double get diskonPersen => _diskonPersen;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;

  double get totalKotor =>
      _keranjang.fold(0.0, (sum, item) => sum + item.subtotal);
  double get nominalDiskon => totalKotor * (_diskonPersen / 100);
  double get totalBayar => totalKotor - nominalDiskon;

  void tambahProduk(ProdukModel produk) {
    final index = _keranjang.indexWhere((item) => item.produk.id == produk.id);
    if (index >= 0) {
      if (_keranjang[index].jumlah < produk.stok) {
        _keranjang[index].jumlah++;
      }
    } else if (produk.stok > 0) {
      _keranjang.add(ItemKeranjang(produk: produk));
    }
    notifyListeners();
  }

  void ubahJumlah(int produkId, int delta) {
    final index = _keranjang.indexWhere((item) => item.produk.id == produkId);
    if (index >= 0) {
      final item = _keranjang[index];
      if (delta > 0 && item.jumlah < item.produk.stok) {
        item.jumlah++;
      } else if (delta < 0) {
        item.jumlah--;
        if (item.jumlah <= 0) {
          _keranjang.removeAt(index);
        }
      }
      notifyListeners();
    }
  }

  void setJumlah(int produkId, int jumlahBaru) {
    final index = _keranjang.indexWhere((item) => item.produk.id == produkId);
    if (index >= 0) {
      if (jumlahBaru <= 0) {
        _keranjang.removeAt(index);
      } else {
        final maxStok = _keranjang[index].produk.stok.toInt();
        _keranjang[index].jumlah = jumlahBaru > maxStok ? maxStok : jumlahBaru;
      }
      notifyListeners();
    }
  }

  void hapusProduk(int produkId) {
    _keranjang.removeWhere((item) => item.produk.id == produkId);
    notifyListeners();
  }

  void setDiskon(double nilai) {
    if (nilai > 10.0) {
      _diskonPersen = 10.0;
    } else if (nilai < 0) {
      _diskonPersen = 0.0;
    } else {
      _diskonPersen = nilai;
    }
    notifyListeners();
  }

  void resetTransaksi() {
    _keranjang.clear();
    _diskonPersen = 0.0;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> prosesPembayaran(double nominalBayar) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final double kembalian =
          nominalBayar >= totalBayar ? (nominalBayar - totalBayar) : 0.0;

      final payload = {
        'metode_pembayaran': 'tunai',
        'total_kotor': totalKotor,
        'total_harga': totalBayar,
        'diskon_persen': diskonPersen,
        'diskon': nominalDiskon,
        'total_bayar': totalBayar,
        'nominal_bayar': nominalBayar,
        'uang_bayar': nominalBayar,
        'bayar': nominalBayar,
        'kembalian': kembalian,
        'items': _keranjang
            .map((item) => {
                  'produk_id': item.produk.id,
                  'jumlah': item.jumlah,
                  'qty': item.jumlah,
                  'diskon_persen': _diskonPersen,
                  'harga': item.produk.hargaJual,
                  'harga_satuan': item.produk.hargaJual,
                  'subtotal': item.subtotal,
                })
            .toList(),
      };

      final response = await ApiService.post('/penjualan', payload);
      final resData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isProcessing = false;
        notifyListeners();
        return true;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        _errorMessage =
            'Sesi login tidak valid atau bukan akun Kasir. Silakan klik Keluar lalu login kembali.';
      } else {
        String detailError = '';
        if (resData is Map && resData['errors'] is Map) {
          final errors = resData['errors'] as Map;
          if (errors.isNotEmpty) {
            final firstVal = errors.values.first;
            detailError =
                firstVal is List ? ' (${firstVal.first})' : ' ($firstVal)';
          }
        }
        _errorMessage =
            '${resData['message'] ?? 'Gagal memproses transaksi'}$detailError';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan koneksi saat memproses transaksi: $e';
    }

    _isProcessing = false;
    notifyListeners();
    return false;
  }
}
