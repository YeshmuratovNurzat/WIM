import 'dart:developer';
import 'package:WIM/data/model/act_model.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import '../../data/database/dbOpenHelper.dart';
import 'act.dart';

class Acts extends StatelessWidget {
  const Acts({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ActsPage(sector: ''),
    );
  }
}

class ActsPage extends StatefulWidget {
  final String sector;
  ActsPage({super.key, required this.sector});

  @override
  State<ActsPage> createState() => _ActsPageState();
}

class _ActsPageState extends State<ActsPage> {
  String sql = "";
  int? id;
  List<ActModel> listAct = [];

  final accountController = TextEditingController();
  final numberActController = TextEditingController();
  final addressController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  final valueListenable = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    getActs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: buildContainer(),
      bottomSheet: buildContainerBottom(context),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      title: Text("Aкты", style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.blueAccent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.filter_alt_rounded),
          onPressed: () => filter(context),
        ),
      ],
    );
  }

  Padding buildContainerBottom(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: () {
            navigateAct(context, widget.sector, '');
          },
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.blueAccent),
          child: Text(
            'Создать акт',
            style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w400, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Container buildContainer() {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0x00fffc95), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: buildSingleChildScrollView(),
    );
  }

  SingleChildScrollView buildSingleChildScrollView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 800,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: listAct.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return buildHeaderRow();
            ActModel act = listAct[index - 1];
            return InkWell(
              onTap: () {
                navigateAct(context, widget.sector, act.id.toString());
              },
              child: buildDataRow(act),
            );
          },
        ),
      ),
    );
  }

  Widget buildHeaderRow() {
    return Row(
      children: [
        buildHeaderCell('№ акта', 100.0),
        buildHeaderCell('Дата акта', 120.0),
        buildHeaderCell('Л/с', 100.0),
        buildHeaderCell('Адрес', 150.0),
        buildHeaderCell('Сектор', 160.0),
        buildHeaderCell('Статус', 150.0),
      ],
    );
  }

  Widget buildDataRow(ActModel act) {
    return IntrinsicHeight(
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                buildDataCell(act.actNumber, 100.0),
                buildDataCell(act.actDate, 120.0),
                buildDataCell(act.accountNumber, 100.0),
                buildDataCell(act.address, 150.0),
                buildDataCell(act.sector, 160.0),
                buildDataCell(act.status, 150.0),
              ],
            ),
          ),
          Divider()
        ],
      ),
    );
  }

  Widget buildHeaderCell(String text, double width) {
    return Container(
      width: width,
      padding: EdgeInsets.all(10),
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget buildDataCell(String text, double width) {
    return Container(
      width: width,
      padding: EdgeInsets.all(8),
      child: Center(child: Text(maxLines: 1, overflow: TextOverflow.ellipsis, text)),
    );
  }

  Widget button(context, String sector) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ActPage(sector: sector, id: '')),
              );
            },
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.blueAccent),
            child: Text(
              'Создать акт',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: Colors.white),
            ),
          ),
        ),
        SizedBox(
          height: 5,
        )
      ],
    );
  }

  Widget buildFilter() {
    final List<Map<String, String>> items = [
      {'name': 'Отобразить все', 'value': '3'},
      {'name': 'Отобразить принятые', 'value': '1'},
      {'name': 'Отобразить не принятые', 'value': '2'},
    ];

    return Column(
      children: [
        Form(
          key: formKey,
          child: DropdownButtonFormField2<String>(
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            hint: const Text(
              'Статус акта',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            items: items
                .map((item) => DropdownItem<String>(
                      value: item["value"],
                      child: Text(
                        "${item["name"]}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                    ))
                .toList(),
            valueListenable: valueListenable,
            onChanged: (value) {
              valueListenable.value = value;
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
        SizedBox(height: 10),
        buildTextField('Лицевой счёт', accountController),
        SizedBox(height: 10),
        buildTextField('№ акта', numberActController),
        SizedBox(height: 10),
        buildTextField('Адрес', addressController)
      ],
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      controller: controller,
    );
  }

  Widget buildButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          getActs();
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.blueAccent),
        child: Text('Показать',
            style: TextStyle(fontSize: 17, color: Colors.white)),
      ),
    );
  }

  void filter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: 420,
            width: double.infinity,
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Фильтр', style: TextStyle(fontSize: 17)),
                SizedBox(height: 10),
                buildFilter(),
                SizedBox(height: 15),
                buildButton(context),
              ],
            ),
          ),
        );
      },
    );
  }

  void navigateAct(BuildContext context, String sector, String id) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActPage(
          sector: sector,
          id: id,
        ),
      ),
    );

    if (result != null) {
      getActs();
      setState(() {});
      log("navigateAct result: $result");
    }
  }

  Future<void> getActs() async {
    String? value = valueListenable.value ?? "3";
    log("value: $value");

    if (value == "1") {
      // Отобразить принятые
      sql = "select  id, NumAct, DtDate, AccountId, Adress, CASE Sector WHEN '0' THEN 'Многоквартирный' WHEN '1' THEN 'Частный' WHEN '2' THEN 'Юредический' ELSE '-' END Sector, CASE StatusId WHEN '1' THEN 'Принят' WHEN '2' THEN 'Не принят' ELSE '-' END Status from Acts  where  StatusId=\"1\"  and Sector=\"${widget.sector}\" ";

      if (accountController.text.isNotEmpty) {
        sql += " and UPPER(AccountId) like UPPER('%${accountController.text}%')";
      }

      if (numberActController.text.isNotEmpty) {
        sql += " and UPPER(NumAct) like UPPER('%${numberActController.text}%')";
      }

      if (addressController.text.isNotEmpty) {
        sql += " and UPPER(Adress) like UPPER('%${addressController.text}%')";
      }

      sql += " order by id DESC;";
    } else if (value == "2") {
      // Отобразить не принятые
      sql = "select  id, NumAct, DtDate, AccountId, Adress, CASE Sector WHEN '0' THEN 'Многоквартирный' WHEN '1' THEN 'Частный' WHEN '2' THEN 'Юредический' ELSE '-' END Sector, CASE StatusId WHEN '1' THEN 'Принят' WHEN '2' THEN 'Не принят' ELSE '-' END Status from Acts  where  StatusId=\"2\"  and Sector=\"${widget.sector}\" ";

      if (accountController.text.isNotEmpty) {
        sql += " and UPPER(AccountId) like UPPER('%${accountController.text}%')";
      }

      if (numberActController.text.isNotEmpty) {
        sql += " and UPPER(NumAct) like UPPER('%${numberActController.text}%')";
      }

      if (addressController.text.isNotEmpty) {
        sql += " and UPPER(Adress) like UPPER('%${addressController.text}%')";
      }

      sql += " order by id DESC;";
    } else {
      // Отобразить все
      sql = "select  id, NumAct, DtDate, AccountId, Adress, CASE Sector WHEN '0' THEN 'Многоквартирный' WHEN '1' THEN 'Частный' WHEN '2' THEN 'Юредический' ELSE '-' END Sector, CASE StatusId WHEN '1' THEN 'Принят' WHEN '2' THEN 'Не принят' ELSE '-' END || ' ' || ifnull(StatusText,'') as Status from Acts where Sector=\"${widget.sector}\"";

      if (accountController.text.isNotEmpty) {
        sql += " and UPPER(AccountId) like UPPER('%${accountController.text}%')";
      }

      if (numberActController.text.isNotEmpty) {
        sql += " and UPPER(NumAct) like UPPER('%${numberActController.text}%')";
      }

      if (addressController.text.isNotEmpty) {
        sql += " and UPPER(Adress) like UPPER('%${addressController.text}%')";
      }

      sql += " order by id DESC;";
    }

    setActs(sql);
  }

  Future<void> setActs(String sql) async {
    final db = await DbOpenHelper().database;
    final result = await db.rawQuery(sql);
    log("result get acts: $result");
    listAct.clear();

    for (var row in result) {
      id = (row['id'] ?? '') as int?;
      log("id = $id");

      String? numAct = (row['NumAct'] ?? '') as String?;
      String? date = (row['DtDate'] ?? '') as String?;
      String? accountId = (row['AccountId'] ?? '') as String?;
      String? address = (row['Adress'] ?? '') as String?;
      String? sector = (row['Sector'] ?? '') as String?;
      String? status = (row['Status'] ?? '') as String?;
      log("numAct = $numAct");
      log("status = $status");

      if (numAct == "" && accountId == "") {
        final db = await DbOpenHelper().database;
        db.rawQuery("delete from Counters where act_id=$id");
        db.rawQuery("delete from Acts where id=$id");
        log("delete act");
      } else {
        listAct.add(ActModel(
            id: id.toString(),
            actNumber: numAct.toString(),
            actDate: date.toString(),
            accountNumber: accountId.toString(),
            address: address.toString(),
            sector: sector.toString(),
            status: status.toString()));
      }
    }

    setState(() {});
  }
}
