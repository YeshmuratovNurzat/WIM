import 'dart:developer';
import 'package:WIM/data/model/water_meter_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:xml/xml.dart';

import '../../data/database/dbOpenHelper.dart';
import '../../data/model/result_model.dart';
import '../../data/model/search_model.dart';
import '../../domain/settingRepository.dart';

class SettingViewModel with ChangeNotifier {
  late final SettingRepository settingRepository;
  SettingViewModel(this.settingRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<SearchModel>? _search = [];
  List<SearchModel>? get searchModel => _search;

  ResultModel? _resultModel;
  ResultModel? get resultModel => _resultModel;

  void clearSearchModel() {
    _search = [];
    notifyListeners();
  }

  Future<void> insertTypePrivateSector(XmlElement n) async {
    final db = await DbOpenHelper().database;

    await db.rawDelete("DELETE FROM Type WHERE Sector = ?", [1]);

    final String typeMeterId =
        n.getAttribute('TypeMeterId')?.replaceAll('"', "'") ?? '';
    final String typeMeterName =
        n.getAttribute('TypeMeterName')?.replaceAll('"', "'") ?? '';
    final String arcfl = n.getAttribute('Arcfl')?.replaceAll('"', "'") ?? '';

    await db.insert(
      'Type',
      {
        'Sector': 1,
        'TypeMeterId': typeMeterId,
        'TypeMeterName': typeMeterName,
        'Arcfl': arcfl,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertTypeApartmentSector(XmlElement n) async {
    final db = await DbOpenHelper().database;

    await db.rawDelete("DELETE FROM Type WHERE Sector = ?", [0]);

    final String typeMeterId =
        n.getAttribute('TypeMeterId')?.replaceAll('"', "'") ?? '';
    final String typeMeterName =
        n.getAttribute('TypeMeterName')?.replaceAll('"', "'") ?? '';
    final String arcfl = n.getAttribute('Arcfl')?.replaceAll('"', "'") ?? '';

    await db.insert(
      'Type',
      {
        'Sector': 0,
        'TypeMeterId': typeMeterId,
        'TypeMeterName': typeMeterName,
        'Arcfl': arcfl,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertTypeLegalSector(XmlElement n) async {
    final db = await DbOpenHelper().database;

    await db.rawDelete("DELETE FROM Type WHERE Sector = ?", [2]);

    final String typeMeterId =
        n.getAttribute('TypeMeterId')?.replaceAll('"', "'") ?? '';
    final String typeMeterName =
        n.getAttribute('TypeMeterName')?.replaceAll('"', "'") ?? '';
    final String arcfl = n.getAttribute('Arcfl')?.replaceAll('"', "'") ?? '';

    await db.insert(
      'Type',
      {
        'Sector': 2,
        'TypeMeterId': typeMeterId,
        'TypeMeterName': typeMeterName,
        'Arcfl': arcfl,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> getTypePrivateSector() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await settingRepository.getTypePrivateSector();
      log("Type Private Sector: ${result.data}");
      final document = XmlDocument.parse(result.response.data);
      final elements = document.findAllElements('TypeMeter');

      for (var element in elements) {
        insertTypePrivateSector(element);
      }
    } catch (e) {
      _errorMessage = "$e";
      log("Type Private Sector Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getTypeApartmentSector() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await settingRepository.getTypeApartmentSector();
      log("Type Apartment Sector: ${result.data}");

      final document = XmlDocument.parse(result.response.data);
      final elements = document.findAllElements('TypeMeter');

      for (var element in elements) {
        insertTypeApartmentSector(element);
      }
    } catch (e) {
      _errorMessage = "$e";
      log("Type Apartment Sector Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getTypeLegalSector() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await settingRepository.getTypeLegalSector();
      log("Type Legal Sector: ${result.data}");

      final document = XmlDocument.parse(result.response.data);
      final elements = document.findAllElements('TypeMeter');

      for (var element in elements) {
        insertTypeLegalSector(element);
      }
    } catch (e) {
      _errorMessage = "$e";
      log("Type Legal Sector Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> insertPlaces(XmlElement n) async {
    final db = await DbOpenHelper().database;

    await db.rawDelete("DELETE FROM places");

    final String id = n.getAttribute('RpuId')?.replaceAll('"', "'") ?? '';
    final String name = n.getAttribute('RpuName')?.replaceAll('"', "'") ?? '';

    await db.insert(
      'places',
      {
        'id': id,
        'name': name,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertClass(XmlElement n) async {
    final db = await DbOpenHelper().database;

    await db.rawDelete("DELETE FROM Class");

    final String id = n.getAttribute('KpuId')?.replaceAll('"', "'") ?? '';
    final String name = n.getAttribute('KpuIdName')?.replaceAll('"', "'") ?? '';

    await db.insert(
      'Class',
      {
        'KpuId': id,
        'KpuIdName': name,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> getPlaces() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await settingRepository.getPlaces();
      log("Places: ${result.data}");

      final document = XmlDocument.parse(result.response.data);
      final elements = document.findAllElements('Rpu');

      for (var element in elements) {
        insertPlaces(element);
      }
    } catch (e) {
      _errorMessage = "$e";
      log("Places Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getClass() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await settingRepository.getClass();
      log("Class: ${result.data}");

      final document = XmlDocument.parse(result.response.data);
      final elements = document.findAllElements('TypeMeter');

      for (var element in elements) {
        insertClass(element);
      }
    } catch (e) {
      _errorMessage = "$e";
      log("Class Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> insertSituationsApartmentSector(XmlElement n) async {
    final db = await DbOpenHelper().database;

    await db.rawDelete("DELETE FROM Situations where Sector=0");

    final String id = n.getAttribute('TypSituId')?.replaceAll('"', "'") ?? '';
    final String name =
        n.getAttribute('TypSituName')?.replaceAll('"', "'") ?? '';

    await db.insert(
      'Situations',
      {
        'Sector': 0,
        'TypSituId': id,
        'TypSituName': name,
      },
    );
  }

  Future<void> insertSituationsPrivateSector(XmlElement n) async {
    final db = await DbOpenHelper().database;

    await db.rawDelete("DELETE FROM Situations where Sector=1");

    final String id = n.getAttribute('TypSituId')?.replaceAll('"', "'") ?? '';
    final String name =
        n.getAttribute('TypSituName')?.replaceAll('"', "'") ?? '';

    await db.insert(
      'Situations',
      {
        'Sector': 1,
        'TypSituId': id,
        'TypSituName': name,
      },
    );
  }

  Future<void> insertSituationsLegalSector(XmlElement n) async {
    final db = await DbOpenHelper().database;

    await db.rawDelete("DELETE FROM Situations where Sector=2");

    final String id = n.getAttribute('TypSituId')?.replaceAll('"', "'") ?? '';
    final String name =
        n.getAttribute('TypSituName')?.replaceAll('"', "'") ?? '';

    await db.insert(
      'Situations',
      {
        'Sector': 2,
        'TypSituId': id,
        'TypSituName': name,
      },
    );
  }

  Future<void> getSituationsApartmentSector() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await settingRepository.getSituationsApartmentSector();
      log("Situations Apartment Sector: ${result.data}");

      final document = XmlDocument.parse(result.response.data);
      final elements = document.findAllElements('TypSitu');

      for (var element in elements) {
        insertSituationsApartmentSector(element);
      }
    } catch (e) {
      _errorMessage = "$e";
      log("Situations Apartment Sector Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getSituationsPrivateSector() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await settingRepository.getSituationsPrivateSector();
      log("Situations Private Sector: ${result.data}");

      final document = XmlDocument.parse(result.response.data);
      final elements = document.findAllElements('TypSitu');

      for (var element in elements) {
        insertSituationsPrivateSector(element);
      }
    } catch (e) {
      _errorMessage = "$e";
      log("Situations Private Sector Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getSituationsLegalSector() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await settingRepository.getSituationsLegalSector();
      log("Situations Legal Sector: ${result.data}");

      final document = XmlDocument.parse(result.response.data);
      final elements = document.findAllElements('TypSitu');

      for (var element in elements) {
        insertSituationsLegalSector(element);
      }
    } catch (e) {
      _errorMessage = "$e";
      log("Situations Legal Sector Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<SearchModel>?> search(Search search, String stype) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await settingRepository.search(search, stype);

      if (result.response.statusCode == 200) {
        final xmlString = result.response.data;
        final document = XmlDocument.parse(xmlString);
        final elements = document.findAllElements('Account');
        final searchResult =
            elements.map((element) => SearchModel.fromXml(element)).toList();
        _search?.clear();
        for (var element in elements) {
          SearchModel s = SearchModel.fromXml(element);
          _search?.add(s);
        }
        log("Search: ${result.response.data}");
        log("Search res: ${searchResult}");
        return searchResult;
      }
    } catch (e) {
      _errorMessage = "$e";
      log("Search Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<void> insertWaterMetersApartmentSector(
      XmlElement n, String actId) async {
    final db = await DbOpenHelper().database;

    final String accountId =
        n.getAttribute('AccountId')?.replaceAll('"', "'") ?? '';

    await db.rawDelete("DELETE FROM Counters where act_id=$actId");
    log("accountId: $accountId");
    log("actId: $actId");

    final data = n.findElements("Counter");
    log("data: $data");

    for (var node in data) {
      log("node: $node");

      String counterId =
          node.getAttribute('CounterId')?.replaceAll('"', "'") ?? '';
      String kpuId = node.getAttribute('Kpuid')?.replaceAll('"', "'") ?? '';
      String typeMeterId =
          node.getAttribute('TypeMeterId')?.replaceAll('"', "'") ?? '';
      String serialNumber =
          node.getAttribute('SerialNumber')?.replaceAll('"', "'") ?? '';
      String sealNumber =
          node.getAttribute('SealNumber')?.replaceAll('"', "'") ?? '';
      String statusId =
          node.getAttribute('StatusId')?.replaceAll('"', "'") ?? '';
      String calibr = node.getAttribute('Calibr')?.replaceAll('"', "'") ?? '';

      await db.insert(
        'Counters',
        {
          'act_id': actId,
          'CounterId': counterId,
          'Calibr': calibr,
          'Kpuid': kpuId,
          'TypeMeterId': typeMeterId,
          'SerialNumber': serialNumber,
          'DateVerif': null,
          'ActionId': null,
          'SealNumber': sealNumber,
          'StatusId': statusId,
          'Readout': null,
          'PhotoName': null,
          'PhotoNameActOutputs': null,
          'RpuId': '',
          'Diameter': '',
        },
      );
    }

    log("Data inserted successfully.");
  }

  Future<void> getWaterMetersApartmentSector(
      Account account, String actId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result =
          await settingRepository.getWaterMetersApartmentSector(account);

      if (result.response.statusCode == 200) {
        final xmlString = result.response.data;
        final document = XmlDocument.parse(xmlString);
        final elements = document.findAllElements('Account');
        log("Get Water Meters Apartment Sector: ${result.response.data}");
        log("elements: ${elements}");
        for (var element in elements) {
          log("element: ${element}");
          await insertWaterMetersApartmentSector(element, actId);
        }
      }
    } catch (e) {
      _errorMessage = "$e";
      log("Get Water Meters Apartment Sector Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getWaterMetersPrivateSector(
      Account account, String actId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result =
          await settingRepository.getWaterMetersPrivateSector(account);

      if (result.response.statusCode == 200) {
        final xmlString = result.response.data;
        final document = XmlDocument.parse(xmlString);
        final elements = document.findAllElements('Account');
        log("Get Water Meters Private Sector: ${result.response.data}");
        log("elements: ${elements}");
        for (var element in elements) {
          log("element: ${element}");
          await insertWaterMetersApartmentSector(element, actId);
        }
      }
    } catch (e) {
      _errorMessage = "$e";
      log("Get Water Meters Private Sector Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ResultModel?> sendAct(String data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await settingRepository.sendAct(data);

      if (result.response.statusCode == 200) {
        final xmlString = result.response.data;
        final document = XmlDocument.parse(xmlString);
        final element = document.findAllElements('ActList').first;
        _resultModel = ResultModel.fromXml(element);
        log("Send Act Result: ${result.response.data}");
        log("Send Act element: ${element}");
        return _resultModel;
      }
    } catch (e) {
      _errorMessage = "$e";
      log("Send Act Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }
}
