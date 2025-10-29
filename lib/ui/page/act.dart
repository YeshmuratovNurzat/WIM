import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:WIM/data/model/search_model.dart';
import 'package:WIM/ui/page/searchAccount.dart';
import 'package:WIM/ui/util/global.dart';
import 'package:WIM/ui/viewModel/settingViewModel.dart';
import 'package:WIM/ui/page/waterMeter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/database/dbOpenHelper.dart';
import '../../data/model/water_meter_model.dart';

void main() {
  runApp(const Act());
}

class Act extends StatelessWidget {
  const Act({super.key});

  static const platform = MethodChannel('com.example.android_id/android');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ActPage(sector: '', id: ''),
    );
  }
}

class ActPage extends StatefulWidget {
  final String sector;
  final String id;

  ActPage({super.key, required this.sector, required this.id});

  @override
  State<ActPage> createState() => _ActPageState();
}

class _ActPageState extends State<ActPage> {
  DateTime? _selectedDate;
  String _id = "";
  String _sector = "";
  bool _addressVisible = false;

  String? actId = "";
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String? _result;
  var androidId;

  final numberActController = TextEditingController();
  final accountController = TextEditingController();
  final photoController = TextEditingController();
  final phoneMobileController = TextEditingController();
  final phoneHomeController = TextEditingController();
  final addressController = TextEditingController();
  final dateController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final altitudeController = TextEditingController();

  late List<WaterMeterModel> itemWaterMeter = [];
  late WaterMeterModel waterMeter;

  final FocusNode _buttonFocusNode = FocusNode();
  bool enabledBtn = true;
  bool visibilityActions = true;

  @override
  void initState() {
    super.initState();
    getData();
    createNewAct();
    getAndroidId();
    getAct();
  }

  @override
  Widget build(BuildContext context) {
    final settingViewModel = Provider.of<SettingViewModel>(context, listen: true);

    return Scaffold(
      appBar: buildAppBar(settingViewModel),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0x00fffc95), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
            child: settingViewModel.isLoading
                ? CircularProgressIndicator()
                : buildSingleChildScrollView(context, settingViewModel)),
      ),
    );
  }

  AppBar buildAppBar(SettingViewModel settingViewModel) {
    return AppBar(
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      title: Text(
        "Создать акт",
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.blueAccent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context, "act");
        },
      ),
      actions: [
        Visibility(
            visible: visibilityActions,
            child: IconButton(
              icon: Icon(Icons.save),
              onPressed: () async {
                final result = await saveAct();
                if (result) {
                  Navigator.pop(context, "act");
                } else {
                  print("Не удалось сохранить акт");
                }
              },
            )),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            deleteDialogShow(context);
          },
        ),
        Visibility(
            visible: visibilityActions,
            child: IconButton(
              icon: Icon(Icons.send_outlined),
              onPressed: () async {
                await send(settingViewModel);
              },
            ))
      ],
    );
  }

  Widget buildSingleChildScrollView(BuildContext context, SettingViewModel settingViewModel) {
    return SingleChildScrollView(
      child: buildContainer(context, settingViewModel),
    );
  }

  Widget buildContainer(BuildContext context, SettingViewModel settingViewModel) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0x00fffc95), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            buildNumberAct(),
            SizedBox(height: 8),
            buildDateAct(context),
            SizedBox(height: 8),
            buildPersonalAccount(context, settingViewModel),
            SizedBox(height: 8),
            buildPhoneMobile(),
            SizedBox(height: 8),
            buildPhoneHome(),
            SizedBox(height: 8),
            buildAddress(),
            buildPhotoAct(context),
            SizedBox(height: 8),
            buildGeo(),
            SizedBox(height: 8),
            buildBtn(context),
            buildListWaterMeter(),
          ],
        ),
      ),
    );
  }

  Widget buildListWaterMeter() {
    return SizedBox(
      height: 800,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 1300,
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(), // Отключает прокрутку
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: itemWaterMeter.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return buildHeaderRow();
              WaterMeterModel act = itemWaterMeter[index - 1];
              return InkWell(
                onTap: () {
                  navigateEditWaterMeter(context, act.id);
                },
                child: buildDataRow(act),
              );
              // return GestureDetector(
              //   onTap: () {
              //     navigateEditWaterMeter(context, act.id);
              //   },
              //   child: buildDataRow(act),
              // );
            },
          ),
        ),
      ),
    );
  }

  Widget buildGeo() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 55,
            child: TextField(
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: 'широта',
                border: OutlineInputBorder(),
              ),
              canRequestFocus: false,
              keyboardType: TextInputType.text,
              controller: latitudeController,
            ),
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Expanded(
          child: SizedBox(
            height: 55,
            child: TextField(
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: 'долгота',
                border: OutlineInputBorder(),
              ),
              canRequestFocus: false,
              keyboardType: TextInputType.text,
              controller: longitudeController,
            ),
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Expanded(
          child: SizedBox(
            height: 55,
            child: TextField(
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: 'высота',
                border: OutlineInputBorder(),
              ),
              canRequestFocus: false,
              keyboardType: TextInputType.text,
              controller: altitudeController,
            ),
          ),
        ),
        SizedBox(
          width: 60,
          height: 50,
          child: IconButton(
            icon: Icon(Icons.language),
            color: Colors.blue,
            iconSize: 35,
            onPressed: () {
              getCurrentLocation();
            },
          ),
        ),
      ],
    );
  }

  Widget buildBtn(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        focusNode: _buttonFocusNode,
        onPressed: (enabledBtn == false)
            ? null
            : () {
                navigateWaterMeter(context);
              },
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.blueAccent),
        child: Text('Новый водомер',
            style: TextStyle(
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.w400)),
      ),
    );
  }

  Widget buildPhotoAct(BuildContext context) {
    return SizedBox(
      height: 55,
      child: TextField(
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            labelText: 'Фото (акт)',
            border: OutlineInputBorder(),
          ),
          controller: photoController,
          canRequestFocus: false,
          showCursor: false,
          keyboardType: TextInputType.text,
          onTap: () {
            bottomSheetView(context);
          }),
    );
  }

  void bottomSheetView(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 200,
            width: double.infinity,
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Фото (акт)', style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent),
                      child: Text(
                        'Фото',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        pickImage(ImageSource.camera);
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent),
                      child: Text(
                        'Выбрать',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        pickImage(ImageSource.gallery);
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent),
                      child: Text(
                        'Отобразить',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        openFile();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      backgroundColor: Colors.white,
                      shadowColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Отмена',
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget buildAddress() {
    FocusNode focusNode = FocusNode(canRequestFocus: false);
    return Visibility(
      visible: _addressVisible,
      child: Column(
        children: [
          SizedBox(
            height: 55,
            child: TextField(
              readOnly: true,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: "Адрес",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
              controller: addressController,
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget buildPhoneHome() {
    return SizedBox(
      height: 50,
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Дом. телефон',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.phone,
        controller: phoneHomeController,
      ),
    );
  }

  Widget buildPhoneMobile() {

    var maskFormatter = MaskTextInputFormatter(
        mask: '+# (###) ###-##-##',
        filter: {"#": RegExp(r'[0-9]')},
        type: MaskAutoCompletionType.lazy);

    return SizedBox(
      height: 50,
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Моб. телефон',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.phone,
        controller: phoneMobileController,
        inputFormatters: [maskFormatter],
      ),
    );
  }

  Widget buildPersonalAccount(BuildContext context, SettingViewModel settingViewModel) {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              canRequestFocus: false,
              showCursor: false,
              decoration: InputDecoration(
                labelText: 'Лицевой счёт',
                border: OutlineInputBorder(),
              ),
              controller: accountController,
              keyboardType: TextInputType.text,
            ),
          ),
          SizedBox(width: 10.0),
          SizedBox(
            width: 60,
            height: 50,
            child: IconButton(
              icon: Icon(Icons.search),
              color: Colors.blue,
              iconSize: 35,
              tooltip: 'Search',
              onPressed: () {
                navigateSearch(context, settingViewModel);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDateAct(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Дата акта',
                border: OutlineInputBorder(),
              ),
              controller: dateController,
              keyboardType: TextInputType.number,
            ),
          ),
          SizedBox(width: 10.0),
          SizedBox(
            width: 60,
            height: 50,
            child: IconButton(
              icon: Icon(Icons.date_range_rounded),
              color: Colors.blue,
              iconSize: 35,
              tooltip: 'Date',
              onPressed: () {
                _selectDate(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNumberAct() {
    return SizedBox(
      height: 50,
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Номер акта',
          border: OutlineInputBorder(),
        ),
        controller: numberActController,
        keyboardType: TextInputType.phone,
      ),
    );
  }

  Widget buildHeaderRow() {
    return Row(
      children: [
        buildHeaderCell('ИПУ', 80),
        buildHeaderCell('Действие', 100),
        buildHeaderCell('Заводской номер', 150),
        buildHeaderCell('Класс ИПУ', 130),
        buildHeaderCell('Тип ИПУ', 100),
        buildHeaderCell('Калибр', 100),
        buildHeaderCell('Дата проверки', 150),
        buildHeaderCell('Показание', 100),
        buildHeaderCell('Номер пломбы', 150),
        buildHeaderCell('Фото', 100),
        buildHeaderCell('Статус', 100),
      ],
    );
  }

  Widget buildDataRow(WaterMeterModel act) {
    return IntrinsicHeight(
      child: Column(
        children: [
          Divider(),
          IntrinsicHeight(
            child: Row(
              children: [
                buildDataCell(act.counterId, 80),
                buildDataCell(act.actionId, 100),
                buildDataCell(act.serialNumber, 150),
                buildDataCell(act.kpuid, 130),
                buildDataCell(act.typeMeterId, 100),
                buildDataCell(act.calibr, 100),
                buildDataCell(act.dateVerif, 150),
                buildDataCell(act.readout, 100),
                buildDataCell(act.sealNumber, 150),
                buildDataCell(act.photoName, 100),
                buildDataCell(act.statusId, 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDataCell(String text, double width) {
    return Container(
      width: width,
      padding: EdgeInsets.all(8),
      child: Center(
          child: Text(maxLines: 1, overflow: TextOverflow.ellipsis, text)),
    );
  }

  Widget buildHeaderCell(String text, double width) {
    return Container(
      width: width,
      padding: EdgeInsets.all(8),
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Widget buildResult(BuildContext context, SettingViewModel settingViewModel) {
  //   return Consumer<SettingViewModel>(
  //     builder: (context, viewModel, child) {
  //       if (viewModel.resultModel != null && viewModel.resultModel?.actMsg != null) {
  //         WidgetsBinding.instance.addPostFrameCallback((_) {
  //           dialogShow(context, viewModel.resultModel?.actMsg.toString() ?? "");
  //         });
  //         log("Result Model: ${viewModel.resultModel?.actMsg.toString()}");
  //       }
  //       return SizedBox();
  //     },
  //   );
  // }

  Future<void> getAndroidId() async {
    try {
      final String result = await Act.platform.invokeMethod('getAndroidId');
      setState(() {
        androidId = result;
      });
    } on PlatformException catch (e) {
      setState(() {
        androidId = "Ошибка: '${e.message}'.";
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    String? formattedDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        formattedDate = DateFormat('dd.MM.yyyy').format(picked);
        dateController.text = formattedDate.toString();
      });
    }
  }

  Future<void> getData() async {
    _id = widget.id;
    _sector = widget.sector;
    log("get act id: $_id");
    log("get sector: $_sector");
    setState(() {});
  }

  Future<void> createNewAct() async {
    if (_id == null || _id == "") {
      final db = await DbOpenHelper().database;
      String sql = "insert into Acts(Sector)values(\"$_sector\");";
      await db.execute(sql);
      fetchMaxId(db);
    }
  }

  Future<void> fetchMaxId(Database db) async {
    final List<Map<String, dynamic>> result = await db.rawQuery("select max(id) as max_id from Acts");

    if (result.isNotEmpty) {
      final String? maxId = result.first['max_id']?.toString();
      _id = maxId.toString();
      log("Max ID: $maxId");
    } else {
      log("Max ID: No data found");
    }
  }

  Future<void> getAct() async {
    if (_id.isNotEmpty) {
      final db = await DbOpenHelper().database;
      final result = await db.rawQuery("select ifnull(a.ActId,'') ActId,ifnull(StatusId,'') StatusId,a.Sector,a.NumAct,a.PhoneM,a.PhoneH,a.DtDate,a.AccountId,a.Adress,ifnull(a.UchrId,'') UchrId,ifnull(a.lon,'') lon,ifnull(a.lat,'') lat,ifnull(a.alt,'') alt,a.PhotoName from Acts a where a.id=$_id;");

      for (var row in result) {
        if (row.isNotEmpty) {
          actId = (row['ActId'] ?? '') as String?;
          String? numberAct = (row['NumAct'] ?? '') as String?;
          String? date = (row['DtDate'] ?? '') as String?;
          String? account = (row['AccountId'] ?? '') as String?;
          String? phoneM = (row['PhoneM'] ?? '') as String?;
          String? phoneH = (row['PhoneH'] ?? '') as String?;

          String? address = (row['Adress'] ?? '') as String?;
          String? uchrId = (row['UchrId'] ?? '') as String?;
          String? photo = (row['PhotoName'] ?? '') as String?;
          String? altitude = (row['alt'] ?? '') as String?;
          String? longitude = (row['lon'] ?? '') as String?;
          String? latitude = (row['lat'] ?? '') as String?;
          String? statusId = (row['StatusId'] ?? '') as String?;

          if (statusId == "1") {
            enabledBtn = false;
          }

          numberActController.text = numberAct.toString();
          dateController.text = date.toString();
          accountController.text = account.toString();
          phoneMobileController.text = phoneM.toString();
          phoneHomeController.text = phoneH.toString();
          _addressVisible = true;
          addressController.text = address.toString();

          photoController.text = photo.toString();
          altitudeController.text = altitude.toString();
          latitudeController.text = latitude.toString();
          longitudeController.text = longitude.toString();

          await updateCountersTable(_sector, _id);
        }
      }

      log("result get act: $result");
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      setState(() {
        altitudeController.text = position.altitude.toString();
        latitudeController.text = position.latitude.toString();
        longitudeController.text = position.longitude.toString();
        log("Latitude: ${position.latitude}, Longitude: ${position.longitude}, Altitude: ${position.altitude}");
      });
    } catch (e) {
      setState(() {
        log("Ошибка: $e");
      });
    }
  }

  Future<String> encodeImageToBase64(String path) async {
    final bytes = await File(path).readAsBytes();
    final base64Image = base64Encode(bytes);
    return base64Image;
  }

  Future<void> send(SettingViewModel settingViewModel) async {
    final resultCheckCounter = await checkCounter();
    final resultCheckAct = await checkAct(true);

    if (resultCheckCounter && resultCheckAct) {
      final resultSaveAct = await saveAct();
      if (resultSaveAct) {
        String? userId = Global().userId;
        final db = await DbOpenHelper().database;

        String numberAct = numberActController.text.toString();
        String date = dateController.text.toString();
        String accountId = accountController.text.toString();
        String phoneM = phoneMobileController.text.toString();
        String phoneH = phoneHomeController.text.toString();
        String address = addressController.text.toString();
        String lat = latitudeController.text.toString();
        String lon = longitudeController.text.toString();
        String altitude = altitudeController.text.toString();
        String photo = photoController.text.toString();

        final file = await encodeImageToBase64(photo);

        String xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><root><ActList ActId=\"$actId\" NumAct=\"$numberAct\" Sector=\"$_sector\" DtDate=\"$date\" UserId=\"$userId\" AccountId=\"$accountId\" UchrId=\"\" PdaId=\"$androidId\" Lat=\"$lat\" Lon=\"$lon\" Alt=\"$altitude\" TelMob=\"$phoneM\" TelDom=\"$phoneH\"><ActFile>$file</ActFile>";

        final sql = await db.rawQuery("select ifnull(CounterId,'') CounterId,ifnull(Kpuid,'') Kpuid,ifnull(TypeMeterId,'') TypeMeterId,ifnull(SerialNumber,'') SerialNumber,ifnull(DateVerif,'') DateVerif,ifnull(ActionId,'') ActionId,ifnull(SealNumber,'') SealNumber,ifnull(Readout,'') Readout,ifnull(TypSituId,'') TypSituId,PhotoName,PhotoNameActOutputs,CdDate,ifnull(RpuId,'') RpuId,ifnull(Diameter,'') Diameter from Counters where act_id=\"$_id\";");
        log("counter sql = $sql");

        for (var row in sql) {
          print("row result: $row");

          String? counterId = (row['CounterId'] ?? '') as String?;
          String? kpuId = (row['Kpuid'] ?? '') as String?;
          String? calibr = (row['Calibr'] ?? '') as String?;
          String? typeMeterName = (row['TypeMeterId'] ?? '') as String?;
          String? typSituId = (row['TypSituId'] ?? '') as String?;
          String? serialNumber = (row['SerialNumber'] ?? '') as String?;
          String? date = (row['DateVerif'] ?? '') as String?;
          String? actionName = (row['ActionId'] ?? '') as String?;
          String? sealNumber = (row['SealNumber'] ?? '') as String?;
          String? statusName = (row['Status_name'] ?? '') as String?;
          String? readout = (row['Readout'] ?? '') as String?;
          String? photoName = (row['PhotoName'] ?? '') as String?;
          String? photoNameActOutputs = (row['PhotoNameActOutputs'] ?? '') as String?;
          String? cdDate = (row['CdDate'] ?? '') as String?;
          String? diameter = (row['Diameter'] ?? '') as String?;
          String? rpuId = (row['RpuId'] ?? '') as String?;

          xml += "<Counter";
          xml += " CounterId=\"$counterId\"";
          xml += " Kpuid=\"$kpuId\"";
          xml += " TypeMeterId=\"$typeMeterName\"";
          xml += " SerialNumber=\"$serialNumber\"";
          xml += " DateVerif=\"$date\"";
          xml += " ActionId=\"$actionName\"";
          xml += " SealNumber=\"$sealNumber\"";
          xml += " Readout=\"$readout\"";
          xml += " TypSituId=\"$typSituId\"";
          xml += " CdDate=\"$cdDate\"";
          xml += " RpuId=\"$rpuId\"";
          xml += " Diameter=\"$diameter\"";
          xml += ">";

          final photoIpu = await encodeImageToBase64(photoName.toString());
          xml += "<Photo>";
          xml += "<Photo1>$photoIpu</Photo1>";

          String photoActOutputs = "";

          if (photoNameActOutputs != "") {
            photoActOutputs = await encodeImageToBase64(photoNameActOutputs.toString());

            if (photoActOutputs.isNotEmpty) {
              xml += "<Photo2>$photoActOutputs</Photo2>";
            }

          }

          xml += "</Photo>";

          xml += "</Counter>";

        }

        xml += "</ActList>" + "</root>";

        log("final xml = $xml");
        print("final xml = $xml");

        final result = await settingViewModel.sendAct(xml);
        if (result != null) {
          dialogShow(context, "${result.actMsg.toString()} ${result.statusName.toString()}");

          if (result.statusId == "1") {
            final db = await DbOpenHelper().database;
            String sql;
            String actId = "null";

            actId = result.actId.toString();
            log("actId = $actId");

            if (actId == "null") {
              sql = "update Acts set StatusId=${result.statusId} where id=$_id;";
            } else {
              sql = "update Acts set ActId=$actId, StatusId=${result.statusId} where id=$_id;";
            }

            await db.rawQuery(sql);
          }
        }
      }
    }
  }

  Future<void> navigateSearch(BuildContext context, SettingViewModel settingViewModel) async {

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchAccountPage(sector: _sector)),
    );

    if (result != null) {
      SearchModel model = result;
      var waterMeter = Account(accountId: model.accountId, uchrId: model.address);

      if (_sector == "1") {
        await settingViewModel.getWaterMetersPrivateSector(waterMeter, _id);
      } else {
        await settingViewModel.getWaterMetersApartmentSector(waterMeter, _id);
      }

      _addressVisible = true;
      accountController.text = model.accountId;
      addressController.text = model.address;

      log("navigateSearch result: $result");
      log("navigateSearch model address: ${model.address}");
      log("navigateSearch model accountId: ${model.accountId}");
      await updateCountersTable(_sector, _id);
    }
  }

  Future<void> navigateEditWaterMeter(BuildContext context, String actId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaterMaterPage(
          sector: _sector,
          id: actId,
          actId: '',
        ),
      ),
    );

    if (result != null) {
      updateCountersTable(_sector, _id);
      log("navigateEditWaterMeter result: $result");
      log("navigateEditWaterMeter result sector: $_sector");
    }
  }

  Future<void> navigateWaterMeter(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaterMaterPage(
          sector: _sector,
          id: '',
          actId: _id,
        ),
      ),
    );

    if (result != null) {
      await updateCountersTable(_sector, _id);
      log("navigateWaterMeter result: $result");
    }
  }

  Future<void> updateCountersTable(String sector, String actId) async {
    final db = await DbOpenHelper().database;
    final sql = await db.rawQuery("select  co.id, co.act_id, co.CounterId, CASE WHEN co.ActionId='1' THEN 'Снятие' WHEN co.ActionId='10' THEN 'Установка' WHEN co.ActionId='9' THEN 'Показание' WHEN co.ActionId='8' THEN 'Поверка без демонтажа' ELSE '-' END Action_name, co.SerialNumber, cl.KpuIdName, t.TypeMeterName, co.Calibr, co.DateVerif, co.Readout, co.SealNumber, co.PhotoName, co.PhotoNameActOutputs, CASE WHEN co.StatusId='0' THEN 'Запрешен монтаж ПУ' WHEN co.StatusId='1' THEN 'Разрешен монтаж ПУ' ELSE '-' END Status_name from  Counters co left join Class cl on co.Kpuid=cl.KpuId left join Type t on t.TypeMeterId=co.TypeMeterId and t.Sector=\"$sector\" where act_id=\"$actId\";");
    log("counters sql $sql");
    itemWaterMeter.clear();

    for (var row in sql) {
      setState(() {});
      log("row:$row");
      int? id = (row['id'] ?? '') as int?;
      int? idAct = (row['act_id'] ?? '') as int?;
      String? counterId = (row['CounterId'] ?? '') as String?;
      String? kpuId = (row['KpuIdName'] ?? '') as String?;
      String? calibr = (row['Calibr'] ?? '') as String?;
      String? typeMeterName = (row['TypeMeterName'] ?? '') as String?;
      String? serialNumber = (row['SerialNumber'] ?? '') as String?;
      String? date = (row['DateVerif'] ?? '') as String?;
      String? actionName = (row['Action_name'] ?? '') as String?;
      String? sealNumber = (row['SealNumber'] ?? '') as String?;
      String? statusName = (row['Status_name'] ?? '') as String?;
      String? readout = (row['Readout'] ?? '') as String?;
      String? photoName = (row['PhotoName'] ?? '') as String?;
      String? photoNameActOutputs = (row['PhotoNameActOutputs'] ?? '') as String?;

      log("id:$id");

      itemWaterMeter.add(WaterMeterModel(
          id: id.toString(),
          actId: idAct.toString(),
          counterId: counterId.toString(),
          kpuid: kpuId.toString(),
          calibr: calibr.toString(),
          typeMeterId: typeMeterName.toString(),
          serialNumber: serialNumber.toString(),
          dateVerif: date.toString(),
          actionId: actionName.toString(),
          sealNumber: sealNumber.toString(),
          statusId: statusName.toString(),
          readout: readout.toString(),
          typSituId: '',
          photoName: photoName.toString(),
          photoNameActOutputs: photoNameActOutputs.toString(),
          cdDate: photoName.toString(),
          rpuId: '',
          diameter: ''));
    }
  }

  Future<bool> checkAct(bool photoCheck) async {
    bool result = true;

    String numberAct = numberActController.text.toString();
    if (numberAct.isEmpty) {
      dialogShow(context, "Поле Номер акта обязательно!");
      return false;
    }

    String date = dateController.text.toString();
    if (date.isEmpty) {
      dialogShow(context, "Поле Дата акта обязательно!");
      return false;
    }

    String account = accountController.text.toString();
    if (account.isEmpty) {
      dialogShow(context, "Поле Лицевой счёт обязательно!");
      return false;
    }

    if (photoCheck) {
      String photo = photoController.text.toString();
      if (photo.isEmpty) {
        dialogShow(context, "Поле Фото(акт) обязательно!");
        return false;
      }
    }

    return result;
  }

  Future<bool> saveAct() async {
    bool result = false;
    final resultCheck = await checkAct(false);
    if (resultCheck) {
      log("save act");
      final db = await DbOpenHelper().database;
      String sql;

      String numberAct = numberActController.text.toString();
      String date = dateController.text.toString();
      String account = accountController.text.toString();
      String phoneM = phoneMobileController.text.toString();
      String phoneH = phoneHomeController.text.toString();

      String address = addressController.text.toString();
      String uchId = "";

      String photo = photoController.text.toString();
      String altitude = altitudeController.text.toString();
      String longitude = longitudeController.text.toString();
      String latitude = latitudeController.text.toString();

      sql = "update Acts set NumAct=\"$numberAct\",PhoneM=\"$phoneM\",PhoneH=\"$phoneH\", DtDate=\"$date\", AccountId=\"$account\", Adress=\"$address\", UchrId=\"$uchId\", lat=\"$latitude\", lon=\"$longitude\", Alt=\"$altitude\", PhotoName=\"$photo\" where id=$_id;";

      log("save id:$_id");

      await db.rawQuery(sql);
      result = true;
    }
    return result;
  }

  Future<bool> checkCounter() async {
    String sql;
    bool resultCheck = true;
    bool withdrawal = false;

    final db = await DbOpenHelper().database;

    sql = "select 1 from Counters where act_id=$_id";
    final result = await db.rawQuery(sql);
    if (result.isEmpty) {
      dialogShow(context, "Нет ни одного водомера!");
      resultCheck = false;
    }

    sql = "select 1 from Counters where ActionId=1 and act_id=$_id";
    final res = await db.rawQuery(sql);
    if (res.isNotEmpty) {
      withdrawal = true;
    }

    if (withdrawal) {
      sql = "select 1 from Counters where ActionId=10 and act_id=$_id";
      final result = await db.rawQuery(sql);
      if (result.isEmpty) {
        dialogShow(context, "Нет действия установки прибор учета в акте!");
        resultCheck = false;
      }
    }

    sql = "select 1 from Counters where (ActionId is null or ActionId='' or Readout is null or Readout='' or PhotoName is null or PhotoName='' or PhotoNameActOutputs='') and act_id=$_id";
    final result1 = await db.rawQuery(sql);
    log("result Counters not null: $result1");
    if (result1.isNotEmpty) {
      dialogShow(context, "В водомерах не заполнены все обязательные поля!");
      resultCheck = false;
    }

    return resultCheck;
  }

  Future<bool> delete() async {
    final db = await DbOpenHelper().database;
    db.rawQuery("delete from Counters where act_id=$_id");
    db.rawQuery("delete from Acts where id=$_id");
    Navigator.pop(context, "act");
    return true;
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxHeight: 800, // Изменить размер изображения, если нужно
        maxWidth: 800,
      );
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          photoController.text = _image?.path ?? "";
        });
      }
    } catch (e) {
      print("Ошибка: $e");
    }
  }

  Future<void> openFile() async {
    try {
      String filePath = photoController.text;
      if (filePath.isEmpty) {
        setState(() {
          _result = "Введите путь к файлу";
        });
        return;
      }

      if (!File(filePath).existsSync()) {
        setState(() {
          _result = "Файл не найден: $filePath";
        });
        return;
      }

      final result = await OpenFile.open(filePath);
      setState(() {
        _result = "Результат: ${result.message}";
      });
    } catch (e) {
      setState(() {
        _result = "Ошибка: $e";
      });
    }
  }

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

}
