import 'package:cameraApp/app/camera_view.dart';
import 'package:cameraApp/app/home.dart';
import 'package:cameraApp/bloc/nav/nav_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavBloc, NavState>(
      builder: (_, state) {
        if(state is HomeState) {
          return HomePage();
        }
        else if (state is CameraViewState){
          return CameraView();
        }
        else {
          return Scaffold(body: Container());
        }
      },
    );
  }
}
