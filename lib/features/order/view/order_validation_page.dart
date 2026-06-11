import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:jariksa/core/theme/app_fontweight.dart';
import 'package:jariksa/core/theme/app_typography.dart';
import 'package:jariksa/core/theme/color_value.dart';
import 'package:jariksa/core/widgets/app_button.dart';
import 'package:jariksa/features/order/cubit/customer_check_cubit.dart';
import 'package:jariksa/features/order/cubit/order_menu_cubit.dart';
import 'package:jariksa/features/order/cubit/order_inspect_cubit.dart';
import 'package:jariksa/features/order/view/widgets/order_stepper_card_widget.dart';
import 'package:jariksa/features/order/view/order_payment_page.dart';

class OrderValidationPage extends StatelessWidget {
  const OrderValidationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ─── Retrieve State Data ─────────────────────────────────────────
    
    // 1. Customer Name
    final customerState = context.read<CustomerCheckCubit>().state;
    final customerName = customerState is CustomerCheckSuccess
        ? customerState.customer.name
        : 'Andi Saputra';

    // 2. Service, Category, and Price
    final menuState = context.read<OrderMenuCubit>().state;
    String serviceName = 'Cuci';
    String categoryName = 'Sepatu';
    int price = 35000;
    int durationHours = 72; // default fallback (3 days)

    if (menuState is OrderMenuSuccess) {
      final activeCategory = menuState.categories.firstWhere(
        (cat) => cat.categoryId == menuState.selectedCategoryId,
        orElse: () => menuState.categories.first,
      );
      categoryName = activeCategory.categoryName;
      
      if (menuState.selectedServiceId != null) {
        final activeService = activeCategory.services.firstWhere(
          (s) => s.serviceId == menuState.selectedServiceId,
          orElse: () => activeCategory.services.first,
        );
        serviceName = activeService.serviceName;
        price = activeService.price;
        durationHours = activeService.durationHours;
      }
    }

    // 3. AI Damage Tags
    final inspectState = context.read<OrderInspectCubit>().state;
    List<String> damageTags = [];
    if (inspectState is OrderInspectSuccess) {
      damageTags = inspectState.result.results.first.damageDetails
          .map((d) => d.kategoriKerusakan)
          .toSet()
          .toList();
    }
    if (damageTags.isEmpty) {
      damageTags = ['Noda warna', 'Yellowing ringan']; // fallback mock tags if empty
    }

    // 4. Estimation Date dynamically calculated using durationHours
    final today = DateTime.now();
    final estimationDate = today.add(Duration(hours: durationHours));
    final formattedDate = DateFormat('d MMMM yyyy', 'id_ID').format(estimationDate);

    // 5. Format Price
    final formattedPrice = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(price);

    return Scaffold(
      backgroundColor: ColorValue.primary50,
      body: Stack(
        children: [
          // ─── Layer 1: Background Gradient ──────────────────────────
          Container(
            width: double.infinity,
            height: 380.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ColorValue.primary600,
                  ColorValue.primary300,
                  const Color(0xFFE9F1F6).withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ─── Layer 2: Main Content ──────────────────────────────────
          SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 22.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h),
                  // Back Button
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
                    "KONFIRMASI",
                    style: AppTypography.body03.copyWith(
                      fontWeight: AppFontWeight.semiBold,
                      color: ColorValue.primary200,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Validasi pesanan",
                    style: AppTypography.heading03.copyWith(
                      fontWeight: AppFontWeight.semiBold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Kirim bukti digital ke pelanggan. Pesanan baru bisa diproses setelah disetujui.",
                    style: AppTypography.body02.copyWith(
                      fontWeight: AppFontWeight.medium,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 16.h),
                  // Stepper Component
                  OrderStepperCardWidget(
                    currentStep: 3, // index 3 represents Validation step 4
                    steps: const [
                      OrderStepItem(number: 1, label: 'Pelanggan'),
                      OrderStepItem(number: 2, label: 'Pilih'),
                      OrderStepItem(number: 3, label: 'Periksa'),
                      OrderStepItem(number: 4, label: 'Validasi'),
                      OrderStepItem(number: 5, label: 'Bayar'),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // ─── Actions Summary Card ───────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: ColorValue.neutral100,
                                width: 1.w,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "RINGKASAN TINDAKAN",
                                  style: AppTypography.body03.copyWith(
                                    fontWeight: AppFontWeight.semiBold,
                                    color: ColorValue.neutral600,
                                  ),
                                ),
                                SizedBox(height: 20.h),

                                // Pelanggan Row
                                _buildRowItem("Pelanggan", customerName),
                                _buildDivider(),

                                // Layanan Row
                                _buildRowItem("Layanan", serviceName),
                                _buildDivider(),

                                // Kategori Row
                                _buildRowItem("Kategori", "$categoryName · ${serviceName.contains("Cuci") ? "Reguler" : serviceName}"),
                                _buildDivider(),

                                // Kerusakan Row
                                _buildDamageRow("Kerusakan", damageTags),
                                _buildDivider(),

                                // Estimasi Selesai Row
                                _buildRowItem("Estimasi selesai", formattedDate),
                                
                                SizedBox(height: 10.h),

                                // Total Harga Container
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                    vertical: 12.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ColorValue.primary50,
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: ColorValue.primary100,
                                      width: 1.w,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Total harga",
                                        style: AppTypography.body02.copyWith(
                                          fontWeight: AppFontWeight.medium,
                                          color: ColorValue.primary700,
                                        ),
                                      ),
                                      Text(
                                        formattedPrice,
                                        style: AppTypography.body01.copyWith(
                                          fontWeight: AppFontWeight.semiBold,
                                          color: ColorValue.primary700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),

                  // ─── Bottom Navigation Button ────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: AppButton(
                      label: "Lanjut pembayaran",
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const OrderPaymentPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.body03.copyWith(
              fontWeight: AppFontWeight.regular,
              color: ColorValue.neutral600,
            ),
          ),
          Text(
            value,
            style: AppTypography.body03.copyWith(
              fontWeight: AppFontWeight.medium,
              color: ColorValue.neutral900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDamageRow(String label, List<String> tags) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTypography.body03.copyWith(
              fontWeight: AppFontWeight.regular,
              color: ColorValue.neutral600,
            ),
          ),
          Wrap(
            spacing: 6.w,
            children: tags.map((tag) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: ColorValue.orange50,
                  borderRadius: BorderRadius.circular(40.r),
                ),
                child: Text(
                  tag,
                  style: AppTypography.body03.copyWith(
                    fontWeight: AppFontWeight.regular,
                    color: ColorValue.orange500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: ColorValue.neutral100,
      height: 1.h,
      thickness: 1.h,
    );
  }
}
