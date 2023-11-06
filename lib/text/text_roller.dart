import 'package:flutter/material.dart';
import 'package:dart_dice_parser/dart_dice_parser.dart';

import '../saved_roll.dart';

void rollText(SavedRoll roll, Function addToHistory) {
  var SavedRoll(:description, :extra) = roll;
  List<Widget> entry = [];
  String rollSpeech = '';
  if (description != '') {
    entry.add(Text(
      description,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ));
    entry.add(const SizedBox(width: 5));
    rollSpeech = description;
  }
  bool showMetadata = extra.endsWith('/m');

  extra = extra.replaceFirst(RegExp(r'/m$'), '');

  final roller = DiceExpression.create(extra);

  RollResult result = roller.roll();

  entry.add(Text('$extra='));
  String rollResult = result.total.toString();
  entry.add(Text(rollResult));

  String metadata = '';

  if (showMetadata) {
    for (MapEntry<String, Object> item in result.metadata.entries) {
      metadata += ' ${item.key}';
      if (item.value.runtimeType == List<int>) {
        List<int> values = item.value as List<int>;
        for (int value in values) {
          metadata += ' $value';
        }
      } else {
        metadata += ' metadata not expected type';
      }
    }

    entry.add(Text(metadata));
  }

  rollSpeech += '$extra=$rollResult $metadata';

  if (showMetadata) {}

  addToHistory(
      Wrap(
        alignment: WrapAlignment.center,
        children: entry,
      ),
      rollSpeech);
}
