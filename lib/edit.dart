import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class EditPage extends StatelessWidget {
  final XFile file;

  const EditPage(this.file, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit the Picture"),
      ),
      body: const Text("heresut textin"),
    );
  }
}
