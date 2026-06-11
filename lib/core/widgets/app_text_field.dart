import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jariksa/core/theme/app_fontweight.dart';
import 'package:jariksa/core/theme/app_typography.dart';
import 'package:jariksa/core/theme/color_value.dart';

/// Widget TextField reusable untuk seluruh halaman di JaRiksa.
///
/// Spesifikasi:
/// - Label: body03, medium, neutral800
/// - Border radius: 8.r, stroke neutral300 weight 1 (default), primary500 (focused)
/// - Content padding: 12 semua sisi
/// - Prefix icon: 24×24, gap 12 ke teks
/// - Warna ikon & hint: neutral500 (default) → primary500 (focused)
///
/// Siap integrasi API:
/// - [controller] untuk membaca/menulis nilai field
/// - [onChanged] dipanggil setiap karakter berubah
/// - [validator] untuk validasi form (gunakan di dalam [Form] + [GlobalKey<FormState>])
/// - [textInputAction] untuk kontrol keyboard (next, done, dll)
/// - [keyboardType] untuk tipe keyboard yang sesuai (email, number, dll)
class AppTextField extends StatefulWidget {
  /// Teks label yang muncul di atas field
  final String label;

  /// Teks placeholder di dalam field
  final String hint;

  /// Controller untuk membaca dan mengontrol nilai field
  final TextEditingController controller;

  /// Ikon di sebelah kiri dalam field (ukuran 24×24)
  final IconData prefixIcon;

  /// Jika true, field menjadi mode password (karakter disembunyikan + toggle mata)
  final bool isPassword;

  /// Callback dipanggil setiap kali nilai field berubah
  final ValueChanged<String>? onChanged;

  /// Fungsi validasi. Return null jika valid, return String pesan error jika tidak valid.
  /// Wajib digunakan dalam widget [Form] + [GlobalKey<FormState>].
  final String? Function(String?)? validator;

  /// Tipe keyboard yang muncul (contoh: TextInputType.emailAddress)
  final TextInputType? keyboardType;

  /// Aksi tombol "Enter" di keyboard (next, done, dll)
  final TextInputAction? textInputAction;

  /// FocusNode eksternal (opsional). Berguna untuk mengontrol fokus antar field.
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.prefixIcon,
    this.isPassword = false,
    this.onChanged,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _isObscured = true; // Hanya relevan jika isPassword = true
  bool _hasText = false;   // True jika field sudah ada isinya (filled state)

  @override
  void initState() {
    super.initState();
    // Gunakan FocusNode dari luar jika ada, atau buat yang baru
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
    // Listen controller agar warna ikut berubah saat ada / tidak ada teks
    widget.controller.addListener(_handleTextChange);
  }

  void _handleFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  void _handleTextChange() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    // Hanya dispose FocusNode yang kita buat sendiri (bukan dari luar)
    if (widget.focusNode == null) {
      _focusNode.removeListener(_handleFocusChange);
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Warna dinamis:
    // - neutral500 → idle & kosong
    // - primary500 → sedang fokus ATAU sudah ada isi (filled)
    final Color dynamicColor =
        (_isFocused || _hasText) ? ColorValue.primary500 : ColorValue.neutral500;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- Label di atas field ----
        Text(
          widget.label,
          style: AppTypography.body03.copyWith(
            fontWeight: AppFontWeight.medium,
            color: ColorValue.neutral800,
          ),
        ),
        SizedBox(height: 6.h),

        // ---- TextField ----
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.isPassword && _isObscured,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          validator: widget.validator,
          style: AppTypography.body02.copyWith(
            fontWeight: AppFontWeight.medium,
            color: ColorValue.primary500,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTypography.body02.copyWith(
              fontWeight: AppFontWeight.medium,
              color: ColorValue.neutral500,
            ),

            // Padding dalam field: 12 semua sisi
            contentPadding: EdgeInsets.all(12.w),

            // Prefix icon 24×24 dengan gap 12 ke kanan
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 12.w, right: 12.w),
              child: Icon(widget.prefixIcon, size: 24.w, color: dynamicColor),
            ),
            // Hapus constraint default agar padding prefix bisa dikontrol manual
            prefixIconConstraints: const BoxConstraints(),

            // Suffix icon toggle password (hanya muncul jika isPassword = true)
            suffixIcon: widget.isPassword
                ? GestureDetector(
                    onTap: () =>
                        setState(() => _isObscured = !_isObscured),
                    child: Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: Icon(
                        _isObscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 24.w,
                        color: dynamicColor,
                      ),
                    ),
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(),

            // Border: ikut dynamicColor — neutral300 (kosong) atau primary500 (filled/focused)
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: dynamicColor, width: 1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: dynamicColor, width: 1),
              borderRadius: BorderRadius.circular(8.r),
            ),

            // Border error: merah, weight 1
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
      ],
    );
  }
}
