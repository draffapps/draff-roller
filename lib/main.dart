import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roller/SavedRoll.dart';
import 'package:roller/roll_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'odd roller',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Just keep on rollin baby'),
    );
  }
}

List<int> dieList = [20, 4, 6, 8, 10, 12, 100];

class DieDropDown extends StatefulWidget {
  final Function(int value) notifyParent;
  const DieDropDown({Key? key, required this.notifyParent}) : super(key: key);

  @override
  State<DieDropDown> createState() => _DieDropDownState();
}

class _DieDropDownState extends State<DieDropDown> {
  int dropdownValue = dieList.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: dropdownValue,
      // icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (int? value) {
        if (value == null) return;
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value;
        });
        widget.notifyParent(value);
      },
      items: dieList.map<DropdownMenuItem<int>>((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text('D$value'),
        );
      }).toList(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentDie = 20;
  String symbol = '+';
  final List<Row> history = [];
  List<SavedRoll> savedRolls = [];
  final numberOfDiceController = TextEditingController(text: '1');
  final bonusController = TextEditingController(text: '0');

  void _loadSavedRolls() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String json = prefs.getString('savedRolls') ?? '[]';
    List<dynamic> rollMap = jsonDecode(json);

    List<SavedRoll> rolls = [];

    for (var e in rollMap) {
      rolls.add(SavedRoll.fromJson(e));
    }
    setState(() {
      savedRolls = rolls;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSavedRolls();
  }

  void _addSavedRoll(SavedRoll savedRoll) async {
    final prefs = await SharedPreferences.getInstance();
    List<SavedRoll> newList = [...savedRolls, savedRoll];

    setState(() {
      savedRolls = newList;
      prefs.setString('savedRolls', jsonEncode(newList));
    });
  }

  void _deleteRoll(SavedRoll roll) async {
    final prefs = await SharedPreferences.getInstance();
    int index = savedRolls.indexOf(roll);

    savedRolls.removeAt(index);
    setState(() {
      savedRolls = savedRolls;
      prefs.setString('savedRolls', jsonEncode(savedRolls));
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    numberOfDiceController.dispose();
    bonusController.dispose();
    super.dispose();
  }

  Future<void> _saveDialog() async {
    final nameController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Name'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                    autofocus: true,
                    textAlign: TextAlign.center,
                    controller: nameController,
                    decoration:
                        const InputDecoration(border: UnderlineInputBorder()))
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (nameController.text.isEmpty) return;
                _addSavedRoll(SavedRoll(
                    nameController.text,
                    int.parse(numberOfDiceController.text),
                    currentDie,
                    symbol,
                    int.parse(bonusController.text)));
                rollIt(int.parse(numberOfDiceController.text), currentDie,
                    symbol, int.parse(bonusController.text), _addToHistory,
                    description: nameController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _savedRollsDialog() async {
    if (savedRolls.isEmpty) {
      return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'No Rolls Saved',
                textAlign: TextAlign.center,
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Select Roll',
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: savedRolls
                  .map((e) => Row(children: [
                        Expanded(
                            child: OutlinedButton(
                                onPressed: () {
                                  rollIt(e.numberOfDice, e.dieSize, e.symbol,
                                      e.bonus, _addToHistory,
                                      description: e.description);
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                    '${e.description}: ${e.numberOfDice}d${e.dieSize} ${e.symbol} ${e.bonus}'))),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: 'Delete',
                          onPressed: () {
                            _deleteRoll(e);

                            Navigator.of(context).pop();
                            _savedRollsDialog();
                          },
                        )
                      ]))
                  .toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _setDieSize(int dieSize) {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      currentDie = dieSize;
    });
  }

  void _setSymbol(String symbol) {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      symbol = symbol;
    });
  }

  void _addToHistory(Row entry) {
    setState(() {
      history.add(entry);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 5,
              child:
                  ListView(children: history.reversed.map((e) => e).toList()),
            ),
            const SizedBox(height: 5),
            SizedBox(
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: 50,
                          child: TextField(
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ], // Only numbers can be entered
                              controller: numberOfDiceController,
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                              ))),
                      DieDropDown(
                        notifyParent: _setDieSize,
                      ),
                      SizedBox(
                          width: 30,
                          height: 30,
                          child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.all(2)),
                              onPressed: () {
                                if (symbol == '+') {
                                  _setSymbol('-');
                                } else {
                                  _setSymbol('+');
                                }
                              },
                              child: Text(
                                symbol,
                                textAlign: TextAlign.center,
                              ))),
                      SizedBox(
                          width: 50,
                          child: TextField(
                              textAlign: TextAlign.center,
                              controller: bonusController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ], // Only numbers can be entered
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                              ))),
                      OutlinedButton(
                          onPressed: () {
                            rollIt(
                                int.parse(numberOfDiceController.text),
                                currentDie,
                                symbol,
                                int.parse(bonusController.text),
                                _addToHistory);
                          },
                          child: const Text('Roll')),
                      OutlinedButton(
                          onPressed: _saveDialog, child: const Text('Save')),
                    ],
                  ),
                )),
            OutlinedButton(
                onPressed: _savedRollsDialog,
                child: const Text('Show Saved Rolls')),
          ],
        ),
      ),
    );
  }
}
