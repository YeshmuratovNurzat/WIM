import 'package:WIM/data/model/search_model.dart';
import 'package:WIM/ui/viewModel/SettingViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const SearchAccount());
}

class SearchAccount extends StatelessWidget {
  const SearchAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SearchAccountPage(sector: ''),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SearchAccountPage extends StatefulWidget {
  final String sector;

  SearchAccountPage({super.key, required this.sector});

  @override
  State<SearchAccountPage> createState() => _SearchAccountPageState();
}

class _SearchAccountPageState extends State<SearchAccountPage> {
  List<SearchModel> searchResult = [];

  final account = TextEditingController();
  final street = TextEditingController();
  final houseNumber = TextEditingController();
  final apartmentNumber = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final settingViewModel =
        Provider.of<SettingViewModel>(context, listen: true);

    return Scaffold(
      appBar: buildAppBar(context, settingViewModel),
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
              : Consumer<SettingViewModel>(
                  builder: (context, viewmodel, child) {
                    return buildContent(viewmodel);
                  },
                ),
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context, SettingViewModel settingViewModel) {
    return AppBar(
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      title: Text("Лицевой счёт", style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.blueAccent,
    );
  }

  Widget buildContent(SettingViewModel settingViewModel) {
    return Column(
      children: [
        buildSearchFields(),
        buildSearchButton(context, settingViewModel),
        SizedBox(height: 10),
        if (settingViewModel.searchModel != null) ...[
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: settingViewModel.searchModel!.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return buildHeaderRow();
                SearchModel act = settingViewModel.searchModel![index - 1];
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context, act);
                  },
                  child: buildDataRow(act),
                );
              },
            ),
          ),
        ]
      ],
    );
  }

  Widget buildHeaderRow() {
    return Row(
      children: [
        buildHeaderCell('Лицевой счет', 140),
        buildHeaderCell('Адрес', 150),
      ],
    );
  }

  Widget buildDataRow(SearchModel act) {
    return IntrinsicHeight(
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                buildDataCell(act.accountId, 140),
                buildDataCell(act.address, 200),
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
      padding: EdgeInsets.all(8),
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildDataCell(String text, double width) {
    return Container(
      width: width,
      padding: EdgeInsets.all(10),
      child: Center(child: Text(text)),
    );
  }

  void showSearchModal(
      BuildContext context, SettingViewModel settingViewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SizedBox(
                height: 420,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Поиск', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 10),
                    buildSearchFields(),
                    SizedBox(height: 15),
                    buildSearchButton(context, settingViewModel),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildSearchFields() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          buildTextField('Лицевой счёт', account),
          SizedBox(height: 10),
          buildTextField('Улица', street),
          SizedBox(height: 10),
          buildTextField('Номер дома', houseNumber),
          SizedBox(height: 10),
          buildTextField('Номер квартиры', apartmentNumber),
        ],
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return SizedBox(
      height: 50,
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        controller: controller,
      ),
    );
  }

  Widget buildSearchButton(
      BuildContext context, SettingViewModel settingViewModel) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () async {
            var search = Search(
                accountId: account.text,
                street: street.text,
                houseNumber: houseNumber.text,
                apartmentNumber: apartmentNumber.text);

            settingViewModel.search(search, widget.sector);
          },
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.blueAccent),
          child: Text('Найти',
              style: TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.w400)),
        ),
      ),
    );
  }
}
