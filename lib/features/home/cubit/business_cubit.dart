import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:jariksa/core/storage/token_storage.dart';
import 'package:jariksa/features/home/models/business_model.dart';
import 'business_state.dart';

class BusinessCubit extends Cubit<BusinessState> {
  BusinessCubit() : super(const BusinessInitial());

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://vincent.bccdev.id/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// Fetch business profile details from API
  Future<void> fetchBusinessProfile() async {
    emit(const BusinessLoading());

    try {
      final token = await TokenStorage.getToken();

      final response = await _dio.get(
        '/business',
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      final responseData = response.data;
      if (responseData != null && responseData['status'] == 'success') {
        final data = responseData['data'] as Map<String, dynamic>;
        final business = BusinessModel.fromJson(data);
        emit(BusinessSuccess(business));
      } else {
        emit(const BusinessError('Gagal memuat profil bisnis.'));
      }
    } on DioException catch (e) {
      emit(BusinessError(_parseDioError(e)));
    } catch (e) {
      emit(BusinessError('Terjadi kesalahan tidak terduga: $e'));
    }
  }

  /// Parse DioException to user-friendly message
  String _parseDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout. Periksa internet Anda.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server.';
      case DioExceptionType.badResponse:
        final serverMessage = e.response?.data?['message'] as String?;
        return serverMessage ?? 'Gagal memuat profil bisnis (status: ${e.response?.statusCode}).';
      default:
        return 'Terjadi kesalahan jaringan.';
    }
  }
}
