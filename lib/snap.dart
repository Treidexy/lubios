import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:lubios/edit.dart';

late List<CameraDescription> cameras;

class SnapPage extends StatefulWidget {
  const SnapPage({super.key});

  @override
  State<SnapPage> createState() => _SnapPageState();
}

class _SnapPageState extends State<SnapPage> with WidgetsBindingObserver {
  late CameraController cameraController;
  int cameraIdx = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (!cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  void _initCamera() {
    cameraController =
        CameraController(cameras[cameraIdx], ResolutionPreset.max);
    cameraController.initialize().then((_) {
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
    cameraIdx %= cameras.length;
    // cameraController.dispose();
    _initCamera();
  }

  @override
  void dispose() {
    cameraController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<XFile?> takePicture() async {
    if (!cameraController.value.isInitialized ||
        cameraController.value.isTakingPicture) {
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!cameraController.value.isInitialized) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Snap a Picture"),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              takePicture().then((file) {
                print('saved to ${file?.path}');
                if (file != null) {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => EditPage(file)));
                }
              });
            });
          },
          child: const Icon(Icons.camera_alt)),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onDoubleTap: () {},
              onPanEnd: (details) {
                if (details.velocity.pixelsPerSecond.dy.abs() > 130) {
                  _nextCamera();
                }
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
                child: CameraPreview(cameraController),
              ),
            ),
          ),
          Text("hello, world!"),
        ],
      ),
    );
  }
}
