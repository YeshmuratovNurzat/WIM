import 'dart:developer';
import 'dart:io';
import 'package:WIM/data/model/water_meter_model.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/DbOpenHelper.dart';
import 'package:open_file/open_file.dart';

class WaterMeter extends StatelessWidget {
  const WaterMeter({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: WaterMaterPage(sector: '', id: '', actId: ''),
    );
  }
}

class WaterMaterPage extends StatefulWidget {
  final String sector;
  final String id;
  final String actId;

  WaterMaterPage(
      {super.key, required this.sector, required this.id, required this.actId});

  @override
  State<WaterMaterPage> createState() => _WaterMaterPageState();
}

class _WaterMaterPageState extends State<WaterMaterPage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String btnDeleteTxt = "Удалить";
  bool isLoading = false;

  bool edit = true;
  bool onlyRead = false;

  bool isVisibleBtnDelete = false;
  bool isVisibleIpuTextField = false;

  bool isVisibleDiameter = true;
  bool isVisiblePlaceInstallation = true;
  bool isVisibleDate = true;
  bool isVisibleFillingsNumber = true;

  final ipuController = TextEditingController();
  final factoryNumberController = TextEditingController();
  final fillingsNumberController = TextEditingController();
  final indicationController = TextEditingController();
  final dateController = TextEditingController();
  final photoController = TextEditingController();

  late List<Map<String, String>> itemPlaces = [];
  late List<Map<String, String>> itemType = [];
  late List<Map<String, String>> itemClass = [];
  late List<Map<String, String>> itemSituations = [];

  late WaterMeterModel waterMeterModel;

  final List<Map<String, String>> itemActions = [
    {'name': 'Снятие ПУ', 'value': '1'},
    {'name': 'Показание ПУ', 'value': '9'},
    {'name': 'Установка ПУ', 'value': '10'},
  ];

  final List<Map<String, String>> itemDiameters = [
    {'name': '15', 'value': '15'},
    {'name': '20', 'value': '20'},
    {'name': '25', 'value': '25'},
    {'name': '30', 'value': '30'},
    {'name': '32', 'value': '32'},
    {'name': '40', 'value': '40'},
    {'name': '50', 'value': '50'},
    {'name': '65', 'value': '65'},
    {'name': '80', 'value': '80'},
    {'name': '100', 'value': '100'},
    {'name': '125', 'value': '125'},
    {'name': '150', 'value': '150'},
    {'name': '200', 'value': '200'},
  ];

  final valueListenableAction = ValueNotifier<String?>(null);
  final valueListenableClassIpu = ValueNotifier<String?>(null);
  final valueListenableTypeIpu = ValueNotifier<String?>(null);
  final valueListenableDiameter = ValueNotifier<String?>(null);
  final valueListenablePlaceInstallation = ValueNotifier<String?>(null);
  final valueListenableTypicalSituation = ValueNotifier<String?>(null);

  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  final _formKey4 = GlobalKey<FormState>();
  final _formKey5 = GlobalKey<FormState>();

  DateTime? _selectedDate;
  var textController = TextEditingController();

  Future<void> places() async {
    final db = await DbOpenHelper().database;
    final result =
        await db.rawQuery("select id,name from places order by name");

    for (var row in result) {
      itemPlaces.add({
        'id': row['id'] as String,
        'name': row['name'] as String,
      });
    }

    log("places");
  }

  Future<void> typeIpu(String sector) async {
    final db = await DbOpenHelper().database;
    final result = await db.rawQuery(
        "select TypeMeterId, TypeMeterName from Type where Sector = ? order by TypeMeterName",
        [sector]);

    for (var row in result) {
      itemType.add({
        'id': row['TypeMeterId'] as String,
        'name': row['TypeMeterName'] as String,
      });

      setState(() {});
    }

    log("typeIpu");
  }

  Future<void> classIpu() async {
    final db = await DbOpenHelper().database;
    final result = await db
        .rawQuery("select KpuId, KpuIdName from Class order by KpuIdName");
    for (var row in result) {
      itemClass.add({
        'id': row['KpuId'] as String,
        'name': row['KpuIdName'] as String,
      });

      setState(() {});
    }

    log("classIpu");
  }

  Future<void> situations(String sector) async {
    final db = await DbOpenHelper().database;
    final result = await db.rawQuery(
        "select TypSituId, TypSituName from Situations where Sector = ? order by TypSituName",
        [sector]);

    for (var row in result) {
      itemSituations.add({
        'id': row['TypSituId'] as String,
        'name': row['TypSituName'] as String,
      });
    }

    log("situations");
  }

  Future<void> fetchCounters(String actId) async {
    final db = await DbOpenHelper().database;
    final result =
        await db.rawQuery("SELECT * from Counters where id = ? ", [actId]);

    if (result.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      for (var row in result) {
        int? id = (row['id'] ?? '') as int?;
        String? idCounter = (row['CounterId'] ?? '') as String?;
        String? idKpu = (row['Kpuid'] ?? '') as String?;
        String? calibr = (row['Calibr'] ?? '') as String?;
        String? idTypeMeter = (row['TypeMeterId'] ?? '') as String?;
        String? serialNumber = (row['SerialNumber'] ?? '') as String?;
        String? date = (row['DateVerif'] ?? '') as String?;
        String? idAction = (row['ActionId'] ?? '') as String?;
        String? sealNumber = (row['SealNumber'] ?? '') as String?;
        String? statusId = (row['StatusId'] ?? '') as String?;
        String? readout = (row['Readout'] ?? '') as String?;
        String? idTypSitu = (row['TypSituId'] ?? '') as String?;
        String? photoName = (row['PhotoName'] ?? '') as String?;
        String? cdDate = (row['CdDate'] ?? '') as String?;
        String? rpuId = (row['RpuId'] ?? '') as String?;
        String? diameter = (row['Diameter'] ?? '') as String?;

        waterMeterModel = WaterMeterModel(
            id: id.toString(),
            ActId: row['act_id'].toString(),
            CounterId: idCounter.toString(),
            Kpuid: idKpu.toString(),
            Calibr: calibr.toString(),
            TypeMeterId: idTypeMeter.toString(),
            SerialNumber: serialNumber.toString(),
            DateVerif: date.toString(),
            ActionId: idAction.toString(),
            SealNumber: sealNumber.toString(),
            StatusId: statusId.toString(),
            Readout: readout.toString(),
            TypSituId: idTypSitu.toString(),
            PhotoName: photoName.toString(),
            CdDate: cdDate.toString(),
            RpuId: rpuId.toString(),
            Diameter: diameter.toString());

        waterMeterModel.toXml();
        isVisibleBtnDelete = true;

        await Future.delayed(Duration(milliseconds: 500));

        setState(() {
          isLoading = false;
        });

        String actionId = waterMeterModel.ActionId;
        if (actionId != "null" && actionId != "") {
          valueListenableAction.value = waterMeterModel.ActionId;
          if (valueListenableAction.value == "1" ||
              valueListenableAction.value == "9") {
            isVisibleDate = false;
            isVisibleDiameter = false;
            isVisiblePlaceInstallation = false;
            isVisibleFillingsNumber = false;
          } else if (valueListenableAction.value == "8") {
            isVisibleDiameter = false;
            isVisiblePlaceInstallation = false;
            isVisibleDate = true;
          } else {
            isVisibleDate = true;
            isVisibleDiameter = true;
            isVisiblePlaceInstallation = true;
            isVisibleFillingsNumber = true;
          }
        }

        String counterId = waterMeterModel.CounterId.toString();
        if (counterId != "null" && counterId != "" && counterId != null) {
          ipuController.text = counterId;
          isVisibleIpuTextField = true;

          //Так как установить установленный нельзя скрываем Установка ПУ
          itemActions.removeLast();
          itemActions.add({'name': 'Поверка без демонтажа', 'value': '8'});

          btnDeleteTxt = "Очистить";
          onlyRead = true;
        }

        String kpuId = waterMeterModel.Kpuid;
        if (kpuId != "null" && kpuId != "") {
          valueListenableClassIpu.value = kpuId;
        }

        String typeMeterId = waterMeterModel.TypeMeterId;
        if (typeMeterId != "" && kpuId != "null") {
          valueListenableTypeIpu.value = typeMeterId;
        }

        String typSituId = waterMeterModel.TypSituId;
        if (typSituId != null && typSituId.isNotEmpty && typSituId != "null") {
          valueListenableTypicalSituation.value = typSituId;
        }

        String dia = waterMeterModel.Diameter;
        if (diameter != null && diameter.isNotEmpty && diameter != "null") {
          valueListenableDiameter.value = dia;
        }

        String rpu = waterMeterModel.RpuId;
        if (rpu != null && rpu.isNotEmpty && rpu != "null") {
          valueListenablePlaceInstallation.value = rpu;
        }

        factoryNumberController.text = waterMeterModel.SerialNumber.toString();
        indicationController.text = waterMeterModel.Readout.toString();
        fillingsNumberController.text = waterMeterModel.SealNumber.toString();
        photoController.text = waterMeterModel.PhotoName.toString();
        dateController.text = waterMeterModel.DateVerif.toString();

        setState(() {});
      }
    } else {
      print('Нет данных для id = $actId');
    }
    log("result getWaterM: ${result}");
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        dateController.text = _selectedDate == null
            ? 'Дата не выбрана!'
            : '${_selectedDate?.day.toString()}.${_selectedDate?.month.toString()}.${_selectedDate?.year.toString()}';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    places();
    classIpu();
    typeIpu(widget.sector);
    situations(widget.sector);
    fetchCounters(widget.id);
  }

  @override
  void dispose() {
    valueListenableTypeIpu.dispose();
    valueListenableClassIpu.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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
        child: Center(
            child: isLoading
                ? CircularProgressIndicator()
                : Container(
                    height: screenHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0x00fffc95), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: buildSingleChildScrollView(context))),
      ),
    );
  }

  SingleChildScrollView buildSingleChildScrollView(BuildContext context) {
    return SingleChildScrollView(
      child: buildPadding(context),
    );
  }

  Padding buildPadding(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: buildColumn(context),
    );
  }

  Column buildColumn(BuildContext context) {
    return Column(children: [
      buildIpu(),
      buildAction(),
      buildFactoryNumber(),
      buildClassIpu(),
      buildTypeIpu(),
      buildDiameter(),
      buildPlaceInstallation(),
      buildDateVerification(context),
      buildIndication(),
      buildFillingsNumber(),
      buildTypicalSituation(),
      buildPhoto(context),
      buildBtn(),
    ]);
  }

  Column buildBtn() {
    return Column(
      children: [
        SizedBox(height: 10.0),
        Row(
          children: [
            Visibility(
              visible: isVisibleBtnDelete,
              replacement: SizedBox(),
              child: Expanded(
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      btnDelete();
                      Navigator.pop(context, "waterMeter");
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.blueAccent),
                    child: Text(
                      btnDeleteTxt,
                      style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 5.0),
            Expanded(
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    btnSave();
                    Navigator.pop(context, "waterMeter");
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.blueAccent),
                  child: Text(
                    'Сохранить',
                    style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Column buildPhoto(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10.0),
        SizedBox(
          height: 55,
          child: TextField(
              decoration: InputDecoration(
                labelText: 'Фото',
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
                            Text('Фото ИПУ', style: TextStyle(fontSize: 18)),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent),
                                  child: Text(
                                    'Фото',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400),
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
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400),
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
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  onPressed: () {
                                    openFile();
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
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    });
              }),
        ),
      ],
    );
  }

  Column buildTypicalSituation() {
    return Column(
      children: [
        SizedBox(height: 10.0),
        Form(
          key: _formKey5,
          child: DropdownButtonFormField2<String>(
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            hint: const Text(
              'Типичная ситуация',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            items: itemSituations
                .map((item) => DropdownItem<String>(
                      value: item['id'],
                      child: Text(
                        "${item['name']}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                    ))
                .toList(),
            valueListenable: valueListenableTypicalSituation,
            onChanged: (value) {
              setState(() => valueListenableTypicalSituation.value = value);
            },
            iconStyleData: const IconStyleData(
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.black45,
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  Visibility buildFillingsNumber() {
    return Visibility(
      visible: isVisibleFillingsNumber,
      replacement: SizedBox(),
      child: Column(
        children: [
          SizedBox(height: 10.0),
          SizedBox(
            height: 50,
            child: TextField(
              readOnly: onlyRead,
              decoration: InputDecoration(
                labelText: 'Номер пломбы',
                border: OutlineInputBorder(),
              ),
              controller: fillingsNumberController,
              keyboardType: TextInputType.phone,
            ),
          ),
        ],
      ),
    );
  }

  Column buildIndication() {
    return Column(
      children: [
        SizedBox(height: 10.0),
        SizedBox(
          height: 50,
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Показание',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            controller: indicationController,
          ),
        ),
      ],
    );
  }

  Visibility buildDateVerification(BuildContext context) {
    return Visibility(
      visible: isVisibleDate,
      replacement: SizedBox(),
      child: Column(
        children: [
          SizedBox(height: 10.0),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Дата поверки',
                      border: OutlineInputBorder(),
                    ),
                    controller: dateController,
                    keyboardType: TextInputType.text,
                  ),
                ),
              ),
              SizedBox(width: 10.0),
              SizedBox(
                width: 60,
                height: 55,
                child: IconButton(
                  icon: Icon(Icons.date_range_rounded),
                  // The icon displayed
                  color: Colors.blue,
                  // The color of the icon
                  iconSize: 40.0,
                  // The size of the icon
                  tooltip: 'Date',
                  // Tooltip when long-pressed
                  onPressed: () {
                    selectDate(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Visibility buildPlaceInstallation() {
    return Visibility(
      visible: isVisiblePlaceInstallation,
      replacement: SizedBox(),
      child: Column(
        children: [
          SizedBox(height: 10.0),
          Form(
            key: _formKey4,
            child: DropdownButtonFormField2<String>(
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              hint: const Text(
                'Место установки',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
              items: itemPlaces
                  .map((item) => DropdownItem<String>(
                        value: item['id'],
                        child: Text(
                          "${item['name']}",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                      ))
                  .toList(),
              valueListenable: valueListenablePlaceInstallation,
              onChanged: (value) {
                valueListenablePlaceInstallation.value = value;
              },
              iconStyleData: const IconStyleData(
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black45,
                ),
              ),
              dropdownStyleData: DropdownStyleData(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              menuItemStyleData: const MenuItemStyleData(
                padding: EdgeInsets.symmetric(horizontal: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Visibility buildDiameter() {
    return Visibility(
      visible: isVisibleDiameter,
      replacement: SizedBox(),
      child: Column(
        children: [
          SizedBox(height: 10.0),
          Form(
            key: _formKey3,
            child: DropdownButtonFormField2<String>(
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              hint: const Text(
                'Диаметр',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
              items: itemDiameters
                  .map((item) => DropdownItem<String>(
                        value: item.values.last,
                        child: Text(
                          item.values.first,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                      ))
                  .toList(),
              valueListenable: valueListenableDiameter,
              onChanged: (value) {
                valueListenableDiameter.value = value;
              },
              iconStyleData: const IconStyleData(
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black45,
                ),
              ),
              dropdownStyleData: DropdownStyleData(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              menuItemStyleData: const MenuItemStyleData(
                padding: EdgeInsets.symmetric(horizontal: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column buildTypeIpu() {
    return Column(
      children: [
        SizedBox(height: 10.0),
        Form(
          key: _formKey2,
          child: DropdownButtonFormField2<String>(
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            hint: const Text(
              'Тип ИПУ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            items: itemType
                .map((item) => DropdownItem<String>(
                      value: item['id'],
                      child: Text(
                        "${item['name']}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                    ))
                .toList(),
            valueListenable: valueListenableTypeIpu,
            onChanged: onlyRead
                ? null
                : (value) {
                    valueListenableTypeIpu.value = value;
                  },
            iconStyleData: const IconStyleData(
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.black45,
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              padding: EdgeInsets.symmetric(horizontal: 15),
            ),
          ),
        ),
      ],
    );
  }

  Column buildClassIpu() {
    return Column(
      children: [
        SizedBox(height: 10.0),
        Form(
          key: _formKey1,
          child: DropdownButtonFormField2<String>(
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            hint: const Text(
              'Класс ИПУ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            items: itemClass
                .map((item) => DropdownItem<String>(
                      value: item['id'],
                      child: Text(
                        "${item['name']}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                    ))
                .toList(),
            valueListenable: valueListenableClassIpu,
            onChanged: onlyRead
                ? null
                : (newValue) {
                    valueListenableClassIpu.value = newValue;
                  },
            iconStyleData: const IconStyleData(
              icon: Icon(Icons.arrow_drop_down, color: Colors.black45),
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              padding: EdgeInsets.symmetric(horizontal: 15),
            ),
          ),
        ),
      ],
    );
  }

  Column buildFactoryNumber() {
    return Column(
      children: [
        SizedBox(height: 10.0),
        SizedBox(
          height: 50,
          child: TextField(
            readOnly: onlyRead,
            decoration: InputDecoration(
              labelText: 'Заводской номер',
              border: OutlineInputBorder(),
            ),
            controller: factoryNumberController,
            keyboardType: TextInputType.text,
          ),
        ),
      ],
    );
  }

  Form buildAction() {
    return Form(
      key: _formKey,
      child: DropdownButtonFormField2<String>(
        isExpanded: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
        hint: const Text(
          'Действие',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        items: itemActions
            .map((item) => DropdownItem<String>(
                  value: item.values.last,
                  child: Text(
                    item.values.first,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                ))
            .toList(),
        valueListenable: valueListenableAction,
        onChanged: (value) {
          valueListenableAction.value = value;
          setState(() {
            if (value == "1" || value == "9") {
              isVisibleDate = false;
              isVisibleDiameter = false;
              isVisiblePlaceInstallation = false;
              isVisibleFillingsNumber = false;
            } else if (value == "8") {
              isVisibleDiameter = false;
              isVisiblePlaceInstallation = false;
              isVisibleDate = true;
            } else {
              isVisibleDate = true;
              isVisibleDiameter = true;
              isVisiblePlaceInstallation = true;
              isVisibleFillingsNumber = true;
            }
          });
        },
        iconStyleData: const IconStyleData(
          icon: Icon(
            Icons.arrow_drop_down,
            color: Colors.black45,
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          padding: EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Visibility buildIpu() {
    FocusNode focusNode = FocusNode(canRequestFocus: false);
    return Visibility(
      visible: isVisibleIpuTextField,
      replacement: SizedBox(),
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: TextField(
              readOnly: true,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Ипу',
                border: OutlineInputBorder(),
              ),
              controller: ipuController,
              keyboardType: TextInputType.text,
            ),
          ),
          SizedBox(height: 10.0),
        ],
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      title: Text(
        "Новый водомер",
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.blueAccent,
    );
  }

  void pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxHeight: 800,
        maxWidth: 800,
      );
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          photoController.text = _image!.path;
        });
      }
    } catch (e) {
      log("Ошибка: $e");
    }
  }

  void openFile() async {
    try {
      String filePath = photoController.text;
      if (filePath.isEmpty) {
        setState(() {
          log("Введите путь к файлу");
        });
        return;
      }

      if (!File(filePath).existsSync()) {
        setState(() {
          log("Файл не найден: $filePath");
        });
        return;
      }

      final result = await OpenFile.open(filePath);
      setState(() {
        log("Результат: ${result.message}");
        Navigator.pop(context);
      });
    } catch (e) {
      setState(() {
        log("Ошибка: $e");
      });
    }
  }

  void btnSave() async {
    String sql;
    final db = await DbOpenHelper().database;

    String? kpuId = valueListenableClassIpu.value ?? '';
    String? typeMeterId = valueListenableTypeIpu.value ?? '';
    String serialNumber = factoryNumberController.text.toString();
    String? actionId = valueListenableAction.value ?? '';
    String date = dateController.text.toString();
    String sealNumber = fillingsNumberController.text.toString();
    String readout = indicationController.text.toString();
    String? typSituId = valueListenableTypicalSituation.value ?? '';
    String photoName = photoController.text.toString();
    int timestampInSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    log("time $timestampInSeconds");
    String cdDate = timestampInSeconds.toString();
    String? diameter = valueListenableDiameter.value ?? '';
    String? rpuId = valueListenablePlaceInstallation.value ?? '';

    if (widget.id == "") {
      String actId = widget.actId;

      sql =
          "insert into Counters(act_id,Kpuid,TypeMeterId,SerialNumber,ActionId,DateVerif,SealNumber,Readout,TypSituId,PhotoName,CdDate,Diameter,RpuId)" +
              "values(" +
              actId +
              ",\"" +
              kpuId +
              "\",\"" +
              typeMeterId +
              "\",\"" +
              serialNumber +
              "\",\"" +
              actionId +
              "\",\"" +
              date +
              "\",\"" +
              sealNumber +
              "\",\"" +
              readout +
              "\",\"" +
              typSituId +
              "\",\"" +
              photoName +
              "\",\"" +
              cdDate +
              "\",\"" +
              diameter +
              "\",\"" +
              rpuId +
              "\");";

      await db.execute(sql);
      log("insert Counters $sql");
    } else {
      String actId = widget.id;

      sql = "update Counters set" +
          " Kpuid=\"" +
          kpuId +
          "\"," +
          " TypeMeterId=\"" +
          typeMeterId +
          "\"," +
          " SerialNumber=\"" +
          serialNumber +
          "\"," +
          " ActionId=\"" +
          actionId +
          "\"," +
          " DateVerif=\"" +
          date +
          "\"," +
          " SealNumber=\"" +
          sealNumber +
          "\"," +
          " Readout=\"" +
          readout +
          "\"," +
          " TypSituId=\"" +
          typSituId +
          "\"," +
          " PhotoName=\"" +
          photoName +
          "\"," +
          " CdDate=\"" +
          cdDate +
          "\"," +
          " Diameter=\"" +
          diameter +
          "\"," +
          " RpuId=\"" +
          rpuId +
          "\"" +
          " where id=" +
          actId +
          ";";

      await db.execute(sql);
      log("update Counters $sql");
    }
  }

  void btnDelete() async {
    String sql;
    final db = await DbOpenHelper().database;

    // Если ИПУ не задан то удаляем полностью
    if (ipuController.text == "") {
      sql = "delete from Counters where id=${widget.id}";
      await db.execute(sql);
      log("delete sql $sql");
    } else {
      // Если ИПУ задан очищаем поля
      sql =
          "update Counters set ActionId=null, DateVerif=null, Readout=null, PhotoName=null where id=${widget.id}";
      await db.execute(sql);
      log("delete update sql $sql");
    }
  }
}
