import 'dart:io';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:jariksa/core/storage/token_storage.dart';
import 'package:jariksa/features/order/models/inspect_result_model.dart';

part 'order_inspect_state.dart';

class OrderInspectCubit extends Cubit<OrderInspectState> {
  OrderInspectCubit() : super(const OrderInspectInitial());

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://vincent.bccdev.id/api',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  /// Reset state to initial
  void reset() {
    emit(const OrderInspectInitial());
  }

  /// Upload captured or selected image for AI analysis
  Future<void> uploadImage(String filePath) async {
    emit(const OrderInspectUploading());

    try {
      final token = await TokenStorage.getToken();
      final fileName = filePath.split(Platform.isWindows ? '\\' : '/').last;
      final fileSize = _getFileSizeString(filePath);

      // Construct form-data matching the Postman specification
      final formData = FormData.fromMap({
        'images': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/ai/scan-batch',
        data: formData,
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      final responseData = response.data;
      if (responseData is Map && responseData['success'] == true) {
        final result = InspectResultModel.fromJson(responseData as Map<String, dynamic>);
        emit(OrderInspectSuccess(
          result: result,
          localImagePath: filePath,
          localFileSize: fileSize,
        ));
      } else {
        String? message;
        if (responseData is Map) {
          message = responseData['message'] as String?;
        }
        emit(OrderInspectFailure(message ?? 'Gagal menganalisis gambar.'));
      }
    } on DioException catch (e) {
      emit(OrderInspectFailure(_parseDioError(e)));
    } catch (e) {
      emit(OrderInspectFailure('Terjadi kesalahan tidak terduga: $e'));
    }
  }

  /// Format file size from bytes
  String _getFileSizeString(String filePath) {
    try {
      final file = File(filePath);
      final bytes = file.lengthSync();
      if (bytes <= 0) return "0 B";
      const suffixes = ["B", "KB", "MB", "GB"];
      var i = (log(bytes) / log(1024)).floor();
      return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
    } catch (_) {
      return "0 B";
    }
  }

  /// Parse DioException to user-friendly message
  String _parseDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout saat mengunggah foto. Periksa internet Anda.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server untuk mengunggah foto.';
      case DioExceptionType.badResponse:
        String? serverMessage;
        final data = e.response?.data;
        if (data is Map) {
          serverMessage = data['message'] as String?;
        } else if (data is String) {
          serverMessage = data;
        }
        return serverMessage ?? 'Gagal mengunggah (status: ${e.response?.statusCode}).';
      default:
        return 'Terjadi kesalahan jaringan saat mengunggah foto.';
    }
  }
}
