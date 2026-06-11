import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:jariksa/core/theme/app_fontweight.dart';
import 'package:jariksa/core/theme/app_typography.dart';
import 'package:jariksa/core/theme/color_value.dart';
import 'package:jariksa/core/widgets/app_button.dart';
import 'package:jariksa/features/home/cubit/home_cubit.dart';
import 'package:jariksa/features/order/cubit/customer_check_cubit.dart';
import 'package:jariksa/features/order/cubit/order_menu_cubit.dart';
import 'package:jariksa/features/order/cubit/order_inspect_cubit.dart';
import 'package:jariksa/features/order/cubit/order_payment_cubit.dart';
import 'package:jariksa/features/order/view/widgets/order_stepper_card_widget.dart';
import 'package:jariksa/core/pages/main_page.dart';

class OrderPaymentPage extends StatefulWidget {
  const OrderPaymentPage({super.key});

  @override
  State<OrderPaymentPage> createState() => _OrderPaymentPageState();
}

class _OrderPaymentPageState extends State<OrderPaymentPage> {
  String _selectedMethod = 'NOW'; // 'NOW' or 'LATER'

  @override
  Widget build(BuildContext context) {
    // ─── Retrieve State Data from Cubits ─────────────────────────────────

    // 1. Customer Name
    final customerState = context.read<CustomerCheckCubit>().state;
    final customerName = customerState is CustomerCheckSuccess
        ? customerState.customer.name
        : 'Andi Saputra';
    final customerId = customerState is CustomerCheckSuccess
        ? customerState.customer.id
        : 1;

    // 2. Service & Pricing details
    final menuState = context.read<OrderMenuCubit>().state;
    String serviceName = 'Cuci';
    int serviceId = 1;
    int price = 35000;

    if (menuState is OrderMenuSuccess) {
      final activeCategory = menuState.categories.firstWhere(
        (cat) => cat.categoryId == menuState.selectedCategoryId,
        orElse: () => menuState.categories.first,
      );
      if (menuState.selectedServiceId != null) {
        final activeService = activeCategory.services.firstWhere(
          (s) => s.serviceId == menuState.selectedServiceId,
          orElse: () => activeCategory.services.first,
        );
        serviceName = activeService.serviceName;
        serviceId = activeService.serviceId;
        price = activeService.price;
      }
    }

    // 3. Scan ID
    final inspectState = context.read<OrderInspectCubit>().state;
    int? scanId;
    if (inspectState is OrderInspectSuccess) {
      scanId = inspectState.result.scanId;
    }

    // 4. Formatted Price
    final formattedPrice = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(price);

    return BlocConsumer<OrderPaymentCubit, OrderPaymentState>(
      listener: (context, state) {
        if (state is OrderPaymentSuccess) {
          _showSuccessDialog(context, state.paymentOption);
        } else if (state is OrderPaymentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFE53E3E),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is OrderPaymentLoading;

        return Scaffold(
          backgroundColor: ColorValue.primary50,
          body: Stack(
            children: [
              // ─── Layer 1: Background Gradient ────────────────────────
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

              // ─── Layer 2: Main Content ──────────────────────────────
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
                              "PEMBAYARAN",
                              style: AppTypography.body03.copyWith(
                                fontWeight: AppFontWeight.semiBold,
                                color: ColorValue.primary200,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              "Kapan dibayar?",
                              style: AppTypography.heading03.copyWith(
                                fontWeight: AppFontWeight.semiBold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              "Pilih yang paling nyaman untuk pelanggan.",
                              style: AppTypography.body02.copyWith(
                                fontWeight: AppFontWeight.medium,
                                color: Colors.white,
                              ),
                            ),

                            SizedBox(height: 16.h),
                            // Stepper (currentStep = 4 representing Step 5: Bayar)
                            OrderStepperCardWidget(
                              currentStep: 4,
                              steps: const [
                                OrderStepItem(number: 1, label: 'Pelanggan'),
                                OrderStepItem(number: 2, label: 'Pilih'),
                                OrderStepItem(number: 3, label: 'Periksa'),
                                OrderStepItem(number: 4, label: 'Validasi'),
                                OrderStepItem(number: 5, label: 'Bayar'),
                              ],
                            ),

                            SizedBox(height: 40.h),

                            // ─── Price Summary Box ─────────────────────
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "$customerName · $serviceName",
                                    style: AppTypography.body03.copyWith(
                                      fontWeight: AppFontWeight.regular,
                                      color: ColorValue.primary500,
                                    ),
                                  ),
                                  Text(
                                    formattedPrice,
                                    style: AppTypography.heading05.copyWith(
                                      fontWeight: AppFontWeight.semiBold,
                                      color: ColorValue.primary800,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 34.h),

                            // Header Pilih Cara Bayar
                            Text(
                              "PILIH CARA BAYAR",
                              style: AppTypography.body03.copyWith(
                                fontWeight: AppFontWeight.semiBold,
                                color: ColorValue.neutral600,
                              ),
                            ),

                            SizedBox(height: 16.h),

                            // ─── 2 Cara Bayar Side-by-Side ──────────────
                            Row(
                              children: [
                                // Left Card: Bayar Sekarang (NOW)
                                Expanded(
                                  child: _buildPaymentMethodCard(
                                    isSelected: _selectedMethod == 'NOW',
                                    onTap: () {
                                      setState(() {
                                        _selectedMethod = 'NOW';
                                      });
                                    },
                                    activeBgColor: ColorValue.primary50,
                                    activeStrokeColor: ColorValue.primary400,
                                    icon: Icons.qr_code_2_rounded,
                                    iconColor: ColorValue.primary600,
                                    iconBgColor: ColorValue.primary100,
                                    title: "Bayar sekarang",
                                    subtitle: "QRIS · langsung lunas",
                                    subtitleActiveColor: ColorValue.primary500,
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                // Right Card: Bayar Saat Ambil (LATER)
                                Expanded(
                                  child: _buildPaymentMethodCard(
                                    isSelected: _selectedMethod == 'LATER',
                                    onTap: () {
                                      setState(() {
                                        _selectedMethod = 'LATER';
                                      });
                                    },
                                    activeBgColor: ColorValue.orange50,
                                    activeStrokeColor: ColorValue.orange500,
                                    icon: Icons.access_time_filled_rounded,
                                    iconColor: ColorValue.orange500,
                                    iconBgColor: ColorValue.orange100,
                                    title: "Bayar saat ambil",
                                    subtitle: "Tandai belum bayar",
                                    subtitleActiveColor: ColorValue.orange500,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 24.h),

                            // ─── Info Box ──────────────────────────────
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: ColorValue.neutral100,
                                  width: 1.w,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: ColorValue.neutral400,
                                    size: 20.r,
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      "Setelah pesanan masuk antrean, status bisa dipantau langsung dari halaman Pesanan.",
                                      style: AppTypography.body03.copyWith(
                                        fontWeight: AppFontWeight.regular,
                                        color: ColorValue.neutral600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 110.h),
                          ],
                        ),
                      ),
                    ),

                    // ─── Floating Bottom Action Button ─────────────────
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.only(
                          left: 22.w,
                          right: 22.w,
                          bottom: 20.h,
                          top: 10.h,
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
                            stops: const [0.0, 0.3, 1.0],
                          ),
                        ),
                        child: AppButton(
                          label: isLoading
                              ? "Memproses..."
                              : (_selectedMethod == 'NOW'
                                    ? "Bayar sekarang"
                                    : "Selesai & masuk antrean"),
                          isActive: !isLoading,
                          onPressed: () {
                            context.read<OrderPaymentCubit>().createOrder(
                              customerId: customerId,
                              totalPrice: price,
                              serviceId: serviceId,
                              itemPrice: price,
                              scanId: scanId,
                              paymentOption: _selectedMethod,
                            );
                          },
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

  Widget _buildPaymentMethodCard({
    required bool isSelected,
    required VoidCallback onTap,
    required Color activeBgColor,
    required Color activeStrokeColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required Color subtitleActiveColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160.h,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? activeBgColor : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? activeStrokeColor : ColorValue.neutral100,
            width: isSelected ? 1.5.w : 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with rounded circle background
            Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? iconBgColor : ColorValue.neutral50,
              ),
              child: Icon(
                icon,
                color: isSelected ? iconColor : ColorValue.neutral400,
                size: 22.r,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: AppTypography.body03.copyWith(
                fontWeight: AppFontWeight.semiBold,
                color: isSelected
                    ? ColorValue.neutral900
                    : ColorValue.neutral400,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: AppTypography.body03.copyWith(
                fontWeight: AppFontWeight.regular,
                color: isSelected ? subtitleActiveColor : ColorValue.neutral400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String option) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return PopScope(
          canPop: false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72.r,
                    height: 72.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: option == 'NOW'
                          ? ColorValue.primary50
                          : ColorValue.green50,
                    ),
                    child: Icon(
                      option == 'NOW'
                          ? Icons.payment_rounded
                          : Icons.check_circle_outline_rounded,
                      color: option == 'NOW'
                          ? ColorValue.primary500
                          : ColorValue.green500,
                      size: 40.r,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    option == 'NOW'
                        ? "Membuka Midtrans..."
                        : "Pesanan Berhasil",
                    style: AppTypography.heading05.copyWith(
                      fontWeight: AppFontWeight.bold,
                      color: ColorValue.neutral900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    option == 'NOW'
                        ? "Silakan lakukan pembayaran pada halaman Midtrans Snap yang terbuka di browser Anda."
                        : "Pesanan masuk antrean dengan status Belum Dibayar. Silakan tagih pembayaran saat pengambilan.",
                    style: AppTypography.body02.copyWith(
                      fontWeight: AppFontWeight.regular,
                      color: ColorValue.neutral600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: "Kembali ke Beranda",
                      onPressed: () {
                        // Reset all cubits to prepare for next order
                        context.read<CustomerCheckCubit>().reset();
                        context.read<OrderInspectCubit>().reset();
                        context.read<OrderMenuCubit>().fetchMenu();
                        context.read<OrderPaymentCubit>().reset();

                        // Refresh home dashboard
                        context.read<HomeCubit>().fetchDashboard();

                        // Navigate to MainPage and clear stack
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const MainPage(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
