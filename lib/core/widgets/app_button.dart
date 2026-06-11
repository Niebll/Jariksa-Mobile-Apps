import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jariksa/core/theme/app_fontweight.dart';
import 'package:jariksa/core/theme/app_typography.dart';
import 'package:jariksa/core/theme/color_value.dart';

/// Custom button reusable untuk seluruh halaman di JaRiksa.
///
/// Memiliki 3 tampilan yang dikontrol oleh 2 boolean:
///
/// | isActive | isFilled | Tampilan                                        |
/// |----------|----------|-------------------------------------------------|
/// | false    | (any)    | **Disabled** — abu-abu, tidak bisa ditekan      |
/// | true     | true     | **Solid** — bg primary500, teks putih (default) |
/// | true     | false    | **Outline** — border primary500, teks primary   |
///
/// Semua warna bisa di-override via parameter opsional.
///
/// Contoh penggunaan:
/// ```dart
/// // Tombol aktif solid (default)
/// AppButton(label: 'Masuk', onPressed: _handleLogin);
///
/// // Tombol outline
/// AppButton(label: 'Batal', onPressed: _handleCancel, isFilled: false);
///
/// // Tombol disabled
/// AppButton(label: 'Masuk', onPressed: _handleLogin, isActive: false);
///
/// // Warna custom
/// AppButton(
///   label: 'Hapus',
///   onPressed: _handleDelete,
///   backgroundColor: ColorValue.orange500,
/// );
/// ```
class AppButton extends StatelessWidget {
  /// Teks yang ditampilkan di dalam tombol
  final String label;

  /// Callback saat tombol ditekan.
  /// Nilai ini tetap diperlukan meski [isActive] = false — hanya tidak akan dipanggil.
  final VoidCallback? onPressed;

  /// Jika false, tombol tampil abu-abu dan tidak bisa ditekan (disabled state).
  /// Default: true
  final bool isActive;

  /// Jika true, tombol tampil solid (bg terisi). Jika false, tampil outline (border saja).
  /// Hanya berlaku saat [isActive] = true.
  /// Default: true
  final bool isFilled;

  // ── Override warna ──────────────────────────────────────────────────
  /// Override warna background (hanya untuk solid/filled state)
  final Color? backgroundColor;

  /// Override warna teks
  final Color? textColor;

  /// Override warna border (hanya untuk outline state)
  final Color? borderColor;

  /// Optional icon to show in front of the text label
  final Widget? icon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isActive = true,
    this.isFilled = true,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // ── Tentukan nilai warna berdasarkan state ──────────────────────
    final Color resolvedBg;
    final Color resolvedText;
    final BorderSide resolvedBorder;

    if (!isActive) {
      // State 1: Disabled — abu-abu
      resolvedBg = ColorValue.neutral200;
      resolvedText = ColorValue.neutral500;
      resolvedBorder = BorderSide.none;
    } else if (isFilled) {
      // State 2: Active + Solid
      resolvedBg = backgroundColor ?? ColorValue.primary500;
      resolvedText = textColor ?? Colors.white;
      resolvedBorder = BorderSide.none;
    } else {
      // State 3: Active + Outline
      resolvedBg = backgroundColor ?? Colors.transparent;
      resolvedText = textColor ?? ColorValue.primary500;
      resolvedBorder = BorderSide(
        color: borderColor ?? ColorValue.primary500,
        width: 1.5,
      );
    }

    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: isActive ? onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: resolvedBg,
            borderRadius: BorderRadius.circular(35.r),
            border: Border.fromBorderSide(resolvedBorder),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  icon!,
                  SizedBox(width: 8.w),
                ],
                Text(
                  label,
                  style: AppTypography.body02.copyWith(
                    fontWeight: AppFontWeight.semiBold,
                    color: resolvedText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
