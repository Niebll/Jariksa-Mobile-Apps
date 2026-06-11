import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jariksa/core/theme/app_fontweight.dart';
import 'package:jariksa/core/theme/app_typography.dart';
import 'package:jariksa/core/theme/color_value.dart';

/// Model data untuk satu langkah di stepper.
class OrderStepItem {
  final int number;
  final String label;

  const OrderStepItem({required this.number, required this.label});
}

/// Widget card progress langkah pembuatan pesanan (stepper).
///
/// Layout dihitung manual via LayoutBuilder agar:
/// - Setiap step mendapat slot lebar yang sama (totalWidth / n)
/// - Circle selalu tepat di tengah slot-nya
/// - Label selalu tepat di bawah circle-nya, tidak overflow
/// - Connector selalu rapi di antara tepi circle kiri dan kanan
class OrderStepperCardWidget extends StatelessWidget {
  final List<OrderStepItem> steps;
  final int currentStep; // 0-based

  const OrderStepperCardWidget({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final circleSize = 28.r;
          final n = steps.length;

          // Setiap step mendapat slot yang sama
          final slotWidth = totalWidth / n;

          // Titik tengah horizontal tiap step
          final centers = List.generate(
            n,
            (i) => slotWidth * i + slotWidth / 2,
          );

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Baris 1: circles + connectors ──────────────
              SizedBox(
                width: totalWidth,
                height: circleSize,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Connector garis
                    for (int i = 0; i < n - 1; i++)
                      Positioned(
                        left: centers[i] + circleSize / 2,
                        width: centers[i + 1] - centers[i] - circleSize,
                        top: circleSize / 2 - 0.75,
                        height: 1.5,
                        child: _buildConnector(),
                      ),
                    // Lingkaran step
                    for (int i = 0; i < n; i++)
                      Positioned(
                        left: centers[i] - circleSize / 2,
                        top: 0,
                        child: _buildCircle(
                          steps[i].number,
                          isActive: i == currentStep,
                          isFinished: i < currentStep,
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 8.h),

              // ── Baris 2: labels sejajar dengan slot tiap step ──
              SizedBox(
                width: totalWidth,
                child: Row(
                  children: [
                    for (int i = 0; i < n; i++)
                      SizedBox(
                        width: slotWidth,
                        child: Center(
                          child: _buildLabel(
                            steps[i].label,
                            isActive: i == currentStep,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCircle(
    int number, {
    required bool isActive,
    required bool isFinished,
  }) {
    // ── Finished: lingkaran gelap + ikon centang ──────────────
    if (isFinished) {
      return Container(
        width: 28.r,
        height: 28.r,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [ColorValue.primary700, ColorValue.primary600],
          ),
        ),
        child: Center(
          child: Icon(Icons.check_rounded, color: Colors.white, size: 16.r),
        ),
      );
    }

    // ── Active: gradient terang + angka ───────────────────────
    if (isActive) {
      return Container(
        width: 28.r,
        height: 28.r,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [ColorValue.primary600, ColorValue.primary400],
          ),
        ),
        child: Center(
          child: Text(
            '$number',
            style: AppTypography.body02.copyWith(
              fontWeight: AppFontWeight.semiBold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    // ── Unreached: abu-abu muda + angka ───────────────────────
    return Container(
      width: 28.r,
      height: 28.r,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: ColorValue.primary50,
      ),
      child: Center(
        child: Text(
          '$number',
          style: AppTypography.body02.copyWith(
            fontWeight: AppFontWeight.semiBold,
            color: ColorValue.primary200,
          ),
        ),
      ),
    );
  }

  Widget _buildConnector() {
    return Container(
      decoration: BoxDecoration(
        color: ColorValue.primary200,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }

  Widget _buildLabel(String label, {required bool isActive}) {
    return FittedBox(
      fit: BoxFit.scaleDown,

      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.body03.copyWith(
          fontWeight: AppFontWeight.semiBold,
          color: isActive ? ColorValue.primary600 : ColorValue.primary300,
        ),
      ),
    );
  }
}
