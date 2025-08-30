import 'package:WIM/ui/viewModel/settingViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer';
import '../../data/database/dbOpenHelper.dart';

void main() {
  runApp(const Settings());
}

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SettingsPage(),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final passwordController = TextEditingController();
  final urlController = TextEditingController();
  bool urlVis = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final settingViewModel =
        Provider.of<SettingViewModel>(context, listen: true);

    return Scaffold(
      backgroundColor: Color.fromRGBO(247, 249, 249, 6),
      body: Center(
          child: settingViewModel.isLoading
              ? CircularProgressIndicator()
              : buildContainer(settingViewModel)),
      appBar: buildAppBar(),
    );
  }

  Container buildContainer(SettingViewModel settingViewModel) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Color(0x00fffc95), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            url(),
            SizedBox(height: 12.0),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  urlDialogShow(context);
                },
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.blueAccent),
                child: Text(
                  'Изменить URL',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 12.0),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.blueAccent),
                child: Text(
                  'Применить',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 12.0),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  update(settingViewModel);
                },
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.blueAccent),
                child: Text(
                  'Обновить справочники',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 12.0),
            btnDelete(),
          ],
        ),
      ),
    );
  }

  SizedBox btnDelete() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          deleteDialogShow(context);
        },
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.blueAccent),
        child: Text(
          'Удалить отправленные',
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w400, color: Colors.white),
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      iconTheme: IconThemeData(
        color: Colors.white, // Change the back button color
      ),
      title: Text(
        "Настройки",
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.blueAccent,
    );
  }

  Future<void> update(SettingViewModel viewModel) async {
    viewModel.getSituationsPrivateSector();
    viewModel.getSituationsApartmentSector();
    viewModel.getSituationsLegalSector();

    viewModel.getClass();
    viewModel.getPlaces();

    viewModel.getTypePrivateSector();
    viewModel.getTypeApartmentSector();
    viewModel.getTypeLegalSector();
  }

  void deleteDialogShow(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            padding: EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                Text("Вы действительно хотите удалить?",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Нет',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        delete();
                      },
                      child: Text(
                        'Да',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void urlDialogShow(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            padding: EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                Text("Изменить URL",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center),
                SizedBox(height: 8),
                password(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Отмена',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        log("${passwordController.text.toString()}");

                        if (passwordController.text.toString() == "!12345") {
                          urlVis = true;
                          urlController.text =
                              "http://as-portal.kz:442/default.aspx";
                          setState(() {});
                          log("rrrrrr");
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(
                        'Ok',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Visibility url() {
    return Visibility(
      visible: urlVis,
      child: Column(
        children: [
          SizedBox(height: 10.0),
          SizedBox(
            height: 50,
            child: TextField(
              decoration: InputDecoration(
                labelText: 'URL',
                border: OutlineInputBorder(),
              ),
              controller: urlController,
              keyboardType: TextInputType.text,
            ),
          ),
        ],
      ),
    );
  }

  Column password() {
    return Column(
      children: [
        SizedBox(height: 10.0),
        SizedBox(
          height: 50,
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Пароль',
              border: OutlineInputBorder(),
            ),
            controller: passwordController,
            keyboardType: TextInputType.text,
          ),
        ),
      ],
    );
  }

  void urlSetting() {}

  void dialogShow(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            padding: EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                Text(text,
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Закрыть',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> delete() async {
    final db = await DbOpenHelper().database;
    String sql = "delete from Acts where StatusId='1'";
    log("Удалить отправленные");
    await db.rawQuery(sql);
  }
}
