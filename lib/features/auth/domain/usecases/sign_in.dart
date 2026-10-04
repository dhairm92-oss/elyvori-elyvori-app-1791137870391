import '../../../../core/error/failure.dart';
import '../../../../core/result/result.dart';
import '../entities/session.dart';
import '../repositories/auth_repository.dart';

class SignIn {
  const SignIn(this._repository);

  final AuthRepository _repository;

  Future<Result<Session>> call({required String email, required String password}) async {
    final cleanEmail = email.trim().toLowerCase();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(cleanEmail)) {
      return const Result.failure(Failure('Please enter a valid email.'));
    }
    if (password.length < 6) {
      return const Result.failure(Failure('The password must be at least 6 characters.'));
    }
    return _repository.signIn(email: cleanEmail, password: password);
  }
}
