part of 'share_bloc.dart';

@immutable
abstract class ShareState {}

class ShareInitial extends ShareState {}

class ShareStartedState extends ShareState {
}

class PictureTakenState extends ShareState {
  final String imagePath;

  PictureTakenState(this.imagePath);

}
