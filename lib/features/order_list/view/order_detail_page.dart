import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:jariksa/core/theme/color_value.dart';
import 'package:jariksa/core/theme/app_typography.dart';
import 'package:jariksa/core/theme/app_fontweight.dart';
import 'package:jariksa/features/order_list/cubit/order_detail_cubit.dart';
import 'package:jariksa/features/order_list/cubit/order_detail_state.dart';
import 'package:jariksa/features/order_list/models/order_detail_model.dart';
import 'package:jariksa/core/widgets/app_button.dart';

class OrderDetailPage extends StatefulWidget {
  final int orderId;
  const OrderDetailPage({super.key, this.orderId = 2});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  void _fetchDetails() {
    context.read<OrderDetailCubit>().fetchOrderDetail(widget.orderId);
  }

  /// Helper untuk mendapatkan inisial dari nama pelanggan (max 2 huruf)
  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  /// Helper untuk memformat phone number dari "081234567890" menjadi "+62 812 – 3456 – 7890"
  String _formatDisplayPhone(String phone) {
    String digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    } else if (digits.startsWith('62')) {
      digits = digits.substring(2);
    }

    final buffer = StringBuffer('+62 ');
    for (int i = 0; i < digits.length; i++) {
      if (i == 3 || i == 7) {
        buffer.write(' – ');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// Helper untuk memformat nominal integer/string ke Rupiah
  String _formatRupiah(String amountStr) {
    final amount = double.tryParse(amountStr)?.toInt() ?? 0;
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(amount);
  }

  /// Helper untuk format tanggal dari API ke format ID
  String _formatDate(String isoString, {bool showTime = false}) {
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      if (showTime) {
        return DateFormat('d MMMM yyyy · HH.mm', 'id_ID').format(dateTime) + ' WIB';
      }
      return DateFormat('d MMMM yyyy', 'id_ID').format(dateTime);
    } catch (_) {
      return isoString;
    }
  }

  /// Menentukan status stepper index (0: Masuk, 1: Diproses, 2: Selesai)
  int _getStepIndex(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('siap diambil') || 
        lower.contains('ready for pickup') || 
        lower.contains('selesai') || 
        lower.contains('done')) {
      return 2;
    }
    if (lower.contains('diproses') || 
        lower.contains('processing')) {
      return 1;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorValue.neutral50,
      body: BlocBuilder<OrderDetailCubit, OrderDetailState>(
        builder: (context, state) {
          if (state is OrderDetailLoading) {
            return _buildSkeletonLoader();
          } else if (state is OrderDetailError) {
            return _buildErrorState(state.message);
          } else if (state is OrderDetailSuccess) {
            return _buildContent(state.order);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Tampilan Utama Rincian Pesanan
  Widget _buildContent(OrderDetailModel order) {
    final stepIndex = _getStepIndex(order.status);
    final hasItems = order.items.isNotEmpty;
    final firstItem = hasItems ? order.items.first : null;
    final damageTags = firstItem?.getDamageTags() ?? [];

    final String currentStatusLower = order.status.toLowerCase().trim();
    final bool showUpdateButton = currentStatusLower != 'selesai' && 
                                  currentStatusLower != 'done' && 
                                  currentStatusLower != 'canceled' && 
                                  currentStatusLower != 'cancelled';

    // Map item name or fallback to file name
    String itemName = 'Barang';
    if (firstItem != null && firstItem.aiReport != null) {
      try {
        final results = firstItem.aiReport!['results'] as List? ?? [];
        if (results.isNotEmpty) {
          final original = results.first['original_name'] as String? ?? '';
          if (original.isNotEmpty) {
            // Remove file extension
            itemName = original.contains('.')
                ? original.substring(0, original.lastIndexOf('.'))
                : original;
          }
        }
      } catch (_) {}
    }
    if (itemName == 'Barang' || itemName == 'images' || itemName == 'berhasil') {
      itemName = 'Sepatu / Pakaian';
    }

    return Stack(
      children: [
        Column(
          children: [
        // AppBar (Fixed Height 168.h dengan linear gradient)
        Container(
          width: double.infinity,
          height: 168.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ColorValue.primary600,
                ColorValue.primary300,
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24.r),
              bottomRight: Radius.circular(24.r),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 22.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h),
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          "assets/icons/back.svg",
                          height: 24.h,
                          width: 24.w,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "Pesanan aktif",
                          style: AppTypography.body02.copyWith(
                            fontWeight: AppFontWeight.regular,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  // Centered ID and Date
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "#${order.id}",
                          style: AppTypography.heading04.copyWith(
                            fontWeight: AppFontWeight.semiBold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _formatDate(order.createdAt, showTime: true),
                          style: AppTypography.body03.copyWith(
                            fontWeight: AppFontWeight.medium,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 20.h),
            child: Column(
              children: [
                // CARD 1: Pelanggan
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
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
                        "PELANGGAN",
                        style: AppTypography.body03.copyWith(
                          fontWeight: AppFontWeight.semiBold,
                          color: ColorValue.neutral600,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          // Profile initials avatar
                          Container(
                            width: 44.r,
                            height: 44.r,
                            decoration: const BoxDecoration(
                              color: ColorValue.secondary50,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _getInitials(order.customerName),
                              style: AppTypography.body02.copyWith(
                                fontWeight: AppFontWeight.semiBold,
                                color: ColorValue.secondary600,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          // Column Nama & NoHP
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  order.customerName,
                                  style: AppTypography.heading05.copyWith(
                                    fontWeight: AppFontWeight.medium,
                                    color: ColorValue.neutral900,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  _formatDisplayPhone(order.phoneNumber),
                                  style: AppTypography.body02.copyWith(
                                    fontWeight: AppFontWeight.regular,
                                    color: ColorValue.neutral500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          // Kendala Button
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: ColorValue.neutral200,
                                width: 1.w,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: ColorValue.neutral600,
                                  size: 16.r,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  "Kendala",
                                  style: AppTypography.body03.copyWith(
                                    fontWeight: AppFontWeight.medium,
                                    color: ColorValue.neutral600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // CARD 2: Detail Barang
                if (firstItem != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
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
                          "DETAIL BARANG",
                          style: AppTypography.body03.copyWith(
                            fontWeight: AppFontWeight.semiBold,
                            color: ColorValue.neutral600,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Foto barang (80x80 radius 4)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4.r),
                              child: firstItem.imageUrls.isNotEmpty
                                  ? Image.network(
                                      firstItem.imageUrls.first,
                                      height: 80.r,
                                      width: 80.r,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 80.r,
                                          width: 80.r,
                                          color: ColorValue.neutral100,
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.image_outlined,
                                            color: ColorValue.neutral400,
                                            size: 32.r,
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      height: 80.r,
                                      width: 80.r,
                                      color: ColorValue.neutral100,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.image_outlined,
                                        color: ColorValue.neutral400,
                                        size: 32.r,
                                      ),
                                    ),
                            ),
                            SizedBox(width: 12.w),
                            // Column Tipe & Detail
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    firstItem.serviceName,
                                    style: AppTypography.heading05.copyWith(
                                      fontWeight: AppFontWeight.medium,
                                      color: ColorValue.neutral900,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    itemName,
                                    style: AppTypography.body02.copyWith(
                                      fontWeight: AppFontWeight.regular,
                                      color: ColorValue.neutral500,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  // Label/Tags
                                  if (damageTags.isNotEmpty)
                                    Wrap(
                                      spacing: 6.w,
                                      runSpacing: 4.h,
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
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Divider(
                          color: ColorValue.neutral100,
                          height: 1.h,
                          thickness: 1.h,
                        ),
                        SizedBox(height: 12.h),
                        // Cloud Storage Info Row
                        Row(
                          children: [
                            Icon(
                              Icons.cloud_queue_rounded,
                              color: ColorValue.neutral500,
                              size: 20.r,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                "${firstItem.imageUrls.length} foto kondisi awal — Google Cloud Storage",
                                style: AppTypography.body03.copyWith(
                                  fontWeight: AppFontWeight.regular,
                                  color: ColorValue.neutral800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 16.h),

                // CARD 3: Proses Pengerjaan
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
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
                        "PROSES PENGERJAAN",
                        style: AppTypography.body03.copyWith(
                          fontWeight: AppFontWeight.semiBold,
                          color: ColorValue.neutral600,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      // Stepper Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStep(
                            index: 0,
                            currentStep: stepIndex,
                            label: "Masuk",
                            showLeftLine: false,
                            showRightLine: true,
                          ),
                          _buildStep(
                            index: 1,
                            currentStep: stepIndex,
                            label: "Diproses",
                            showLeftLine: true,
                            showRightLine: true,
                          ),
                          _buildStep(
                            index: 2,
                            currentStep: stepIndex,
                            label: (order.status.toLowerCase().contains('siap diambil') || 
                                    order.status.toLowerCase().contains('ready for pickup'))
                                ? "Siap Diambil"
                                : "Selesai",
                            showLeftLine: true,
                            showRightLine: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // CARD 4: Estimasi, Harga & Status
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: ColorValue.neutral100,
                      width: 1.w,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Estimasi selesai
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Estimasi selesai",
                            style: AppTypography.body02.copyWith(
                              fontWeight: AppFontWeight.regular,
                              color: ColorValue.neutral600,
                            ),
                          ),
                          Text(
                            _formatDate(order.estimatedCompletion),
                            style: AppTypography.heading05.copyWith(
                              fontWeight: AppFontWeight.medium,
                              color: ColorValue.neutral900,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Divider(
                        color: ColorValue.neutral100,
                        height: 1.h,
                        thickness: 1.h,
                      ),
                      SizedBox(height: 12.h),
                      // Harga layanan
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Harga layanan",
                            style: AppTypography.body02.copyWith(
                              fontWeight: AppFontWeight.regular,
                              color: ColorValue.neutral600,
                            ),
                          ),
                          Text(
                            _formatRupiah(order.totalPrice),
                            style: AppTypography.heading05.copyWith(
                              fontWeight: AppFontWeight.semiBold,
                              color: ColorValue.neutral900,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Divider(
                        color: ColorValue.neutral100,
                        height: 1.h,
                        thickness: 1.h,
                      ),
                      SizedBox(height: 12.h),
                      // Status transaksi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Status transaksi",
                            style: AppTypography.body02.copyWith(
                              fontWeight: AppFontWeight.regular,
                              color: ColorValue.neutral600,
                            ),
                          ),
                          _buildTransactionStatusBadge(order.status),
                        ],
                      ),
                    ],
                  ),
                ),
                // Spacing to prevent floating button from covering content
                SizedBox(height: showUpdateButton ? 100.h : 24.h),
              ],
            ),
          ),
        ),
      ],
    ),

    // Floating Bottom Button
    if (showUpdateButton)
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
                ColorValue.neutral50.withOpacity(0.0),
                ColorValue.neutral50.withOpacity(0.9),
                ColorValue.neutral50,
              ],
              stops: const [0.0, 0.3, 1.0],
            ),
          ),
          child: AppButton(
            label: "Update Status",
            isActive: true,
            onPressed: () => _showUpdateStatusBottomSheet(context, order.id, order.status),
          ),
        ),
      ),
  ],
  );
  }

  /// Membuat element step kustom dengan garis horizontal
  Widget _buildStep({
    required int index,
    required int currentStep,
    required String label,
    required bool showLeftLine,
    required bool showRightLine,
  }) {
    final bool isCompleted = currentStep >= index;
    final bool isLeftLineActive = currentStep >= index;
    final bool isRightLineActive = currentStep > index;

    return Expanded(
      child: Column(
        children: [
          Row(
            children: [
              // Garis kiri
              Expanded(
                child: showLeftLine
                    ? Container(
                        height: 2.h,
                        color: isLeftLineActive ? ColorValue.primary600 : ColorValue.neutral200,
                      )
                    : const SizedBox.shrink(),
              ),
              // Lingkaran step
              Container(
                width: 22.r,
                height: 22.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: isCompleted ? ColorValue.primary600 : ColorValue.neutral300,
                    width: 2.w,
                  ),
                ),
                alignment: Alignment.center,
                child: isCompleted
                    ? Container(
                        width: 10.r,
                        height: 10.r,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorValue.primary600,
                        ),
                      )
                    : null,
              ),
              // Garis kanan
              Expanded(
                child: showRightLine
                    ? Container(
                        height: 2.h,
                        color: isRightLineActive ? ColorValue.primary600 : ColorValue.neutral200,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: AppTypography.body03.copyWith(
              fontWeight: isCompleted ? AppFontWeight.semiBold : AppFontWeight.medium,
              color: isCompleted ? ColorValue.primary600 : ColorValue.neutral400,
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun badge status transaksi dinamis
  Widget _buildTransactionStatusBadge(String status) {
    final lower = status.toLowerCase();
    Color bgColor;
    Color textColor;
    String label;

    if (lower.contains('cancel') || lower.contains('batal') || lower.contains('dibatalkan')) {
      bgColor = ColorValue.neutral100;
      textColor = ColorValue.neutral600;
      label = "Dibatalkan";
    } else if (lower.contains('belum') || lower.contains('menunggu') || lower.contains('pending')) {
      bgColor = const Color(0xFFFDE8E8);
      textColor = const Color(0xFFE53E3E);
      label = "Belum bayar";
    } else {
      bgColor = ColorValue.green50;
      textColor = ColorValue.green600;
      label = "Lunas";
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: AppTypography.body03.copyWith(
          fontWeight: AppFontWeight.semiBold,
          color: textColor,
        ),
      ),
    );
  }

  /// Shimmer loading skeleton
  Widget _buildSkeletonLoader() {
    final baseColor = Colors.grey.shade300;
    final highlightColor = Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        children: [
          // AppBar Skeleton
          Container(
            width: double.infinity,
            height: 168.h,
            color: Colors.white,
          ),
          // Body cards skeleton
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 20.h),
              child: Column(
                children: List.generate(4, (index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    height: 110.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tampilan Error State dengan tombol coba lagi
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(22.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: const Color(0xFFE53E3E),
              size: 64.r,
            ),
            SizedBox(height: 16.h),
            Text(
              "Gagal memuat rincian pesanan",
              style: AppTypography.heading05.copyWith(
                fontWeight: AppFontWeight.bold,
                color: ColorValue.neutral900,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: AppTypography.body02.copyWith(
                color: ColorValue.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _fetchDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorValue.primary600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: const Text("Coba Lagi"),
            ),
          ],
        ),
      ),
    );
  }

  /// Membuka bottom sheet pilihan update status
  void _showUpdateStatusBottomSheet(BuildContext context, int orderId, String currentStatus) {
    final lower = currentStatus.toLowerCase().trim();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      backgroundColor: ColorValue.neutral50,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "UPDATE STATUS PESANAN",
                    style: AppTypography.body02.copyWith(
                      fontWeight: AppFontWeight.bold,
                      color: ColorValue.neutral600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: Icon(Icons.close, color: ColorValue.neutral400, size: 24.r),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: _buildValidStatusList(context, lower, orderId),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Menampilkan pilihan status manual yang relevan berdasarkan status saat ini
  List<Widget> _buildValidStatusList(BuildContext context, String currentStatusLower, int orderId) {
    final List<Widget> list = [];

    if (currentStatusLower == 'menunggu pembayaran' || 
        currentStatusLower == 'masuk' || 
        currentStatusLower == 'pending') {
      list.add(
        _buildStatusOption(
          context,
          title: "Diproses",
          description: "Pesanan mulai dicuci/dikerjakan (Bayar diawal)",
          icon: Icons.sync_rounded,
          iconColor: ColorValue.primary600,
          iconBgColor: ColorValue.primary50,
          apiValue: "Diproses",
          orderId: orderId,
        ),
      );
      list.add(
        _buildStatusOption(
          context,
          title: "Diproses - Belum Dibayar",
          description: "Pesanan dikerjakan, pembayaran saat diambil (Bayar nanti)",
          icon: Icons.access_time_rounded,
          iconColor: Colors.blueGrey,
          iconBgColor: const Color(0xFFECEFF1),
          apiValue: "Diproses - Belum Dibayar",
          orderId: orderId,
        ),
      );
    } else if (currentStatusLower == 'diproses' || 
               currentStatusLower == 'processing' || 
               currentStatusLower == 'diproses - belum dibayar') {
      list.add(
        _buildStatusOption(
          context,
          title: "Siap Diambil",
          description: "Pesanan selesai dan siap diserahkan ke pelanggan",
          icon: Icons.check_circle_outline_rounded,
          iconColor: ColorValue.green600,
          iconBgColor: ColorValue.green50,
          apiValue: "Siap Diambil",
          orderId: orderId,
        ),
      );
      list.add(
        _buildStatusOption(
          context,
          title: "Terlambat",
          description: "Pengerjaan melebihi estimasi waktu selesai",
          icon: Icons.warning_amber_rounded,
          iconColor: ColorValue.orange500,
          iconBgColor: ColorValue.orange50,
          apiValue: "Terlambat",
          orderId: orderId,
        ),
      );
      list.add(
        _buildStatusOption(
          context,
          title: "Selesai",
          description: "Pesanan telah selesai dan diserahkan ke pelanggan",
          icon: Icons.done_all_rounded,
          iconColor: Colors.purple,
          iconBgColor: const Color(0xFFF3E8FF),
          apiValue: "Selesai",
          orderId: orderId,
        ),
      );
    } else if (currentStatusLower == 'siap diambil' || 
               currentStatusLower == 'ready for pickup' || 
               currentStatusLower == 'terlambat') {
      list.add(
        _buildStatusOption(
          context,
          title: "Selesai",
          description: "Pesanan telah selesai dan diserahkan ke pelanggan",
          icon: Icons.done_all_rounded,
          iconColor: Colors.purple,
          iconBgColor: const Color(0xFFF3E8FF),
          apiValue: "Selesai",
          orderId: orderId,
        ),
      );
      if (currentStatusLower != 'terlambat') {
        list.add(
          _buildStatusOption(
            context,
            title: "Terlambat",
            description: "Pengerjaan melebihi estimasi waktu selesai",
            icon: Icons.warning_amber_rounded,
            iconColor: ColorValue.orange500,
            iconBgColor: ColorValue.orange50,
            apiValue: "Terlambat",
            orderId: orderId,
          ),
        );
      }
    }

    return list;
  }

  /// Opsi status di dalam bottom sheet
  Widget _buildStatusOption(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String apiValue,
    required int orderId,
  }) {
    return GestureDetector(
      onTap: () async {
        final navigator = Navigator.of(context);
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        final orderDetailCubit = context.read<OrderDetailCubit>();

        navigator.pop(); // close bottom sheet
        
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => const Center(
            child: CircularProgressIndicator(color: ColorValue.primary600),
          ),
        );

        final success = await orderDetailCubit.updateOrderStatus(orderId, apiValue);
        
        navigator.pop(); // remove loading dialog

        if (success) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text("Status berhasil diubah menjadi $title"),
              backgroundColor: ColorValue.green500,
            ),
          );
        } else {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text("Gagal mengubah status pesanan."),
              backgroundColor: Color(0xFFE53E3E),
            ),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: ColorValue.neutral100, width: 1.w),
        ),
        child: Row(
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconBgColor,
              ),
              child: Icon(icon, color: iconColor, size: 20.r),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body02.copyWith(
                      fontWeight: AppFontWeight.semiBold,
                      color: ColorValue.neutral900,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    description,
                    style: AppTypography.body03.copyWith(
                      fontWeight: AppFontWeight.regular,
                      color: ColorValue.neutral500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: ColorValue.neutral400,
              size: 20.r,
            ),
          ],
        ),
      ),
    );
  }
}
