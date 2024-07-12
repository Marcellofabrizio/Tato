import 'dart:async';
import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tato/components/animated_button.dart';
import 'package:tato/config/app_stylers.dart';
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

enum Step { pomodoro, shortBreak, longBreak }

Step currentStep = Step.pomodoro;

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();
  }


  int pomodoroStepCounter = 0;

  bool _isButtonToggled = false;
  String buttonText = "START";

  Color backgroundColor = AppStyles.primaryColor;

  final GlobalKey<AnimatedButtonState> _mainButtonKey = GlobalKey<AnimatedButtonState>();
  final GlobalKey<AnimatedButtonState> _pomodoroButtonKey = GlobalKey<AnimatedButtonState>();
  final GlobalKey<AnimatedButtonState> _shortBreakButtonKey = GlobalKey<AnimatedButtonState>();
  final GlobalKey<AnimatedButtonState> _longBreakButtonKey = GlobalKey<AnimatedButtonState>();

  int duration = 1500000;
  final _pomodoroDuration = 10000; //1500000;
  final _shortBreakDuration = 300000;
  final _longBreakDuration = 900000;

  final _timerSteps = [Step.pomodoro, Step.shortBreak, Step.pomodoro, Step.shortBreak, Step.pomodoro, Step.shortBreak, Step.pomodoro, Step.longBreak];

  late Isolate timerIsolate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F6EE),
        title: Text(widget.title),
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(15.0),
                  padding: const EdgeInsets.only(top: 40, bottom: 40),
                  // decoration:
                  //     BoxDecoration(border: Border.all(color: Colors.blueAccent)),
                  color: const Color.fromARGB(50, 255, 255, 255),
                  child: Column(children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IntrinsicWidth(
                          child: AnimatedButton(
                              key: _pomodoroButtonKey,
                              // width: 105,
                              height: 50,
                              color: Colors.white,
                              onPressed: () async {},
                              enabled: true,
                              tapToggleEnabled: false,
                              initiallyToggled: true,
                              shadowDegree: ShadowDegree.light,
                              onToggle: (toggled) {
                                if (toggled) {
                                  handlePomodoroStepToggle();
                                }
                              },
                              child: Text(
                                'POMODORO',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: backgroundColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              )),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        AnimatedButton(
                          key: _shortBreakButtonKey,
                          // width: 105,
                          height: 50,
                          color: Colors.white,
                          onPressed: () async {},
                          enabled: true,
                          tapToggleEnabled: false,
                          shadowDegree: ShadowDegree.light,
                          onToggle: (toggled) {
                            if (toggled) {
                              handleShortBreakButtonToggle();
                            }
                          },
                          child: Text(
                            'SHORT BREAK',
                            style: TextStyle(
                              fontSize: 10,
                              color: backgroundColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        AnimatedButton(
                          key: _longBreakButtonKey,
                          // width: 105,
                          height: 50,
                          color: Colors.white,
                          onPressed: () async {},
                          enabled: true,
                          tapToggleEnabled: false,
                          shadowDegree: ShadowDegree.light,
                          onToggle: (toggled) {
                            if (toggled) {
                              handleLongBreakButtonToggle();
                            }
                          },
                          child: Text(
                            'LONG BREAK',
                            style: TextStyle(
                              fontSize: 10,
                              color: backgroundColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
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
                            await handleMainButtonToggle();
                          } else {
                            timerIsolate.kill();
                          }
                        },
                        child: Text(
                          buttonText,
                          style: TextStyle(
                            fontSize: 22,
                            color: backgroundColor,
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                  ]))
            ],
          ),
        ),
      ),
    );
  }

  void handleLongBreakButtonToggle() {
    stopTimer();

    _shortBreakButtonKey.currentState!.untoggleButton();
    _pomodoroButtonKey.currentState!.untoggleButton();
    duration = _longBreakDuration;
    backgroundColor = AppStyles.breakColor;
    currentStep = Step.longBreak;
    setState(() {
      duration;
    });
  }

  void handleShortBreakButtonToggle() {
    stopTimer();
    _pomodoroButtonKey.currentState!.untoggleButton();
    _longBreakButtonKey.currentState!.untoggleButton();
    duration = _shortBreakDuration;
    backgroundColor = AppStyles.breakColor;
    currentStep = Step.shortBreak;
    setState(() {
      duration;
    });
  }

  void handlePomodoroStepToggle() {
    stopTimer();
    _shortBreakButtonKey.currentState!.untoggleButton();
    _longBreakButtonKey.currentState!.untoggleButton();
    duration = _pomodoroDuration;
    backgroundColor = AppStyles.primaryColor;
    currentStep = Step.pomodoro;
    setState(() {
      duration;
    });
  }

  void stopTimer() {
    if (_isButtonToggled) {
      _mainButtonKey.currentState?.untoggleButton();
      timerIsolate.kill();
    }
    updateButtonState(false);
  }

  Future<void> handleMainButtonToggle() async {
    log('Initiating Isolate');

    final ReceivePort receivePort = ReceivePort();
    timerIsolate = await Isolate.spawn(isolateMain, [receivePort.sendPort, duration]);

    final sendPort = await receivePort.first as SendPort;
    final answerPort = ReceivePort();

    sendPort.send(answerPort.sendPort);

    answerPort.listen((message) {
      if (message != 0) {
        setState(() {
          duration = message;
        });
      } else {
        pomodoroStepCounter++;
        pomodoroStepCounter = pomodoroStepCounter % _timerSteps.length; // round robin
        currentStep = _timerSteps[pomodoroStepCounter];

        switch (currentStep) {
          case Step.pomodoro:
            _pomodoroButtonKey.currentState!.toggleButton();
            handlePomodoroStepToggle();
            break;
          case Step.shortBreak:
            _shortBreakButtonKey.currentState!.toggleButton();
            handleShortBreakButtonToggle();
            break;
          case Step.longBreak:
            _longBreakButtonKey.currentState!.toggleButton();
            handleLongBreakButtonToggle();
            break;
        }

        _mainButtonKey.currentState?.untoggleButton();
        handleNotification();
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

void handleNotification() {
  switch (currentStep) {
    case Step.pomodoro:
      NotificationService().showNotification(title: 'Hora de Foco', body: 'É hora de focar nas suas tarefas!');
      break;
    case Step.shortBreak:
      NotificationService().showNotification(title: 'Hora de Uma Pausa', body: 'É hora de parar e fazer uma pausa!');
      break;
    case Step.longBreak:
      NotificationService().showNotification(title: 'Hora de Uma Pausa Longa', body: 'É hora de parar e fazer uma pausa longa!');
      break;
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
