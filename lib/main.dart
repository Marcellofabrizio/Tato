import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  int duration = 5000;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 186, 73, 73),
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
                margin: const EdgeInsets.all(20.0),
                padding: const EdgeInsets.all(40.0),
                // decoration:
                //     BoxDecoration(border: Border.all(color: Colors.blueAccent)),
                color: const Color.fromARGB(50, 255, 255, 255),
                child: Column(children: <Widget>[
                  Center(
                    child: Row(
                      children: [Container(margin: const EdgeInsets.all(5.0), padding: const EdgeInsets.all(5.0), color: const Color.fromARGB(50, 0, 255, 0), child: Text('Pomodoro')), Container(margin: const EdgeInsets.all(5.0), padding: const EdgeInsets.all(5.0), color: const Color.fromARGB(50, 0, 255, 0), child: Text('Pausa Curta')), Container(margin: const EdgeInsets.all(5.0), padding: const EdgeInsets.all(5.0), color: const Color.fromARGB(50, 0, 255, 0), child: Text('Pausa Longa'))],
                    ),
                  ),
                  Text(
                    formatDuration(duration),
                    style: TextStyle(fontSize: 70.0),
                  ),
                  AnimatedButton(
                      color: Colors.white,
                      onPressed: () async {},
                      enabled: true,
                      shadowDegree: ShadowDegree.light,
                      onToggle: (toggled) async {
                        _isButtonToggled = toggled;
                        _isButtonToggled ? buttonText = "PAUSE" : buttonText = "START";
                        setState(() {
                          buttonText;
                        });
                        final ReceivePort receivePort = ReceivePort();
                        await Isolate.spawn(isolateMain, [receivePort.sendPort, duration]);

                        final sendPort = await receivePort.first as SendPort;
                        final answerPort = ReceivePort();

                        sendPort.send(answerPort.sendPort);

                        answerPort.listen((message) {
                          setState(() {
                            duration = message;
                          });
                        });
                        log("click");
                      },
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Color.fromARGB(255, 186, 73, 73),
                          fontWeight: FontWeight.w500,
                        ),
                      )),
                  // Text(
                  //   '$_counter',
                  //   style: Theme.of(context).textTheme.headlineMedium,
                  // ),
                ]))
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
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
  }
}
