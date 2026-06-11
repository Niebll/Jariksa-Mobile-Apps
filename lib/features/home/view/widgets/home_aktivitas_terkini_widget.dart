import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jariksa/core/theme/app_fontweight.dart';
import 'package:jariksa/core/theme/app_typography.dart';
import 'package:jariksa/core/theme/color_value.dart';
import 'package:jariksa/features/order_list/view/order_detail_page.dart';

// ── Enum status pesanan ────────────────────────────────────────────────────
enum StatusPesanan { diproses, selesai, terlambat, canceled, siapDiambil }

// ── Model data pesanan ─────────────────────────────────────────────────────
class PesananItem {
  /// ID Pesanan
  final int id;

  /// Nama pembeli
  final String namaPembeli;

  /// Tipe servis, mis. "Cuci Repaint"
  final String tipeServis;

  /// Status: diproses / selesai / terlambat / canceled
  final StatusPesanan status;

  /// Tanggal & waktu yang ditampilkan, mis. "6 Mei · 08.30"
  final String tanggal;

  /// Path asset icon, mis. "assets/icons/baju.svg"
  final String iconAsset;

  const PesananItem({
    required this.id,
    required this.namaPembeli,
    required this.tipeServis,
    required this.status,
    required this.tanggal,
    required this.iconAsset,
  });
}

// ── Widget utama ───────────────────────────────────────────────────────────
class HomeAktivitasTerkiniWidget extends StatelessWidget {
  /// List pesanan yang akan ditampilkan
  final List<PesananItem> items;

  const HomeAktivitasTerkiniWidget({super.key, required this.items});

  // ── Helpers warna berdasarkan status ──────────────────────────────────
  Color _borderColor(StatusPesanan status) {
    return status == StatusPesanan.terlambat
        ? ColorValue.orange100
        : ColorValue.neutral100;
  }

  Color _iconBgColor(StatusPesanan status) {
    if (status == StatusPesanan.terlambat) {
      return ColorValue.orange50;
    }
    if (status == StatusPesanan.canceled) {
      return ColorValue.neutral100;
    }
    if (status == StatusPesanan.siapDiambil) {
      return ColorValue.orange50;
    }
    return ColorValue.primary50;
  }

  Color _badgeBgColor(StatusPesanan status) {
    switch (status) {
      case StatusPesanan.diproses:
        return ColorValue.secondary50;
      case StatusPesanan.siapDiambil:
        return ColorValue.orange50;
      case StatusPesanan.selesai:
        return ColorValue.green50;
      case StatusPesanan.terlambat:
        return ColorValue.orange500;
      case StatusPesanan.canceled:
        return ColorValue.neutral100;
    }
  }

  Color _badgeTextColor(StatusPesanan status) {
    switch (status) {
      case StatusPesanan.diproses:
        return ColorValue.secondary700;
      case StatusPesanan.siapDiambil:
        return ColorValue.orange600;
      case StatusPesanan.selesai:
        return ColorValue.green600;
      case StatusPesanan.terlambat:
        return Colors.white;
      case StatusPesanan.canceled:
        return ColorValue.neutral600;
    }
  }

  String _badgeLabel(StatusPesanan status) {
    switch (status) {
      case StatusPesanan.diproses:
        return 'Diproses';
      case StatusPesanan.siapDiambil:
        return 'Siap Diambil';
      case StatusPesanan.selesai:
        return 'Selesai';
      case StatusPesanan.terlambat:
        return 'Terlambat';
      case StatusPesanan.canceled:
        return 'Dibatalkan';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Header Row ──────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "AKTIVITAS TERKINI",
              style: AppTypography.body02.copyWith(
                color: ColorValue.neutral600,
                fontWeight: AppFontWeight.semiBold,
              ),
            ),
            Text(
              "Lihat Semua",
              style: AppTypography.body03.copyWith(
                fontWeight: AppFontWeight.regular,
                color: ColorValue.primary700,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),

        // ── List Aktivitas ───────────────────────────────────
        ListView.builder(
          // Agar bisa di-scroll bersama parent SingleChildScrollView
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero, // hapus default padding ListView
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => OrderDetailPage(orderId: item.id),
                  ),
                );
              },
              child: Container(
                // Gap 8 antar item, kecuali item terakhir
                margin: EdgeInsets.only(
                  bottom: index < items.length - 1 ? 8.h : 0,
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: _borderColor(item.status),
                    width: 1.w,
                  ),
                ),
                child: Row(
                  children: [
                    // ── Icon background ─────────────────────────────────────────
                    Container(
                      height: 40.h,
                      width: 40.w,
                      decoration: BoxDecoration(
                        color: _iconBgColor(item.status),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Image.asset(
                          item.iconAsset,
                          height: 20.h,
                          width: 28.w,
                        ),
                      ),
                    ),

                    SizedBox(width: 8.w),

                    // ── Nama & tipe servis ───────────────────────────────────────
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.namaPembeli,
                            style: AppTypography.body02.copyWith(
                              fontWeight: AppFontWeight.medium,
                              color: ColorValue.neutral900,
                            ),
                          ),
                          Text(
                            item.tipeServis,
                            style: AppTypography.body03.copyWith(
                              fontWeight: AppFontWeight.regular,
                              color: ColorValue.neutral900,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 8.w),

                    // ── Badge status + tanggal ───────────────────────────────────
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Badge status
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: _badgeBgColor(item.status),
                            borderRadius: BorderRadius.circular(40.r),
                          ),
                          child: Text(
                            _badgeLabel(item.status),
                            style: AppTypography.body03.copyWith(
                              fontWeight: AppFontWeight.medium,
                              color: _badgeTextColor(item.status),
                            ),
                          ),
                        ),

                        SizedBox(height: 4.h),

                        // Tanggal & waktu
                        Text(
                          item.tanggal,
                          style: AppTypography.body03.copyWith(
                            color: ColorValue.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ), // ListView.builder
      ],
    ); // Column
  }
}
