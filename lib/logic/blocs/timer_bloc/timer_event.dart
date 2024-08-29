abstract class TimerEvent {}

class StartTimer extends TimerEvent {}

class Tick extends TimerEvent {
  final int seconds;
  Tick(this.seconds);
}

class ScreenshotCaptured extends TimerEvent {
  final String imagePath;

  ScreenshotCaptured(this.imagePath);
}

class PictureCaptured extends TimerEvent {
  final String imagePath;

  PictureCaptured(this.imagePath);
}
