import 'package:flutter/material.dart';
import 'package:roller/custom_icons.dart';
import 'package:roller/d20/d20_controller.dart';
import 'package:roller/shadowrun/shadowrun5_controls.dart';
import 'package:roller/subversion/subversion_controller.dart';
import 'package:roller/text/text_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'odd roller',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const oddRoller(title: 'Just keep on rollin baby'),
    );
  }
}

// ignore: camel_case_types
class oddRoller extends StatefulWidget {
  const oddRoller({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<oddRoller> createState() => _oddRollerState();
}

// ignore: camel_case_types
class _oddRollerState extends State<oddRoller> {
  final List<Widget> history = [];
  int currentRoller = 0;

  @override
  void initState() {
    super.initState();
    _getLastRoller();
  }

  void _getLastRoller() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      currentRoller = prefs.getInt('lastRoller') ?? 0;
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  void _addToHistory(Widget entry) {
    setState(() {
      history.add(entry);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget rollWidget;

    switch (currentRoller) {
      case 1:
        rollWidget = Shadowrun5Roller(addToHistory: _addToHistory);
        break;
      case 2:
        rollWidget = SubversionRoller(addToHistory: _addToHistory);
        break;
      case 3:
        rollWidget = TextController(addToHistory: _addToHistory);
        break;
      default:
        rollWidget = D20Roller(addToHistory: _addToHistory);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 5,
              child: ListView(
                  reverse: true,
                  children: history.reversed.map((e) => e).toList()),
            ),
            const SizedBox(height: 5),
            rollWidget,
            SafeArea(
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(CustomIcons.dice_d20),
                    label: 'D20',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.keyboard_alt),
                    label: 'Shadowrun',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CustomIcons.horse_head),
                    label: 'Subversion',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.text_fields),
                    label: 'Text',
                  ),
                ],
                currentIndex: currentRoller,
                onTap: (value) async {
                  setState(() {
                    currentRoller = value;
                  });
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setInt('lastRoller', currentRoller);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
