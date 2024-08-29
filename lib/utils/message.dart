import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class MessageHelper {
  displayMessage(BuildContext context, String message) {
    toastification.show(
      context: context, // optional if you use ToastificationWrapper
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 5),
    );
  }
}
