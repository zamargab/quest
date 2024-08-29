import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'timer_event.dart';
import 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  Timer? _timer;
  static const platform = MethodChannel('com.quest.screenshot');

  TimerBloc() : super(TimerState.initial()) {
    on<StartTimer>(_onStartTimer);
    on<Tick>(_onTick);
    on<ScreenshotCaptured>(_onScreenshotCaptured);
    on<PictureCaptured>(_onPictureCaptured);
  }

  void _onStartTimer(StartTimer event, Emitter<TimerState> emit) async {
    _timer?.cancel();
    emit(state.copyWith(seconds: 0, isRunning: true));

    // Start the timer
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      add(Tick(state.seconds + 1));
    });

    // Capture the screenshot and picture
    await captureScreenshot();
    await capturePicture();
  }

  void _onTick(Tick event, Emitter<TimerState> emit) {
    emit(state.copyWith(seconds: event.seconds, isRunning: true));
  }

  void _onScreenshotCaptured(
      ScreenshotCaptured event, Emitter<TimerState> emit) {
    emit(state.copyWith(screenshotPath: event.imagePath));
  }

  void _onPictureCaptured(PictureCaptured event, Emitter<TimerState> emit) {
    emit(state.copyWith(picturePath: event.imagePath));
  }

  Future<void> captureScreenshot() async {
    try {
      final String imagePath = await platform.invokeMethod('captureScreenshot');
      add(ScreenshotCaptured(imagePath));
    } on PlatformException catch (e) {
      print('Failed to capture screenshot: ${e.message}');
    }
  }

  Future<void> capturePicture() async {
    try {
      final String imagePath = await platform.invokeMethod('capturePicture');
      add(PictureCaptured(imagePath));
    } on PlatformException catch (e) {
      print('Failed to capture picture: ${e.message}');
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
