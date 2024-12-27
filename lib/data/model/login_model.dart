import 'package:xml/xml.dart';

class LoginModel {
  final String id;
  final String firmaName;
  final String error;

  LoginModel({required this.id, required this.firmaName, required this.error});

  factory LoginModel.fromXml(XmlElement xml) {
    return LoginModel(
      id: xml.getAttribute('ID') ?? '',
      firmaName: xml.getAttribute('FirmaName') ?? '',
      error: xml.getAttribute('Errmsg') ?? '',
    );
  }
}
