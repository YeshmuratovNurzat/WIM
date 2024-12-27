import 'dart:developer';
import 'package:WIM/domain/repo/SettingRepository.dart';
import 'package:WIM/ui/settings.dart';
import 'package:WIM/ui/viewModel/SettingViewModel.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../data/DbOpenHelper.dart';
import '../data/network/Api.dart';
import 'acts.dart';

void main() {
  final dio = Dio();
  final apiService = Api(dio);
  final settingRepository = SettingRepository(apiService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => SettingViewModel(settingRepository)),
        // Другие провайдеры, если нужно
      ],
      child: Home(),
    ),
  );
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> checkType() async {
    final db = await DbOpenHelper().database;

    List<Map<String, dynamic>> result = await db.rawQuery("select 1 from Type");
    log("result $result");

    if (result.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        final settingViewModel =
            Provider.of<SettingViewModel>(context, listen: false);
        settingViewModel.getTypeApartmentSector();
        settingViewModel.getTypePrivateSector();
        settingViewModel.getTypeLegalSector();
        settingViewModel.getPlaces();
        settingViewModel.getClass();
        settingViewModel.getSituationsApartmentSector();
        settingViewModel.getSituationsLegalSector();
        settingViewModel.getSituationsPrivateSector();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkType();
    requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0x00fffc95), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              buildWidgetApartmentSector(context),
              SizedBox(height: 12),
              buildWidgetPrivateSector(context),
              SizedBox(height: 12),
              buildWidgetLegalSector(context),
              SizedBox(height: 12),
              buildBtnSettings(context),
            ],
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      title: Text(
        "WIM Service",
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.blueAccent,
    );
  }

  SizedBox buildBtnSettings(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsPage()),
          );
        },
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.blueAccent),
        child: Text(
          'Настройки',
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w400, color: Colors.white),
        ),
      ),
    );
  }

  Widget buildWidgetLegalSector(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ActsPage(
                      sector: '2',
                    )),
          );
        },
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.blueAccent),
        child: Text(
          'Юр сектор',
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w400, color: Colors.white),
        ),
      ),
    );
  }

  Widget buildWidgetApartmentSector(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ActsPage(sector: '0')));
        },
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.blueAccent),
        child: Text(
          'Многоквартирный сектор',
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w400, color: Colors.white),
        ),
      ),
    );
  }

  Widget buildWidgetPrivateSector(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ActsPage(sector: '1')),
          );
        },
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.blueAccent),
        child: Text(
          'Частный сектор',
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w400, color: Colors.white),
        ),
      ),
    );
  }

  void requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.location,
      Permission.storage,
    ].request();

    if (statuses[Permission.location]?.isGranted ?? false) {
      print("Location permission granted.");
    } else {
      print("Location permission denied.");
    }

    if (statuses[Permission.camera]?.isGranted ?? false) {
      print("Camera permission granted.");
    } else {
      print("Camera permission denied.");
    }

    if (statuses[Permission.storage]?.isGranted ?? false) {
      print("Storage permission granted.");
    } else {
      print("Storage permission denied.");
    }

    if (statuses.values.any((status) => status.isPermanentlyDenied)) {
      await openAppSettings();
    }
  }
}
