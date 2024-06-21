import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roller/d20/d20_roller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../saved_roll.dart';

class D20Roller extends StatefulWidget {
  const D20Roller(
      {super.key, required this.addToHistory, required this.clearHistory});
  final Function(Wrap, String) addToHistory;
  final Function() clearHistory;

  @override
  State<D20Roller> createState() => _D20RollerState();
}

// ignore: camel_case_types
class _D20RollerState extends State<D20Roller> {
  int currentDie = 20;
  String symbol = '+';
  final List<Row> history = [];
  List<SavedRoll> savedRolls = [];
  final numberOfDiceController = TextEditingController(text: '1');
  final bonusController = TextEditingController(text: '0');
  String extra = '';

  void _loadSavedRolls() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String json = prefs.getString('d20Rolls') ?? '[]';
    List<dynamic> rollMap = jsonDecode(json);

    List<SavedRoll> rolls = [];

    for (var e in rollMap) {
      rolls.add(SavedRoll.fromJson(e));
    }
    setState(() {
      savedRolls = rolls;
    });
  }

  void _checkDieToExtra() {
    if (extra != '' && numberOfDiceController.text != '1') {
      numberOfDiceController.text = '1';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSavedRolls();
    numberOfDiceController.addListener(_checkDieToExtra);
  }

  void _addSavedRoll(SavedRoll savedRoll) async {
    final prefs = await SharedPreferences.getInstance();
    List<SavedRoll> newList = [...savedRolls, savedRoll];

    setState(() {
      savedRolls = newList;
      prefs.setString('d20Rolls', jsonEncode(newList));
    });
  }

  void _deleteRoll(SavedRoll roll) async {
    final prefs = await SharedPreferences.getInstance();
    int index = savedRolls.indexOf(roll);

    savedRolls.removeAt(index);
    setState(() {
      savedRolls = savedRolls;
      prefs.setString('d20Rolls', jsonEncode(savedRolls));
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
      barrierDismissible: true,
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
            Semantics(
              label: 'Save Button',
              child: TextButton(
                child: const Text('Save'),
                onPressed: () {
                  if (nameController.text.isEmpty) return;
                  SavedRoll roll = SavedRoll(
                      nameController.text,
                      int.parse(numberOfDiceController.text),
                      currentDie,
                      symbol,
                      int.parse(bonusController.text),
                      extra: extra);
                  _addSavedRoll(roll);
                  rollD20(roll, widget.addToHistory);
                  Navigator.of(context).pop();
                },
              ),
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
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'No Rolls Saved',
                textAlign: TextAlign.center,
              ),
              actions: <Widget>[
                Semantics(
                  label: 'Cancel Button',
                  child: TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            );
          });
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
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
                                  rollD20(e, widget.addToHistory);
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                    '${e.description}: ${e.numberOfDice}d${e.dieSize} ${e.symbol} ${e.bonus}'))),
                        Semantics(
                          label: 'Delete Roll Button',
                          child: IconButton(
                            icon: const Icon(Icons.delete),
                            tooltip: 'Delete',
                            onPressed: () {
                              _deleteRoll(e);

                              Navigator.of(context).pop();
                              _savedRollsDialog();
                            },
                          ),
                        )
                      ]))
                  .toList(),
            ),
          ),
          actions: <Widget>[
            Semantics(
              label: 'Cancel Button',
              child: TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _setDieSize(String dieInfo) {
    String advantageDisadvantage = '';
    int dieSize = 0;

    if (dieInfo.length == 3) {
      if (dieInfo == '100') {
        dieSize = 100;
      } else {
        if (dieInfo.endsWith('A')) {
          dieSize = 20;
          advantageDisadvantage = 'A';
        } else {
          dieSize = 20;
          advantageDisadvantage = 'D';
        }
        if (numberOfDiceController.text != '1') {
          numberOfDiceController.text = '1';
        }
      }
    } else {
      dieSize = int.parse(dieInfo);
    }
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      currentDie = dieSize;
      extra = advantageDisadvantage;
    });
  }

  void _setSymbol(String newSymbol) {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      symbol = newSymbol;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
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
                      decoration: InputDecoration(
                        border: const UnderlineInputBorder(),
                        enabled: extra.isEmpty,
                      ),
                      enableInteractiveSelection: extra.isEmpty,
                    ),
                  ),
                  DieDropDown(
                    notifyParent: _setDieSize,
                  ),
                  SizedBox(
                      width: 30,
                      height: 30,
                      child: Semantics(
                        label: 'Plus Minus button, currently $symbol',
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
                            )),
                      )),
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
                  Semantics(
                    label: 'Roll Button',
                    child: OutlinedButton(
                        onPressed: () {
                          SavedRoll roll = SavedRoll(
                              '',
                              int.parse(numberOfDiceController.text),
                              currentDie,
                              symbol,
                              int.parse(bonusController.text),
                              extra: extra);
                          rollD20(roll, widget.addToHistory);
                        },
                        child: const Text('Roll')),
                  ),
                  Semantics(
                    label: 'Save Roll Button',
                    child: OutlinedButton(
                        onPressed: _saveDialog, child: const Text('Save')),
                  ),
                ],
              ),
            )),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Semantics(
            label: 'Show Saved Rolls Button',
            child: OutlinedButton(
                onPressed: savedRolls.isEmpty ? null : _savedRollsDialog,
                child: const Text('Show Saved Rolls')),
          ),
          Semantics(
            label: 'Clear History Button',
            child: OutlinedButton(
                onPressed: widget.clearHistory,
                child: const Text('Clear History')),
          ),
        ])
      ],
    );
  }
}

List<String> dieList = ['20', '4', '6', '8', '10', '12', '100', '20A', '20D'];

class DieDropDown extends StatefulWidget {
  final Function(String value) notifyParent;
  const DieDropDown({Key? key, required this.notifyParent}) : super(key: key);

  @override
  State<DieDropDown> createState() => _DieDropDownState();
}

class _DieDropDownState extends State<DieDropDown> {
  String dropdownValue = dieList.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      elevation: 16,
      style: TextStyle(color: Theme.of(context).colorScheme.primary),
      underline: Container(
        height: 2,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      onChanged: (String? value) {
        if (value == null) return;
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value;
        });
        widget.notifyParent(value);
      },
      items: dieList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text('D$value'),
        );
      }).toList(),
    );
  }
}
