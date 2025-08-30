import 'package:xml/xml.dart';

class User {
  final String login;
  final String password;
  final String pdaId;

  User({
    required this.login,
    required this.password,
    required this.pdaId,
  });

  String toXml() {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('root', nest: () {
      builder.element('User', nest: () {
        builder.attribute('UserName', login);
        builder.attribute('Password', password);
        builder.attribute('PdaId', pdaId);
      });
    });
    final document = builder.buildDocument();
    return document.toXmlString();
  }
}
