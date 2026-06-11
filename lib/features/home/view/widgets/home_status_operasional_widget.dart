import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jariksa/core/theme/app_fontweight.dart';
import 'package:jariksa/core/theme/app_typography.dart';
import 'package:jariksa/core/theme/color_value.dart';

class HomeStatusOperasionalWidget extends StatefulWidget {
  /// Jumlah pesanan yang baru masuk
  final int pesananMasuk;

  /// Jumlah pesanan yang sedang diproses
  final int sedangDiproses;

  /// Jumlah pesanan yang siap diambil
  final int siapDiambil;

  const HomeStatusOperasionalWidget({
    super.key,
    required this.pesananMasuk,
    required this.sedangDiproses,
    required this.siapDiambil,
  });

  @override
  State<HomeStatusOperasionalWidget> createState() =>
      _HomeStatusOperasionalWidgetState();
}

class _HomeStatusOperasionalWidgetState
    extends State<HomeStatusOperasionalWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Header Row ──────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "STATUS OPERASIONAL",
              style: AppTypography.body02.copyWith(
                color: ColorValue.neutral600,
                fontWeight: AppFontWeight.semiBold,
              ),
            ),
            Text(
              "Lihat Semua",
              style: AppTypography.body03.copyWith(
                fontWeight: AppFontWeight.regular,
                color: ColorValue.primary700,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),

        // ── 3 Status Containers ──────────────────────────────
        Row(
          children: [
            // --- Pesanan Masuk (primary700) ---
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.5.w,
                  vertical: 20.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border(
                    top: BorderSide(
                      color: ColorValue.primary700,
                      width: 2.w,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.pesananMasuk}',
                      style: AppTypography.heading02.copyWith(
                        color: ColorValue.primary700,
                        fontWeight: AppFontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Pesanan masuk',
                      textAlign: TextAlign.center,
                      style: AppTypography.body03.copyWith(
                        color: ColorValue.primary700,
                        fontWeight: AppFontWeight.medium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),

            // --- Sedang Diproses (secondary700) ---
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.5.w,
                  vertical: 20.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border(
                    top: BorderSide(
                      color: ColorValue.secondary700,
                      width: 2.w,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.sedangDiproses}',
                      style: AppTypography.heading02.copyWith(
                        color: ColorValue.secondary700,
                        fontWeight: AppFontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Sedang diproses',
                      textAlign: TextAlign.center,
                      style: AppTypography.body03.copyWith(
                        color: ColorValue.secondary700,
                        fontWeight: AppFontWeight.medium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),

            // --- Siap Diambil (orange600) ---
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.5.w,
                  vertical: 20.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border(
                    top: BorderSide(
                      color: ColorValue.orange600,
                      width: 2.w,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.siapDiambil}',
                      style: AppTypography.heading02.copyWith(
                        color: ColorValue.orange600,
                        fontWeight: AppFontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Siap diambil',
                      textAlign: TextAlign.center,
                      style: AppTypography.body03.copyWith(
                        color: ColorValue.orange600,
                        fontWeight: AppFontWeight.medium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}