import 'dart:math';

import 'package:flutter/material.dart';
import 'package:roller/custom_icons.dart';
import 'package:roller/saved_roll.dart';

int getDie(int size, {int reRollLessThan = 0}) {
  var roll = Random().nextInt(size) + 1;
  return roll > reRollLessThan
      ? roll
      : getDie(size, reRollLessThan: reRollLessThan);
}

void rollD20(SavedRoll roll, Function addToHistory) {
  var SavedRoll(
    :numberOfDice,
    :dieSize,
    :symbol,
    :bonus,
    :description,
    :extra
  ) = roll;
  List<Widget> entry = [];
  if (description != '') {
    entry.add(Text(
      description,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ));
    entry.add(const SizedBox(width: 5));
  }
  entry.add(Text(
    '${numberOfDice}d$dieSize $symbol $bonus ',
    style: const TextStyle(fontStyle: FontStyle.italic),
  ));

  String rollInfo = ': ';
  int sum = bonus;
  if (symbol == '-') sum *= -1;
  if (extra != 'A' && extra != 'D') {
    for (int walker = 0; walker < numberOfDice; walker++) {
      int dieRoll = getDie(dieSize);
      if (walker > 0) rollInfo += ' + ';
      rollInfo += '$dieRoll ';
      sum += dieRoll;
    }
  } else {
    int dieRoll = getDie(dieSize);
    int dieRoll2 = getDie(dieSize);

    int keep = extra == 'A' ? max(dieRoll, dieRoll2) : min(dieRoll, dieRoll2);
    sum += keep;
    int discard = dieRoll2 + dieRoll - keep;
    entry.add(const Text('('));
    entry.add(Text('$dieRoll',
        style: TextStyle(
            decoration: dieRoll == keep
                ? TextDecoration.none
                : TextDecoration.lineThrough)));

    entry.add(const Text(' '));

    entry.add(Text('$dieRoll2',
        style: TextStyle(
            decoration: dieRoll2 == discard
                ? TextDecoration.lineThrough
                : TextDecoration.none)));

    entry.add(const Text(')'));
  }

  rollInfo += '$symbol $bonus = ';

  entry.add(Text(rollInfo));
  entry.add(Text(sum.toString(),
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      )));

  addToHistory(Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: entry,
  ));
}

final diceIcons = {
  2: CustomIcons.dice_two,
  3: CustomIcons.dice_three,
  4: CustomIcons.dice_four,
  5: CustomIcons.dice_five,
  6: CustomIcons.dice_six
};

List<int> rollShadowrun5(SavedRoll roll, Function addToHistory,
    {List<int>? priorRoll}) {
  var SavedRoll(:numberOfDice, :description, :extra) = roll;

  List<int> rollInfo = [];
  List<Widget> entry = [];

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
  }

  if (priorRoll.isNotEmpty) {
    numberOfDice = priorRoll.length;
    priorRoll = priorRoll.where((element) => element >= 5).toList();

    for (var element in priorRoll) {
      entry.add(Icon(
        diceIcons[element],
        color: Colors.blue,
      ));
    }
    numberOfDice -= priorRoll.length;
  }
  int hits = priorRoll.length;
  int ones = 0;

  for (var walker = 0; walker < numberOfDice; walker++) {
    int current = getDie(6);
    rollInfo.add(current);
    if (current == 1) {
      entry.add(const Icon(
        CustomIcons.dice_one,
        color: Colors.orange,
      ));
      ones++;
    } else if (current >= 5) {
      entry.add(Icon(
        diceIcons[current],
        color: Colors.blue,
      ));
      hits++;
      if (extra == '<') {
        while (current == 6) {
          current = getDie(6);
          entry.add(const Text(
            ' ',
          ));
          rollInfo.add(current);
          if (current == 1) {
            entry.add(const Icon(
              CustomIcons.dice_one,
              color: Colors.orange,
            ));
            ones++;
          } else if (current >= 5) {
            entry.add(Icon(
              diceIcons[current],
              color: Colors.blue,
            ));
            hits++;
          } else {
            entry.add(Icon(diceIcons[current]));
          }
        }
      }
    } else {
      entry.add(Icon(diceIcons[current]));
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
    }
    entry.add(const Text(
      ' GLITCH',
      style: TextStyle(color: Colors.lightGreenAccent),
    ));
  }

  addToHistory(Wrap(
    alignment: WrapAlignment.center,
    children: entry,
  ));

  return priorRoll.isEmpty && extra.isEmpty ? rollInfo : [];
}
