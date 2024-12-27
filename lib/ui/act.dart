import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:WIM/data/model/search_model.dart';
import 'package:WIM/data/model/send_act_model.dart';
import 'package:WIM/ui/searchAccount.dart';
import 'package:WIM/ui/util/global.dart';
import 'package:WIM/ui/viewModel/SettingViewModel.dart';
import 'package:WIM/ui/waterMeter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import '../data/DbOpenHelper.dart';
import '../data/model/water_meter_model.dart';

void main() {
  runApp(const Act());
}

class Act extends StatelessWidget {
  const Act({super.key});

  static const platform = MethodChannel('com.example.android_id/android');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
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
  String sector = "";
  String userId = "";
  bool addressVisible = false;

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
    final settingViewModel =
        Provider.of<SettingViewModel>(context, listen: true);

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
        IconButton(
          icon: Icon(Icons.save),
          onPressed: () async {
            if (await saveAct(context)) {
              Navigator.pop(context, "act");
            }
          },
        ),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            deleteDialogShow(context);
          },
        ),
        IconButton(
          icon: Icon(Icons.send_outlined),
          onPressed: () async {
            await actionSend(settingViewModel);
          },
        ),
      ],
    );
  }

  SingleChildScrollView buildSingleChildScrollView(
      BuildContext context, SettingViewModel settingViewModel) {
    return SingleChildScrollView(
      child: buildContainer(context, settingViewModel),
    );
  }

  Container buildContainer(
      BuildContext context, SettingViewModel settingViewModel) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0x00fffc95), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
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

  Row buildGeo() {
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

  SizedBox buildListWaterMeter() {
    return SizedBox(
      height: 300,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 1300,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: itemWaterMeter.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return buildHeaderRow();
              WaterMeterModel act = itemWaterMeter[index - 1];
              return GestureDetector(
                onTap: () {
                  log("act id: ${act.id}");
                  navigateEditWaterMeter(context, act.id);
                },
                child: buildDataRow(act),
              );
            },
          ),
        ),
      ),
    );
  }

  SizedBox buildBtn(BuildContext context) {
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
                              style:
                                  TextStyle(fontSize: 16, color: Colors.blue),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                });
          }),
    );
  }

  Visibility buildAddress() {
    return Visibility(
      visible: addressVisible,
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: TextField(
              decoration: InputDecoration(
                labelText: "Адрес",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
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
    var maskFormatter = new MaskTextInputFormatter(
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

  Widget buildPersonalAccount(
      BuildContext context, SettingViewModel settingViewModel) {
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
              keyboardType: TextInputType.text,
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
                buildDataCell(act.CounterId, 80),
                buildDataCell(act.ActionId, 100),
                buildDataCell(act.SerialNumber, 150),
                buildDataCell(act.Kpuid, 130),
                buildDataCell(act.TypeMeterId, 100),
                buildDataCell(act.Calibr, 100),
                buildDataCell(act.DateVerif, 150),
                buildDataCell(act.Readout, 100),
                buildDataCell(act.SealNumber, 150),
                buildDataCell(act.PhotoName, 100),
                buildDataCell(act.StatusId, 100),
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

  Widget buildResult(BuildContext context, SettingViewModel settingViewModel) {
    return Consumer<SettingViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.resultModel != null &&
            viewModel.resultModel?.actMsg != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            dialogShow(context, viewModel.resultModel?.actMsg.toString() ?? "");
          });
          log("Result Model: ${viewModel.resultModel?.actMsg.toString()}");
        }
        return SizedBox();
      },
    );
  }

  Future<void> getAndroidId() async {
    try {
      final String result = await Act.platform.invokeMethod('getAndroidId');
      setState(() {
        androidId = result;
      });
    } on PlatformException catch (e) {
      setState(() {
        androidId = "Failed to get ANDROID_ID: '${e.message}'.";
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Set the initial date
      firstDate: DateTime(2000), // Set the minimum selectable date
      lastDate: DateTime(2100), // Set the maximum selectable date
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        dateController.text = _selectedDate == null
            ? 'No date selected!'
            : '${_selectedDate?.day.toString()}.${_selectedDate?.month.toString()}.${_selectedDate?.year.toString()}';
      });
    }
  }

  Future<void> getData() async {
    _id = widget.id;
    sector = widget.sector;
    log("get act id: $_id");
    log("get sector: $sector");
    setState(() {});
  }

  // Создаём новый акт
  Future<void> createNewAct() async {
    if (_id.isEmpty || _id == "") {
      final db = await DbOpenHelper().database;
      String sql = "insert into Acts(Sector)values(\"$sector\");";
      await db.execute(sql);
      log("create new act");
      fetchMaxId(db);
    }
  }

  Future<void> fetchMaxId(Database db) async {
    final List<Map<String, dynamic>> result =
        await db.rawQuery("select max(id) as max_id from Acts");

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
      final result = await db.rawQuery(
          "select ifnull(a.ActId,'') ActId,ifnull(StatusId,'') StatusId,a.Sector,a.NumAct,a.PhoneM,a.PhoneH,a.DtDate,a.AccountId,a.Adress,ifnull(a.UchrId,'') UchrId,ifnull(a.lon,'') lon,ifnull(a.lat,'') lat,ifnull(a.alt,'') alt,a.PhotoName from Acts a where a.id=$_id;");

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
          log("status =$statusId");

          if (statusId == "1") {
            enabledBtn = false;
          }

          numberActController.text = numberAct.toString();
          dateController.text = date.toString();
          accountController.text = account.toString();
          phoneMobileController.text = phoneM.toString();
          phoneHomeController.text = phoneH.toString();
          addressVisible = true;
          addressController.text = address.toString();

          photoController.text = photo.toString();
          altitudeController.text = altitude.toString();
          latitudeController.text = latitude.toString();
          longitudeController.text = longitude.toString();

          await updateCountersTable(sector, _id);
        }
      }

      log("result get act: $result");
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      // Запрашиваем разрешение на доступ к геолокации
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

      // Получаем текущие координаты
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        altitudeController.text = position.altitude.toString();
        latitudeController.text = position.latitude.toString();
        longitudeController.text = position.longitude.toString();
        log("Latitude: ${position.latitude}, Longitude: ${position.longitude}, Altitude: ${position.altitude}");
      });
    } catch (e) {
      setState(() {
        log("Error: $e");
      });
    }
  }

  Future<String> encodeImageToBase64(String path) async {
    final bytes = await File(path).readAsBytes(); // Прочитать файл как байты
    final base64Image = base64Encode(bytes); // Закодировать в Base64
    return base64Image;
  }

  Future<void> actionSend(SettingViewModel settingViewModel) async {
    if (await checkCounter() && await checkAct(true)) {
      if (await saveAct(context)) {
        String? userId = Global().userId;
        final db = await DbOpenHelper().database;

        String numberAct = numberActController.text.toString();
        String phoneM = phoneMobileController.text.toString();
        String phoneH = phoneHomeController.text.toString();
        String date = dateController.text.toString();
        String accountId = accountController.text.toString();
        String address = addressController.text.toString();
        String lat = latitudeController.text.toString();
        String lon = longitudeController.text.toString();
        String altitude = altitudeController.text.toString();
        String photoName = photoController.text.toString();

        final file = await encodeImageToBase64(photoName);

        String encodedImage = file;

        String xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><root>" +
            "<ActList ActId=\"" +
            actId.toString() +
            "\" NumAct=\"" +
            numberAct +
            "\" Sector=\"" +
            sector +
            "\" DtDate=\"" +
            date +
            "\" UserId=\"" +
            userId.toString() +
            "\" AccountId=\"" +
            accountId +
            "\" UchrId=\"" +
            "" +
            "\" PdaId=\"" +
            androidId +
            "\" Lat=\"" +
            lat +
            "\" Lon=\"" +
            lon +
            "\" Alt=\"" +
            altitude +
            "\" TelMob=\"" +
            phoneM +
            "\" TelDom=\"" +
            phoneH +
            "\">" +
            "<ActFile>" +
            encodedImage +
            "</ActFile>";

        var sendAct = SendActModel(
            ActId: "",
            NumAct: numberAct,
            Sector: sector,
            DtDate: date,
            UserId: userId.toString(),
            AccountId: accountId,
            UchrId: '',
            PdaId: androidId,
            Lat: lat,
            Lon: lon,
            Alt: altitude,
            TelMob: phoneM,
            TelDom: phoneH,
            File: encodedImage);

        final sql = await db.rawQuery(
            "select ifnull(CounterId,'') CounterId,ifnull(Kpuid,'') Kpuid,ifnull(TypeMeterId,'') TypeMeterId,ifnull(SerialNumber,'') SerialNumber,ifnull(DateVerif,'') DateVerif,ifnull(ActionId,'') ActionId,ifnull(SealNumber,'') SealNumber,ifnull(Readout,'') Readout,ifnull(TypSituId,'') TypSituId,PhotoName,CdDate,ifnull(RpuId,'') RpuId,ifnull(Diameter,'') Diameter from Counters where act_id=\"$_id\";");
        log("counters sql = $sql");

        int? id;
        int? idAct;
        String? counterId;
        String? kpuId;
        String? calibr;
        String? typeMeterName;
        String? typSituId;
        String? serialNumber;
        String? _date;
        String? actionName;
        String? sealNumber;
        String? statusName;
        String? readout;
        String? _photoName;
        String? cdDate;
        String? diameter;
        String? rpuId;

        for (var row in sql) {
          log("row send water:$row");
          counterId = (row['CounterId'] ?? '') as String?;
          kpuId = (row['Kpuid'] ?? '') as String?;
          calibr = (row['Calibr'] ?? '') as String?;
          typeMeterName = (row['TypeMeterId'] ?? '') as String?;
          typSituId = (row['TypSituId'] ?? '') as String?;
          serialNumber = (row['SerialNumber'] ?? '') as String?;
          _date = (row['DateVerif'] ?? '') as String?;
          actionName = (row['ActionId'] ?? '') as String?;
          sealNumber = (row['SealNumber'] ?? '') as String?;
          statusName = (row['Status_name'] ?? '') as String?;
          readout = (row['Readout'] ?? '') as String?;
          _photoName = (row['PhotoName'] ?? '') as String?;
          cdDate = (row['CdDate'] ?? '') as String?;
          diameter = (row['Diameter'] ?? '') as String?;
          rpuId = (row['RpuId'] ?? '') as String?;
          final photoBase = await encodeImageToBase64(_photoName.toString());

          log("id:$id");
          log("_date:$_date");

          xml += "<Counter";
          xml +=
              " CounterId=\"${counterId}\""; //"Идентификатор ИПУ в систему АИСЦРА", Type – число
          xml += " Kpuid=\"${kpuId}\""; //”Класс прибор учета”
          xml +=
              " TypeMeterId=\"${typeMeterName}\""; //"Код типа прибора учета", Type – число
          xml +=
              " SerialNumber=\"${serialNumber}\""; //"Заводской номер", Type – текст
          xml +=
              " DateVerif=\"${_date}\""; //"Дата поверки", Type – дата формат(‘DD.MM.YYYY’)
          xml +=
              " ActionId=\"${actionName}\""; //"ID действия(1-Снятие,10-Установка, 9-Показание ПУ)”, Type – число
          xml += " SealNumber=\"${sealNumber}\""; //"Номер пломбы", Type – текст
          xml += " Readout=\"${readout}\""; //"Показания (куб)", Type – число
          xml += " TypSituId=\"${typSituId}\"";
          xml += " CdDate=\"${cdDate}\""; //Дата фотографирования
          xml +=
              " RpuId=\"${rpuId}\""; // "Код место установки", Type – число (выбирается из справочника)
          xml +=
              " Diameter=\"${diameter}\""; // " Диаметр водомера", Type – число(имеет значение 15, 20, 25,30,32,40,50,65,80,100,125,150,200)
          xml += ">";

          xml += "<Photo>" + photoBase + "</Photo>";
          xml += "</Counter>";
        }

        xml += "</ActList>" + "</root>";

        log("xml " + xml);

        final result = await settingViewModel.sendAct(xml);
        if (result != null) {
          dialogShow(context,
              "${result.actMsg.toString()} ${result.statusName.toString()}");

          if (result.statusId == "1") {
            final db = await DbOpenHelper().database;
            String sql;
            String actId = "null";

            actId = result.actId.toString();
            log("actId = $actId");

            if (actId == "null") {
              sql =
                  "update Acts set StatusId=${result.statusId} where id=$_id;";
            } else {
              sql =
                  "update Acts set ActId=$actId, StatusId=${result.statusId} where id=$_id;";
            }

            log("sql acts $sql");

            await db.rawQuery(sql);
          }
        }
      }
    }
  }

  Future<void> navigateSearch(
      BuildContext context, SettingViewModel settingViewModel) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchAccountPage(
          sector: sector,
        ),
      ),
    );

    if (result != null) {
      SearchModel model = result;
      var waterMeter =
          Account(AccountId: model.accountId, UchrId: model.address);
      await settingViewModel.getWaterMetersApartmentSector(waterMeter, _id);
      addressVisible = true;
      accountController.text = model.accountId;
      addressController.text = model.address;

      log("navigateSearch result: $result");
      log("navigateSearch model address: ${model.address}");
      log("navigateSearch model accountId: ${model.accountId}");
      await updateCountersTable(sector, _id);
    }
  }

  Future<void> navigateEditWaterMeter(
      BuildContext context, String actId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaterMaterPage(
          sector: sector,
          id: actId,
          actId: '',
        ),
      ),
    );

    if (result != null) {
      updateCountersTable(sector, _id);
      log("navigateEditWaterMeter result: $result");
      log("navigateEditWaterMeter result sector: $sector");
    }
  }

  Future<void> navigateWaterMeter(BuildContext context) async {
    log("navigateWaterMeter sector: $sector");
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaterMaterPage(
          sector: sector,
          id: '',
          actId: _id,
        ),
      ),
    );

    if (result != null) {
      await updateCountersTable(sector, _id);
      log("navigateWaterMeter result: $result");
      log("navigateWaterMeter result sector: $sector");
    }
  }

  Future<void> updateCountersTable(String sector, String actId) async {
    final db = await DbOpenHelper().database;
    final sql = await db.rawQuery(
        "select  co.id, co.act_id, co.CounterId, CASE WHEN co.ActionId='1' THEN 'Снятие' WHEN co.ActionId='10' THEN 'Установка' WHEN co.ActionId='9' THEN 'Показание' WHEN co.ActionId='8' THEN 'Поверка без демонтажа' ELSE '-' END Action_name, co.SerialNumber, cl.KpuIdName, t.TypeMeterName, co.Calibr, co.DateVerif, co.Readout, co.SealNumber, co.PhotoName, CASE WHEN co.StatusId='0' THEN 'Запрешен монтаж ПУ' WHEN co.StatusId='1' THEN 'Разрешен монтаж ПУ' ELSE '-' END Status_name from  Counters co left join Class cl on co.Kpuid=cl.KpuId left join Type t on t.TypeMeterId=co.TypeMeterId and t.Sector=\"$sector\" where act_id=\"$actId\";");
    log("counters sql $sql");
    itemWaterMeter.clear();

    int? id;
    int? idAct;
    String? counterId;
    String? kpuId;
    String? calibr;
    String? typeMeterName;
    String? serialNumber;
    String? date;
    String? actionName;
    String? sealNumber;
    String? statusName;
    String? readout;
    String? photoName;

    for (var row in sql) {
      setState(() {});
      log("row:$row");
      id = (row['id'] ?? '') as int?;
      idAct = (row['act_id'] ?? '') as int?;
      counterId = (row['CounterId'] ?? '') as String?;
      kpuId = (row['KpuIdName'] ?? '') as String?;
      calibr = (row['Calibr'] ?? '') as String?;
      typeMeterName = (row['TypeMeterName'] ?? '') as String?;
      serialNumber = (row['SerialNumber'] ?? '') as String?;
      date = (row['DateVerif'] ?? '') as String?;
      actionName = (row['Action_name'] ?? '') as String?;
      sealNumber = (row['SealNumber'] ?? '') as String?;
      statusName = (row['Status_name'] ?? '') as String?;
      readout = (row['Readout'] ?? '') as String?;
      photoName = (row['PhotoName'] ?? '') as String?;

      log("id:$id");

      itemWaterMeter.add(WaterMeterModel(
          id: id.toString(),
          ActId: idAct.toString(),
          CounterId: counterId.toString(),
          Kpuid: kpuId.toString(),
          Calibr: calibr.toString(),
          TypeMeterId: typeMeterName.toString(),
          SerialNumber: serialNumber.toString(),
          DateVerif: date.toString(),
          ActionId: actionName.toString(),
          SealNumber: sealNumber.toString(),
          StatusId: statusName.toString(),
          Readout: readout.toString(),
          TypSituId: '',
          PhotoName: photoName.toString(),
          CdDate: photoName.toString(),
          RpuId: '',
          Diameter: ''));
    }
  }

  Future<bool> checkAct(bool photo) async {
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

    String altitude = altitudeController.text.toString();
    String longitude = longitudeController.text.toString();
    String latitude = latitudeController.text.toString();
    if (latitude.isEmpty) {
      dialogShow(context, "Поле Широта обязательно!");
      return false;
    }

    if (photo) {
      String photo = photoController.text.toString();
      if (photo.isEmpty) {
        dialogShow(context, "Поле Фото(акт) обязательно!");
        return false;
      }
    }

    return result;
  }

  Future<bool> saveAct(BuildContext context) async {
    bool result = false;

    if (await checkAct(false)) {
      log("save true");
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

      sql =
          "update Acts set NumAct=\"$numberAct\",PhoneM=\"$phoneM\",PhoneH=\"$phoneH\", DtDate=\"$date\", AccountId=\"$account\",Adress=\"$address\",UchrId=\"$uchId\",lat=\"$latitude\",lon=\"$longitude\",Alt=\"$altitude\", PhotoName=\"$photo\" where id=$_id;";

      log("id save:$_id");

      await db.rawQuery(sql);
      result = true;
    }

    return result;
  }

  Future<bool> checkCounter() async {
    String sql;
    bool resultCheck = true;
    bool snatie = false;

    final db = await DbOpenHelper().database;

    sql = "select 1 from Counters where act_id=$_id";
    final result = await db.rawQuery(sql);
    log("result Counters act_id $result");
    if (result.isEmpty) {
      dialogShow(context, "Нет ни одного водомера!");
      resultCheck = false;
    }

    sql = "select 1 from Counters where ActionId=1 and act_id=$_id";
    final sql1 = await db.rawQuery(sql);
    log("result Counters select $sql1");
    if (sql1.isNotEmpty) {
      snatie = true;
    }

    if (snatie) {
      sql = "select 1 from Counters where ActionId=10 and act_id=" + _id;
      final result = await db.rawQuery(sql);
      log("result Counters ActionId=10 $result");
      if (result.isEmpty) {
        dialogShow(context, "Нет действия установки прибор учета в акте!");
        resultCheck = false;
      }
    }

    sql =
        "select 1 from Counters where (ActionId is null or ActionId='' or Readout is null or Readout='' or PhotoName is null or PhotoName='') and act_id=" +
            _id;
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
          photoController.text = _image!.path;
          // encodeImageToBase64(photoController.text);
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
