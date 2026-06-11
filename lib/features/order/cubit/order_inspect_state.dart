part of 'order_inspect_cubit.dart';

sealed class OrderInspectState {
  const OrderInspectState();
}

class OrderInspectInitial extends OrderInspectState {
  const OrderInspectInitial();
}

class OrderInspectUploading extends OrderInspectState {
  const OrderInspectUploading();
}

class OrderInspectSuccess extends OrderInspectState {
  final InspectResultModel result;
  final String localImagePath;
  final String localFileSize;

  const OrderInspectSuccess({
    required this.result,
    required this.localImagePath,
    required this.localFileSize,
  });
}

class OrderInspectFailure extends OrderInspectState {
  final String message;
  const OrderInspectFailure(this.message);
}
