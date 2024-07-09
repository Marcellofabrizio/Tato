import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tato/components/animated_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Just Another Pomodoro Timer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

String formatDuration(int milliseconds) {
  int totalSeconds = milliseconds ~/ 1000;

  int minutes = totalSeconds ~/ 60;
  int seconds = totalSeconds % 60;

  String minutesStr = minutes.toString().padLeft(2, '0');
  String secondsStr = seconds.toString().padLeft(2, '0');

  return '$minutesStr:$secondsStr';
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isButtonToggled = false;
  String buttonText = "START";
  final GlobalKey<AnimatedButtonState> _mainButtonKey =
      GlobalKey<AnimatedButtonState>();

  final _pomodoroDurations = [15000, 300000, 900000];
  int duration = 15000;
  int pomodoroStep = 0;

  late Isolate timerIsolate;

  final _pomodoroIdx = 0;
  final _shortBreakIdx = 1;
  final _longBreakIdx = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 186, 73, 73),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(40.0),
                // decoration:
                //     BoxDecoration(border: Border.all(color: Colors.blueAccent)),
                color: const Color.fromARGB(50, 255, 255, 255),
                child: Column(children: <Widget>[
                  Center(
                    child: Row(
                      children: [
                        Expanded(
                            child: AnimatedButton(
                                width: 105,
                                height: 50,
                                color: Colors.white,
                                onPressed: () async {},
                                enabled: true,
                                shadowDegree: ShadowDegree.light,
                                onToggle: (toggled) async {},
                                child: const Text(
                                  'POMODORO',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color.fromARGB(255, 186, 73, 73),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ))),
                        Expanded(
                          child: AnimatedButton(
                              width: 105,
                              height: 50,
                              color: Colors.white,
                              onPressed: () async {},
                              enabled: true,
                              shadowDegree: ShadowDegree.light,
                              onToggle: (toggled) async {},
                              child: const Text(
                                'SHORT BREAK',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color.fromARGB(255, 186, 73, 73),
                                  fontWeight: FontWeight.w500,
                                ),
                              )),
                        ),
                        Expanded(
                          child: AnimatedButton(
                              width: 105,
                              height: 50,
                              color: Colors.white,
                              onPressed: () async {},
                              enabled: true,
                              shadowDegree: ShadowDegree.light,
                              onToggle: (toggled) async {},
                              child: const Text(
                                'LONG BREAK',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color.fromARGB(255, 186, 73, 73),
                                  fontWeight: FontWeight.w500,
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatDuration(duration),
                    style: const TextStyle(fontSize: 70.0),
                  ),
                  AnimatedButton(
                      key: _mainButtonKey,
                      color: Colors.white,
                      onPressed: () async {},
                      enabled: true,
                      shadowDegree: ShadowDegree.light,
                      onToggle: (toggled) async {
                        updateButtonState(toggled);
                        if (toggled) {
                          await startTimer();
                        } else {
                          log('Terminating Isolate');
                          timerIsolate.kill();
                        }
                      },
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Color.fromARGB(255, 186, 73, 73),
                          fontWeight: FontWeight.w500,
                        ),
                      )),
                ]))
          ],
        ),
      ),
    );
  }

  Future<void> startTimer() async {
    log('Initiating Isolate');

    final ReceivePort receivePort = ReceivePort();
    timerIsolate =
        await Isolate.spawn(isolateMain, [receivePort.sendPort, duration]);

    final sendPort = await receivePort.first as SendPort;
    final answerPort = ReceivePort();

    sendPort.send(answerPort.sendPort);

    answerPort.listen((message) {
      if (message != 0) {
        setState(() {
          duration = message;
        });
      } else {
        pomodoroStep++;
        pomodoroStep = pomodoroStep % 3; // round robin
        duration = _pomodoroDurations[pomodoroStep];
        _mainButtonKey.currentState?.untoggleButton();
      }
    });
  }

  void updateButtonState(bool toggled) {
    _isButtonToggled = toggled;
    _isButtonToggled ? buttonText = "PAUSE" : buttonText = "START";

    setState(() {
      buttonText;
    });
  }
}

void isolateMain(List<dynamic> args) async {
  final SendPort sendPort = args[0] as SendPort;
  int duration = args[1] as int;

  final ReceivePort port = ReceivePort();
  sendPort.send(port.sendPort);

  await for (var message in port) {
    final SendPort replyPort = message as SendPort;

    while (duration > 0) {
      duration--;
      replyPort.send(duration);
      log(duration.toString());
      if (duration % 1000 == 0) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    replyPort.send(duration);

    if (duration == 0) {
      Isolate.exit();
    }
  }
}
