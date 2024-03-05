import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:lubios/snap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // gud code, dw bbg
  cameras = await availableCameras();

  runApp(const LubiosApp());
}

class LubiosApp extends StatelessWidget {
  const LubiosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      home: const SnapPage(),
    );
  }
}
