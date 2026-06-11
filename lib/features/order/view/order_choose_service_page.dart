import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:jariksa/core/theme/app_fontweight.dart';
import 'package:jariksa/core/theme/app_typography.dart';
import 'package:jariksa/core/theme/color_value.dart';
import 'package:jariksa/features/order/cubit/order_menu_cubit.dart';
import 'package:jariksa/features/order/view/widgets/order_stepper_card_widget.dart';
import 'package:jariksa/core/widgets/app_button.dart';
import 'package:jariksa/features/order/view/order_scan_page.dart';

class OrderChooseServicePage extends StatefulWidget {
  const OrderChooseServicePage({super.key});

  @override
  State<OrderChooseServicePage> createState() => _OrderChooseServicePageState();
}

class _OrderChooseServicePageState extends State<OrderChooseServicePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorValue.primary50,
      body: Stack(
        children: [
          // ─── Layer 1: Background Gradient ─────────────────────
          Container(
            width: double.infinity,
            height: 380.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ColorValue.primary600, // 0%
                  ColorValue.primary300, // 50%
                  const Color(0xFFE9F1F6).withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ─── Layer 2: Main Content (Scrollable Page) ──────────
          SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 22.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.h),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icons/back.svg",
                                height: 24.h,
                                width: 24.w,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "Kembali",
                                style: AppTypography.body02.copyWith(
                                  fontWeight: AppFontWeight.regular,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          "CATAT PESANAN BARU",
                          style: AppTypography.body03.copyWith(
                            fontWeight: AppFontWeight.semiBold,
                            color: ColorValue.primary200,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Pilih Layanan",
                          style: AppTypography.heading03.copyWith(
                            fontWeight: AppFontWeight.semiBold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Apa yang perlu kami rawat hari ini?",
                          style: AppTypography.body02.copyWith(
                            fontWeight: AppFontWeight.medium,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        OrderStepperCardWidget(
                          currentStep: 1,
                          steps: const [
                            OrderStepItem(number: 1, label: 'Pelanggan'),
                            OrderStepItem(number: 2, label: 'Pilih'),
                            OrderStepItem(number: 3, label: 'Periksa'),
                            OrderStepItem(number: 4, label: 'Validasi'),
                            OrderStepItem(number: 5, label: 'Bayar'),
                          ],
                        ),
                        SizedBox(height: 20.h),

                        // ─── BlocBuilder for Menu Content ──────────────
                        BlocBuilder<OrderMenuCubit, OrderMenuState>(
                          builder: (context, state) {
                            if (state is OrderMenuLoading) {
                              return _buildShimmerLoading();
                            } else if (state is OrderMenuError) {
                              return _buildError(state.message);
                            } else if (state is OrderMenuSuccess) {
                              return _buildMenuContent(state);
                            }
                            return const SizedBox.shrink();
                          },
                        ),

                        // Spacer at the bottom so list items aren't obscured by the floating button
                        SizedBox(height: 110.h),
                      ],
                    ),
                  ),
                ),

                // ─── Floating Bottom Action Button ──────────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: BlocBuilder<OrderMenuCubit, OrderMenuState>(
                    builder: (context, state) {
                      if (state is! OrderMenuSuccess) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        padding: EdgeInsets.only(
                          left: 22.w,
                          right: 22.w,
                          bottom: 24.h,
                          top: 20.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              ColorValue.primary50.withValues(alpha: 0.0),
                              ColorValue.primary50.withValues(alpha: 0.9),
                              ColorValue.primary50,
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                        child: AppButton(
                          label: "Lanjut pilih layanan",
                          isActive: state.selectedServiceId != null,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const OrderScanPage(),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Renders category horizontal list and service vertical list.
  Widget _buildMenuContent(OrderMenuSuccess state) {
    final activeCategory = state.categories.firstWhere(
      (cat) => cat.categoryId == state.selectedCategoryId,
      orElse: () => state.categories.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // KATEGORI label
        Text(
          "KATEGORI",
          style: AppTypography.body03.copyWith(
            fontWeight: AppFontWeight.semiBold,
            color: ColorValue.neutral600,
          ),
        ),
        SizedBox(height: 12.h),

        // Horizontal Category List (Edge-to-Edge Row of Expanded Items)
        SizedBox(
          height: 105.h,
          child: Row(
            children: List.generate(state.categories.length, (index) {
              final category = state.categories[index];
              final isActive = category.categoryId == state.selectedCategoryId;

              String getIconPath(String name) {
                final n = name.toLowerCase();
                if (n.contains('pakaian')) {
                  return 'assets/icons/baju.png';
                } else if (n.contains('sepatu')) {
                  return 'assets/icons/sepatu.png';
                }
                return 'assets/icons/baju.png';
              }

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == state.categories.length - 1 ? 0 : 16.w,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      context.read<OrderMenuCubit>().selectCategory(
                        category.categoryId,
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isActive ? ColorValue.primary50 : Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isActive
                              ? ColorValue.primary400
                              : ColorValue.neutral100,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            getIconPath(category.categoryName),
                            width: 24.w,
                            height: 32.h,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            category.categoryName,
                            style: AppTypography.body02.copyWith(
                              fontWeight: AppFontWeight.semiBold,
                              color: isActive
                                  ? ColorValue.primary900
                                  : ColorValue.neutral900,
                            ),
                          ),
                          Text(
                            '${category.services.length} layanan',
                            style: AppTypography.body03.copyWith(
                              fontWeight: AppFontWeight.regular,
                              color: isActive
                                  ? ColorValue.primary400
                                  : ColorValue.neutral300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        SizedBox(height: 24.h),

        // PILIH LAYANAN label
        Text(
          "PILIH LAYANAN",
          style: AppTypography.body03.copyWith(
            fontWeight: AppFontWeight.semiBold,
            color: ColorValue.neutral600,
          ),
        ),
        SizedBox(height: 12.h),

        // Vertical Services List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: 20.h),
          itemCount: activeCategory.services.length,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final service = activeCategory.services[index];
            final isSelected = service.serviceId == state.selectedServiceId;

            final priceFormatted = NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp',
              decimalDigits: 0,
            ).format(service.price);

            return GestureDetector(
              onTap: () {
                context.read<OrderMenuCubit>().selectService(service.serviceId);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: isSelected ? ColorValue.primary50 : Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected
                        ? ColorValue.primary400
                        : ColorValue.neutral100,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          service.serviceName,
                          style: AppTypography.body03.copyWith(
                            fontWeight: AppFontWeight.semiBold,
                            color: ColorValue.neutral900,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          service.description,
                          style: AppTypography.body03.copyWith(
                            fontWeight: AppFontWeight.regular,
                            color: ColorValue.neutral500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      "$priceFormatted/${service.unit}",
                      style: AppTypography.body02.copyWith(
                        fontWeight: AppFontWeight.semiBold,
                        color: ColorValue.neutral900,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    // Radio button circle
                    Container(
                      width: 20.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? ColorValue.primary500
                            : Colors.transparent,
                        border: isSelected
                            ? null
                            : Border.all(
                                color: ColorValue.neutral300,
                                width: 1.5,
                              ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 8.w,
                                height: 8.h,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Shimmer loading layout for category and services list.
  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: ColorValue.neutral100,
      highlightColor: ColorValue.neutral50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 80.w, height: 14.h, color: Colors.white),
          SizedBox(height: 12.h),
          SizedBox(
            height: 105.h,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 105.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Container(
                    height: 105.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Container(width: 120.w, height: 14.h, color: Colors.white),
          SizedBox(height: 12.h),
          Column(
            children: List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Container(
                  width: double.infinity,
                  height: 64.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Error placeholder.
  Widget _buildError(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE8E8),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFF8B4B4), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: const Color(0xFFE53E3E), size: 20.r),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: AppTypography.body03.copyWith(
                fontWeight: AppFontWeight.medium,
                color: const Color(0xFF9B1C1C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
