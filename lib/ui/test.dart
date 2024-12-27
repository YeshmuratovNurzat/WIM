import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// void main() {
//   runApp(Test());
// }

class Act {
  final String actNumber;
  final String actDate;
  final String accountNumber;
  final String address;
  final String sector;
  final String status;

  Act({
    required this.actNumber,
    required this.actDate,
    required this.accountNumber,
    required this.address,
    required this.sector,
    required this.status,
  });
}

class ActListView extends StatelessWidget {
  final List<Act> actList = [
    Act(
      actNumber: '001',
      actDate: '2024-10-01',
      accountNumber: 'L1234',
      address: '123 Main St',
      sector: 'Sector A',
      status: 'Open',
    ),
    Act(
      actNumber: '002',
      actDate: '2024-10-02',
      accountNumber: 'L1235',
      address: '456 Elm St',
      sector: 'Sector B',
      status: 'Closed',
    ),
    Act(
      actNumber: '003',
      actDate: '2024-10-03',
      accountNumber: 'L1236',
      address: '789 Oak St',
      sector: 'Sector C',
      status: 'Pending',
    ),
    Act(
      actNumber: '003',
      actDate: '2024-10-03',
      accountNumber: 'L1236',
      address: '789 Oak St',
      sector: 'Sector C',
      status: 'Pending',
    ),
    Act(
      actNumber: '003',
      actDate: '2024-10-03',
      accountNumber: 'L1236',
      address: '789 Oak St',
      sector: 'Sector C',
      status: 'Pending',
    ),
    Act(
      actNumber: '003',
      actDate: '2024-10-03',
      accountNumber: 'L1236',
      address: '789 Oak St',
      sector: 'Sector C',
      status: 'Pending',
    ),
    Act(
      actNumber: '003',
      actDate: '2024-10-03',
      accountNumber: 'L1236',
      address: '789 Oak St',
      sector: 'Sector C',
      status: 'Pending',
    ),
    Act(
      actNumber: '003',
      actDate: '2024-10-03',
      accountNumber: 'L1236',
      address: '789 Oak St',
      sector: 'Sector C',
      status: 'Pending',
    ),
    Act(
      actNumber: '003',
      actDate: '2024-10-03',
      accountNumber: 'L1236',
      address: '789 Oak St',
      sector: 'Sector C',
      status: 'Pending',
    ),
    // Add more Act objects as necessary
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Act List'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Horizontal scrolling
        child: Container(
          width: 1000, // Adjust to fit the total width of your columns
          child: ListView.builder(
            scrollDirection: Axis.vertical, // Vertical scrolling
            itemCount: actList.length + 1, // +1 for the header row
            itemBuilder: (context, index) {
              if (index == 0) {
                // Return the header row
                return _buildHeaderRow();
              }
              Act act =
                  actList[index - 1]; // Index - 1 to account for the header
              return _buildDataRow(act);
            },
          ),
        ),
      ),
    );
  }

  // Helper function to build the header row
  Widget _buildHeaderRow() {
    return Row(
      children: [
        _buildHeaderCell('№ акта', 100.0),
        _buildHeaderCell('Дата акта', 100.0),
        _buildHeaderCell('Л/с', 100.0),
        _buildHeaderCell('Адрес', 300.0),
        _buildHeaderCell('Сектор', 150.0),
        _buildHeaderCell('Статус', 250.0),
      ],
    );
  }

  // Helper function to build each data row
  Widget _buildDataRow(Act act) {
    return Row(
      children: [
        _buildDataCell(act.actNumber, 100.0),
        _buildDataCell(act.actDate, 100.0),
        _buildDataCell(act.accountNumber, 100.0),
        _buildDataCell(act.address, 300.0),
        _buildDataCell(act.sector, 150.0),
        _buildDataCell(act.status, 250.0),
      ],
    );
  }

  // Helper function to create header cells
  Widget _buildHeaderCell(String text, double width) {
    return Container(
      width: width,
      padding: EdgeInsets.all(10),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Helper function to create data cells
  Widget _buildDataCell(String text, double width) {
    return Container(
      width: width,
      padding: EdgeInsets.all(10),
      child: Text(text),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ActListView(),
  ));
}

class Test extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VerticalListWithTitleAndItems(),
    );
  }
}

class VerticalListWithTitleAndItems extends StatelessWidget {
  // Sample data for the list
  final List<Map<String, dynamic>> data = [
    {
      'title': 'Category 1',
      'items': ['Item 1', 'Item 2', 'Item 3']
    },
    {
      'title': 'Category 2',
      'items': ['Item 4', 'Item 5', 'Item 6']
    },
    {
      'title': 'Category 3',
      'items': ['Item 7', 'Item 8', 'Item 9']
    }
  ];

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text('Vertical List with Titles and Items'),
    //   ),
    //   body: ListView.builder(
    //     itemCount: data.length, // Number of categories
    //     itemBuilder: (context, index) {
    //       return CategoryWidget(
    //         title: data[index]['title'],
    //         items: data[index]['items'],
    //       );
    //     },
    //   ),
    // );
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            Container(
              height: 35.0, // Set height for the header row
              child: Row(
                children: [
                  Container(
                    width: 100.0,
                    child: Text(
                      '№ акта',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    width: 100.0,
                    child: Text(
                      'Дата акта',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    width: 100.0,
                    child: Text(
                      'Л/с',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    width: 300.0,
                    child: Text(
                      'Адрес',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    width: 150.0,
                    child: Text(
                      'Сектор',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    width: 250.0,
                    child: Text(
                      'Статус',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Replace with your dynamic item count
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Container(
                        width: 100.0,
                        child: Text('Data $index'), // Replace with your data
                      ),
                      Container(
                        width: 100.0,
                        child: Text('Data $index'),
                      ),
                      Container(
                        width: 100.0,
                        child: Text('Data $index'),
                      ),
                      Container(
                        width: 300.0,
                        child: Text('Data $index'),
                      ),
                      Container(
                        width: 150.0,
                        child: Text('Data $index'),
                      ),
                      Container(
                        width: 250.0,
                        child: Text('Data $index'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryWidget extends StatelessWidget {
  final String title;
  final List<String> items;

  CategoryWidget({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10), // Spacing between title and items
              Column(
                children: items
                    .map((item) => ListTile(
                          title: Text(item),
                          leading: Icon(Icons.check_box_outline_blank),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
