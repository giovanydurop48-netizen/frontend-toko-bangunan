import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/transaksi_model.dart';
import '../../services/api_services.dart';
import '../../widgets/struk_dialog.dart';

class RiwayatTransaksiScreen extends StatefulWidget {
  const RiwayatTransaksiScreen({super.key});

  @override
  State<RiwayatTransaksiScreen> createState() => _RiwayatTransaksiScreenState();
}

class _RiwayatTransaksiScreenState extends State<RiwayatTransaksiScreen> {
  List<TransaksiModel> _listTransaksi = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRiwayat();
  }

  Future<void> _fetchRiwayat() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.get('/transaksi/riwayat');
      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        final List data = resData['data'] ?? [];
        setState(() {
          _listTransaksi = data.map((json) => TransaksiModel.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat riwayat transaksi';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan koneksi';
        _isLoading = false;
      });
    }
  }

  void _cetakUlangStruk(TransaksiModel tx) {
    final payloadStruk = {
      'kode_transaksi': tx.kodeTransaksi,
      'total_kotor': tx.totalKotor,
      'diskon_persen': tx.diskonPersen,
      'total_bayar': tx.totalBayar,
      'nominal_bayar': tx.nominalBayar,
      'kembalian': tx.kembalian,
      'items': tx.items,
    };

    showDialog(
      context: context,
      builder: (_) => StrukDialog(
        dataTransaksi: payloadStruk,
        onSuccess: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi Penjualan'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRiwayat,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _fetchRiwayat,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _listTransaksi.isEmpty
                  ? const Center(child: Text('Belum ada riwayat transaksi'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _listTransaksi.length,
                      itemBuilder: (context, index) {
                        final tx = _listTransaksi[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ExpansionTile(
                            leading: const Icon(Icons.receipt_long, color: Colors.blueAccent),
                            title: Text(
                              tx.kodeTransaksi,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Total: Rp ${tx.totalBayar.toStringAsFixed(0)}'),
                            trailing: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              ),
                              onPressed: () => _cetakUlangStruk(tx),
                              icon: const Icon(Icons.print, size: 16),
                              label: const Text('Struk', style: TextStyle(fontSize: 12)),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Rincian Barang:',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                    const SizedBox(height: 6),
                                    ...tx.items.map(
                                      (item) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '• ${item.namaProduk} (${item.jumlah} ${item.satuan})',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                            Text(
                                              'Rp ${item.subtotal.toStringAsFixed(0)}',
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Divider(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Bayar: Rp ${tx.nominalBayar.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                        Text('Kembali: Rp ${tx.kembalian.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Colors.green)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}