import 'package:xml/xml.dart';

class Search {
  final String accountId;
  final String street;
  final String houseNumber;
  final String apartmentNumber;

  Search(
      {required this.accountId,
      required this.street,
      required this.houseNumber,
      required this.apartmentNumber});

  factory Search.fromXml(XmlElement xml) {
    return Search(
      accountId: xml.getAttribute('AccountId') ?? '',
      street: xml.getAttribute('Adres') ?? '',
      houseNumber: xml.getAttribute('Nd') ?? '',
      apartmentNumber: xml.getAttribute('Kv') ?? '',
    );
  }

  String toXml() {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('root', nest: () {
      builder.element('Adres', nest: () {
        builder.attribute('AccountId', accountId);
        builder.attribute('UlName', street);
        builder.attribute('Nd', houseNumber);
        builder.attribute('Kv', apartmentNumber);
      });
    });
    final document = builder.buildDocument();
    return document.toXmlString();
  }
}

class SearchModel {
  final String accountId;
  final String address;

  SearchModel({required this.accountId, required this.address});

  factory SearchModel.fromXml(XmlElement xml) {
    return SearchModel(
      accountId: xml.getAttribute('AccountId') ?? '',
      address: xml.getAttribute('Adress') ?? '',
    );
  }
}
