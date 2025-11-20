import 'package:moot_web/core/model/user_data_model.dart';

abstract class LoginRepository {
  Future<AuthModel> login({required String email, required String password});
}
