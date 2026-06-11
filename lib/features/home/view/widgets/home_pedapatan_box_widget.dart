import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jariksa/core/theme/app_fontweight.dart';
import 'package:jariksa/core/theme/app_typography.dart';
import 'package:jariksa/core/theme/color_value.dart';

class HomePedapatanBoxWidget extends StatelessWidget {
  /// Nominal pendapatan yang sudah diformat, contoh: "Rp 289.000"
  final String pendapatan;

  /// Teks persentase perbandingan, contoh: "18% vs kemarin"
  final String persentase;

  /// true = tren naik (icon & warna hijau), false = tren turun (icon & warna merah)
  final bool isTrendNaik;

  const HomePedapatanBoxWidget({
    super.key,
    required this.pendapatan,
    required this.persentase,
    this.isTrendNaik = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24.h,
        left: 16.w,
        right: 16.w,
        bottom: 18.h,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "PENDAPATAN HARI INI",
            style: AppTypography.body03.copyWith(
              fontWeight: AppFontWeight.semiBold,
              color: ColorValue.neutral600,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pendapatan,
                    style: AppTypography.heading01.copyWith(
                      fontWeight: AppFontWeight.bold,
                      color: ColorValue.primary600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: isTrendNaik
                      ? ColorValue.secondary50
                      : const Color(0xFFFEECEC),
                  borderRadius: BorderRadius.circular(40.r),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      isTrendNaik
                          ? "assets/icons/trend_up.svg"
                          : "assets/icons/trend_down.svg",
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      persentase,
                      style: AppTypography.body03.copyWith(
                        fontWeight: AppFontWeight.semiBold,
                        color: isTrendNaik
                            ? ColorValue.secondary700
                            : const Color(0xFFD32F2F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}