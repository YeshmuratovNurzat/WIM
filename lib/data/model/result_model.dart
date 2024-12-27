import 'package:xml/xml.dart';

class ResultModel {
  final String statusId;
  final String statusName;
  final String actMsg;
  final String actId;

  ResultModel(
      {required this.statusId,
      required this.statusName,
      required this.actMsg,
      required this.actId});

  factory ResultModel.fromXml(XmlElement xml) {
    return ResultModel(
      statusId: xml.getAttribute('StatusId') ?? '',
      statusName: xml.getAttribute('StatusName') ?? '',
      actMsg: xml.getAttribute('ActMsg') ?? '',
      actId: xml.getAttribute('ActId') ?? '',
    );
  }
}
