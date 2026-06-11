import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:jariksa/core/storage/token_storage.dart';
import 'package:jariksa/features/home/models/dashboard_model.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://vincent.bccdev.id/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// Fetch dashboard data from API.
  Future<void> fetchDashboard() async {
    emit(HomeLoading());

    try {
      final token = await TokenStorage.getToken();
      
      final response = await _dio.get(
        '/dashboard',
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      final responseData = response.data;
      if (responseData != null && responseData['status'] == 'success') {
        final dashboardData = responseData['data'] as Map<String, dynamic>;
        final dashboard = DashboardModel.fromJson(dashboardData);
        emit(HomeSuccess(dashboard));
      } else {
        emit(HomeError('Gagal memuat data dashboard.'));
      }
    } on DioException catch (e) {
      emit(HomeError(_parseDioError(e)));
    } catch (e) {
      emit(HomeError('Terjadi kesalahan tidak terduga: $e'));
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
        final serverMessage = e.response?.data?['message'] as String?;
        return serverMessage ?? _httpStatusMessage(e.response?.statusCode);
      default:
        return 'Gagal memuat dashboard. Silakan coba lagi.';
    }
  }

  /// Pesan fallback berdasarkan HTTP status code.
  String _httpStatusMessage(int? statusCode) {
    return switch (statusCode) {
      400 => 'Permintaan tidak valid.',
      401 => 'Sesi Anda telah berakhir. Silakan login kembali.',
      403 => 'Anda tidak memiliki akses.',
      404 => 'Halaman tidak ditemukan.',
      500 || 502 || 503 => 'Server sedang bermasalah. Coba lagi nanti.',
      _ => 'Gagal memuat data (kode: $statusCode).',
    };
  }
}
