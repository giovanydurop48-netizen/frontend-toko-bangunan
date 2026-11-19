import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class PrinterService {
  final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;

  Future<List<BluetoothDevice>> getPairedDevices() async {
    try {
      return await _bluetooth.getBondedDevices();
    } catch (e) {
      return [];
    }
  }

  Future<bool> cetakStruk({
    required BluetoothDevice device,
    required Map<String, dynamic> dataTransaksi,
  }) async {
    try {
      bool? isConnected = await _bluetooth.isConnected;
      if (isConnected != true) {
        await _bluetooth.connect(device);
      }

      // Ukuran Teks: 0 = Normal, 1 = Sedang, 2 = Besar, 3 = Sangat Besar
      // Alignment: 0 = Kiri, 1 = Tengah, 2 = Kanan

      // Header Toko
      _bluetooth.printCustom("TOKO BANGUNAN POS", 2, 1);
      _bluetooth.printCustom("Jl. Raya Material No. 123", 0, 1);
      _bluetooth.printCustom("Telp: 0812-3456-7890", 0, 1);
      _bluetooth.printCustom("--------------------------------", 0, 1);

      // Detail Transaksi
      _bluetooth.printLeftRight("No. TRX:", dataTransaksi['kode_transaksi'], 0);
      _bluetooth.printLeftRight("Tanggal:", DateTime.now().toString().substring(0, 16), 0);
      _bluetooth.printCustom("--------------------------------", 0, 1);

      // List Barang Belanjaan
      final items = dataTransaksi['items'] as List;
      for (var item in items) {
        final namaProduk = item.produk.namaProduk;
        final qty = item.jumlah;
        final harga = item.produk.hargaJual.toStringAsFixed(0);
        final subtotal = item.subtotal.toStringAsFixed(0);

        _bluetooth.printCustom(namaProduk, 0, 0);
        _bluetooth.printLeftRight("  $qty x Rp $harga", "Rp $subtotal", 0);
      }

      _bluetooth.printCustom("--------------------------------", 0, 1);

      // Total & Pembayaran
      final totalKotor = dataTransaksi['total_kotor'].toStringAsFixed(0);
      final diskon = dataTransaksi['diskon_persen'].toStringAsFixed(0);
      final totalBayar = dataTransaksi['total_bayar'].toStringAsFixed(0);
      final nominalBayar = dataTransaksi['nominal_bayar'].toStringAsFixed(0);
      final kembalian = dataTransaksi['kembalian'].toStringAsFixed(0);

      _bluetooth.printLeftRight("Subtotal:", "Rp $totalKotor", 0);
      if (dataTransaksi['diskon_persen'] > 0) {
        _bluetooth.printLeftRight("Diskon ($diskon%):", "- Rp ${(dataTransaksi['total_kotor'] * dataTransaksi['diskon_persen'] / 100).toStringAsFixed(0)}", 0);
      }
      _bluetooth.printLeftRight("TOTAL:", "Rp $totalBayar", 1);
      _bluetooth.printLeftRight("Bayar:", "Rp $nominalBayar", 0);
      _bluetooth.printLeftRight("Kembali:", "Rp $kembalian", 0);

      // Footer
      _bluetooth.printCustom("--------------------------------", 0, 1);
      _bluetooth.printCustom("Terima Kasih Atas Kunjungan Anda", 0, 1);
      _bluetooth.printCustom("Barang yang sudah dibeli", 0, 1);
      _bluetooth.printCustom("tidak dapat dikembalikan.", 0, 1);
      _bluetooth.printNewLine();
      _bluetooth.printNewLine();

      return true;
    } catch (e) {
      return false;
    }
  }
}