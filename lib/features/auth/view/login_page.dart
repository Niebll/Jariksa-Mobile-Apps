import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jariksa/core/pages/main_page.dart';
import 'package:jariksa/core/theme/app_fontweight.dart';
import 'package:jariksa/core/theme/app_typography.dart';
import 'package:jariksa/core/theme/color_value.dart';
import 'package:jariksa/core/widgets/app_button.dart';
import 'package:jariksa/core/widgets/app_text_field.dart';
import 'package:jariksa/features/auth/cubit/login_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers untuk membaca nilai field saat submit
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // State tombol: aktif jika email & password tidak kosong
  bool _isFormValid = false;

  void _onFieldChanged() {
    final isValid =
        _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    if (isValid != _isFormValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  // FocusNode untuk navigasi antar field via keyboard
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Pasang listener agar tombol aktif/nonaktif saat user mengetik
    _emailController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
  }

  /// Dipanggil saat tombol Masuk ditekan.
  void _handleLogin() {
    context.read<LoginCubit>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  void dispose() {
    _emailController.removeListener(_onFieldChanged);
    _passwordController.removeListener(_onFieldChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _showTopSnackBar(BuildContext context, String message, {bool isError = false}) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final screenHeight = mediaQuery.size.height;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: screenHeight - topPadding - 80.h,
          left: 20.w,
          right: 20.w,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainPage()),
            );
          } else if (state is LoginError) {
            _showTopSnackBar(context, state.message, isError: true);
          }
        },
        builder: (context, state) {
          final isLoading = state is LoginLoading;
          return Scaffold(
            resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // =========================================
          // LAYER 1: BACKGROUND GRADIENT (FULL SCREEN)
          // Berbeda dengan home_page yang hanya 271.h,
          // di sini gradient memenuhi seluruh tinggi layar.
          // Arah: atas (primary800/gelap) → bawah (putih)
          // =========================================
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ColorValue.primary800, // 0% — paling gelap di atas
                  ColorValue.primary400, // 50% — medium blue
                  Colors.white, // 100% — putih di bawah
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // =========================================
          // LAYER 2: KONTEN UTAMA
          // Tambahkan konten login di sini
          // =========================================
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset("assets/images/login_1.png", height: 168.h),
          ),
          SafeArea(
            child: Column(
              children: [
                // ---- Header: Logo + Judul ----
                SizedBox(height: 42.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 44.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/images/jariksa_logo.png",
                        width: 94.w,
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "Selamat Datang Kembali!",
                        style: AppTypography.heading03.copyWith(
                          fontWeight: AppFontWeight.semiBold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Pantau operasional dan lindungi usaha Anda hari ini.",
                        style: AppTypography.body03.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontWeight: AppFontWeight.regular,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 44.h),

                // ---- White Card ----
                // Expanded memberi tinggi terbatas ke Container → Spacer bisa bekerja
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 22.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32.r),
                        topRight: Radius.circular(32.r),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 20.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Column(
                            children: [
                              AppTextField(
                                label: 'Email',
                                hint: 'Masukkan email',
                                controller: _emailController,
                                focusNode: _emailFocusNode,
                                prefixIcon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                onChanged: (value) {},
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email tidak boleh kosong';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Format email tidak valid';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: 16.h),

                              AppTextField(
                                label: 'Kata Sandi',
                                hint: 'Masukkan kata sandi',
                                controller: _passwordController,
                                focusNode: _passwordFocusNode,
                                prefixIcon: Icons.lock_outline_rounded,
                                isPassword: true,
                                keyboardType: TextInputType.visiblePassword,
                                textInputAction: TextInputAction.done,
                                onChanged: (value) {},
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Kata sandi tidak boleh kosong';
                                  }
                                  if (value.length < 6) {
                                    return 'Kata sandi minimal 6 karakter';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),

                        AppButton(
                          label: isLoading ? 'Memproses...' : 'Masuk',
                          onPressed: (_isFormValid && !isLoading)
                              ? _handleLogin
                              : null,
                          isActive: _isFormValid && !isLoading,
                        ),
                        SizedBox(height: 20.h),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Belum punya akun? ",
                                style: AppTypography.body02.copyWith(
                                  fontWeight: AppFontWeight.medium,
                                  color: ColorValue.neutral700,
                                ),
                              ),
                              Text(
                                "Daftar",
                                style: AppTypography.body02.copyWith(
                                  fontWeight: AppFontWeight.semiBold,
                                  color: ColorValue.primary800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
        },
      );
  }
}

