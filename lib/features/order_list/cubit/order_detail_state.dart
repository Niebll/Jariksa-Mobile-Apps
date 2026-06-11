import 'package:jariksa/features/order_list/models/order_detail_model.dart';

sealed class OrderDetailState {
  const OrderDetailState();
}

class OrderDetailInitial extends OrderDetailState {
  const OrderDetailInitial();
}

class OrderDetailLoading extends OrderDetailState {
  const OrderDetailLoading();
}

class OrderDetailSuccess extends OrderDetailState {
  final OrderDetailModel order;
  const OrderDetailSuccess(this.order);
}

class OrderDetailError extends OrderDetailState {
  final String message;
  const OrderDetailError(this.message);
}
