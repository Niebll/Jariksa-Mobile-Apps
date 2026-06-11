import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jariksa/core/theme/app_fontweight.dart';
import 'package:jariksa/core/theme/app_typography.dart';
import 'package:jariksa/core/theme/color_value.dart';

/// Card ringkasan status pesanan untuk halaman Daftar Pesanan.
class OrderListSummaryCardWidget extends StatelessWidget {
  final int masuk;
  final int diproses;
  final int selesai;
  final int terlambat;

  const OrderListSummaryCardWidget({
    super.key,
    required this.masuk,
    required this.diproses,
    required this.selesai,
    required this.terlambat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 20.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [ColorValue.primary600, ColorValue.primary300],
        ),
        borderRadius: BorderRadius.all(Radius.circular(12.r)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildItem("Masuk", masuk),
          _buildSeparator(),
          _buildItem("Diproses", diproses),
          _buildSeparator(),
          _buildItem("Selesai", selesai),
          _buildSeparator(),
          _buildItem("Terlambat", terlambat),
        ],
      ),
    );
  }

  Widget _buildItem(String label, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "$value",
          style: AppTypography.heading03.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: AppTypography.body03.copyWith(
            fontWeight: AppFontWeight.medium,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator() {
    return Container(
      width: 1.5.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: ColorValue.primary300,
        borderRadius: BorderRadius.circular(10.r),
      ),
    );
  }
}
