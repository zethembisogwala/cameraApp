import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cameraApp/bloc/nav/nav_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_share/social_share.dart';

part 'share_event.dart';
part 'share_state.dart';

class ShareBloc extends Bloc<ShareEvent, ShareState> {
  ShareBloc() : super(ShareInitial());

  @override
  Stream<ShareState> mapEventToState(
    ShareEvent event,
  ) async* {
    if(event is StartShareEvent) {
      event.eventContext.bloc<NavBloc>().add(CameraEvent());
      yield ShareStartedState();
    }
    else if(event is PictureTakenEvent) {
      event.eventContext.bloc<NavBloc>().add(HomeEvent());
      yield PictureTakenState(event.imagePath);
    }
  }
}
