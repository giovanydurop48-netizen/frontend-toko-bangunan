import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend_toko_bangunan/providers/auth_provider.dart';
import 'package:frontend_toko_bangunan/providers/produk_provider.dart';
import 'package:frontend_toko_bangunan/providers/pos_provider.dart';
import 'package:frontend_toko_bangunan/screens/auth/login_screen.dart';
import 'package:frontend_toko_bangunan/screens/pos/pos_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProdukProvider()),
        ChangeNotifierProvider(create: (_) => PosProvider()),
      ],
      child: MaterialApp(
        title: 'POS Toko Bangunan',
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/pos': (context) => const PosScreen(),
          '/kasir': (context) => const PosScreen(),
        },
      ),
    );
  }
}
