import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:jariksa/core/theme/app_fontweight.dart';
import 'package:jariksa/core/theme/app_typography.dart';
import 'package:jariksa/core/theme/color_value.dart';
import 'package:jariksa/features/home/cubit/home_cubit.dart';
import 'package:jariksa/features/home/cubit/business_cubit.dart';
import 'package:jariksa/features/home/cubit/business_state.dart';
import 'package:jariksa/features/home/view/widgets/home_aktivitas_terkini_widget.dart';
import 'package:jariksa/features/home/view/widgets/home_pedapatan_box_widget.dart';
import 'package:jariksa/features/home/view/widgets/home_status_operasional_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorValue.primary50,
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            context.read<HomeCubit>().fetchDashboard(),
            context.read<BusinessCubit>().fetchBusinessProfile(),
          ]);
        },
        color: ColorValue.primary600,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 22.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 60.h),
                    Text(
                      'SELAMAT PAGI',
                      style: AppTypography.body03.copyWith(
                        color: ColorValue.primary100,
                        fontWeight: AppFontWeight.semiBold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    BlocBuilder<BusinessCubit, BusinessState>(
                      builder: (context, state) {
                        String storeName = 'Roketto Laundry';
                        String? profilePictureUrl;

                        if (state is BusinessSuccess) {
                          storeName = state.business.storeName;
                          profilePictureUrl = state.business.profilePicture;
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    storeName,
                                    style: AppTypography.heading03.copyWith(
                                      color: Colors.white,
                                      fontWeight: AppFontWeight.semiBold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    '${DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now())} · Sedang buka',
                                    style: AppTypography.body02.copyWith(
                                      color: Colors.white,
                                      fontWeight: AppFontWeight.medium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Container(
                              height: 60.h,
                              width: 60.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                                image:
                                    profilePictureUrl != null &&
                                        profilePictureUrl.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(profilePictureUrl),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child:
                                  profilePictureUrl == null ||
                                      profilePictureUrl.isEmpty
                                  ? const Icon(
                                      Icons.store_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    )
                                  : null,
                            ),
                          ],
                        );
                      },
                    ),
                    // BlocBuilder untuk memuat data secara dinamis dari API /dashboard
                    BlocBuilder<HomeCubit, HomeState>(
                      builder: (context, state) {
                        if (state is HomeLoading) {
                          return _buildHomeSkeleton();
                        } else if (state is HomeError) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 60.h),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red.shade700,
                                    size: 48.r,
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    state.message,
                                    style: AppTypography.body02.copyWith(
                                      color: ColorValue.neutral900,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 16.h),
                                  ElevatedButton(
                                    onPressed: () => context
                                        .read<HomeCubit>()
                                        .fetchDashboard(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ColorValue.primary600,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                    ),
                                    child: const Text('Coba Lagi'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else if (state is HomeSuccess) {
                          final dashboard = state.dashboard;

                          // Map recent activities ke PesananItem (maksimal 3 item)
                          final activities = dashboard.recentActivities
                              .take(3)
                              .map((act) {
                                StatusPesanan status;
                                switch (act.status.toLowerCase()) {
                                  case 'siap diambil':
                                  case 'ready for pickup':
                                    status = StatusPesanan.siapDiambil;
                                    break;
                                  case 'selesai':
                                    status = StatusPesanan.selesai;
                                    break;
                                  case 'delayed':
                                  case 'terlambat':
                                    status = StatusPesanan.terlambat;
                                    break;
                                  case 'canceled':
                                  case 'cancelled':
                                  case 'batal':
                                  case 'dibatalkan':
                                    status = StatusPesanan.canceled;
                                    break;
                                  case 'diproses':
                                  default:
                                    status = StatusPesanan.diproses;
                                    break;
                                }

                                // Format tanggal dari API (contoh: 2026-06-07T04:03:17.395Z)
                                String tanggalFormatted = '';
                                try {
                                  final dateTime = DateTime.parse(
                                    act.createdAt,
                                  ).toLocal();
                                  tanggalFormatted = DateFormat(
                                    'd MMM · HH.mm',
                                    'id_ID',
                                  ).format(dateTime);
                                } catch (_) {
                                  tanggalFormatted = act.createdAt;
                                }

                                // Tentukan iconAsset berdasarkan tipe servis
                                final serviceName = act.mainService
                                    .toLowerCase();
                                final iconAsset = serviceName.contains('sepatu')
                                    ? 'assets/icons/sepatu.png'
                                    : 'assets/icons/baju.png';

                                return PesananItem(
                                  id: act.id,
                                  namaPembeli: act.customerName,
                                  tipeServis: act.mainService,
                                  status: status,
                                  tanggal: tanggalFormatted,
                                  iconAsset: iconAsset,
                                );
                              })
                              .toList();

                          return Column(
                            children: [
                              SizedBox(height: 20.h),
                              // Card Pendapatan Hari Ini
                              HomePedapatanBoxWidget(
                                pendapatan: _formatRupiah(
                                  dashboard.income.today,
                                ),
                                persentase:
                                    '${dashboard.income.trendPercentage}% vs kemarin',
                                isTrendNaik: dashboard.income.isUp,
                              ),

                              SizedBox(height: 20.h),
                              HomeStatusOperasionalWidget(
                                pesananMasuk: dashboard.operationalStatus.masuk,
                                sedangDiproses:
                                    dashboard.operationalStatus.diproses,
                                siapDiambil:
                                    dashboard.operationalStatus.selesai,
                              ),

                              SizedBox(height: 20.h),
                              if (activities.isNotEmpty) ...[
                                HomeAktivitasTerkiniWidget(items: activities),
                                SizedBox(height: 20.h),
                              ],
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper untuk memformat nominal integer ke Rupiah (misal: 289000 -> Rp 289.000)
  String _formatRupiah(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  /// Membuat efek loading skeleton shimmer yang menyerupai layout asli
  Widget _buildHomeSkeleton() {
    final baseColor = Colors.grey.shade300;
    final highlightColor = Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        children: [
          SizedBox(height: 20.h),

          // Skeleton Box Pendapatan
          Container(
            height: 98.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),

          SizedBox(height: 20.h),

          // Skeleton Status Operasional (3 Box)
          Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Container(
                  height: 108.h,
                  margin: EdgeInsets.only(right: index < 2 ? 8.w : 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // Skeleton Aktivitas Terkini (List 3 Row)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 16.h,
                    width: 120.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  Container(
                    height: 16.h,
                    width: 70.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Item List
              Column(
                children: List.generate(
                  3,
                  (index) => Container(
                    height: 64.h,
                    margin: EdgeInsets.only(bottom: index < 2 ? 8.h : 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
