import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras = [];

void main() {
  runApp(const CameraApp());
}

class CameraApp extends StatelessWidget {
  const CameraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CameraHomePage(),
    );
  }
}

class CameraHomePage extends StatefulWidget {
  const CameraHomePage({Key? key}) : super(key: key);

  @override
  _CameraHomePageState createState() => _CameraHomePageState();
}

class _CameraHomePageState extends State<CameraHomePage> {
  late CameraController _controller;
  bool _isCameraOn = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  void initCamera() async {
    try {
      cameras = await availableCameras();
      _controller = CameraController(cameras[0], ResolutionPreset.high);
      await _controller.initialize();
      _controller.startImageStream((image) {
        // Handle the image stream here if needed
      });
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleCameraStream() {
    if (_isCameraOn) {
      if (_controller.value.isStreamingImages) {
        _controller.stopImageStream();
        setState(() {
          _isCameraOn = false;
        });
      }
    } else {
      if (_controller.value.isInitialized) {
        _controller.startImageStream((image) {
          // Handle the image stream here if needed
        }).catchError((error) {
          print('Error starting image stream: $error');
        });
        setState(() {
          _isCameraOn = true;
        });
      } else {
        print('Camera controller is not initialized.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera App'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: _isCameraOn && _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: CameraPreview(_controller),
                    )
                  : Container(), // Empty container when the camera is off
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FloatingActionButton(
                onPressed: toggleCameraStream,
                child: Icon(_isCameraOn ? Icons.camera_alt : Icons.camera),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
