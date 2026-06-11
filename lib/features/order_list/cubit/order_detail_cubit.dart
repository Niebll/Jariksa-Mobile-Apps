import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:jariksa/core/storage/token_storage.dart';
import 'package:jariksa/features/order_list/models/order_detail_model.dart';
import 'order_detail_state.dart';

class OrderDetailCubit extends Cubit<OrderDetailState> {
  OrderDetailCubit() : super(const OrderDetailInitial());

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://vincent.bccdev.id/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// Fetch order details by ID
  Future<void> fetchOrderDetail(int id) async {
    emit(const OrderDetailLoading());

    try {
      final token = await TokenStorage.getToken();

      final response = await _dio.get(
        '/orders/$id',
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      final responseData = response.data;
      if (responseData != null && responseData['status'] == 'success') {
        final data = responseData['data'] as Map<String, dynamic>;
        final order = OrderDetailModel.fromJson(data);
        emit(OrderDetailSuccess(order));
      } else {
        emit(const OrderDetailError('Gagal memuat rincian pesanan.'));
      }
    } on DioException catch (e) {
      emit(OrderDetailError(_parseDioError(e)));
    } catch (e) {
      emit(OrderDetailError('Terjadi kesalahan tidak terduga: $e'));
    }
  }

  /// Reset state to initial
  void reset() {
    emit(const OrderDetailInitial());
  }

  /// Update order status
  Future<bool> updateOrderStatus(int id, String newStatus) async {
    try {
      final token = await TokenStorage.getToken();

      final response = await _dio.put(
        '/orders/$id/status',
        data: {'status': newStatus},
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      final responseData = response.data;
      if (responseData != null && responseData['status'] == 'success') {
        // Fetch updated order details
        await fetchOrderDetail(id);
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
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
        return serverMessage ?? 'Gagal memuat rincian pesanan (status: ${e.response?.statusCode}).';
      default:
        return 'Terjadi kesalahan jaringan.';
    }
  }
}
