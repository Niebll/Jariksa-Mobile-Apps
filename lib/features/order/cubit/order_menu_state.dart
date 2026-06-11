part of 'order_menu_cubit.dart';

sealed class OrderMenuState {
  const OrderMenuState();
}

class OrderMenuInitial extends OrderMenuState {
  const OrderMenuInitial();
}

class OrderMenuLoading extends OrderMenuState {
  const OrderMenuLoading();
}

class OrderMenuSuccess extends OrderMenuState {
  final List<MenuCategoryModel> categories;
  final int selectedCategoryId;
  final int? selectedServiceId;

  const OrderMenuSuccess({
    required this.categories,
    required this.selectedCategoryId,
    this.selectedServiceId,
  });

  OrderMenuSuccess copyWith({
    List<MenuCategoryModel>? categories,
    int? selectedCategoryId,
    int? selectedServiceId,
    bool clearSelectedService = false,
  }) {
    return OrderMenuSuccess(
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedServiceId: clearSelectedService ? null : (selectedServiceId ?? this.selectedServiceId),
    );
  }
}

class OrderMenuError extends OrderMenuState {
  final String message;
  const OrderMenuError(this.message);
}
