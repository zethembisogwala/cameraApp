import 'package:cameraApp/bloc/nav/nav_bloc.dart';
import 'package:cameraApp/bloc/share/share_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_share/social_share.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {



    return BlocBuilder<ShareBloc, ShareState>(
      builder: (_, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RaisedButton(
                onPressed: () => context.bloc<ShareBloc>().add(StartShareEvent(context)),
                child: Text('Open camera'),
              ),
              state is PictureTakenState ?
              RaisedButton(
                onPressed: () => SocialShare.shareOptions('', imagePath: state.imagePath),
                child: Text('Share on WhatsApp'),
              ) : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
