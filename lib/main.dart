import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
  runApp(const CameraApp());
}

class CameraApp extends StatefulWidget {
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> with WidgetsBindingObserver {
  late CameraController controller;
  int cameraIdx = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  void _initCamera() {
    controller = CameraController(_cameras[cameraIdx], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            break;
          default:
            break;
        }
      }
    });
  }

  void _nextCamera() {
    cameraIdx++;
    cameraIdx %= _cameras.length;
    controller.dispose();
    _initCamera();
  }

  @override
  void dispose() {
    controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }

    return MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Lubios"),
        ),
        floatingActionButton: FloatingActionButton(onPressed: () {
          setState(() {});
        }),
        body: Column(
          children: [
            Expanded(
              child: FocusScope(
                autofocus: true,
                child: Focus(
                  autofocus: true,
                  canRequestFocus: true,
                  onFocusChange: (value) {
                    print('focus -> $value');
                  },
                  onKeyEvent: (node, event) {
                    print('key: ${event.physicalKey}');

                    if (event.logicalKey == LogicalKeyboardKey.audioVolumeUp) {
                      print('YAY!');
                      return KeyEventResult.handled;
                    }

                    return KeyEventResult.handled;
                  },
                  child: Builder(
                    builder: (context) {
                      final FocusNode focusNode = Focus.of(context);
                      final hasFocus = focusNode.hasFocus;

                      return GestureDetector(
                        onTap: () {
                          if (hasFocus) {
                            focusNode.unfocus();
                          } else {
                            focusNode.requestFocus();
                          }
                        },
                        onPanEnd: (details) {
                          if (details.velocity.pixelsPerSecond.dy.abs() > 130) {
                            _nextCamera();
                          }
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                          child: CameraPreview(controller),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Text("hello, world!"),
          ],
        ),
      ),
    );
  }
}
