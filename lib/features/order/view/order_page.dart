import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:jariksa/core/theme/app_fontweight.dart';
import 'package:jariksa/core/theme/app_typography.dart';
import 'package:jariksa/core/theme/color_value.dart';
import 'package:jariksa/core/widgets/app_button.dart';
import 'package:jariksa/features/order/cubit/customer_check_cubit.dart';
import 'package:jariksa/features/order/view/widgets/order_customer_card_widget.dart';
import 'package:jariksa/features/order/view/widgets/order_phone_input_card_widget.dart';
import 'package:jariksa/features/order/view/widgets/order_stepper_card_widget.dart';
import 'package:jariksa/features/order/view/order_choose_service_page.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();
  bool _isAddingNewCustomer = false;

  @override
  void initState() {
    super.initState();
    _nameFocusNode.addListener(_onNameFocusChange);
    _nameController.addListener(_onNameChange);
  }

  void _onNameFocusChange() {
    setState(() {});
  }

  void _onNameChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _nameFocusNode.removeListener(_onNameFocusChange);
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    return BlocListener<CustomerCheckCubit, CustomerCheckState>(
      listener: (context, state) {
        if (state is CustomerCheckSuccess && _isAddingNewCustomer) {
          setState(() {
            _isAddingNewCustomer = false;
            _nameController.clear();
          });
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const OrderChooseServicePage(),
            ),
          );
        } else if (state is CustomerCheckError) {
          final isAlreadyExists = state.message.contains('already exists') ||
              state.message.contains('sudah terdaftar') ||
              state.message.contains('exists');

          if (isAlreadyExists) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Nomor HP sudah terdaftar sebagai pelanggan',
                ),
                backgroundColor: ColorValue.orange500,
              ),
            );
            setState(() {
              _isAddingNewCustomer = false;
              _nameController.clear();
            });
            // Auto fetch existing customer details
            context.read<CustomerCheckCubit>().checkCustomer(_phoneController.text);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFE53E3E),
              ),
            );
          }
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: ColorValue.primary50,

        body: Stack(
          children: [
            // =========================================
            // LAYER 1: BACKGROUND GRADIENT (FIXED 380.h)
            // =========================================
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

            // =========================================
            // LAYER 2: KONTEN UTAMA
            // =========================================
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
                          // Back button
                          GestureDetector(
                            onTap: () {
                              if (_isAddingNewCustomer) {
                                setState(() {
                                  _isAddingNewCustomer = false;
                                });
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
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
                            "Siapa pelanggannya?",
                            style: AppTypography.heading03.copyWith(
                              fontWeight: AppFontWeight.semiBold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "Masukkan nomor HP untuk mulai. Kami yang urus sisanya.",
                            style: AppTypography.body02.copyWith(
                              fontWeight: AppFontWeight.medium,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(height: 16.h),
                          OrderStepperCardWidget(
                            currentStep: 0,
                            steps: const [
                              OrderStepItem(number: 1, label: 'Pelanggan'),
                              OrderStepItem(number: 2, label: 'Pilih'),
                              OrderStepItem(number: 3, label: 'Periksa'),
                              OrderStepItem(number: 4, label: 'Validasi'),
                              OrderStepItem(number: 5, label: 'Bayar'),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // Card Input Nomor HP
                          OrderPhoneInputCardWidget(
                            controller: _phoneController,
                            onChanged: (value) {
                              if (!_isAddingNewCustomer) {
                                context
                                    .read<CustomerCheckCubit>()
                                    .checkCustomer(value);
                              }
                            },
                          ),

                          // Card Input Nama (Hanya jika Tambah Pelanggan Baru aktif)
                          if (_isAddingNewCustomer) ...[
                            SizedBox(height: 12.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'NAMA PELANGGAN',
                                    style: AppTypography.body03.copyWith(
                                      fontWeight: AppFontWeight.semiBold,
                                      color: ColorValue.neutral600,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(
                                        color: _nameFocusNode.hasFocus ||
                                                _nameController.text.isNotEmpty
                                            ? ColorValue.primary500
                                            : ColorValue.neutral300,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _nameController,
                                            focusNode: _nameFocusNode,
                                            style: AppTypography.heading05
                                                .copyWith(
                                                  fontWeight:
                                                      AppFontWeight.medium,
                                                  color: ColorValue.neutral900,
                                                ),
                                            decoration: InputDecoration(
                                              isDense: true,
                                              contentPadding: EdgeInsets.all(
                                                12.w,
                                              ),
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              disabledBorder: InputBorder.none,
                                              hintText: 'Nama pelanggan baru',
                                              hintStyle: AppTypography.heading05
                                                  .copyWith(
                                                    fontWeight:
                                                        AppFontWeight.medium,
                                                    color:
                                                        ColorValue.neutral300,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(right: 12.w),
                                          child: Icon(
                                            Icons.person_outline,
                                            size: 20.r,
                                            color: _nameFocusNode.hasFocus ||
                                                    _nameController
                                                        .text
                                                        .isNotEmpty
                                                ? ColorValue.primary500
                                                : ColorValue.neutral300,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // BlocBuilder Hasil Verifikasi
                          BlocBuilder<CustomerCheckCubit, CustomerCheckState>(
                            builder: (context, state) {
                              if (state is CustomerCheckError) {
                                final isAlreadyExists = state.message.contains('already exists') ||
                                    state.message.contains('sudah terdaftar') ||
                                    state.message.contains('exists');
                                return Padding(
                                  padding: EdgeInsets.only(top: 12.h),
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      color: isAlreadyExists ? ColorValue.orange50 : const Color(0xFFFDE8E8),
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: isAlreadyExists ? ColorValue.orange200 : const Color(0xFFF8B4B4),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isAlreadyExists ? Icons.info_outline : Icons.error_outline,
                                          color: isAlreadyExists ? ColorValue.orange500 : const Color(0xFFE53E3E),
                                          size: 20.r,
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Text(
                                            isAlreadyExists
                                                ? 'Nomor HP sudah terdaftar sebagai pelanggan.'
                                                : state.message,
                                            style: AppTypography.body03.copyWith(
                                              fontWeight: AppFontWeight.medium,
                                              color: isAlreadyExists ? ColorValue.orange900 : const Color(0xFF9B1C1C),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              if (!_isAddingNewCustomer) {
                                if (state is CustomerCheckLoading) {
                                  return Shimmer.fromColors(
                                    baseColor: ColorValue.neutral100,
                                    highlightColor: ColorValue.neutral50,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 12.h),
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(16.w),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16.r,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 48.r,
                                              height: 48.r,
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            SizedBox(width: 12.w),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 140.w,
                                                    height: 16.h,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4.r,
                                                          ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 8.h),
                                                  Container(
                                                    width: 100.w,
                                                    height: 12.h,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4.r,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                } else if (state is CustomerCheckSuccess) {
                                  return Padding(
                                    padding: EdgeInsets.only(top: 12.h),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const OrderChooseServicePage(),
                                          ),
                                        );
                                      },
                                      child: OrderCustomerCardWidget(
                                        customer: state.customer,
                                      ),
                                    ),
                                  );
                                } else if (state is CustomerCheckNotFound) {
                                  return Padding(
                                    padding: EdgeInsets.only(top: 12.h),
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(12.w),
                                      decoration: BoxDecoration(
                                        color: ColorValue.orange50,
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        border: Border.all(
                                          color: ColorValue.orange200,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: ColorValue.orange500,
                                            size: 20.r,
                                          ),
                                          SizedBox(width: 8.w),
                                          Expanded(
                                            child: Text(
                                              'Nomor HP belum terdaftar sebagai pelanggan.',
                                              style: AppTypography.body03
                                                  .copyWith(
                                                    fontWeight:
                                                        AppFontWeight.medium,
                                                    color: ColorValue.orange900,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              }
                              return const SizedBox.shrink();
                            },
                          ),

                          // Spacer at the bottom so text fields aren't obscured by the floating button
                          SizedBox(height: isKeyboardVisible ? 24.h : 110.h),
                        ],
                      ),
                    ),
                  ),

                  // Floating Bottom Action Button matching choose service design
                  if (!isKeyboardVisible)
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
                        child: BlocBuilder<CustomerCheckCubit, CustomerCheckState>(
                          builder: (context, state) {
                            final bool isChecking = state is CustomerCheckLoading;

                            String label;
                            bool isActive;
                            VoidCallback onPressed;

                            if (_isAddingNewCustomer) {
                              label = "Lanjut pilih layanan";
                              isActive =
                                  _nameController.text.trim().isNotEmpty &&
                                  _phoneController.text.trim().isNotEmpty &&
                                  !isChecking;
                              onPressed = () {
                                context.read<CustomerCheckCubit>().registerCustomer(
                                      _nameController.text,
                                      _phoneController.text,
                                    );
                              };
                            } else {
                              if (state is CustomerCheckSuccess) {
                                label = "Lanjut pilih layanan";
                                isActive = true;
                                onPressed = () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const OrderChooseServicePage(),
                                    ),
                                  );
                                };
                              } else {
                                label = "Tambah pelanggan baru";
                                isActive = true;
                                onPressed = () {
                                  setState(() {
                                    _isAddingNewCustomer = true;
                                  });
                                };
                              }
                            }

                            return AppButton(
                              label: isChecking ? "Memproses..." : label,
                              isActive: isActive,
                              onPressed: onPressed,
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
      ),
    );
  }
}
