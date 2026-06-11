import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jariksa/core/theme/app_fontweight.dart';
import 'package:jariksa/core/theme/app_typography.dart';
import 'package:jariksa/core/theme/color_value.dart';

class AppNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabTapped;
  final VoidCallback onFabTapped;

  const AppNavbar({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
    required this.onFabTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Icon di kiri FAB (index 0 & 1) dan kanan FAB (index 2 & 3)
    final List<IconData> iconList = [
      Icons.home_rounded,
      Icons.receipt_long_rounded,
      Icons.people_alt_rounded,
      Icons.store_rounded,
    ];

    final List<String> labelList = [
      'Beranda',
      'Pesanan',
      'Pelanggan',
      'Toko',
    ];

    return AnimatedBottomNavigationBar.builder(
      itemCount: iconList.length,
      tabBuilder: (int index, bool isActive) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconList[index],
              size: 24.r,
              color: isActive ? ColorValue.primary500 : ColorValue.neutral400,
            ),
            SizedBox(height: 4.h),
            Text(
              labelList[index],
              style: AppTypography.body03.copyWith(
                fontWeight: AppFontWeight.semiBold,
                color: isActive ? ColorValue.primary500 : ColorValue.neutral400,
              ),
            ),
          ],
        );
      },
      activeIndex: currentIndex,
      gapLocation: GapLocation.center,
      notchSmoothness: NotchSmoothness.smoothEdge,
      leftCornerRadius: 20.r,
      rightCornerRadius: 20.r,
      onTap: onTabTapped,
      backgroundColor: Colors.white,
      elevation: 8,
      notchMargin: 6.w,
      height: 65.h,

      shadow: BoxShadow(
        offset: const Offset(0, -2),
        blurRadius: 16,
        color: Colors.black.withValues(alpha: 0.08),
      ),
    );
  }
}
