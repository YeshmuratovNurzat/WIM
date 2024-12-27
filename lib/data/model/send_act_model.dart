import 'dart:developer';

import 'package:WIM/data/model/water_meter_model.dart';
import 'package:xml/xml.dart';

class SendActModel {
  final String ActId;
  final String NumAct;
  final String Sector;
  final String DtDate;
  final String UserId;
  final String AccountId;
  final String UchrId;
  final String PdaId;
  final String Lat;
  final String Lon;
  final String Alt;
  final String TelMob;
  final String TelDom;
  final String File;

  SendActModel(
      {required this.ActId,
      required this.NumAct,
      required this.Sector,
      required this.DtDate,
      required this.UserId,
      required this.AccountId,
      required this.UchrId,
      required this.PdaId,
      required this.Lat,
      required this.Lon,
      required this.Alt,
      required this.TelMob,
      required this.TelDom,
      required this.File});

  factory SendActModel.fromXml(XmlElement xml) {
    return SendActModel(
      ActId: xml.getAttribute('ActId') ?? '',
      NumAct: xml.getAttribute('NumAct') ?? '',
      Sector: xml.getAttribute('Sector') ?? '',
      DtDate: xml.getAttribute('DtDate') ?? '',
      UserId: xml.getAttribute('UserId') ?? '',
      AccountId: xml.getAttribute('AccountId') ?? '',
      UchrId: xml.getAttribute('UchrId') ?? '',
      PdaId: xml.getAttribute('PdaId') ?? '',
      Lat: xml.getAttribute('Lat') ?? '',
      Lon: xml.getAttribute('Lon') ?? '',
      Alt: xml.getAttribute('Alt') ?? '',
      TelMob: xml.getAttribute('TelMob') ?? '',
      TelDom: xml.getAttribute('TelDom') ?? '',
      File: xml.getAttribute('File') ?? '',
    );
  }

  String toXml(WaterMeterModel waterMeter) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('root', nest: () {
      builder.element('ActList', nest: () {
        builder.attribute('ActId', ActId);
        builder.attribute('NumAct', NumAct);
        builder.attribute('Sector', Sector);
        builder.attribute('DtDate', DtDate);
        builder.attribute('UserId', UserId);
        builder.attribute('AccountId', AccountId);
        builder.attribute('UchrId', UchrId);
        builder.attribute('PdaId', PdaId);
        builder.attribute('Lat', Lat);
        builder.attribute('Lon', Lon);
        builder.attribute('Alt', Alt);
        builder.attribute('TelMob', TelMob);
        builder.attribute('TelDom', TelDom);
      });
      builder.element('ActFile', nest: File);
      builder.element('Counter', nest: () {
        builder.attribute('CounterId', waterMeter.CounterId);
        builder.attribute('Kpuid', waterMeter.Kpuid);
        builder.attribute('TypeMeterId', waterMeter.TypeMeterId);
        builder.attribute('TypSituId', waterMeter.TypSituId);
        builder.attribute('SerialNumber', waterMeter.SerialNumber);
        builder.attribute('DateVerif', waterMeter.DateVerif);
        builder.attribute('ActionId', waterMeter.ActionId);
        builder.attribute('SealNumber', waterMeter.SealNumber);
        builder.attribute('Readout', waterMeter.Readout);
        builder.attribute('CdDate', waterMeter.CdDate);
        builder.attribute('RpuId', waterMeter.RpuId);
        builder.attribute('Diameter', waterMeter.Diameter);
      });
      builder.element('Photo', nest: waterMeter.PhotoName);
    });
    final document = builder.buildDocument();
    log("xml ${document.toXmlString()}");
    return document.toXmlString();
  }
}
