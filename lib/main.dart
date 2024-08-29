import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:quest/logic/blocs/timer_bloc/timer_bloc.dart';
import 'package:quest/logic/blocs/timer_bloc/timer_event.dart';
import 'package:quest/logic/blocs/timer_bloc/timer_state.dart';
import 'package:quest/presentation/timer/pages/timer_page.dart';
import 'package:quest/utils/message.dart';

import 'dart:io';

import 'package:toastification/toastification.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timer and Camera App',
      home: BlocProvider(
        create: (context) => TimerBloc(),
        child: const TimerPage(),
      ),
    );
  }
}
