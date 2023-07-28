import 'dart:math';

import 'package:flutter/material.dart';

int getDie(int size, {int reRollLessThan = 0}) {
  var roll = Random().nextInt(size) + 1;
  return roll > reRollLessThan
      ? roll
      : getDie(size, reRollLessThan: reRollLessThan);
}

void rollIt(int numberOfDice, int dieSize, String symbol, int bonus,
    Function addToHistory,
    {String? description}) {
  List<Widget> entry = [];
  if (description != null) {
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
  for (int walker = 0; walker < numberOfDice; walker++) {
    int dieRoll = getDie(dieSize);
    if (walker > 0) rollInfo += ' + ';
    rollInfo += '$dieRoll ';
    sum += dieRoll;
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
