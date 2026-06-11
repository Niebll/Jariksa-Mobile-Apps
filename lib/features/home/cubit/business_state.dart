import 'package:jariksa/features/home/models/business_model.dart';

sealed class BusinessState {
  const BusinessState();
}

class BusinessInitial extends BusinessState {
  const BusinessInitial();
}

class BusinessLoading extends BusinessState {
  const BusinessLoading();
}

class BusinessSuccess extends BusinessState {
  final BusinessModel business;
  const BusinessSuccess(this.business);
}

class BusinessError extends BusinessState {
  final String message;
  const BusinessError(this.message);
}
