import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jariksa/core/pages/main_page.dart';
import 'package:jariksa/core/storage/token_storage.dart';
import 'package:jariksa/core/theme/color_value.dart';
import 'package:jariksa/features/auth/view/login_page.dart';

/// Halaman Splash Screen yang mengarahkan pengguna secara otomatis
/// ke MainPage (jika sudah login/ada token) atau LoginPage (jika belum).
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Delay 2 detik agar transisi visual logo terlihat halus
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Periksa status token menggunakan TokenStorage
    final hasToken = await TokenStorage.hasToken();

    if (!mounted) return;

    if (hasToken) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainPage()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorValue.primary800,
              ColorValue.primary600,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Aplikasi
              Image.asset(
                "assets/images/jariksa_logo.png",
                width: 140.w,
              ),
              SizedBox(height: 32.h),
              // Indikator Loading Simpel
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
