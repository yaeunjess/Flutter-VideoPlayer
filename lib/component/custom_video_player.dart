import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vid_player/component/custom_icon_button.dart';
import 'package:flutter_vid_player/component/custom_time_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

// StatefulWidget은 매개변수의 값이 변경될때 폐기되고, 새로 생성된다.
// StatefulWidget 클래스 에서의 createState() 메소드 : State 객체가 생성됨
// State<T> 클래스 에서의 initState() 메소드 : State 객체가 처음 생성될 때 한 번 호출됨
// State<T> 클래스 에서의 build() 메소드 : 위젯의 UI를 생성함, 상태가 변경될 때마다 호출됨
// State<T> 클래스 에서의 setState() 메소드 : 상태를 변경하고, UI를 다시 빌드하게 build()를 실행해줌
// State<T> 클래스 에서의 didUpdateWidget() 메소드 : 부모 위젯이 새 인스턴스로 교체될 때 호출됨 (주로 위젯의 매개변수가 변경되었을때 호출됨)
// State<T> 클래스 에서의 deactivate() 메소드 : 위젯이 위젯트리에서 제거되기 직전에 호출됨, 정리 작업을 진행함
// State<T> 클래스 에서의 dispose() 메소드 : 위젯이 위젯트리에서 제거될때 호출됨, 리소스를 해제함

class CustomVideoPlayer extends StatefulWidget {
  final XFile video;
  final GestureTapCallback onNewVideoPressed;

  const CustomVideoPlayer({
    required this.video,
    required this.onNewVideoPressed,
    super.key,
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  bool showControls = false;
  VideoPlayerController? videoController;

  // State 객체가 처음 생성될때(즉 StatefulWidget 클래스에서 createState()가 호출될때) 한 번 호출된다.
  @override
  void initState() {
    super.initState();

    initializeController();
  }

  void initializeController() async{
    // 1. VideoPlayerController.file() 생성자를 이용해, controller 생성하기
    // + State<T>에서 T의 멤버 변수에 접근하고 싶으면, widget.(멤버 변수명)을 사용하면 된다.
    final videoController = VideoPlayerController.file(
      File(widget.video.path),
    );

    // 2. initialize() 함수를 실행해서 동영상을 재생할 수 있는 상태로 준비하기
    await videoController.initialize();

    videoController.addListener(videoControllerListener); // controller 속성이 바뀔때마다 실행할 함수 등록

    // 3. 생성한 conroller를 videoContorller 변수에 저장하기
    setState(() {
      this.videoController = videoController;
    });
  }

  void videoControllerListener(){
    setState(() {});
  }

  // StatefulWidget(위젯)이 새 인스턴스로 교체될때(주로 매개변수가 변경될때) 호출된다.
  @override
  void didUpdateWidget(covariant CustomVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // StatefulWidget의 매개변수인 video(매개변수)가 변경되면서 State 객체의 didUpdateWidget() 메소드 -> build() 메소드가 호출되는데,
    // 이때 initializeController()를 호출하여 변경된 widget.video.path를 VideoPlayerController 매개변수에 넣어줌으로써 VideoPlayerController를 재생성한다.
    if(oldWidget.video.path != widget.video.path){
      initializeController();
    }
  }

  // StatefulWidget(위젯)이 위젯트리에서 제거될때 호출된다.
  @override
  void dispose() {
    // listener를 제거하는 이유
    // 1. 메모리 누수 방지
    // controller가 State 객체 외부에서 참조되고 있는 경우에 listener를 제거해주지 않으면,
    // 해당 listener는 계속 존재하게 되고 그리하여 메모리 누수가 발생할 수 있다.
    // 2. 불필요한 작업 방지
    // controller가 State 객체의 수명과 일치하지 않거나 오래 살아남는 경우,
    // 불필요한 작업이 계속해서 발생할 수 있다.
    videoController?.removeListener(videoControllerListener);

    super.dispose();
  }

  // State 객체가 처음 생성된 후 초기 빌드, setState()가 호출 후, 부모 위젯의 변경, 종속성 변경 시 호출된다.
  @override
  Widget build(BuildContext context) {
    if (videoController == null){
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return GestureDetector(
      onTap: (){
        setState(() {
          showControls = !showControls;
        });
      },
      child: AspectRatio(
        aspectRatio: videoController!.value.aspectRatio,
        child: Stack(
          children: [
            VideoPlayer(
              videoController!,
            ),

            if(showControls)
              Container(
                color: Colors.black.withOpacity(0.5),
              ),

            if(showControls)
              Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    CustomTimeText(
                      duration: videoController!.value.position,
                    ),
                    Expanded(
                      child: Slider(
                        onChanged: (double val){
                          videoController!.seekTo(
                            Duration(seconds: val.toInt()),
                          );
                        },
                        value: videoController!.value.position.inSeconds.toDouble(),
                        min: 0,
                        max: videoController!.value.duration.inSeconds.toDouble(),
                      ),
                    ),
                    CustomTimeText(
                      duration: videoController!.value.duration,
                    ),
                  ],
                )
              )
            ),

            if(showControls)
              Align(
                alignment: Alignment.topRight,
                child: CustomIconButton(
                  onPressed: widget.onNewVideoPressed,
                  iconData: Icons.photo_camera_back,
                ),
              ),

            if(showControls)
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomIconButton(onPressed: onReversePressed, iconData: Icons.rotate_left),
                    CustomIconButton(onPressed: onPlayPressed, iconData: videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,),
                    CustomIconButton(onPressed: onForwardPressed, iconData: Icons.rotate_right),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void onReversePressed(){
    final currentPosition = videoController!.value.position; // 현재 실행 중인 위치

    Duration position = Duration(); // 0초로 실행 위치 초기화 (-> 현재 실행 중인 위치가 3초보다 짧을때 postion을 0으로 위치시키기 위함)

    if(currentPosition.inSeconds > 3){ // 현재 실행 중인 위치가 3초보다 길때만 3초 빼기
      position = currentPosition - Duration(seconds: 3);
    }

    videoController!.seekTo(position);
  }

  void onForwardPressed(){
    final maxPosition = videoController!.value.duration; // 동영상 길이
    final currentPosition = videoController!.value.position;

    Duration position = maxPosition; // 동영상 길이로 실행 위치 초기화

    // 동영상 길이에서 3초를 뺀 값보다 현재 위치가 짧을때만 3초 더하기
    if((maxPosition - Duration(seconds: 3)).inSeconds > currentPosition.inSeconds){
      position = currentPosition + Duration(seconds: 3);
    }

    videoController!.seekTo(position);
  }

  void onPlayPressed(){
    if(videoController!.value.isPlaying){
      videoController!.pause();
    }
    else{
      videoController!.play();
    }
  }
}
