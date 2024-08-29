import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quest/logic/blocs/timer_bloc/timer_bloc.dart';
import 'package:quest/logic/blocs/timer_bloc/timer_event.dart';
import 'package:quest/logic/blocs/timer_bloc/timer_state.dart';
import 'package:quest/logic/blocs/timer_bloc/timer_event.dart';
import 'package:quest/logic/blocs/timer_bloc/timer_state.dart';
import 'package:quest/utils/message.dart';

import 'dart:io';

import 'package:toastification/toastification.dart';

const platform = MethodChannel('com.quest.screenshot');

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  Future<void> captureScreenshot() async {
    try {
      await platform.invokeMethod('captureScreenshot');
    } on PlatformException catch (e) {
      if (mounted) {
        MessageHelper().displayMessage(
          context,
          'Failed to capture screenshot: ${e.message}',
        );
      }
    }
  }

  Future<void> capturePicture(TimerBloc bloc) async {
    try {
      final String? filePath = await platform.invokeMethod('capturePicture');
      if (!mounted) return; // Check if the widget is still in the widget tree

      if (filePath != null) {
        bloc.add(PictureCaptured(filePath));
      }
    } on PlatformException catch (e) {
      if (mounted) {
        MessageHelper()
            .displayMessage(context, 'Failed to capture picture: ${e.message}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer and Camera App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            BlocBuilder<TimerBloc, TimerState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Timer: ${state.seconds} seconds',
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 20),
                    if (state.screenshotPath != null)
                      Image.file(
                        File(state.screenshotPath!),
                        height: 100,
                      ),
                    if (state.picturePath != null)
                      Image.file(File(state.picturePath!)),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  context.read<TimerBloc>().add(StartTimer());
                  capturePicture(context.read<TimerBloc>());
                  captureScreenshot();
                },
                child: const Text('Start Timer & Capture Screenshot'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
