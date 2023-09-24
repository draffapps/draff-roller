import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:roller/text/text_roller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../saved_roll.dart';

class TextController extends StatefulWidget {
  const TextController({super.key, required this.addToHistory});
  final Function(Wrap, String) addToHistory;

  @override
  State<TextController> createState() => _TextControllerState();
}

// ignore: camel_case_types
class _TextControllerState extends State<TextController> {
  final List<Row> history = [];
  List<SavedRoll> savedRolls = [];
  final textController = TextEditingController(text: '');

  void _loadSavedRolls() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String json = prefs.getString('textRolls') ?? '[]';
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
      prefs.setString('textRolls', jsonEncode(newList));
    });
  }

  void _deleteRoll(SavedRoll roll) async {
    final prefs = await SharedPreferences.getInstance();
    int index = savedRolls.indexOf(roll);

    savedRolls.removeAt(index);
    setState(() {
      savedRolls = savedRolls;
      prefs.setString('textRolls', jsonEncode(savedRolls));
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textController.dispose();
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
                SavedRoll roll = SavedRoll(nameController.text, 0, 0, '', 0,
                    extra: textController.text);
                _addSavedRoll(roll);
                rollText(roll, widget.addToHistory);
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
                                  rollText(e, widget.addToHistory);
                                  Navigator.of(context).pop();
                                },
                                child: Text('${e.description}: ${e.extra}'))),
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
                  Expanded(
                    child: TextField(
                      textAlign: TextAlign.left,
                      controller: textController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                  OutlinedButton(
                      onPressed: () {
                        SavedRoll roll = SavedRoll('', 0, 0, '', 0,
                            extra: textController.text);
                        rollText(roll, widget.addToHistory);
                      },
                      child: const Text('Roll')),
                  OutlinedButton(
                      onPressed: _saveDialog, child: const Text('Save')),
                ],
              ),
            )),
        OutlinedButton(
            onPressed: savedRolls.isEmpty ? null : _savedRollsDialog,
            child: const Text('Show Saved Rolls')),
      ],
    );
  }
}
