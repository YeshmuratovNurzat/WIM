import 'dart:developer';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:xml/xml.dart';

class DbOpenHelper {
  static final DbOpenHelper instance = DbOpenHelper._internal();
  static Database? _database;

  static const String DB_NAME = 'WaterMeterAct.db';
  static const int DB_VERSION = 2;

  DbOpenHelper._internal();

  factory DbOpenHelper() {
    return instance;
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), DB_NAME);
    return await openDatabase(
      path,
      version: DB_VERSION,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE _users (
        id INTEGER NOT NULL PRIMARY KEY,
        login TEXT,
        password TEXT,
        FirmaName TEXT
      )
    ''');

    // Acts table
    await db.execute('''
      CREATE TABLE Acts (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        ActId TEXT,
        StatusId TEXT,
        StatusText TEXT,
        Sector TEXT,
        NumAct TEXT,
        PhoneM TEXT,
        PhoneH TEXT,
        DtDate TEXT,
        UserId TEXT,
        AccountId TEXT,
        PdaId TEXT,
        Adress TEXT,
        UchrId TEXT,
        lat TEXT,
        lon TEXT,
        alt TEXT,
        PhotoName TEXT
      )
    ''');

    // Counters table
    await db.execute('''
      CREATE TABLE Counters (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        act_id INTEGER,
        CounterId TEXT,
        Kpuid TEXT,
        Calibr TEXT,
        TypeMeterId TEXT,
        SerialNumber TEXT,
        DateVerif TEXT,
        ActionId TEXT,
        SealNumber TEXT,
        StatusId TEXT,
        Readout TEXT,
        TypSituId TEXT,
        PhotoName TEXT,
        PhotoNameActOutputs TEXT,
        CdDate TEXT,
        RpuId TEXT,
        Diameter TEXT
      )
    ''');

    // Class table
    await db.execute('''
      CREATE TABLE Class (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        KpuId TEXT,
        KpuIdName TEXT
      )
    ''');

    //Справочник типов прибора учета х.в.
    await db.execute('''
      CREATE TABLE Type (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        Sector TEXT,
        TypeMeterId TEXT,
        TypeMeterName TEXT,
        Arcfl TEXT
      )
    ''');

    // Situations table
    await db.execute('''
      CREATE TABLE Situations (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        Sector TEXT,
        TypSituId TEXT,
        TypSituName TEXT,
        FotoFl TEXT
      )
    ''');

    // Places table
    await db.execute('''
      CREATE TABLE places (
        id TEXT,
        name TEXT
      )
    ''');

    print("Database created");
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute('DROP TABLE IF EXISTS _users');
      await db.execute('DROP TABLE IF EXISTS Acts');
      await db.execute('DROP TABLE IF EXISTS Counters');
      await db.execute('DROP TABLE IF EXISTS Class');
      await db.execute('DROP TABLE IF EXISTS Type');
      await db.execute('DROP TABLE IF EXISTS Situations');
      await db.execute('DROP TABLE IF EXISTS places');
      await _onCreate(db, newVersion);
    }
  }

  Future<void> insertUser(
      int id, String login, String password, String firmaName) async {
    final db = await database;
    await db.rawInsert(
      "INSERT INTO _users(id, login, password, FirmaName) VALUES(?, ?, ?, ?)",
      [id, login, password, firmaName],
    );
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    final result = await db.query('_users');
    return result;
  }

  Future<void> deleteAllUsers() async {
    final db = await database;
    await db.delete('_users');
  }

  Future<void> insertWaterMetersApartmentSector(
      XmlElement n, String actId) async {
    final db = await DbOpenHelper().database;
    log("insertWaterMetersApartmentSector");

    final String accountId =
        n.getAttribute('AccountId')?.replaceAll('"', "'") ?? '';

    await db.rawDelete("DELETE FROM Counters where act_id=$actId");
    log("accountId: $accountId");
    log("actId: $actId");

    XmlNode counter = n.childElements.first;

    final String counterId =
        counter.getAttribute('CounterId')?.replaceAll('"', "'") ?? '';
    final String kpuId =
        counter.getAttribute('Kpuid')?.replaceAll('"', "'") ?? '';
    final String typeMeterId =
        counter.getAttribute('TypeMeterId')?.replaceAll('"', "'") ?? '';
    final String serialNumber =
        counter.getAttribute('SerialNumber')?.replaceAll('"', "'") ?? '';
    final String sealNumber =
        counter.getAttribute('SealNumber')?.replaceAll('"', "'") ?? '';
    final String statusId =
        counter.getAttribute('StatusId')?.replaceAll('"', "'") ?? '';
    final String calibr =
        counter.getAttribute('Calibr')?.replaceAll('"', "'") ?? '';

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
        'RpuId': '',
        'Diameter': '',
      },
    );
  }
}
