import 'dart:convert';
import 'package:retrofit/retrofit.dart';
import '../../data/model/user_model.dart';
import '../../data/network/Api.dart';

class LoginRepository {
  late final Api _apiService;
  LoginRepository(this._apiService);

  Future<HttpResponse> login(User user) async {
    final xmlData = user.toXml();
    final encodedXml = base64Encode(utf8.encode(xmlData));

    return await _apiService.login(
        "test",
        "test",
        "40", // stype — фиксированное значение
        encodedXml);
  }

  Future<HttpResponse> getTypePrivateSector() async {
    return await _apiService.getType(
      "test",
      "test",
      "43", // stype — фиксированное значение
    );
  }
}
