import 'dart:math';

import 'package:roller/custom_icons.dart';

int getDie(int size, {int reRollLessThan = 0}) {
  var roll = Random().nextInt(size) + 1;
  return roll > reRollLessThan
      ? roll
      : getDie(size, reRollLessThan: reRollLessThan);
}

final diceIcons = {
  1: CustomIcons.dice_one,
  2: CustomIcons.dice_two,
  3: CustomIcons.dice_three,
  4: CustomIcons.dice_four,
  5: CustomIcons.dice_five,
  6: CustomIcons.dice_six
};
