import 'package:flutter/material.dart';
import 'package:roller/roll_utils.dart';
import 'package:roller/saved_roll.dart';

void rollSubversion(
    SavedRoll roll, Function addToHistory, AnimationController animcontroller) {
  Animation<double> animation = Tween<double>(begin: 1.5, end: 1)
      .animate(CurvedAnimation(parent: animcontroller, curve: Curves.bounceIn));
  var SavedRoll(:numberOfDice, :symbol, :description, :bonus, :extra) = roll;
  List<Widget> entry = [];
  List<int> rollInfo = [];
  List<int> modifiedRolls = [];
  int sum = bonus;
  int sixes = 0;
  int reliable = symbol.isEmpty ? 1 : int.parse(symbol);
  int dull = extra.isEmpty ? 6 : int.parse(extra);

  if (description != '') {
    entry.add(Text(
      description,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ));
    entry.add(const SizedBox(width: 5));
  }

  for (var walker = 0; walker < numberOfDice; walker++) {
    int current = getDie(6);
    rollInfo.add(current);

    if (dull < current) {
      current = dull;
    }

    if (reliable > current) {
      current = reliable;
    }

    modifiedRolls.add(current);
  }

  List<int> keptRolls = List.from(modifiedRolls);
  keptRolls.sort();
  keptRolls = keptRolls.sublist(keptRolls.length - 3);

  for (var dieWalker = 0; dieWalker < modifiedRolls.length; dieWalker++) {
    int dieRoll = modifiedRolls[dieWalker];
    int originalRoll = rollInfo[dieWalker];
    if (keptRolls.contains(dieRoll)) {
      if (dieRoll == 6) {
        sixes++;
      }
      sum += dieRoll;
      keptRolls.remove(dieRoll);
      if (dieRoll != originalRoll) {
        entry.add(Badge(
            backgroundColor:
                originalRoll < dieRoll ? Colors.green : Colors.orange,
            label: Text('${dieRoll - originalRoll}'),
            child: Icon(diceIcons[dieRoll], color: Colors.blue)));
      } else {
        if (dieRoll != 6) {
          entry.add(Icon(diceIcons[dieRoll], color: Colors.blue));
        } else {
          entry.add(ScaleTransition(
              scale: animation,
              child: Icon(diceIcons[dieRoll], color: Colors.blue)));
        }
      }
    } else {
      if (dieRoll != originalRoll) {
        entry.add(Badge(
            backgroundColor:
                originalRoll < dieRoll ? Colors.green : Colors.orange,
            label: Text('${dieRoll - originalRoll}'),
            child: Icon(diceIcons[dieRoll])));
      } else {
        if (dieRoll != 6) {
          entry.add(Icon(diceIcons[dieRoll]));
        } else {
          entry.add(ScaleTransition(
              scale: animation, child: Icon(diceIcons[dieRoll])));
        }
      }
    }
  }

  entry.add(Text('+ $bonus = $sum'));

  if (sixes == 3) {
    entry.add(const Text(' '));
    entry.add(ScaleTransition(
        scale: animation,
        child: Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              color: Colors.pinkAccent),
          child: const Text(
            'CRITICAL SUCCESS',
            style: TextStyle(
              color: Colors.lightGreenAccent,
            ),
          ),
        )));
  }

  addToHistory(Wrap(alignment: WrapAlignment.center, children: entry));
}
