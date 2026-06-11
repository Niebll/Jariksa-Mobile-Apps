part of 'order_payment_cubit.dart';

sealed class OrderPaymentState {
  const OrderPaymentState();
}

class OrderPaymentInitial extends OrderPaymentState {
  const OrderPaymentInitial();
}

class OrderPaymentLoading extends OrderPaymentState {
  const OrderPaymentLoading();
}

class OrderPaymentSuccess extends OrderPaymentState {
  final Map<String, dynamic> orderData;
  final String? redirectUrl;
  final String paymentOption;

  const OrderPaymentSuccess({
    required this.orderData,
    this.redirectUrl,
    required this.paymentOption,
  });
}

class OrderPaymentError extends OrderPaymentState {
  final String message;
  const OrderPaymentError(this.message);
}
