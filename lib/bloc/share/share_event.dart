part of 'share_bloc.dart';

@immutable
abstract class ShareEvent {
  final BuildContext eventContext;

  ShareEvent(this.eventContext);
}

class StartShareEvent extends ShareEvent {
  StartShareEvent(BuildContext eventContext) : super(eventContext);
  
}

class PictureTakenEvent extends ShareEvent {
  final String imagePath;

  PictureTakenEvent(BuildContext context, this.imagePath) : super(context);
}
