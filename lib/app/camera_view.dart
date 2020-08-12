import 'dart:io';

import 'package:cameraApp/bloc/share/share_bloc.dart';
import 'package:cameraApp/zoomable_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_better_camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../main.dart';

class CameraView extends StatefulWidget {
  @override
  _CameraViewState createState() {
    return _CameraViewState();
  }
}

class _CameraViewState extends State<CameraView>
    with WidgetsBindingObserver {
  CameraController controller;
  String imagePath;
  String videoPath;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  bool enableAudio = true;
  FlashMode flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    onNewCameraSelected(cameras[0]);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: enableAudio,
    );

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        debugPrint('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        onNewCameraSelected(controller.description);
      }
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Center(
                  child: ZoomableWidget(
                      child: _cameraPreviewWidget(),
                      onTapUp: (scaledPoint) {
                        //controller.setPointOfInterest(scaledPoint);
                      },
                      onZoom: (zoom) {
                        print('zoom');
                        if (zoom < 11) {
                          controller.zoom(zoom);
                        }
                      })),
            ),
          ),
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    bool _flashOn = false;
    bool _frontCam = false;

    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: GestureDetector(
                  onTap: () => toggleAutoFocus,
                  child: CameraPreview(controller)),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 60,
            child: IconButton(
              icon: Icon(
                Icons.camera,
                color: Colors.white,
                size: 80,
              ),
              onPressed: ()=> onTakePictureButtonPressed(context),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 65,
            child: IconButton(
              icon: Icon(
                _flashOn ? Icons.flash_off : Icons.flash_on,
                color: Colors.white,
                size: 25,
              ),
              onPressed: () =>
                  setState(() => _flashOn = _flashOn ? false : true),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 65,
            child: IconButton(
              icon: Icon(
                _frontCam ? Icons.camera_rear : Icons.camera_front,
                color: Colors.white,
                size: 25,
              ),
              onPressed: () => null,
            ),
          ),
        ],
      );
    }
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void onTakePictureButtonPressed(BuildContext context) {

    print('pressed');

    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
          videoController?.dispose();
          videoController = null;

        });
        if (filePath != null) {
          context.bloc<ShareBloc>().add(PictureTakenEvent(context, filePath));

          print('Picture saved to $filePath');

        }
      }
    });
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((String filePath) {
      if (mounted) setState(() {});
      if (filePath != null) debugPrint('Saving video to $filePath');
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((_) {
      if (mounted) setState(() {});
      debugPrint('Video recorded to: $videoPath');
    });
  }

  void onPauseButtonPressed() {
    pauseVideoRecording().then((_) {
      if (mounted) setState(() {});
      debugPrint('Video recording paused');
    });
  }

  void onResumeButtonPressed() {
    resumeVideoRecording().then((_) {
      if (mounted) setState(() {});
      debugPrint('Video recording resumed');
    });
  }

  void toggleAutoFocus() {
    controller.setAutoFocus(!controller.value.autoFocusEnabled);
    debugPrint('Toogle auto focus');
  }

  Future<String> startVideoRecording() async {
    if (!controller.value.isInitialized) {
      debugPrint('Error: select a camera first.');
      return null;
    }

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';

    if (controller.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      videoPath = filePath;
      await controller.startVideoRecording(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  Future<void> stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    await _startVideoPlayer();
  }

  Future<void> pauseVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> _startVideoPlayer() async {
    final VideoPlayerController vcontroller =
    VideoPlayerController.file(File(videoPath));
    videoPlayerListener = () {
      if (videoController != null && videoController.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
        videoController.removeListener(videoPlayerListener);
      }
    };
    vcontroller.addListener(videoPlayerListener);
    await vcontroller.setLooping(true);
    await vcontroller.initialize();
    await videoController?.dispose();
    if (mounted) {
      setState(() {
        imagePath = null;
        videoController = vcontroller;
      });
    }
    await vcontroller.play();
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      debugPrint('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    return filePath;
  }

  void _showCameraException(CameraException e) {
    debugPrint('Error: ${e.code}\n${e.description}');
  }
}
