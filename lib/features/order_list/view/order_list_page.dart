import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jariksa/core/theme/app_fontweight.dart';
import 'package:jariksa/core/theme/app_typography.dart';
import 'package:jariksa/core/theme/color_value.dart';
import 'package:jariksa/features/order_list/view/widgets/order_list_summary_card_widget.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorValue.primary50,

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),

        // Menggunakan Stack agar gradient dan konten bisa bertumpuk
        child: Stack(
          children: [
            // =========================================
            // LAYER 1: BACKGROUND GRADIENT (FIXED 271)
            // =========================================
            Container(
              width: double.infinity,
              height: 271.h, // Fixed height sesuai Figma
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ColorValue.primary600, // 0%
                    ColorValue.primary300, // 50%
                    const Color(0xFFE9F1F6).withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.5, 1.0], // Titik berhenti gradasi
                ),
              ),
            ),

            // =========================================
            // LAYER 2: KONTEN UTAMA
            // =========================================
            SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 22.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 14.h),
                    Text(
                      "Pesanan aktif",
                      style: AppTypography.heading03.copyWith(
                        fontWeight: AppFontWeight.semiBold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Sabtu, 9 Mei 2026 · 12 order berjalan",
                      style: AppTypography.body02.copyWith(
                        fontWeight: AppFontWeight.medium,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 17.h),
                    const OrderListSummaryCardWidget(
                      masuk: 4,
                      diproses: 4,
                      selesai: 4,
                      terlambat: 4,
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
}
