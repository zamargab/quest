class TimerState {
  final int seconds;
  final bool isRunning;
  final String? screenshotPath;
  final String? picturePath;

  TimerState({
    required this.seconds,
    required this.isRunning,
    this.screenshotPath,
    this.picturePath,
  });

  TimerState.initial()
      : seconds = 0,
        isRunning = false,
        screenshotPath = null,
        picturePath = null;

  TimerState copyWith({
    int? seconds,
    bool? isRunning,
    String? screenshotPath,
    String? picturePath,
  }) {
    return TimerState(
      seconds: seconds ?? this.seconds,
      isRunning: isRunning ?? this.isRunning,
      screenshotPath: screenshotPath ?? this.screenshotPath,
      picturePath: picturePath ?? this.picturePath,
    );
  }
}
