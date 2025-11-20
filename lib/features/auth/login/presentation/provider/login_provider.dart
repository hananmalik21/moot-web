import 'package:flutter/cupertino.dart';
import 'package:moot_web/core/data/app_exceptions.dart';
import 'package:moot_web/core/model/user_data_model.dart';
import 'package:moot_web/features/auth/login/data/repository/login_repository_impl.dart';

class LoginProvider extends ChangeNotifier {
  final LoginRepositoryImpl _loginRepository = LoginRepositoryImpl();


  final emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');

  bool loading = false;
  bool isButtonEnable = false;

  setLoading(bool val) {
    loading = val;
    notifyListeners();
  }

  Future<dynamic> login({
    required String password,
    required String email,
    required Function(AuthModel userData) onSuccess,
    required Function(String message) onFailure,
  }) async {
    if (email.isEmpty) {
      throw MissingFieldsException("Please enter valid email");
    }
    if (password.isEmpty) {
      throw MissingFieldsException("Please enter password");
    }
    setLoading(true);
    await _loginRepository
        .login(email: email, password: password)
        .then((value) {
      final AuthModel userData = value;
      onSuccess(userData);
    })
        .catchError((err) {
      onFailure(err.toString());
    });
    setLoading(false);
  }

  void setButtonEnable(String val,String email, String password) {
    if (email.isNotEmpty && password.isNotEmpty) {
      isButtonEnable = true;
    } else {
      isButtonEnable = false;
    }

    notifyListeners();
  }
}
