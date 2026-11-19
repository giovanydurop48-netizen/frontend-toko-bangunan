class ProdukModel {
  final int id;
  final String kodeProduk;
  final String namaProduk;
  final String namaKategori;
  final double hargaJual;
  final double stok;
  final String satuan;

  ProdukModel({
    required this.id,
    required this.kodeProduk,
    required this.namaProduk,
    required this.namaKategori,
    required this.hargaJual,
    required this.stok,
    required this.satuan,
  });

  factory ProdukModel.fromJson(Map<String, dynamic> json) {
    return ProdukModel(
      id: json['id'],
      kodeProduk: json['kode_produk'] ?? '',
      namaProduk: json['nama_produk'] ?? '',
      namaKategori: json['kategori']?['nama_kategori'] ?? 'Umum',
      hargaJual: double.parse(json['harga_jual'].toString()),
      stok: double.parse(json['stok'].toString()),
      satuan: json['satuan'] ?? 'pcs',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode_produk': kodeProduk,
      'nama_produk': namaProduk,
      'harga_jual': hargaJual,
      'stok': stok,
      'satuan': satuan,
    };
  }
}