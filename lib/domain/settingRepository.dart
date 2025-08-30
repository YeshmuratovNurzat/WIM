import 'dart:convert';

import 'package:retrofit/dio.dart';

import '../data/model/search_model.dart';
import '../data/model/water_meter_model.dart';
import '../data/network/api.dart';

class SettingRepository {
  late final Api _apiService;
  SettingRepository(this._apiService);

  Future<HttpResponse> getTypePrivateSector() async {
    return await _apiService.getType(
      "test",
      "test",
      "46", // stype — Частный сектор
    );
  }

  Future<HttpResponse> getTypeApartmentSector() async {
    return await _apiService.getType(
      "test",
      "test",
      "45", // stype — Многоквартирный сектор
    );
  }

  Future<HttpResponse> getTypeLegalSector() async {
    return await _apiService.getType(
      "test",
      "test",
      "53", //stype — Юредический сектор
    );
  }

  Future<HttpResponse> getPlaces() async {
    return await _apiService.getPlaces(
      "test",
      "test",
      "55", // stype — фиксированное значение
    );
  }

  Future<HttpResponse> getClass() async {
    return await _apiService.getClass(
      "test",
      "test",
      "47", // stype — фиксированное значение
    );
  }

  Future<HttpResponse> getSituationsPrivateSector() async {
    return await _apiService.getSituations(
      "test",
      "test",
      "44", // stype — Частный сектор
    );
  }

  Future<HttpResponse> getSituationsApartmentSector() async {
    return await _apiService.getSituations(
      "test",
      "test",
      "43", // stype — Многоквартирный сектор
    );
  }

  Future<HttpResponse> getSituationsLegalSector() async {
    return await _apiService.getSituations(
      "test",
      "test",
      "52", // stype — Юредический сектор
    );
  }

  Future<HttpResponse> search(Search search, String stype) async {
    final xmlData = search.toXml();
    final encodedXml = base64Encode(utf8.encode(xmlData));
    String type = '';
    if (stype == "0") {
      type = '41'; // Юредический сектор
    } else if (stype == "1") {
      type = '42'; // Частный сектор
    } else {
      type = '51'; // Многоквартирный сектор
    }

    return await _apiService.getSearch(
        "test",
        "test",
        type, // stype — фиксированное значение
        encodedXml);
  }

  Future<HttpResponse> getWaterMetersPrivateSector(Account account) async {
    final xmlData = account.toXml();
    final encodedXml = base64Encode(utf8.encode(xmlData));

    return await _apiService.getWaterMeters(
        "test",
        "test",
        "49", // stype — Частный сектор
        encodedXml);
  }

  Future<HttpResponse> getWaterMetersApartmentSector(Account account) async {
    final xmlData = account.toXml();
    final encodedXml = base64Encode(utf8.encode(xmlData));

    return await _apiService.getWaterMeters(
        "test",
        "test",
        "48", // stype — Многоквартирный сектор
        encodedXml);
  }

  Future<HttpResponse> getWaterMetersLegalSector(Account account) async {
    final xmlData = account.toXml();
    final encodedXml = base64Encode(utf8.encode(xmlData));

    return await _apiService.getWaterMeters(
        "test",
        "test",
        "54", // stype — Юредический сектор
        encodedXml);
  }

  Future<HttpResponse> sendAct(String data) async {
    // final xmlData = act.toXml(waterMeter);
    final encodedXml = base64Encode(utf8.encode(data));
    return await _apiService.sendAct(
        "test",
        "test",
        "56", // stype — Многоквартирный сектор 50
        encodedXml);
  }
}
