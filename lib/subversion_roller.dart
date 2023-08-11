import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roller/roll_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'saved_roll.dart';

const reliableRolls = ['Reli', '2', '3', '4', '5', '6'];
const dullRolls = ['Dull', '5', '4', '3', '2', '1'];

class ReliableDropDown extends StatefulWidget {
  final Function(String value) notifyParent;
  const ReliableDropDown({Key? key, required this.notifyParent})
      : super(key: key);

  @override
  State<ReliableDropDown> createState() => _ReliableDropDownState();
}

class _ReliableDropDownState extends State<ReliableDropDown> {
  String dropdownValue = reliableRolls.first;

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
      items: reliableRolls.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

class DullDropDown extends StatefulWidget {
  final Function(String value) notifyParent;
  const DullDropDown({Key? key, required this.notifyParent}) : super(key: key);

  @override
  State<DullDropDown> createState() => _DullDropDownState();
}

class _DullDropDownState extends State<DullDropDown> {
  String dropdownValue = dullRolls.first;

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
      items: dullRolls.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

class SubversionRoller extends StatefulWidget {
  const SubversionRoller({super.key, required this.addToHistory});
  final Function(Wrap) addToHistory;

  @override
  State<SubversionRoller> createState() => _SubversionRollerState();
}

// ignore: camel_case_types
class _SubversionRollerState extends State<SubversionRoller> {
  final List<Row> history = [];
  List<SavedRoll> savedRolls = [];
  String symbol = 'Reli';
  String extra = 'Dull';

  List<int> priorRoll = [];
  final numberOfDiceController = TextEditingController(text: '3');
  final bonusController = TextEditingController(text: '0');

  void _loadSavedRolls() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String json = prefs.getString('subversionRolls') ?? '[]';
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
      prefs.setString('subversionRolls', jsonEncode(newList));
    });
  }

  void _deleteRoll(SavedRoll roll) async {
    final prefs = await SharedPreferences.getInstance();
    int index = savedRolls.indexOf(roll);

    savedRolls.removeAt(index);
    setState(() {
      savedRolls = savedRolls;
      prefs.setString('subversionRolls', jsonEncode(savedRolls));
    });
  }

  void _setReliable(String reliable) {
    setState(() {
      symbol = reliable;
    });
  }

  void _setDull(String dull) {
    setState(() {
      extra = dull;
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
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (nameController.text.isEmpty) return;
                SavedRoll roll = SavedRoll(
                    nameController.text,
                    int.parse(numberOfDiceController.text),
                    6,
                    symbol == 'Reli' ? '' : symbol,
                    int.parse(bonusController.text),
                    extra: extra == 'Dull' ? '' : extra);
                _addSavedRoll(roll);
                rollSubversion(roll, widget.addToHistory);
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
          barrierDismissible: true,
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
                                  rollSubversion(e, widget.addToHistory);
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                    '${e.description}: ${e.numberOfDice}d6+${e.bonus}${e.symbol != '' ? ' Reli: ${e.symbol}' : ''}${e.extra != '' ? ' Dull: ${e.extra}' : ''}'))),
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
                          decoration: const InputDecoration(
                              isDense: true,
                              border: UnderlineInputBorder(),
                              hintText: 'Dice'))),
                  const Text('d6+'),
                  SizedBox(
                      width: 50,
                      child: TextField(
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.bottom,
                          controller: bonusController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ], // Only numbers can be entered
                          decoration: const InputDecoration(
                              isDense: true,
                              border: UnderlineInputBorder(),
                              hintText: 'Bonus'))),
                  ReliableDropDown(
                    notifyParent: _setReliable,
                  ),
                  DullDropDown(
                    notifyParent: _setDull,
                  ),
                  OutlinedButton(
                      onPressed: () {
                        SavedRoll roll = SavedRoll(
                            '',
                            int.parse(numberOfDiceController.text),
                            6,
                            symbol == 'Reli' ? '' : symbol,
                            int.parse(bonusController.text),
                            extra: extra == 'Dull' ? '' : extra);
                        rollSubversion(roll, widget.addToHistory);
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
    );
  }
}
