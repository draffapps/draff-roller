import 'package:flutter/material.dart';
import 'package:dart_dice_parser/dart_dice_parser.dart';

import '../saved_roll.dart';

void rollText(SavedRoll roll, Function addToHistory) {
  var SavedRoll(:description, :extra) = roll;
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

  final roller = DiceExpression.create(extra);

  RollResult result = roller.roll();

  entry.add(Text('$extra='));
  entry.add(Text(result.total.toString()));

  addToHistory(Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: entry,
  ));
}
