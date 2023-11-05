import 'package:flutter/material.dart';
import 'package:roller/custom_icons.dart';
import 'package:roller/roll_utils.dart';
import 'package:roller/saved_roll.dart';

List<int> rollShadowrun5(
    SavedRoll roll, Function addToHistory, AnimationController animcontroller,
    {List<int>? priorRoll}) {
  var SavedRoll(:numberOfDice, :description, :extra) = roll;
  Animation<double> sizeAnimation = Tween<double>(begin: 1.5, end: 1)
      .animate(CurvedAnimation(parent: animcontroller, curve: Curves.bounceIn));

  List<int> rollInfo = [];
  List<Widget> entry = [];
  String rollSpeech = '';

  priorRoll = priorRoll ?? [];

  if (priorRoll.isNotEmpty) {
    description = "Post Edged";
  } else if (extra == '<') {
    description = "Pre-Edged";
  }

  if (description != '') {
    entry.add(Text(
      description,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ));
    entry.add(const SizedBox(width: 5));

    rollSpeech += '$description ';
  }

  if (priorRoll.isNotEmpty) {
    numberOfDice = priorRoll.length;
    priorRoll = priorRoll.where((element) => element >= 5).toList();

    for (var element in priorRoll) {
      entry.add(Icon(
        diceIcons[element],
        color: Colors.blue,
      ));

      rollSpeech += '$element ';
    }
    numberOfDice -= priorRoll.length;
  }
  int hits = priorRoll.length;
  int ones = 0;

  for (var walker = 0; walker < numberOfDice; walker++) {
    int current = getDie(6);
    rollInfo.add(current);
    addDieToRoll(current, entry, sizeAnimation);

    rollSpeech += '$current ';

    if (current == 1) {
      ones++;
    } else if (current >= 5) {
      hits++;
      if (extra == '<') {
        while (current == 6) {
          current = getDie(6);
          entry.add(const Text(
            ' ',
          ));
          rollInfo.add(current);
          addDieToRoll(current, entry, sizeAnimation);
          rollSpeech += 'explodes $current ';
          if (current == 1) {
            ones++;
          } else if (current >= 5) {
            hits++;
          }
        }
      }
    }
    entry.add(const Text(
      ' ',
    ));
  }

  entry.add(Text(
    ' = $hits',
  ));

  if (rollInfo.length * .5 < ones && priorRoll.isEmpty) {
    if (hits == 0) {
      entry.add(const Text(
        ' CRITICAL',
        style: TextStyle(color: Colors.pink),
      ));

      rollSpeech += ' CRITICAL';
    }
    entry.add(const Text(
      ' GLITCH',
      style: TextStyle(color: Colors.lightGreenAccent),
    ));

    rollSpeech += ' GLITCH';
  }

  rollSpeech += ' = $hits hits and $ones ones';

  addToHistory(
      Wrap(
        alignment: WrapAlignment.center,
        children: entry,
      ),
      rollSpeech);

  return priorRoll.isEmpty && extra.isEmpty ? rollInfo : [];
}

void addDieToRoll(int roll, List<Widget> entry, Animation<double> animation) {
  if (roll >= 5) {
    entry.add(ScaleTransition(
        scale: animation, child: Icon(diceIcons[roll], color: Colors.blue)));
  } else if (roll == 1) {
    entry.add(const Icon(
      CustomIcons.dice_one,
      color: Colors.orange,
    ));
  } else {
    entry.add(Icon(
      diceIcons[roll],
    ));
  }
}
