import 'dart:developer';

import 'package:xml/xml.dart';

class Account {
  final String AccountId;
  final String UchrId;

  Account({
    required this.AccountId,
    required this.UchrId,
  });

  factory Account.fromXml(XmlElement xml) {
    return Account(
      AccountId: xml.getAttribute('AccountId') ?? '',
      UchrId: xml.getAttribute('UchrId') ?? '',
    );
  }

  String toXml() {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('root', nest: () {
      builder.element('Account', nest: () {
        builder.attribute('AccountId', AccountId);
        builder.attribute('UchrId', UchrId);
      });
    });
    final document = builder.buildDocument();
    log("xml ${document.toXmlString()}");
    return document.toXmlString();
  }
}

class WaterMeterModel {
  final String id;
  final String ActId;
  final String CounterId;
  final String Kpuid;
  final String Calibr;
  final String TypeMeterId;
  final String SerialNumber;
  final String DateVerif;
  final String ActionId;
  final String SealNumber;
  final String StatusId;
  final String Readout;
  final String TypSituId;
  final String PhotoName;
  final String CdDate;
  final String RpuId;
  final String Diameter;

  WaterMeterModel({
    required this.id,
    required this.ActId,
    required this.CounterId,
    required this.Kpuid,
    required this.Calibr,
    required this.TypeMeterId,
    required this.SerialNumber,
    required this.DateVerif,
    required this.ActionId,
    required this.SealNumber,
    required this.StatusId,
    required this.Readout,
    required this.TypSituId,
    required this.PhotoName,
    required this.CdDate,
    required this.RpuId,
    required this.Diameter,
  });

  factory WaterMeterModel.fromXml(XmlElement xml) {
    return WaterMeterModel(
      id: xml.getAttribute('id') ?? '',
      ActId: xml.getAttribute('act_id') ?? '',
      CounterId: xml.getAttribute('CounterId') ?? '',
      Kpuid: xml.getAttribute('Kpuid') ?? '',
      Calibr: xml.getAttribute('Adress') ?? '',
      TypeMeterId: xml.getAttribute('TypeMeterId') ?? '',
      SerialNumber: xml.getAttribute('SerialNumber') ?? '',
      DateVerif: xml.getAttribute('DateVerif') ?? '',
      ActionId: xml.getAttribute('ActionId') ?? '',
      SealNumber: xml.getAttribute('SealNumber') ?? '',
      StatusId: xml.getAttribute('StatusId') ?? '',
      Readout: xml.getAttribute('Readout') ?? '',
      TypSituId: xml.getAttribute('TypSituId') ?? '',
      PhotoName: xml.getAttribute('PhotoName') ?? '',
      CdDate: xml.getAttribute('CdDate') ?? '',
      RpuId: xml.getAttribute('RpuId') ?? '',
      Diameter: xml.getAttribute('Diameter') ?? '',
    );
  }

  String toXml() {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('root', nest: () {
      builder.element('Counter', nest: () {
        builder.attribute('CounterId', CounterId);
        builder.attribute('Kpuid', Kpuid);
        builder.attribute('TypeMeterId', TypeMeterId);
        builder.attribute('TypSituId', TypSituId);
        builder.attribute('SerialNumber', SerialNumber);
        builder.attribute('DateVerif', DateVerif);
        builder.attribute('ActionId', ActionId);
        builder.attribute('SealNumber', SealNumber);
        builder.attribute('Readout', Readout);
        builder.attribute('CdDate', CdDate);
        builder.attribute('RpuId', RpuId);
        builder.attribute('Diameter', Diameter);
      });
      builder.element('Photo', nest: PhotoName);
    });
    final document = builder.buildDocument();
    log("xml ${document.toXmlString()}");
    return document.toXmlString();
  }
}
