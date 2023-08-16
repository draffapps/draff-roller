import 'dart:math';

import 'package:flutter/material.dart';
import 'package:roller/roll_utils.dart';

import '../saved_roll.dart';

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
