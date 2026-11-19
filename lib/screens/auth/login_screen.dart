import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isDarkMode = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final inputUser = _usernameController.text.trim();
      final password = _passwordController.text;

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': inputUser,
          'username': inputUser,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          (data['success'] == true ||
              data['status'] == 'success' ||
              data['token'] != null ||
              data['access_token'] != null)) {
        if (!mounted) return;
        // Sesuaikan '/kasir' dengan nama route halaman kasir di lib/main.dart (misal '/pos' atau '/home')
        Navigator.pushReplacementNamed(context, '/kasir');
      } else {
        if (!mounted) return;
        final pesan = data['message'] ?? 'Email/Username atau password salah.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(pesan),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal terhubung ke server: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Palet warna identik dengan Dashboard Admin & Owner TB. Maju Jaya
    final bgColor =
        _isDarkMode ? const Color(0xFF140E0A) : const Color(0xFFF4F1EC);
    final cardColor = _isDarkMode ? const Color(0xFF1F1610) : Colors.white;
    final sidebarStart =
        _isDarkMode ? const Color(0xFF18100B) : const Color(0xFF231810);
    final sidebarEnd =
        _isDarkMode ? const Color(0xFF2B1D14) : const Color(0xFF332318);
    final primaryColor =
        _isDarkMode ? const Color(0xFFB45D1E) : const Color(0xFF9A4E16);
    final goldColor =
        _isDarkMode ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B);
    final textColor =
        _isDarkMode ? const Color(0xFFF5EFEA) : const Color(0xFF1F1915);
    final mutedColor =
        _isDarkMode ? const Color(0xFFA89E96) : const Color(0xFF6E655F);
    final borderColor =
        _isDarkMode ? const Color(0xFF36281E) : const Color(0xFFE5DFD6);
    final inputFill =
        _isDarkMode ? const Color(0xFF271C14) : const Color(0xFFFAF8F5);

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF231810)
                        .withOpacity(_isDarkMode ? 0.35 : 0.10),
                    blurRadius: 36,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 720;

                  final brandPanel = Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [sidebarStart, sidebarEnd],
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: goldColor.withOpacity(0.16),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: goldColor.withOpacity(0.35)),
                                  ),
                                  child: Icon(Icons.storefront_rounded,
                                      color: goldColor, size: 26),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'TB. Maju Jaya',
                                      style: TextStyle(
                                        color: goldColor,
                                        fontSize: 21,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'Sistem Kasir & POS',
                                      style: TextStyle(
                                          color: Color(0xFFC7BBAE),
                                          fontSize: 12.5),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Aplikasi kasir terpadu untuk transaksi penjualan material bangunan, pencetakan struk, dan sinkronisasi stok gudang.',
                              style: TextStyle(
                                color: Color(0xFFD8CFC6),
                                fontSize: 13,
                                height: 1.55,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildFeaturePill(Icons.point_of_sale_rounded,
                                'Transaksi Kasir Cepat & Akurat', goldColor),
                            const SizedBox(height: 10),
                            _buildFeaturePill(Icons.inventory_2_outlined,
                                'Stok Otomatis Terpotong Real-Time', goldColor),
                            const SizedBox(height: 10),
                            _buildFeaturePill(Icons.receipt_long_rounded,
                                'Riwayat Struk & Laporan Harian', goldColor),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 28),
                          child: Text(
                            '© TB. Maju Jaya • Terminal Kasir',
                            style: TextStyle(
                                color: Color(0xFFB5A89C), fontSize: 11.5),
                          ),
                        ),
                      ],
                    ),
                  );

                  final formPanel = Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 34, vertical: 38),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'POS Toko Bangunan',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Login Khusus Kasir',
                                      style: TextStyle(
                                          color: mutedColor, fontSize: 13.5),
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () =>
                                    setState(() => _isDarkMode = !_isDarkMode),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: inputFill,
                                  foregroundColor: textColor,
                                  side: BorderSide(color: borderColor),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: Icon(
                                  _isDarkMode
                                      ? Icons.wb_sunny_rounded
                                      : Icons.nightlight_round,
                                  size: 16,
                                  color: goldColor,
                                ),
                                label: Text(
                                  _isDarkMode ? 'Mode Terang' : 'Mode Gelap',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'Username / Email',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _usernameController,
                            style: TextStyle(color: textColor, fontSize: 14.5),
                            decoration: InputDecoration(
                              hintText: 'Masukkan username atau email kasir...',
                              hintStyle:
                                  TextStyle(color: mutedColor, fontSize: 13.5),
                              prefixIcon: Icon(Icons.person_outline_rounded,
                                  color: mutedColor),
                              filled: true,
                              fillColor: inputFill,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 15),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: borderColor, width: 1.4),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: primaryColor, width: 1.8),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 1.4),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 1.8),
                              ),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Username atau email wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Password',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: TextStyle(color: textColor, fontSize: 14.5),
                            onFieldSubmitted: (_) => _handleLogin(),
                            decoration: InputDecoration(
                              hintText: 'Masukkan password akun...',
                              hintStyle:
                                  TextStyle(color: mutedColor, fontSize: 13.5),
                              prefixIcon: Icon(Icons.lock_outline_rounded,
                                  color: mutedColor),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: mutedColor,
                                ),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                              filled: true,
                              fillColor: inputFill,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 15),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: borderColor, width: 1.4),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: primaryColor, width: 1.8),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 1.4),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 1.8),
                              ),
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Password wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 26),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.login_rounded, size: 20),
                              label: Text(
                                _isLoading ? 'MEMPROSES...' : 'MASUK KASIR',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  fontSize: 14.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  if (isWide) {
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 5, child: brandPanel),
                          Expanded(flex: 6, child: formPanel),
                        ],
                      ),
                    );
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      brandPanel,
                      formPanel,
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturePill(IconData icon, String label, Color goldColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          Icon(icon, color: goldColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFFEAE2DA), fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}
