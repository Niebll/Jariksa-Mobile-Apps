import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:jariksa/core/storage/token_storage.dart';
import 'package:url_launcher/url_launcher.dart';

part 'order_payment_state.dart';

class OrderPaymentCubit extends Cubit<OrderPaymentState> {
  OrderPaymentCubit() : super(const OrderPaymentInitial());

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://vincent.bccdev.id/api',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// Reset state to initial
  void reset() {
    emit(const OrderPaymentInitial());
  }

  /// Create order on the server
  Future<void> createOrder({
    required int customerId,
    required int totalPrice,
    required int serviceId,
    required int itemPrice,
    int? scanId,
    required String paymentOption, // 'NOW' or 'LATER'
  }) async {
    emit(const OrderPaymentLoading());

    try {
      final token = await TokenStorage.getToken();

      // Build items payload matching standard API structure
      final List<Map<String, dynamic>> itemsPayload = [
        {
          'service_id': serviceId,
          'quantity': 1,
          'price': itemPrice,
          if (scanId != null) 'scan_id': scanId,
        }
      ];

      final Map<String, dynamic> requestData = {
        'customer_id': customerId,
        'total_price': totalPrice,
        'promo_code': '',
        'payment_option': paymentOption,
        'items': itemsPayload,
      };

      print('--- Order POST Request ---');
      print('URL: https://vincent.bccdev.id/api/orders');
      print('Body: $requestData');

      final response = await _dio.post(
        '/orders',
        data: requestData,
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      final responseData = response.data;
      print('--- Order POST Response ---');
      print('Data: $responseData');

      if (responseData != null && responseData['status'] == 'success') {
        final data = responseData['data'] as Map<String, dynamic>;
        
        String? redirectUrl;
        if (paymentOption == 'NOW' && data['payment'] != null) {
          redirectUrl = data['payment']['redirect_url'] as String?;
        }

        emit(OrderPaymentSuccess(
          orderData: data,
          redirectUrl: redirectUrl,
          paymentOption: paymentOption,
        ));

        // If redirect URL is present, launch it automatically
        if (redirectUrl != null && redirectUrl.isNotEmpty) {
          print('Launching Midtrans URL: $redirectUrl');
          final uri = Uri.parse(redirectUrl);
          try {
            await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
          } catch (launchError) {
            print('Error launching URL inAppBrowserView: $launchError. Trying external application...');
            try {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (externalError) {
              print('Failed to launch URL externally: $externalError');
            }
          }
        }
      } else {
        final message = responseData?['message'] as String? ?? 'Gagal membuat pesanan.';
        print('Order POST Error: $message');
        emit(OrderPaymentError(message));
      }
    } on DioException catch (e) {
      final parsedError = _parseDioError(e);
      print('Order POST DioException: $parsedError');
      print('DioException Details: $e');
      if (e.response != null) {
        print('DioException Response Data: ${e.response?.data}');
      }
      emit(OrderPaymentError(parsedError));
    } catch (e) {
      print('Order POST Unexpected Exception: $e');
      emit(OrderPaymentError('Terjadi kesalahan tidak terduga: $e'));
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
        return serverMessage ?? 'Gagal membuat pesanan (status: ${e.response?.statusCode}).';
      default:
        return 'Terjadi kesalahan jaringan.';
    }
  }
}
