import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jariksa/core/theme/app_fontweight.dart';
import 'package:jariksa/core/theme/app_typography.dart';
import 'package:jariksa/core/theme/color_value.dart';
import 'package:jariksa/features/order/cubit/order_inspect_cubit.dart';
import 'package:jariksa/features/order/view/order_inspect_result_page.dart';

class OrderScanPage extends StatefulWidget {
  const OrderScanPage({super.key});

  @override
  State<OrderScanPage> createState() => _OrderScanPageState();
}

class _OrderScanPageState extends State<OrderScanPage> {
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _cameraController = CameraController(
          _cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Gagal menginisialisasi kamera: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  /// Ambil foto menggunakan Kamera live
  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    try {
      final XFile photo = await _cameraController!.takePicture();
      if (mounted) {
        _onPhotoCaptured(photo.path);
      }
    } catch (e) {
      debugPrint("Gagal mengambil gambar: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengambil gambar: $e")),
        );
      }
    }
  }

  /// Unggah foto dari galeri
  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        _onPhotoCaptured(image.path);
      }
    } catch (e) {
      debugPrint("Gagal memilih gambar dari galeri: $e");
    }
  }

  void _onPhotoCaptured(String path) {
    context.read<OrderInspectCubit>().uploadImage(path);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const OrderInspectResultPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double cutoutHeight = 320.h;
    final double cutoutWidth = 327.w;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ─── Kamera Live / Mock Fallback ──────────────────────────
          Positioned.fill(
            child: _isCameraInitialized && _cameraController != null
                ? CameraPreview(_cameraController!)
                : Container(
                    color: const Color(0xFF1C1B1F),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          color: ColorValue.neutral500,
                          size: 64.r,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          "Menghubungkan kamera...",
                          style: AppTypography.body02.copyWith(
                            color: ColorValue.neutral400,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // ─── Inverted Transparent Cutout Overlay (72% Black) ─────
          Positioned.fill(
            child: CustomPaint(
              painter: _InvertedCutoutPainter(
                cutoutHeight: cutoutHeight,
                cutoutWidth: cutoutWidth,
              ),
            ),
          ),

          // ─── Garis Target Frame Tengah + Orange Corners ──────────
          Center(
            child: Container(
              width: cutoutWidth,
              height: cutoutHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: const Color(0xFFD9D9D9).withValues(alpha: 0.4),
                  width: 2.w,
                ),
              ),
              child: Stack(
                children: [
                  // Top Left Corner
                  Positioned(
                    top: 0,
                    left: 0,
                    child: _buildCornerHook(isTop: true, isLeft: true),
                  ),
                  // Top Right Corner
                  Positioned(
                    top: 0,
                    right: 0,
                    child: _buildCornerHook(isTop: true, isLeft: false),
                  ),
                  // Bottom Left Corner
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: _buildCornerHook(isTop: false, isLeft: true),
                  ),
                  // Bottom Right Corner
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: _buildCornerHook(isTop: false, isLeft: false),
                  ),
                ],
              ),
            ),
          ),

          // ─── Ujung Lapisan Teks & Kontrol Tombol ──────────────────
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  // Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox.shrink(),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28.r,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    "Scan kondisi barang",
                    style: AppTypography.heading02.copyWith(
                      fontWeight: AppFontWeight.semiBold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Foto disimpan ke Cloud",
                    style: AppTypography.body02.copyWith(
                      fontWeight: AppFontWeight.regular,
                      color: const Color(0xFFDBDBDB),
                    ),
                  ),

                  const Spacer(),

                  // Button Unggah dari Galeri
                  Center(
                    child: GestureDetector(
                      onTap: _pickFromGallery,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 12.h,
                          horizontal: 36.w,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(1000.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Unggah dari Galeri",
                              style: AppTypography.body02.copyWith(
                                fontWeight: AppFontWeight.semiBold,
                                color: const Color(0xFF1F1E1F),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Icon(
                              Icons.file_upload_outlined,
                              color: const Color(0xFF1F1E1F),
                              size: 20.r,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Circular Shutter Capture Button
                  Center(
                    child: GestureDetector(
                      onTap: _takePicture,
                      child: Container(
                        width: 76.r,
                        height: 76.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4.w),
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          width: 58.r,
                          height: 58.r,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun hook sudut berwarna orange/kuning
  Widget _buildCornerHook({required bool isTop, required bool isLeft}) {
    const double size = 24.0;
    const double thickness = 4.0;
    final Color orangeColor = ColorValue.orange500;

    return SizedBox(
      width: size.r,
      height: size.r,
      child: Stack(
        children: [
          // Garis horizontal
          Positioned(
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            child: Container(
              width: size.r,
              height: thickness.h,
              decoration: BoxDecoration(
                color: orangeColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          // Garis vertikal
          Positioned(
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            child: Container(
              width: thickness.w,
              height: size.r,
              decoration: BoxDecoration(
                color: orangeColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter untuk menggambar overlay hitam transparan (72% opacity)
/// dengan lubang berbentuk rounded rectangle di tengah.
class _InvertedCutoutPainter extends CustomPainter {
  final double cutoutHeight;
  final double cutoutWidth;

  _InvertedCutoutPainter({
    required this.cutoutHeight,
    required this.cutoutWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.72);

    final rectPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutLeft = (size.width - cutoutWidth) / 2;
    final cutoutTop = (size.height - cutoutHeight) / 2;

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cutoutLeft, cutoutTop, cutoutWidth, cutoutHeight),
          Radius.circular(16.r),
        ),
      );

    final path = Path.combine(PathOperation.difference, rectPath, cutoutPath);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
