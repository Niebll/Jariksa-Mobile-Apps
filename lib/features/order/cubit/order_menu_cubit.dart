import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:jariksa/core/storage/token_storage.dart';
import 'package:jariksa/features/order/models/order_menu_model.dart';

part 'order_menu_state.dart';

class OrderMenuCubit extends Cubit<OrderMenuState> {
  OrderMenuCubit() : super(const OrderMenuInitial());

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://vincent.bccdev.id/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// Fetch category and service list from `/business/menu`
  Future<void> fetchMenu() async {
    emit(const OrderMenuLoading());

    try {
      final token = await TokenStorage.getToken();

      final response = await _dio.get(
        '/business/menu',
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      final responseData = response.data;
      if (responseData != null && responseData['status'] == 'success') {
        final rawList = responseData['data'] as List? ?? [];
        final categories = rawList
            .map((item) => MenuCategoryModel.fromJson(item as Map<String, dynamic>))
            .toList();

        if (categories.isNotEmpty) {
          emit(OrderMenuSuccess(
            categories: categories,
            selectedCategoryId: categories.first.categoryId,
            selectedServiceId: null,
          ));
        } else {
          emit(const OrderMenuError('Menu kategori tidak tersedia.'));
        }
      } else {
        emit(const OrderMenuError('Gagal memuat daftar menu layanan.'));
      }
    } on DioException catch (e) {
      emit(OrderMenuError(_parseDioError(e)));
    } catch (e) {
      emit(OrderMenuError('Terjadi kesalahan tidak terduga: $e'));
    }
  }

  /// Change selected category
  void selectCategory(int categoryId) {
    final currentState = state;
    if (currentState is OrderMenuSuccess) {
      emit(currentState.copyWith(
        selectedCategoryId: categoryId,
        clearSelectedService: true,
      ));
    }
  }

  /// Change selected service
  void selectService(int serviceId) {
    final currentState = state;
    if (currentState is OrderMenuSuccess) {
      emit(currentState.copyWith(
        selectedServiceId: serviceId,
      ));
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
        return serverMessage ?? 'Gagal memverifikasi (status: ${e.response?.statusCode}).';
      default:
        return 'Terjadi kesalahan jaringan.';
    }
  }
}
