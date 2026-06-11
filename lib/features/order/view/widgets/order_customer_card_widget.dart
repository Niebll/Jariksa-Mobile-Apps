import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jariksa/core/theme/app_fontweight.dart';
import 'package:jariksa/core/theme/app_typography.dart';
import 'package:jariksa/core/theme/color_value.dart';
import 'package:jariksa/features/order/models/customer_model.dart';

class OrderCustomerCardWidget extends StatelessWidget {
  final CustomerModel customer;

  const OrderCustomerCardWidget({
    super.key,
    required this.customer,
  });

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

  @override
  Widget build(BuildContext context) {
    // Mapping status dari API (misal: "Regular" -> "Setia")
    final displayStatus = customer.loyaltyStatus.toLowerCase() == 'regular'
        ? 'Setia'
        : customer.loyaltyStatus;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ─── Avatar Inisial ─────────────────────────────────────
          Container(
            width: 48.r,
            height: 48.r,
            decoration: const BoxDecoration(
              color: ColorValue.secondary50,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _getInitials(customer.name),
              style: AppTypography.body02.copyWith(
                fontWeight: AppFontWeight.semiBold,
                color: ColorValue.secondary600,
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // ─── Info Nama & Nomor HP ───────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  customer.name,
                  style: AppTypography.heading05.copyWith(
                    fontWeight: AppFontWeight.semiBold,
                    color: ColorValue.neutral900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  _formatDisplayPhone(customer.phoneNumber),
                  style: AppTypography.body03.copyWith(
                    fontWeight: AppFontWeight.regular,
                    color: ColorValue.neutral500,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 8.w),

          // ─── Badge Loyalty Status ──────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: ColorValue.secondary500,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 14.r,
                ),
                SizedBox(width: 4.w),
                Text(
                  displayStatus,
                  style: AppTypography.body03.copyWith(
                    fontWeight: AppFontWeight.semiBold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
