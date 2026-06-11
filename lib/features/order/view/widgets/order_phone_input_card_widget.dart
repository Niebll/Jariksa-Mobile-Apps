import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jariksa/core/theme/app_fontweight.dart';
import 'package:jariksa/core/theme/app_typography.dart';
import 'package:jariksa/core/theme/color_value.dart';

/// Card input nomor HP pelanggan untuk halaman pencatatan pesanan.
class OrderPhoneInputCardWidget extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const OrderPhoneInputCardWidget({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  State<OrderPhoneInputCardWidget> createState() =>
      _OrderPhoneInputCardWidgetState();
}

class _OrderPhoneInputCardWidgetState
    extends State<OrderPhoneInputCardWidget> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
  }

  void _onFocusChange() =>
      setState(() => _isFocused = _focusNode.hasFocus);

  void _onTextChange() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);
    _focusNode.dispose();
    super.dispose();
  }

  // Warna border: primary500 saat fokus/ada isi, neutral300 jika kosong idle
  Color get _borderColor =>
      (_isFocused || _hasText) ? ColorValue.primary500 : ColorValue.neutral300;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── Label ─────────────────────────────────────────────
          Text(
            'NOMOR HP PELANGGAN',
            style: AppTypography.body03.copyWith(
              fontWeight: AppFontWeight.semiBold,
              color: ColorValue.neutral600,
            ),
          ),

          SizedBox(height: 12.h),

          // ─── TextField dengan prefix +62 ───────────────────────
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: _borderColor, width: 1),
            ),
            child: Row(
              children: [
                // Prefix: kotak +62
                Container(
                  margin: EdgeInsets.all(6.w),
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: ColorValue.primary500,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    '+62',
                    style: AppTypography.body02.copyWith(
                      fontWeight: AppFontWeight.semiBold,
                      color: Colors.white,
                    ),
                  ),
                ),

                // TextField
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    onChanged: widget.onChanged,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      _PhoneNumberFormatter(),
                    ],
                    style: AppTypography.heading05.copyWith(
                      fontWeight: AppFontWeight.medium,
                      color: ColorValue.neutral900,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.all(6.w),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: '812 – XXXX – XXX',
                      hintStyle: AppTypography.heading05.copyWith(
                        fontWeight: AppFontWeight.medium,
                        color: ColorValue.neutral300,
                      ),
                    ),
                  ),
                ),

                // Suffix: ikon telepon
                Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: Icon(
                    Icons.phone_outlined,
                    size: 20.r,
                    color: _borderColor,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          // ─── Keterangan bawah ──────────────────────────────────
          Text(
            'Nomor akan dicocokkan dengan database pelanggan',
            style: AppTypography.body03.copyWith(
              fontWeight: AppFontWeight.regular,
              color: ColorValue.neutral500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Formatter auto-format nomor HP: tanpa leading 0, hanya digit,
/// max 11 digit, format XXX – XXXX – XXXX.
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. Ambil digit saja dari input mentah
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // 2. Buang leading 0 (sudah ada +62 di prefix)
    digits = digits.replaceFirst(RegExp(r'^0+'), '');

    // 3. Batasi 11 digit (3 + 4 + 4)
    if (digits.length > 11) digits = digits.substring(0, 11);

    // 4. Format: XXX – XXXX – XXXX
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 3 || i == 7) buffer.write(' – ');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
