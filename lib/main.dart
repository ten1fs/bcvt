import 'package:ffmpeg_kit_flutter_full_gpl/log.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/session.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/statistics.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BiliBili缓存视频转MP4',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'BiliBili缓存视频转MP4'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var videoPath = '';
  var videoName = '';
  var audioPath = '';
  var audioName = '';


  merge() async {
    var dir = await getExternalStorageDirectory();
    var output = '${dir?.path}/output_${DateTime.now().microsecondsSinceEpoch.toString()}.mp4';
    debugPrint('videoPath: $videoPath');
    debugPrint('audioPath: $audioPath');
    debugPrint('outputPath: $output');
    // ffmpeg -i video.m4s -i audio.m4s -c:v copy -c:a aac -strict experimental output.mp4
    FFmpegKit.executeAsync('-i $videoPath -i $audioPath -c:v copy -c:a aac -strict experimental $output', (Session session) async {
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        // Success
        Fluttertoast.showToast(msg: 'Success, MP4文件保存在:$output');
      } else if (ReturnCode.isCancel(returnCode)) {
        // Cancel
        Fluttertoast.showToast(msg: '任务被取消！');
      } else {
        // Error
        Fluttertoast.showToast(msg: '执行出错！');
      }
    }, (Log log) {
      debugPrint(log.getMessage());
    }, (Statistics statistics) {
      // CALLED WHEN SESSION GENERATES STATISTICS
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [TextButton(onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles();
                if (result != null) {
                  PlatformFile file = result.files.first;
                  setState(() {
                    videoPath = file.path!;
                    videoName = file.name;
                  });
                }
              }, child: const Text('点击选择视频文件')), Text(videoName)],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [TextButton(onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles();
                if (result != null) {
                  PlatformFile file = result.files.first;
                  setState(() {
                    audioPath = file.path!;
                    audioName = file.name;
                  });
                }
              }, child: const Text('点击选择音频文件')), Text(audioName)],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [TextButton(onPressed: () {
                if (videoPath == '' || audioPath == '') {
                  Fluttertoast.showToast(msg: '音视频文件不能为空！');
                } else {
                  merge();
                }
              }, child: const Text('合并'))],
            )
          ],
        ),
      ),
    );
  }
}
