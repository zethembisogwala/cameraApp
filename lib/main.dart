import 'dart:async';
import 'package:cameraApp/app/app.dart';
import 'package:cameraApp/bloc/nav/nav_bloc.dart';
import 'package:cameraApp/bloc/share/share_bloc.dart';
import 'file:///C:/Users/zethe/Documents/personal/cameraApp/lib/app/home.dart';
import 'package:flutter_better_camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/camera_view.dart';

class CameraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NavBloc>(
          create: (context) => NavBloc(),
        ),
        BlocProvider<ShareBloc>(
          create: (context) => ShareBloc(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          accentTextTheme: TextTheme(body2: TextStyle(color: Colors.white)),
        ),
        home: App(),
      ),
    );
  }
}

List<CameraDescription> cameras = [];

Future<void> main() async {
  // Fetch the available cameras before initializing the app.
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    throw e;
  }
  runApp(CameraApp());
}

//Zoomer this will be a seprate widget
