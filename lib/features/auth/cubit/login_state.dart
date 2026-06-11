part of 'login_cubit.dart';

/// Sealed base class untuk semua state Login
sealed class LoginState {}

/// State awal sebelum ada aksi apapun
class LoginInitial extends LoginState {}

/// State saat request sedang dikirim ke server
class LoginLoading extends LoginState {}

/// State sukses — membawa token yang diterima dari server
class LoginSuccess extends LoginState {
  final String token;
  LoginSuccess(this.token);
}

/// State error — membawa pesan yang akan ditampilkan ke user
class LoginError extends LoginState {
  final String message;
  LoginError(this.message);
}
