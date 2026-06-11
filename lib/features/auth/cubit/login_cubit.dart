import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:jariksa/core/storage/token_storage.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://vincent.bccdev.id/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// Kirim request login ke server.
  /// Emit [LoginLoading] → [LoginSuccess] atau [LoginError].
  Future<void> login({required String email, required String password}) async {
    emit(LoginLoading());

    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      // Pastikan response.data diparsing ke Map jika tipenya String
      Map<String, dynamic>? dataMap;
      if (response.data is Map) {
        dataMap = Map<String, dynamic>.from(response.data as Map);
      } else if (response.data is String) {
        dataMap = jsonDecode(response.data as String) as Map<String, dynamic>;
      }

      // Ambil token dari respons
      final token = dataMap?['data']?['token'] as String?;

      if (token != null && token.isNotEmpty) {
        await TokenStorage.saveToken(token);
        emit(LoginSuccess(token));
        print("Token : $token");
      } else {
        emit(LoginError('Token tidak ditemukan dalam respons server.'));
      }
    } on DioException catch (e) {
      emit(LoginError(_parseDioError(e)));
    } catch (e, stackTrace) {
      print('Error detail: $e');
      print('Stacktrace: $stackTrace');
      emit(
        LoginError('Terjadi kesalahan tidak terduga: $e. Silakan coba lagi.'),
      );
    }
  }

  /// Parse DioException menjadi pesan yang user-friendly.
  String _parseDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout. Periksa koneksi internet Anda.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      case DioExceptionType.badResponse:
        // Coba ambil pesan dari body respons server (misal: {"message": "..."})
        final serverMessage = e.response?.data?['message'] as String?;
        return serverMessage ?? _httpStatusMessage(e.response?.statusCode);
      default:
        return 'Login gagal. Silakan coba lagi.';
    }
  }

  /// Pesan fallback berdasarkan HTTP status code
  String _httpStatusMessage(int? statusCode) {
    return switch (statusCode) {
      400 => 'Permintaan tidak valid. Periksa email dan kata sandi.',
      401 => 'Email atau kata sandi salah.',
      403 => 'Akun Anda tidak memiliki akses.',
      404 => 'Server tidak ditemukan.',
      500 || 502 || 503 => 'Server sedang bermasalah. Coba lagi nanti.',
      _ => 'Login gagal (kode: $statusCode).',
    };
  }
}
