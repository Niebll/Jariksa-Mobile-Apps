part of 'home_cubit.dart';

sealed class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeSuccess extends HomeState {
  final DashboardModel dashboard;
  HomeSuccess(this.dashboard);
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
