import 'dart:developer';

import 'package:WIM/data/model/water_meter_model.dart';
import 'package:xml/xml.dart';

class SendActModel {
  final String actId;
  final String numAct;
  final String sector;
  final String dtDate;
  final String userId;
  final String accountId;
  final String uchrId;
  final String pdaId;
  final String lat;
  final String lon;
  final String alt;
  final String telMob;
  final String telDom;
  final String file;

  SendActModel(
      {required this.actId,
      required this.numAct,
      required this.sector,
      required this.dtDate,
      required this.userId,
      required this.accountId,
      required this.uchrId,
      required this.pdaId,
      required this.lat,
      required this.lon,
      required this.alt,
      required this.telMob,
      required this.telDom,
      required this.file});

  factory SendActModel.fromXml(XmlElement xml) {
    return SendActModel(
      actId: xml.getAttribute('ActId') ?? '',
      numAct: xml.getAttribute('NumAct') ?? '',
      sector: xml.getAttribute('Sector') ?? '',
      dtDate: xml.getAttribute('DtDate') ?? '',
      userId: xml.getAttribute('UserId') ?? '',
      accountId: xml.getAttribute('AccountId') ?? '',
      uchrId: xml.getAttribute('UchrId') ?? '',
      pdaId: xml.getAttribute('PdaId') ?? '',
      lat: xml.getAttribute('Lat') ?? '',
      lon: xml.getAttribute('Lon') ?? '',
      alt: xml.getAttribute('Alt') ?? '',
      telMob: xml.getAttribute('TelMob') ?? '',
      telDom: xml.getAttribute('TelDom') ?? '',
      file: xml.getAttribute('File') ?? '',
    );
  }

  String toXml(WaterMeterModel waterMeter) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('root', nest: () {
      builder.element('ActList', nest: () {
        builder.attribute('ActId', actId);
        builder.attribute('NumAct', numAct);
        builder.attribute('Sector', sector);
        builder.attribute('DtDate', dtDate);
        builder.attribute('UserId', userId);
        builder.attribute('AccountId', accountId);
        builder.attribute('UchrId', uchrId);
        builder.attribute('PdaId', pdaId);
        builder.attribute('Lat', lat);
        builder.attribute('Lon', lon);
        builder.attribute('Alt', alt);
        builder.attribute('TelMob', telMob);
        builder.attribute('TelDom', telDom);
      });
      builder.element('ActFile', nest: file);
      builder.element('Counter', nest: () {
        builder.attribute('CounterId', waterMeter.counterId);
        builder.attribute('Kpuid', waterMeter.kpuid);
        builder.attribute('TypeMeterId', waterMeter.typeMeterId);
        builder.attribute('TypSituId', waterMeter.typSituId);
        builder.attribute('SerialNumber', waterMeter.serialNumber);
        builder.attribute('DateVerif', waterMeter.dateVerif);
        builder.attribute('ActionId', waterMeter.actionId);
        builder.attribute('SealNumber', waterMeter.sealNumber);
        builder.attribute('Readout', waterMeter.readout);
        builder.attribute('CdDate', waterMeter.cdDate);
        builder.attribute('RpuId', waterMeter.rpuId);
        builder.attribute('Diameter', waterMeter.diameter);
      });
      builder.element('Photo', nest: waterMeter.photoName);
    });
    final document = builder.buildDocument();
    log("xml ${document.toXmlString()}");
    return document.toXmlString();
  }
}
