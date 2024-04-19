import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraView extends StatefulWidget {
  final CameraDescription camera;

  const CameraView({
    Key? key,
    required this.camera,
  }) : super(key: key);

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture = Future.value();

  @override
  void initState() {
    super.initState();
    _requestCameraPermission().then((_) {
      if (mounted) { // Check whether the widget is still in the widget tree
        setState(() {
          _initializeControllerFuture = _initializeCamera();
        });
      }
    });
  }

Future<void> _requestCameraPermission() async {
  print('Requesting camera permission');
  final status = await Permission.camera.request();
  print('Camera permission status: $status');
  if (status.isDenied) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Camera Permission'),
          content: Text('This app needs camera access to function properly.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

  Future<void> _initializeCamera() {
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    return _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Check if the controller is initialized before returning CameraPreview
          if (!_controller.value.isInitialized) {
            return Center(child: CircularProgressIndicator());
          }
          return CameraPreview(_controller);
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}