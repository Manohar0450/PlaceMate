
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
class LoadingScreen extends StatelessWidget {
  final String message;
  const LoadingScreen({super.key, this.message = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    // Using WillPopScope to prevent user from going back during loading
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/lottie/loading.json',
                  width: 140,
                  repeat: true,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900 // Matching your bold theme
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}