import 'dart:async';
import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tato/components/animated_button.dart';
import 'package:tato/services/notification_service.dart';

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
  final GlobalKey<AnimatedButtonState> _pomodoroButtonKey =
      GlobalKey<AnimatedButtonState>();
  final GlobalKey<AnimatedButtonState> _shortBreakButtonKey =
      GlobalKey<AnimatedButtonState>();
  final GlobalKey<AnimatedButtonState> _longBreakButtonKey =
      GlobalKey<AnimatedButtonState>();

  final _pomodoroDuration = 1500000;
  final _shortBreakDuration = 300000;
  final _longBreakDuration = 900000;

  final _pomodoroDurations = [
    15000,
    300000,
    15000,
    300000,
    15000,
    300000,
    15000,
    900000
  ];
  int duration = 5000;
  int pomodoroStep = 0;

  late Isolate timerIsolate;

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
                                key: _pomodoroButtonKey,
                                width: 105,
                                height: 50,
                                color: Colors.white,
                                onPressed: () async {},
                                enabled: true,
                                shadowDegree: ShadowDegree.light,
                                onToggle: (toggled) {
                                  if (toggled) {
                                    handlePomodoroStepToggle();
                                  }
                                },
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
                              key: _shortBreakButtonKey,
                              width: 105,
                              height: 50,
                              color: Colors.white,
                              onPressed: () async {},
                              enabled: true,
                              shadowDegree: ShadowDegree.light,
                              onToggle: (toggled) {
                                if (toggled) {
                                  handleShortBreakButtonToggle();
                                }
                              },
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
                              key: _longBreakButtonKey,
                              width: 105,
                              height: 50,
                              color: Colors.white,
                              onPressed: () async {},
                              enabled: true,
                              shadowDegree: ShadowDegree.light,
                              onToggle: (toggled) {
                                if (toggled) {
                                  handleLongBreakButtonToggle();
                                }
                              },
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
                          timerIsolate.kill();
                          handleNotification();
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

  void handleLongBreakButtonToggle() {
    stopTimer();
    
    _shortBreakButtonKey.currentState!
        .untoggleButton();
    _pomodoroButtonKey.currentState!
        .untoggleButton();
    duration = _longBreakDuration;
    pomodoroStep = 2;
    setState(() {
      duration;
      pomodoroStep;
    });
  }

  void handleShortBreakButtonToggle() {
    stopTimer();
    _pomodoroButtonKey.currentState!
        .untoggleButton();
    _longBreakButtonKey.currentState!
        .untoggleButton();
    duration = _shortBreakDuration;
    pomodoroStep = 1;
    setState(() {
      duration;
      pomodoroStep;
    });
  }

  void handlePomodoroStepToggle() {
    stopTimer();
    _shortBreakButtonKey.currentState!
        .untoggleButton();
    _longBreakButtonKey.currentState!
        .untoggleButton();
    duration = _pomodoroDuration;
    pomodoroStep = 0;
    setState(() {
      duration;
      pomodoroStep;
    });
  }

  void stopTimer() {
    if (_isButtonToggled) {
      _mainButtonKey.currentState?.untoggleButton();
      timerIsolate.kill();
    }
    updateButtonState(false);
  }

  void handleNotification() {
    switch (pomodoroStep) {
      case 0:
        NotificationService().showNotification(
            title: 'Hora de Foco', body: 'É hora de focar nas suas tarefas!');
        break;
      case 1:
        NotificationService().showNotification(
            title: 'Hora de Uma Pausa',
            body: 'É hora de parar e fazer uma pausa!');
        break;
      case 2:
        NotificationService().showNotification(
            title: 'Hora de Uma Pausa Longa',
            body: 'É hora de parar e fazer uma pausa longa!');
        break;
    }
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
        pomodoroStep = pomodoroStep % _pomodoroDurations.length; // round robin
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
      _isButtonToggled;
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
