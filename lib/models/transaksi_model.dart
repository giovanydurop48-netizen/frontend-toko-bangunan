class DetailTransaksiModel {
  final int id;
  final int produkId;
  final String namaProduk;
  final String satuan;
  final int jumlah;
  final double harga;
  final double subtotal;

  DetailTransaksiModel({
    required this.id,
    required this.produkId,
    required this.namaProduk,
    required this.satuan,
    required this.jumlah,
    required this.harga,
    required this.subtotal,
  });

  factory DetailTransaksiModel.fromJson(Map<String, dynamic> json) {
    return DetailTransaksiModel(
      id: json['id'] ?? 0,
      produkId: json['produk_id'] ?? 0,
      namaProduk: json['produk']?['nama_produk'] ?? json['nama_produk'] ?? 'Produk',
      satuan: json['produk']?['satuan'] ?? 'pcs',
      jumlah: json['jumlah'] ?? 0,
      harga: (json['harga'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }
}

class TransaksiModel {
  final int id;
  final String kodeTransaksi;
  final double totalKotor;
  final double diskonPersen;
  final double totalBayar;
  final double nominalBayar;
  final double kembalian;
  final String createdAt;
  final List<DetailTransaksiModel> items;

  TransaksiModel({
    required this.id,
    required this.kodeTransaksi,
    required this.totalKotor,
    required this.diskonPersen,
    required this.totalBayar,
    required this.nominalBayar,
    required this.kembalian,
    required this.createdAt,
    required this.items,
  });

  factory TransaksiModel.fromJson(Map<String, dynamic> json) {
    var list = json['details'] as List? ?? json['items'] as List? ?? [];
    List<DetailTransaksiModel> itemList =
        list.map((i) => DetailTransaksiModel.fromJson(i)).toList();

    return TransaksiModel(
      id: json['id'] ?? 0,
      kodeTransaksi: json['kode_transaksi'] ?? '-',
      totalKotor: (json['total_kotor'] as num).toDouble(),
      diskonPersen: (json['diskon_persen'] as num).toDouble(),
      totalBayar: (json['total_bayar'] as num).toDouble(),
      nominalBayar: (json['nominal_bayar'] as num).toDouble(),
      kembalian: (json['kembalian'] as num).toDouble(),
      createdAt: json['created_at'] ?? '',
      items: itemList,
    );
  }
}