import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';
import 'package:retrofit/retrofit.dart';

part "api.g.dart";

@RestApi(baseUrl: "http://as-portal.kz:442/default.aspx")
abstract class Api {
  factory Api(Dio dio, {String baseUrl}) = _Api;

  // Логин
  @POST("")
  @FormUrlEncoded()
  Future<HttpResponse> login(
    @Field("username") String username,
    @Field("password") String password,
    @Field("stype") String stype,
    @Field("str") String str,
  );

  // Тип прибора учёта
  @GET("")
  @FormUrlEncoded()
  Future<HttpResponse> getType(
    @Field("username") String username,
    @Field("password") String password,
    @Field("stype") String stype,
  );

  // Место установки
  @GET("")
  @FormUrlEncoded()
  Future<HttpResponse> getPlaces(
    @Field("username") String username,
    @Field("password") String password,
    @Field("stype") String stype,
  );

  // Класс ИПУ
  @GET("")
  @FormUrlEncoded()
  Future<HttpResponse> getClass(
    @Field("username") String username,
    @Field("password") String password,
    @Field("stype") String stype,
  );

  // Типичная ситуация
  @GET("")
  @FormUrlEncoded()
  Future<HttpResponse> getSituations(
    @Field("username") String username,
    @Field("password") String password,
    @Field("stype") String stype,
  );

  // Поиск по  л/с и адрес
  @POST("")
  @FormUrlEncoded()
  Future<HttpResponse> getSearch(
    @Field("username") String username,
    @Field("password") String password,
    @Field("stype") String stype,
    @Field("str") String str,
  );

  //Запрос водомеров по ID счёта
  @POST("")
  @FormUrlEncoded()
  Future<HttpResponse> getWaterMeters(
    @Field("username") String username,
    @Field("password") String password,
    @Field("stype") String stype,
    @Field("str") String str,
  );

  //Запрос отправления акта на сервер
  @POST("")
  @FormUrlEncoded()
  Future<HttpResponse> sendAct(
    @Field("username") String username,
    @Field("password") String password,
    @Field("stype") String stype,
    @Field("str") String str,
  );
}
