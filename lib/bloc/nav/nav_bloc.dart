import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'nav_event.dart';
part 'nav_state.dart';

class NavBloc extends Bloc<NavEvent, NavState> {
  NavBloc() : super(HomeState());


  @override
  Stream<NavState> mapEventToState(
    NavEvent event,
  ) async* {
    if(event is CameraEvent) {
      yield CameraViewState();
    }
    else if(event is HomeEvent) {
      yield HomeState();
    }
  }
}
