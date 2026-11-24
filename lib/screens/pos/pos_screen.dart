import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend_toko_bangunan/widgets/struk_dialog.dart';
import 'package:frontend_toko_bangunan/providers/produk_provider.dart';
import 'package:frontend_toko_bangunan/providers/pos_provider.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedKategori = 'Semua';

  // Palet Warna Selaras Dashboard Admin (TB. Maju Jaya)
  static const Color _adminDark = Color(0xFF1F1D1B);
  static const Color _adminPrimary =
      Color(0xFF9E3F12); // Terakota / Cokelat Bata
  static const Color _adminPrimarySoft = Color(0xFFFFF7ED);
  static const Color _adminPrimaryBorder = Color(0xFFFED7AA);
  static const Color _adminAmber = Color(0xFFF59E0B);
  static const Color _adminGreen = Color(0xFF15803D); // Hijau Tombol Transaksi
  static const Color _adminBg = Color(0xFFF5F5F4);
  static const Color _adminBorder = Color(0xFFE7E5E4);
  static const Color _adminTextDark = Color(0xFF1C1917);
  static const Color _adminTextMuted = Color(0xFF57534E);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProdukProvider>(context, listen: false).fetchProduk();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatRupiah(num nominal) {
    final int angka = nominal.round();
    final String str = angka.abs().toString();
    final String formatted = str.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return '${angka < 0 ? '-' : ''}Rp $formatted';
  }

  String _formatStok(num stok) {
    return stok % 1 == 0 ? stok.toInt().toString() : stok.toString();
  }

  @override
  Widget build(BuildContext context) {
    final produkProvider = Provider.of<ProdukProvider>(context);
    final posProvider = Provider.of<PosProvider>(context);

    // Kategori utama selalu tampil + kategori lain dari database
    // Kategori utama selalu tampil + kategori lain dari database
    final Map<String, String> kategoriMap = {
      'semua': 'Semua',
      'bahan mentah': 'Bahan Mentah',
      'bahan siap pakai': 'Bahan Siap Pakai',
    };
    for (final p in produkProvider.produkList) {
      final raw = p.namaKategori.trim();
      if (raw.isNotEmpty) {
        kategoriMap.putIfAbsent(raw.toLowerCase(), () => raw);
      }
    }
    final List<String> daftarKategori = kategoriMap.values.toList();

    // Hitung jumlah produk per kategori
    int hitungPerKategori(String kat) {
      if (kat.toLowerCase() == 'semua') {
        return produkProvider.produkList.length;
      }
      return produkProvider.produkList
          .where(
              (p) => p.namaKategori.trim().toLowerCase() == kat.toLowerCase())
          .length;
    }

    // Filter daftar produk sesuai kategori terpilih
    final filteredProduk = _selectedKategori.toLowerCase() == 'semua'
        ? produkProvider.produkList
        : produkProvider.produkList
            .where((p) =>
                p.namaKategori.trim().toLowerCase() ==
                _selectedKategori.toLowerCase())
            .toList();

    return Scaffold(
      backgroundColor: _adminBg,
      appBar: AppBar(
        backgroundColor: _adminDark,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: _adminAmber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _adminAmber.withOpacity(0.5)),
              ),
              child: const Icon(
                Icons.apartment_rounded,
                color: _adminAmber,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TB. Maju Jaya',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Point of Sale (POS) Kasir',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFA8A29E),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: OutlinedButton.icon(
              onPressed: () => produkProvider.fetchProduk(),
              icon: const Icon(Icons.refresh_rounded,
                  size: 16, color: _adminAmber),
              label: const Text(
                'Refresh Stok',
                style: TextStyle(
                    color: _adminAmber,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _adminAmber.withOpacity(0.6)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: OutlinedButton.icon(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/login'),
              icon: Icon(Icons.logout_rounded,
                  size: 16, color: Colors.red.shade300),
              label: Text(
                'Keluar',
                style: TextStyle(
                    color: Colors.red.shade300,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red.shade400.withOpacity(0.7)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // =================================================================
            // PANEL KIRI: Katalog Material Bangunan
            // =================================================================
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kartu Pencarian & Tab Filter Kategori
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _adminBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) {
                                  setState(() {});
                                  produkProvider.cariProduk(val);
                                },
                                decoration: InputDecoration(
                                  hintText:
                                      'Cari nama material / kode produk...',
                                  hintStyle: const TextStyle(
                                      color: Color(0xFF78716C), fontSize: 13),
                                  prefixIcon: const Icon(Icons.search_rounded,
                                      size: 20, color: _adminPrimary),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear_rounded,
                                              size: 18, color: _adminTextMuted),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() {});
                                            produkProvider.cariProduk('');
                                          },
                                        )
                                      : null,
                                  filled: true,
                                  fillColor: const Color(0xFFFAFAF9),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 11),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFD6D3D1)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: _adminPrimary, width: 1.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: _adminPrimarySoft,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: _adminPrimaryBorder),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.inventory_2_rounded,
                                      size: 16, color: _adminPrimary),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${filteredProduk.length} Item',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: _adminPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Bar Filter Kategori: Semua | Barang Mentah | Bahan Siap Pakai
                        SizedBox(
                          height: 36,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: daftarKategori.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, idx) {
                              final kat = daftarKategori[idx];
                              final bool isSelected =
                                  _selectedKategori.toLowerCase() ==
                                      kat.toLowerCase();
                              final int jumlahKat = hitungPerKategori(kat);

                              IconData katIcon = Icons.category_rounded;
                              if (kat.toLowerCase() == 'semua') {
                                katIcon = Icons.grid_view_rounded;
                              } else if (kat.toLowerCase() == 'barang mentah') {
                                katIcon = Icons.layers_rounded;
                              } else if (kat.toLowerCase() ==
                                  'bahan siap pakai') {
                                katIcon = Icons.handyman_rounded;
                              }

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedKategori = kat;
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? _adminPrimary
                                        : const Color(0xFFFAFAF9),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? _adminPrimary
                                          : const Color(0xFFD6D3D1),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        katIcon,
                                        size: 15,
                                        color: isSelected
                                            ? Colors.white
                                            : _adminPrimary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        kat,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : _adminTextDark,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.white.withOpacity(0.22)
                                              : const Color(0xFFE7E5E4),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '$jumlahKat',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.white
                                                : _adminTextMuted,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Grid Kartu Material
                  Expanded(
                    child: produkProvider.isLoading
                        ? const Center(
                            child:
                                CircularProgressIndicator(color: _adminPrimary))
                        : produkProvider.errorMessage != null
                            ? Center(
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _adminBorder),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.error_outline_rounded,
                                          size: 40, color: Colors.red.shade600),
                                      const SizedBox(height: 8),
                                      Text(
                                        produkProvider.errorMessage!,
                                        style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontSize: 14),
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _adminPrimary,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () =>
                                            produkProvider.fetchProduk(),
                                        icon:
                                            const Icon(Icons.refresh, size: 18),
                                        label: const Text('Coba Lagi'),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : filteredProduk.isEmpty
                                ? Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(28),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: _adminBorder),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.inventory_2_outlined,
                                              size: 44,
                                              color: Colors.grey.shade400),
                                          const SizedBox(height: 10),
                                          Text(
                                            'Belum ada material pada kategori "$_selectedKategori"',
                                            style: const TextStyle(
                                              color: _adminTextDark,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          if (_selectedKategori.toLowerCase() !=
                                              'semua') ...[
                                            const SizedBox(height: 12),
                                            OutlinedButton(
                                              onPressed: () {
                                                setState(() {
                                                  _selectedKategori = 'Semua';
                                                });
                                              },
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: _adminPrimary,
                                                side: const BorderSide(
                                                    color: _adminPrimary),
                                              ),
                                              child: const Text(
                                                  'Tampilkan Semua Material'),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  )
                                : GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 250,
                                      mainAxisExtent: 164,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                    ),
                                    itemCount: filteredProduk.length,
                                    itemBuilder: (context, index) {
                                      final produk = filteredProduk[index];
                                      final bool stokHabis = produk.stok <= 0;
                                      final bool stokMenipis =
                                          produk.stok > 0 && produk.stok <= 10;

                                      int qtyDiKeranjang = 0;
                                      for (final item
                                          in posProvider.keranjang) {
                                        if (item.produk.id == produk.id) {
                                          qtyDiKeranjang = item.jumlah;
                                          break;
                                        }
                                      }

                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: qtyDiKeranjang > 0
                                                ? _adminPrimary
                                                : _adminBorder,
                                            width: qtyDiKeranjang > 0 ? 1.6 : 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.03),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Strip Atas Kartu: Kategori & Badge Stok
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 7),
                                              decoration: BoxDecoration(
                                                color: qtyDiKeranjang > 0
                                                    ? _adminPrimarySoft
                                                    : const Color(0xFFFAFAF9),
                                                borderRadius: const BorderRadius
                                                    .vertical(
                                                    top: Radius.circular(11)),
                                                border: const Border(
                                                  bottom: BorderSide(
                                                      color: _adminBorder),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      produk.namaKategori
                                                          .toUpperCase(),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        color: _adminTextMuted,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        letterSpacing: 0.4,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 7,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: stokHabis
                                                          ? Colors.red.shade50
                                                          : (stokMenipis
                                                              ? const Color(
                                                                  0xFFFEF3C7)
                                                              : const Color(
                                                                  0xFFDCFCE7)),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    child: Text(
                                                      stokHabis
                                                          ? 'Habis'
                                                          : '${_formatStok(produk.stok)} ${produk.satuan}',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: stokHabis
                                                            ? Colors
                                                                .red.shade700
                                                            : (stokMenipis
                                                                ? const Color(
                                                                    0xFFB45309)
                                                                : _adminGreen),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Isi Tengah & Bawah Kartu
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            produk.namaProduk,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14,
                                                              color:
                                                                  _adminTextDark,
                                                              height: 1.2,
                                                            ),
                                                          ),
                                                        ),
                                                        if (qtyDiKeranjang >
                                                            0) ...[
                                                          const SizedBox(
                                                              width: 6),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        7,
                                                                    vertical:
                                                                        2),
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  _adminPrimary,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            child: Text(
                                                              '${qtyDiKeranjang}x',
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                    const Spacer(),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              'Harga Satuan',
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                color:
                                                                    _adminTextMuted,
                                                              ),
                                                            ),
                                                            Text(
                                                              _formatRupiah(produk
                                                                  .hargaJual),
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                color:
                                                                    _adminPrimary,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 34,
                                                          child: ElevatedButton
                                                              .icon(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  _adminPrimary,
                                                              foregroundColor:
                                                                  Colors.white,
                                                              disabledBackgroundColor:
                                                                  Colors.grey
                                                                      .shade300,
                                                              elevation: 0,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          12),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                            ),
                                                            onPressed: stokHabis
                                                                ? null
                                                                : () => posProvider
                                                                    .tambahProduk(
                                                                        produk),
                                                            icon: const Icon(
                                                                Icons
                                                                    .add_rounded,
                                                                size: 16),
                                                            label: const Text(
                                                              'Tambah',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // =================================================================
            // PANEL KANAN: Keranjang Belanja & Ringkasan Pembayaran
            // =================================================================
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _adminBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Gelap Keranjang Belanja (Selaras Sidebar Admin)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: _adminDark,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(11)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.shopping_bag_rounded,
                                  size: 19, color: _adminAmber),
                              const SizedBox(width: 8),
                              const Text(
                                'Keranjang Belanja',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _adminPrimary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${posProvider.keranjang.length} Item',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (posProvider.keranjang.isNotEmpty)
                            InkWell(
                              onTap: () => posProvider.resetTransaksi(),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade900.withOpacity(0.45),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color:
                                          Colors.red.shade400.withOpacity(0.6)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_sweep_rounded,
                                        size: 14, color: Colors.red.shade200),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Reset',
                                      style: TextStyle(
                                        color: Colors.red.shade200,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Daftar Item Keranjang
                    Expanded(
                      child: posProvider.keranjang.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(20),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAFAF9),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: _adminBorder),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: _adminPrimarySoft,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: _adminPrimaryBorder),
                                        ),
                                        child: const Icon(
                                          Icons.shopping_cart_outlined,
                                          size: 32,
                                          color: _adminPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Keranjang Belanja Kosong',
                                        style: TextStyle(
                                          color: _adminTextDark,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Pilih material di sebelah kiri lalu klik + Tambah',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: _adminTextMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(14),
                              itemCount: posProvider.keranjang.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final item = posProvider.keranjang[index];
                                final double subtotalItem =
                                    item.produk.hargaJual * item.jumlah;

                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFAFAF9),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: _adminBorder),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: _adminPrimarySoft,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                              color: _adminPrimaryBorder),
                                        ),
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: _adminPrimary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.produk.namaProduk,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: _adminTextDark,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${_formatRupiah(item.produk.hargaJual)} × ${item.jumlah} ${item.produk.satuan}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: _adminTextMuted,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              _formatRupiah(subtotalItem),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: _adminPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Kontrol Jumlah (- / +)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(7),
                                          border: Border.all(
                                              color: const Color(0xFFD6D3D1)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            InkWell(
                                              onTap: () =>
                                                  posProvider.ubahJumlah(
                                                      item.produk.id, -1),
                                              borderRadius:
                                                  const BorderRadius.horizontal(
                                                      left: Radius.circular(7)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(6),
                                                child: Icon(
                                                  Icons.remove_rounded,
                                                  color: Colors.red.shade600,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              child: Text(
                                                '${item.jumlah}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                  color: _adminTextDark,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () =>
                                                  posProvider.ubahJumlah(
                                                      item.produk.id, 1),
                                              borderRadius:
                                                  const BorderRadius.horizontal(
                                                      right:
                                                          Radius.circular(7)),
                                              child: const Padding(
                                                padding: EdgeInsets.all(6),
                                                child: Icon(
                                                  Icons.add_rounded,
                                                  color: _adminGreen,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      InkWell(
                                        onTap: () => posProvider.ubahJumlah(
                                            item.produk.id, -item.jumlah),
                                        borderRadius: BorderRadius.circular(6),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Icon(
                                            Icons.close_rounded,
                                            size: 16,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),

                    // Footer Rincian Tagihan & Tombol Bayar
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFAFAF9),
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(11)),
                        border: Border(top: BorderSide(color: _adminBorder)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Subtotal Belanja',
                                style: TextStyle(
                                    fontSize: 12, color: _adminTextMuted),
                              ),
                              Text(
                                _formatRupiah(posProvider.totalKotor),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _adminTextDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text(
                                'Diskon (%):',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: _adminTextDark),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 76,
                                height: 32,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFD6D3D1)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7),
                                      borderSide: const BorderSide(
                                          color: _adminPrimary, width: 1.5),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    hintText: 'Maks 10',
                                    hintStyle: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  onChanged: (val) {
                                    final diskon = double.tryParse(val) ?? 0.0;
                                    posProvider.setDiskon(diskon);
                                  },
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '- ${_formatRupiah(posProvider.nominalDiskon)}',
                                style: TextStyle(
                                  color: Colors.red.shade600,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: _adminPrimarySoft,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _adminPrimaryBorder),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'TOTAL BAYAR',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: _adminTextDark,
                                  ),
                                ),
                                Text(
                                  _formatRupiah(posProvider.totalBayar),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: _adminPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _adminGreen,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: _adminBorder,
                                disabledForegroundColor:
                                    const Color(0xFFA8A29E),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: posProvider.keranjang.isEmpty
                                  ? null
                                  : () => _tampilkanModalPembayaran(
                                      context, posProvider, produkProvider),
                              icon:
                                  const Icon(Icons.payments_rounded, size: 19),
                              label: const Text(
                                'PROSES PEMBAYARAN',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _tampilkanModalPembayaran(
    BuildContext context,
    PosProvider posProvider,
    ProdukProvider produkProvider,
  ) {
    final TextEditingController bayarController = TextEditingController();
    double uangDibayar = 0.0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final total = posProvider.totalBayar;
            final kembalian = uangDibayar - total;
            final isCukup = uangDibayar >= total && total > 0;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              title: const Row(
                children: [
                  Icon(Icons.payment_rounded, color: _adminPrimary),
                  SizedBox(width: 8),
                  Text(
                    'Proses Pembayaran Transaksi',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: _adminTextDark),
                  ),
                ],
              ),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _adminPrimarySoft,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _adminPrimaryBorder),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'TOTAL YANG HARUS DIBAYAR',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _adminTextMuted),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatRupiah(total),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: _adminPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Uang Diterima dari Pembeli (Rp):',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: _adminTextDark),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: bayarController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        prefixText: 'Rp ',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFD6D3D1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: _adminPrimary, width: 1.5),
                        ),
                        hintText: '0',
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          uangDibayar = double.tryParse(val) ?? 0.0;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ActionChip(
                          backgroundColor: _adminPrimarySoft,
                          side: const BorderSide(color: _adminPrimaryBorder),
                          label: const Text('Uang Pas',
                              style: TextStyle(
                                  color: _adminPrimary,
                                  fontWeight: FontWeight.w600)),
                          onPressed: () {
                            setModalState(() {
                              uangDibayar = total;
                              bayarController.text = total.toStringAsFixed(0);
                            });
                          },
                        ),
                        ActionChip(
                          label: const Text('Rp 50.000'),
                          onPressed: () {
                            setModalState(() {
                              uangDibayar = 50000;
                              bayarController.text = '50000';
                            });
                          },
                        ),
                        ActionChip(
                          label: const Text('Rp 100.000'),
                          onPressed: () {
                            setModalState(() {
                              uangDibayar = 100000;
                              bayarController.text = '100000';
                            });
                          },
                        ),
                        ActionChip(
                          label: const Text('Rp 200.000'),
                          onPressed: () {
                            setModalState(() {
                              uangDibayar = 200000;
                              bayarController.text = '200000';
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: _adminBorder),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Kembalian:',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _adminTextDark),
                        ),
                        Text(
                          kembalian < 0 ? 'Rp 0' : _formatRupiah(kembalian),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: kembalian >= 0 ? _adminGreen : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: posProvider.isProcessing
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Batal',
                      style: TextStyle(color: _adminTextMuted)),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCukup ? _adminGreen : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: (!isCukup || posProvider.isProcessing)
                      ? null
                      : () async {
                          final navigator = Navigator.of(dialogContext);
                          final messenger = ScaffoldMessenger.of(context);
                          final currentContext = context;

                          final sukses =
                              await posProvider.prosesPembayaran(uangDibayar);

                          navigator.pop();

                          if (sukses) {
                            produkProvider.fetchProduk();
                            if (mounted) {
                              _tampilkanStrukSukses(currentContext, kembalian,
                                  posProvider, uangDibayar);
                            }
                          } else {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(posProvider.errorMessage ??
                                    'Gagal memproses transaksi'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  icon: posProvider.isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.check_circle_rounded),
                  label: const Text('KONFIRMASI BAYAR',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _tampilkanStrukSukses(
    BuildContext context,
    double kembalian,
    PosProvider posProvider,
    double nominalBayar,
  ) {
    final payloadStruk = {
      'kode_transaksi':
          'TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      'total_kotor': posProvider.totalKotor,
      'diskon_persen': posProvider.diskonPersen,
      'total_bayar': posProvider.totalBayar,
      'nominal_bayar': nominalBayar,
      'kembalian': kembalian,
      'items': List.from(posProvider.keranjang),
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StrukDialog(
        dataTransaksi: payloadStruk,
        onSuccess: () {
          posProvider.resetTransaksi();
        },
      ),
    );
  }
}
