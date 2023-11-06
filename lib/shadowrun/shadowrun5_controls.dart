import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roller/shadowrun/shadowrun_roller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../saved_roll.dart';

class Shadowrun5Roller extends StatefulWidget {
  const Shadowrun5Roller({super.key, required this.addToHistory});
  final Function(Wrap, String) addToHistory;

  @override
  State<Shadowrun5Roller> createState() => _Shadowrun5RollerState();
}

// ignore: camel_case_types
class _Shadowrun5RollerState extends State<Shadowrun5Roller>
    with TickerProviderStateMixin {
  final List<Row> history = [];
  List<SavedRoll> savedRolls = [];

  List<int> priorRoll = [];
  final numberOfDiceController = TextEditingController(text: '12');

  void _loadSavedRolls() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String json = prefs.getString('sr5Rolls') ?? '[]';
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
      prefs.setString('sr5Rolls', jsonEncode(newList));
    });
  }

  void _deleteRoll(SavedRoll roll) async {
    final prefs = await SharedPreferences.getInstance();
    int index = savedRolls.indexOf(roll);

    savedRolls.removeAt(index);
    setState(() {
      savedRolls = savedRolls;
      prefs.setString('sr5Rolls', jsonEncode(savedRolls));
    });
  }

  List<int> _roll(SavedRoll roll, {List<int>? priorRoll}) {
    return rollShadowrun5(
        roll,
        widget.addToHistory,
        AnimationController(
            vsync: this, duration: const Duration(milliseconds: 1250))
          ..forward(),
        priorRoll: priorRoll);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    numberOfDiceController.dispose();
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
              label: 'Save Roll Button',
              child: TextButton(
                child: const Text('Save'),
                onPressed: () {
                  if (nameController.text.isEmpty) return;
                  SavedRoll roll = SavedRoll(nameController.text,
                      int.parse(numberOfDiceController.text), 6, '', 0,
                      extra: '');
                  _addSavedRoll(roll);
                  priorRoll = _roll(roll);
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
                                  priorRoll = _roll(e);
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                    '${e.description}: ${e.numberOfDice}'))),
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
                            border: UnderlineInputBorder(),
                          ))),
                  Semantics(
                    label: 'Roll Button',
                    child: OutlinedButton(
                        onPressed: () {
                          SavedRoll roll = SavedRoll('',
                              int.parse(numberOfDiceController.text), 6, '', 0,
                              extra: '');
                          priorRoll = _roll(roll);
                        },
                        child: const Text('Roll')),
                  ),
                  Semantics(
                    label: 'Pre Edge Roll Button',
                    child: OutlinedButton(
                        onPressed: () {
                          SavedRoll roll = SavedRoll('',
                              int.parse(numberOfDiceController.text), 6, '', 0,
                              extra: '<');
                          priorRoll = _roll(roll);
                        },
                        child: const Text('Pre')),
                  ),
                  Semantics(
                    label: 'Post Edge Roll Button',
                    child: OutlinedButton(
                      onPressed: priorRoll.isEmpty ||
                              priorRoll
                                          .where((element) => element == 1)
                                          .length /
                                      priorRoll.length >
                                  .5
                          ? null
                          : () {
                              SavedRoll roll = SavedRoll(
                                  '',
                                  int.parse(numberOfDiceController.text),
                                  6,
                                  '',
                                  0,
                                  extra: '');
                              priorRoll = _roll(roll, priorRoll: priorRoll);
                            },
                      child: const Text('Post'),
                    ),
                  ),
                  Semantics(
                    label: 'Save Button',
                    child: OutlinedButton(
                        onPressed: _saveDialog, child: const Text('Save')),
                  ),
                ],
              ),
            )),
        Semantics(
          label: 'Show Saved Rolls Button',
          child: OutlinedButton(
              onPressed: savedRolls.isEmpty ? null : _savedRollsDialog,
              child: const Text('Show Saved Rolls')),
        ),
      ],
    );
  }
}
