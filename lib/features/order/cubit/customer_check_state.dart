part of 'customer_check_cubit.dart';

sealed class CustomerCheckState {
  const CustomerCheckState();
}

class CustomerCheckInitial extends CustomerCheckState {
  const CustomerCheckInitial();
}

class CustomerCheckLoading extends CustomerCheckState {
  const CustomerCheckLoading();
}

class CustomerCheckSuccess extends CustomerCheckState {
  final CustomerModel customer;
  const CustomerCheckSuccess(this.customer);
}

class CustomerCheckNotFound extends CustomerCheckState {
  final String message;
  const CustomerCheckNotFound(this.message);
}

class CustomerCheckError extends CustomerCheckState {
  final String message;
  const CustomerCheckError(this.message);
}
