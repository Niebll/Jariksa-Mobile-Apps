import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:jariksa/core/storage/token_storage.dart';
import 'package:jariksa/features/order/models/customer_model.dart';

part 'customer_check_state.dart';

class CustomerCheckCubit extends Cubit<CustomerCheckState> {
  CustomerCheckCubit() : super(const CustomerCheckInitial());

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://vincent.bccdev.id/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Timer? _debounceTimer;

  /// Reset state to initial
  void reset() {
    _debounceTimer?.cancel();
    emit(const CustomerCheckInitial());
  }

  /// Helper untuk mem-parse body response menjadi Map secara aman.
  Map<String, dynamic>? _getResponseBody(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    if (data is String) {
      try {
        return jsonDecode(data) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Trigger customer check with a 600ms debounce mechanism.
  void checkCustomer(String rawValue) {
    // 1. Ambil digit saja
    String digits = rawValue.replaceAll(RegExp(r'[^0-9]'), '');
    // 2. Buang leading 0 jika ada
    digits = digits.replaceFirst(RegExp(r'^0+'), '');

    // Jika panjang nomor terlalu pendek (kurang dari 9 digit setelah prefix),
    // cancel timer dan kembali ke state initial agar card tidak muncul/loading.
    if (digits.length < 9) {
      _debounceTimer?.cancel();
      emit(const CustomerCheckInitial());
      return;
    }

    // Cancel timer sebelumnya untuk mereset debounce
    _debounceTimer?.cancel();

    // Jalankan timer baru dengan durasi 600ms
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      _executeCheck(digits);
    });
  }

  /// Eksekusi call API
  Future<void> _executeCheck(String digits) async {
    emit(const CustomerCheckLoading());

    // Prepend '0' di depan digit sesuai spec API
    final formattedPhone = '0$digits';

    try {
      final token = await TokenStorage.getToken();
      
      final response = await _dio.get(
        '/customers/check',
        data: {'phone_number': formattedPhone},
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      final responseData = _getResponseBody(response.data);
      if (responseData != null && responseData['status'] == 'success') {
        final data = responseData['data'] as Map<String, dynamic>;
        final customer = CustomerModel.fromJson(data);
        emit(CustomerCheckSuccess(customer));
      } else {
        final message = responseData?['message'] as String? ?? 'Gagal memverifikasi pelanggan.';
        emit(CustomerCheckNotFound(message));
      }
    } on DioException catch (e) {
      final responseData = _getResponseBody(e.response?.data);
      if (e.response?.statusCode == 404 || responseData?['status'] == 'not_found') {
        final serverMessage = responseData?['message'] as String? ?? 'Customer tidak ditemukan';
        emit(CustomerCheckNotFound(serverMessage));
      } else {
        emit(CustomerCheckError(_parseDioError(e)));
      }
    } catch (e) {
      emit(CustomerCheckError('Terjadi kesalahan: $e'));
    }
  }

  /// Register a new customer via POST `/customers`
  Future<void> registerCustomer(String name, String rawPhone) async {
    emit(const CustomerCheckLoading());

    // Format phone number to start with '0'
    String digits = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
    digits = digits.replaceFirst(RegExp(r'^0+'), '');
    final formattedPhone = '0$digits';

    try {
      final token = await TokenStorage.getToken();

      final response = await _dio.post(
        '/customers',
        data: {
          'name': name,
          'phone_number': formattedPhone,
        },
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      final responseData = _getResponseBody(response.data);
      if (responseData != null && responseData['status'] == 'success') {
        final data = responseData['data'] as Map<String, dynamic>;
        final customer = CustomerModel.fromJson(data);
        emit(CustomerCheckSuccess(customer));
      } else {
        final message = responseData?['message'] as String? ?? 'Gagal mendaftarkan pelanggan.';
        emit(CustomerCheckError(message));
      }
    } on DioException catch (e) {
      final responseData = _getResponseBody(e.response?.data);
      final serverMessage = responseData?['message'] as String?;
      emit(CustomerCheckError(serverMessage ?? _parseDioError(e)));
    } catch (e) {
      emit(CustomerCheckError('Terjadi kesalahan: $e'));
    }
  }

  /// Parse DioException menjadi pesan yang user-friendly.
  String _parseDioError(DioException e) {
    final responseData = _getResponseBody(e.response?.data);
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout. Periksa internet Anda.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server.';
      case DioExceptionType.badResponse:
        final serverMessage = responseData?['message'] as String?;
        return serverMessage ?? 'Gagal memverifikasi (status: ${e.response?.statusCode}).';
      default:
        return 'Terjadi kesalahan jaringan.';
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
