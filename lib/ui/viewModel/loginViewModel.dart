import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:xml/xml.dart';
import '../../data/model/login_model.dart';
import '../../data/model/user_model.dart';
import '../../domain/loginRepository.dart';

class LoginViewModel with ChangeNotifier {
  final LoginRepository loginRepository;
  LoginViewModel(this.loginRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _userId;
  String? get userId => _userId;

  void setUserId(String? id) {
    _userId = id;
    notifyListeners();
  }

  Future<LoginModel> login(User user) async {
    _isLoading = true;
    _errorMessage = null;
    late LoginModel loginModel;
    notifyListeners();

    try {
      final result = await loginRepository.login(user);
      if (result.response.statusCode == 200) {
        final xmlString = result.data;
        final document = XmlDocument.parse(xmlString);
        final userIdElement = document.findAllElements('UserId').first;
        loginModel = LoginModel.fromXml(userIdElement);
        log("Result: ${result.response.data}");
        log("Login Model: ${loginModel.firmaName} ${loginModel.id}}");
        return loginModel;
      }
    } catch (e) {
      _errorMessage = "Ошибка: $e";
      log("$_errorMessage");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return loginModel;
  }
}
