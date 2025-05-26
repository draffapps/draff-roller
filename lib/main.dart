import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:roller/custom_icons.dart';
import 'package:roller/d20/d20_controller.dart';
import 'package:roller/shadowrun/shadowrun5_controls.dart';
import 'package:roller/subversion/subversion_controller.dart';
import 'package:roller/text/text_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'draff roller',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const draffRoller(title: 'Just keep on rollin baby'),
    );
  }
}

// ignore: camel_case_types
class draffRoller extends StatefulWidget {
  const draffRoller({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<draffRoller> createState() => _draffRollerState();
}

enum TtsState { playing, stopped, paused, continued }

// ignore: camel_case_types
class _draffRollerState extends State<draffRoller> {
  late FlutterTts flutterTts;
  final List<Widget> history = [];
  int currentRoller = 0;
  TtsState ttsState = TtsState.stopped;

  bool muted = true;
  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isWeb => kIsWeb;

  @override
  void initState() {
    super.initState();
    _getLastRoller();
    _getMuted();
    initTts();
  }

  initTts() {
    flutterTts = FlutterTts();

    _setAwaitOptions();

    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setPauseHandler(() {
      setState(() {
        print("Paused");
        ttsState = TtsState.paused;
      });
    });

    flutterTts.setContinueHandler(() {
      setState(() {
        print("Continued");
        ttsState = TtsState.continued;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future<dynamic> _getLanguages() async => await flutterTts.getLanguages;

  Future<dynamic> _getEngines() async => await flutterTts.getEngines;

  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }

  Future _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }

  void _getLastRoller() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      currentRoller = prefs.getInt('lastRoller') ?? 0;
    });
  }

  void _getMuted() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      muted = prefs.getBool('muted') ?? true;
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
    flutterTts.stop();
  }

  void _addToHistory(Widget entry, String rollSpeech) async {
    setState(() {
      history.add(entry);
    });
    if (rollSpeech.isNotEmpty && !muted) {
      await flutterTts.setVolume(.5);
      await flutterTts.setSpeechRate(.75);
      await flutterTts.setPitch(.5);
      print('playing');

      flutterTts.speak(rollSpeech);
    }
  }

  void _clearHistory() async {
    setState(() {
      history.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget rollWidget;

    switch (currentRoller) {
      case 1:
        rollWidget = Shadowrun5Roller(
            addToHistory: _addToHistory, clearHistory: _clearHistory);
        break;
      case 2:
        rollWidget = SubversionRoller(
            addToHistory: _addToHistory, clearHistory: _clearHistory);
        break;
      case 3:
        rollWidget = TextController(
            addToHistory: _addToHistory, clearHistory: _clearHistory);
        break;
      default:
        rollWidget =
            D20Roller(addToHistory: _addToHistory, clearHistory: _clearHistory);
    }

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Toggle mute, currently: ${muted ? 'muted' : 'unmuted'}',
        onPressed: () async {
          bool newState = !muted;
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('muted', newState);
          setState(() {
            muted = newState;
          });
        },
        child:
            muted ? const Icon(Icons.volume_off) : const Icon(Icons.volume_up),
      ),
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
                    icon: Icon(CustomIcons.fug),
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
