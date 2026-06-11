import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jariksa/core/theme/app_fontweight.dart';
import 'package:jariksa/core/theme/app_typography.dart';
import 'package:jariksa/core/theme/color_value.dart';
import 'package:jariksa/core/widgets/app_button.dart';
import 'package:jariksa/features/order/cubit/order_inspect_cubit.dart';
import 'package:jariksa/features/order/view/widgets/order_stepper_card_widget.dart';
import 'package:jariksa/features/order/view/order_validation_page.dart';

class OrderInspectResultPage extends StatelessWidget {
  const OrderInspectResultPage({super.key});

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

          // ─── Layer 2: Main Content ──────────────────────────────
          SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 22.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h),
                  // Back / Close Button
                  GestureDetector(
                    onTap: () {
                      context.read<OrderInspectCubit>().reset();
                      Navigator.of(context).pop();
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
                    "JARIKSA · AI DETEKSI KERUSAKAN",
                    style: AppTypography.body03.copyWith(
                      fontWeight: AppFontWeight.semiBold,
                      color: ColorValue.primary200,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Scan kondisi barang",
                    style: AppTypography.heading03.copyWith(
                      fontWeight: AppFontWeight.semiBold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Foto ini jadi bukti digital resmi kondisi barang sebelum dikerjakan.",
                    style: AppTypography.body02.copyWith(
                      fontWeight: AppFontWeight.medium,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 16.h),
                  OrderStepperCardWidget(
                    currentStep: 2, // 3rd step (index 2)
                    steps: const [
                      OrderStepItem(number: 1, label: 'Pelanggan'),
                      OrderStepItem(number: 2, label: 'Pilih'),
                      OrderStepItem(number: 3, label: 'Periksa'),
                      OrderStepItem(number: 4, label: 'Validasi'),
                      OrderStepItem(number: 5, label: 'Bayar'),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // ─── Inspect Content States ────────────────────────
                  Expanded(
                    child: BlocBuilder<OrderInspectCubit, OrderInspectState>(
                      builder: (context, state) {
                        if (state is OrderInspectUploading) {
                          return _buildLoadingShimmer();
                        } else if (state is OrderInspectFailure) {
                          return _buildFailureState(context, state.message);
                        } else if (state is OrderInspectSuccess) {
                          return _buildSuccessContent(context, state);
                        }
                        return const SizedBox.shrink();
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

  /// Membangun isi hasil deteksi yang sukses
  Widget _buildSuccessContent(BuildContext context, OrderInspectSuccess state) {
    final result = state.result.results.first;
    final isDamaged = result.itemStatus.toUpperCase() == "DAMAGED";
    final damageCount = result.totalDamagesDetected;

    // Hitung akurasi dari first damage detail confidence, atau default 92
    double accuracy = 92.0;
    if (result.damageDetails.isNotEmpty) {
      final confidenceStr = result.damageDetails.first.confidence;
      final parsed = double.tryParse(confidenceStr.replaceAll('%', ''));
      if (parsed != null) accuracy = parsed;
    }

    // Ambil list tag kerusakan unik
    final List<String> damageTags = result.damageDetails
        .map((d) => d.kategoriKerusakan)
        .toSet()
        .toList();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── CARD 1: Foto Preview ─────────────────────────
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.file(
                          File(state.localImagePath),
                          height: 120.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.network(
                              result.publicUrl,
                              height: 120.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              result.originalName,
                              style: AppTypography.body02.copyWith(
                                fontWeight: AppFontWeight.medium,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            state.localFileSize,
                            style: AppTypography.body03.copyWith(
                              fontWeight: AppFontWeight.regular,
                              color: ColorValue.neutral600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),

                // ─── CARD 2: Hasil Laporan AI ──────────────────────
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: 20.h,
                    horizontal: 16.w,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: ColorValue.neutral100,
                      width: 1.w,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtitle
                      Text(
                        isDamaged
                            ? "KERUSAKAN TERDETEKSI · $damageCount TITIK"
                            : "KONDISI BARANG · AMAN",
                        style: AppTypography.body03.copyWith(
                          fontWeight: AppFontWeight.semiBold,
                          color: ColorValue.neutral600,
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // Damage Tag Badges / Safe Badge
                      if (isDamaged && damageTags.isNotEmpty)
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: damageTags.map((tag) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 2.h,
                                horizontal: 8.w,
                              ),
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
                        )
                      else
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 2.h,
                            horizontal: 8.w,
                          ),
                          decoration: BoxDecoration(
                            color: ColorValue.green50,
                            borderRadius: BorderRadius.circular(40.r),
                          ),
                          child: Text(
                            "Aman / Tidak ada kerusakan",
                            style: AppTypography.body03.copyWith(
                              fontWeight: AppFontWeight.regular,
                              color: ColorValue.green500,
                            ),
                          ),
                        ),

                      SizedBox(height: 16.h),

                      // Accuracy bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Akurasi deteksi JaRiksa",
                            style: AppTypography.body03.copyWith(
                              fontWeight: AppFontWeight.medium,
                              color: ColorValue.neutral800,
                            ),
                          ),
                          Text(
                            "${accuracy.toStringAsFixed(0)}%",
                            style: AppTypography.body03.copyWith(
                              fontWeight: AppFontWeight.semiBold,
                              color: ColorValue.secondary500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: accuracy / 100.0,
                          minHeight: 6.h,
                          backgroundColor: ColorValue.neutral100,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            ColorValue.secondary500,
                          ),
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // Footer caption
                      Text(
                        "Tag kerusakan ini akan dicantumkan dalam bukti digital pelanggan",
                        style: AppTypography.body03.copyWith(
                          fontWeight: AppFontWeight.regular,
                          color: ColorValue.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ─── Bottom Action Buttons ───────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: "Scan ulang",
                  isFilled: false,
                  onPressed: () {
                    context.read<OrderInspectCubit>().reset();
                    Navigator.of(context).pop();
                  },
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: AppButton(
                  label: "Selanjutnya",
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const OrderValidationPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Custom premium loading layout
  Widget _buildLoadingShimmer() {
    return const Center(
      child: _OrderInspectLoadingWidget(),
    );
  }

  /// Failure error layout
  Widget _buildFailureState(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE8E8),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFF8B4B4), width: 1.w),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: const Color(0xFFE53E3E),
                size: 24.r,
              ),
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
          SizedBox(height: 16.h),
          AppButton(
            label: "Kembali ke Kamera",
            backgroundColor: const Color(0xFFE53E3E),
            onPressed: () {
              context.read<OrderInspectCubit>().reset();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class _OrderInspectLoadingWidget extends StatefulWidget {
  const _OrderInspectLoadingWidget();

  @override
  State<_OrderInspectLoadingWidget> createState() =>
      _OrderInspectLoadingWidgetState();
}

class _OrderInspectLoadingWidgetState
    extends State<_OrderInspectLoadingWidget> {
  final List<String> _loadingTexts = [
    "Mengunggah gambar ke Cloud...",
    "Menghubungkan ke AI JaRiksa...",
    "Menganalisis kondisi barang...",
    "Mendeteksi adanya kerusakan...",
    "Menyusun laporan kondisi...",
  ];
  late final Stream<int> _textStream;

  @override
  void initState() {
    super.initState();
    _textStream = Stream.periodic(
      const Duration(milliseconds: 1800),
      (i) => (i + 1) % _loadingTexts.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: ColorValue.neutral100, width: 1.w),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Premium animated scanning/progress icon
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: ColorValue.primary50,
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 56.r,
              height: 56.r,
              child: CircularProgressIndicator(
                strokeWidth: 4.w,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  ColorValue.primary500,
                ),
                backgroundColor: ColorValue.primary100,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            "Memproses Gambar",
            style: AppTypography.body01.copyWith(
              fontWeight: AppFontWeight.semiBold,
              color: ColorValue.neutral900,
            ),
          ),
          SizedBox(height: 8.h),
          StreamBuilder<int>(
            stream: _textStream,
            initialData: 0,
            builder: (context, snapshot) {
              final text = _loadingTexts[snapshot.data ?? 0];
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  text,
                  key: ValueKey<String>(text),
                  style: AppTypography.body03.copyWith(
                    fontWeight: AppFontWeight.medium,
                    color: ColorValue.neutral600,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
          SizedBox(height: 24.h),
          // Sleek Linear Progress indicator below the text
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: SizedBox(
              width: 180.w,
              child: LinearProgressIndicator(
                minHeight: 4.h,
                backgroundColor: ColorValue.neutral100,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  ColorValue.primary500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
