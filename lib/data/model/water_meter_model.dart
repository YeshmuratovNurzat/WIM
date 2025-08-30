import 'dart:developer';

import 'package:xml/xml.dart';

class Account {
  final String accountId;
  final String uchrId;

  Account({
    required this.accountId,
    required this.uchrId,
  });

  factory Account.fromXml(XmlElement xml) {
    return Account(
      accountId: xml.getAttribute('AccountId') ?? '',
      uchrId: xml.getAttribute('UchrId') ?? '',
    );
  }

  String toXml() {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('root', nest: () {
      builder.element('Account', nest: () {
        builder.attribute('AccountId', accountId);
        builder.attribute('UchrId', uchrId);
      });
    });
    final document = builder.buildDocument();
    log("xml ${document.toXmlString()}");
    return document.toXmlString();
  }
}

class WaterMeterModel {
  final String id;
  final String actId;
  final String counterId;
  final String kpuid;
  final String calibr;
  final String typeMeterId;
  final String serialNumber;
  final String dateVerif;
  final String actionId;
  final String sealNumber;
  final String statusId;
  final String readout;
  final String typSituId;
  final String photoName;
  final String photoNameActOutputs;
  final String cdDate;
  final String rpuId;
  final String diameter;

  WaterMeterModel({
    required this.id,
    required this.actId,
    required this.counterId,
    required this.kpuid,
    required this.calibr,
    required this.typeMeterId,
    required this.serialNumber,
    required this.dateVerif,
    required this.actionId,
    required this.sealNumber,
    required this.statusId,
    required this.readout,
    required this.typSituId,
    required this.photoName,
    required this.photoNameActOutputs,
    required this.cdDate,
    required this.rpuId,
    required this.diameter,
  });

  factory WaterMeterModel.fromXml(XmlElement xml) {
    return WaterMeterModel(
      id: xml.getAttribute('id') ?? '',
      actId: xml.getAttribute('act_id') ?? '',
      counterId: xml.getAttribute('CounterId') ?? '',
      kpuid: xml.getAttribute('Kpuid') ?? '',
      calibr: xml.getAttribute('Adress') ?? '',
      typeMeterId: xml.getAttribute('TypeMeterId') ?? '',
      serialNumber: xml.getAttribute('SerialNumber') ?? '',
      dateVerif: xml.getAttribute('DateVerif') ?? '',
      actionId: xml.getAttribute('ActionId') ?? '',
      sealNumber: xml.getAttribute('SealNumber') ?? '',
      statusId: xml.getAttribute('StatusId') ?? '',
      readout: xml.getAttribute('Readout') ?? '',
      typSituId: xml.getAttribute('TypSituId') ?? '',
      photoName: xml.getAttribute('PhotoName') ?? '',
      photoNameActOutputs: xml.getAttribute('PhotoNameActOutputs') ?? '',
      cdDate: xml.getAttribute('CdDate') ?? '',
      rpuId: xml.getAttribute('RpuId') ?? '',
      diameter: xml.getAttribute('Diameter') ?? '',
    );
  }

  String toXml() {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('root', nest: () {
      builder.element('Counter', nest: () {
        builder.attribute('CounterId', counterId);
        builder.attribute('Kpuid', kpuid);
        builder.attribute('TypeMeterId', typeMeterId);
        builder.attribute('TypSituId', typSituId);
        builder.attribute('SerialNumber', serialNumber);
        builder.attribute('DateVerif', dateVerif);
        builder.attribute('ActionId', actionId);
        builder.attribute('SealNumber', sealNumber);
        builder.attribute('Readout', readout);
        builder.attribute('CdDate', cdDate);
        builder.attribute('RpuId', rpuId);
        builder.attribute('Diameter', diameter);
      });
      builder.element('Photo', nest: photoName);
    });
    final document = builder.buildDocument();
    log("xml ${document.toXmlString()}");
    return document.toXmlString();
  }
}
