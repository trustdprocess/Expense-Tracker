import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'model/adapter.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(ExpenditureAdapter());
  await Hive.openBox<Expenditure>('Expenses_box');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double expenses = 100;
  final _expensesBox = Hive.box<Expenditure>('Expenses_box');
  late List<Expenditure> _items;

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  void _refreshItems() {
    final data = _expensesBox.keys.map((key) {
      final value = _expensesBox.get(key);
      return Expenditure(
        name: value!.name,
        amount: value.amount,
        date: value.date,
      );
    }).toList();

    setState(() {
      _items = data.reversed.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Expense Tracker"),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 250,
                    width: 430,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          "Your Current Balance:",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "\$ " + expenses.toString(),
                            style: TextStyle(color: Colors.green, fontSize: 30),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black),
                    child: ListTile(
                      title: Text(
                        "Expense Name:" + item.name,
                        style: TextStyle(color: Colors.green),
                      ),
                      contentPadding: EdgeInsets.all(8),
                      subtitle: Text(
                        "Total Amount" + item.amount.toString(),
                        style: TextStyle(color: Colors.green),
                      ),
                      trailing: Text(
                        "Date Of Expense " + item.date,
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.green,
        backgroundColor: Colors.black,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddExpenseScreen()),
          ).then((value) {
            if (value != null && value) {
              _refreshItems();
            }
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddExpenseScreen extends StatefulWidget {
  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
 
  TextEditingController _nameController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
    List<String> list = ['Expenses', 'Income'];
  String dropdownValue = 'Expenses';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Expense"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Name Of Expense"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _dateController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Date Of Expense"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                    labelText: "Amount Of Expense",
                       suffixIcon: DropdownButton(
                    value: dropdownValue,
                    icon: const Icon(
                      Icons.arrow_downward,
                      color: Colors.black,
                    ),
                    elevation: 0,
                    items: list.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        dropdownValue = value!;
                      });
                    },
                  ),
              ),
            ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: () {
                  final name = _nameController.text;
                  final amount = double.tryParse(_amountController.text) ?? 0.0;
                  final date = _dateController.text;

                  if (name.isNotEmpty && amount > 0 && date.isNotEmpty) {
                    final newExpense = Expenditure(
                      name: name,
                      amount: amount,
                      date: date,
                    );
                    Hive.box<Expenditure>('Expenses_box').add(newExpense);
                    Navigator.pop(context, true); // Return to previous screen
                  }
                },
                child: Text(
                  "Add Expense",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
