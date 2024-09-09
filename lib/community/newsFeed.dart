import 'dart:async';
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import '../hooks/ApiService.dart';
import '../types/types.dart';

class NewsfeedPage extends StatefulWidget {
  const NewsfeedPage({
    super.key
  });
  @override
  State<NewsfeedPage> createState() => _NewsfeedPageState();
}


class _NewsfeedPageState extends State<NewsfeedPage> {
  @override
  void initState() {
    super.initState(); 
    checkFiles();
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final Dio _dio                            = Dio();
  List<String> images                       = [];
  List<String> videos                       = [];
  List<Map<String, dynamic>> downloadImages = [];
  List<Map<String, dynamic>> downloadVideos = [];
  int fileLength                            = 0;
  int downloaded                            = 1;
  bool downloading                          = false;
  String percent                            = '0';


  late VideoPlayerController _controller;
  Future<void>? _initializeVideoPlayerFuture;
  final ApiService apiService = ApiService();

  Map<String, int> numbers = {
    'duration'        : 1,
    'currentSecond'   : 0,
    'length'          : 0,
    'currentVideo'    : 0
  }; 

  void checkFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    Map<String, String> param = {
      'id'              : token!
    };

    var res = await apiService.postDataRequest('kiosk/get-photo', param);
    KioskContentList data = KioskContentList.fromJson(res);
    String baseUrl = dotenv.env['APP_URL']!;

    for (var photo in data.photos) {
      Map<String, dynamic> current = {
        "url"   : '$baseUrl/contents/image/slide/${photo['name']}',
        "name"  : photo['name'],
        "extn"  : photo['extn']
      };

      downloadImages.add(current);
    }

    for (var video in data.videos) {
      Map<String, dynamic> current = {
        "url"   : '$baseUrl/contents/video/${video['name']}',
        "name"  : video['name'],
        "extn"  : video['extn']
      };

      downloadVideos.add(current);
    }

    setState(() {
      numbers['length'] = data.videos.length;
    });

    downloadFiles();
  }

 Future<String> _getDownloadDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<void> _downloadFile(String url, String fileName, String type) async {
    try {
      String dir = await _getDownloadDirectory();
      String savePath = '$dir/$fileName';

      File file = File(savePath);
      bool fileExists = await file.exists();
      if (fileExists) {
        final exts = ['JPEG', 'JPG', 'PNG'];
        if (exts.contains(type.toUpperCase())) {
          setState(() {
            images.add(savePath);
          });
        } else {
          setState(() {
            videos.add(savePath);
          });
        }
        return;
      }

      await _dio.download(url, savePath, onReceiveProgress: (received, total) {
        if (total != -1) {
          setState(() {
            percent = (received / total * 100).toStringAsFixed(0);
          });
        }
      });

      final exts = ['JPEG', 'JPG', 'PNG'];
      if (exts.contains(type.toUpperCase())) {
        setState(() {
          images.add(savePath);
        });
      } else {
        setState(() {
          videos.add(savePath);
        });
      }
    } catch (e) {
      print('Error downloading file: $e');
    }
  }

  void downloadFiles() async {
    downloaded = 1;
    
    setState(() {
      fileLength = downloadImages.length + downloadVideos.length;
    });

    setState(() {
      downloading = true;
    });

    for (var file in downloadImages) {
      await _downloadFile(file['url'], file['name'], file['extn']);
      downloaded++;
    }

    for (var file in downloadVideos) {
      await _downloadFile(file['url'], file['name'], file['extn']);
      downloaded++;
    }

    setState(() {
      downloading = false;
    });

    if (videos.isNotEmpty) {
      initialVideo(videos[numbers['currentVideo']!]);
      // checkSecond();
    }
  }

  Future<bool> _clearPrevious() async {

    setState(() {
      _initializeVideoPlayerFuture = null;
    }); 

    await _controller.pause();
    await _controller.dispose();
    return true;
  }

  void initialVideo(String url) async {
    _controller = VideoPlayerController.file(File(url));

    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      _controller.play();
    });

    // _controller.setLooping(true);

    _controller.addListener(() {
      // if (_controller.value.position.inSeconds == _controller.value.duration.inSeconds) {
      //   _clearPrevious().then((_) {
      //     if(numbers['currentVideo']! < videos.length - 1) {
      //       setState(() {
      //         numbers['currentVideo'] = numbers['currentVideo']! + 1;
      //       });
      //     } else {
      //       setState(() {
      //         numbers['currentVideo'] = 0;
      //       });
      //     }

      //     print(numbers['currentVideo']);
      //     initialVideo(videos[numbers['currentVideo']!]);
      //   });
      // }
      // setState(() {
      //   numbers['currentSecond'] = _controller.value.position.inSeconds;
      //   numbers['duration'] = _controller.value.duration.inSeconds;
      // });
    });
  }

  void checkSecond() {
    Timer.periodic(const Duration(seconds: 3), (timer) {
      final c = DateTime.now();
      final time = DateTime(c.year, c.month, c.day, c.hour, c.minute);

      // if(time.isAfter(_poweroff!)) {
      //   timer.cancel();
      //   _controller.pause();
      //   _controller.dispose();
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context){
      //         return Sleep();
      //       },
      //     ),
      //   );
      // }

      print('====${numbers['currentSecond']}, ${numbers['duration']}');
      // setState(() {
      //   if(numbers['currentSecond'] == numbers['duration']) {
      //     if(numbers['currentVideo']! < videos.length - 1) {
      //       setState(() {
      //         numbers['currentVideo'] = numbers['currentVideo']! + 1;
      //       });
      //     } else {
      //       setState(() {
      //         numbers['currentVideo'] = 0;
      //       });
      //     }

      //     setState(() {
      //       numbers['currentSecond'] = 0;
      //       numbers['duration'] = 1;
      //     });

      //     _buildingVideo(videos[numbers['currentVideo']!]);
      //   }
      // });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (downloading) {
                  return const SizedBox.shrink();
                }

                if (snapshot.connectionState == ConnectionState.done) {
                  return AspectRatio(
                    aspectRatio: 1920/1080,
                    child: VideoPlayer(_controller),
                  );
                } else {
                  return Container(
                    alignment: Alignment.center,
                    width: size.width,
                    height: size.width/(1920/1080),
                    child: SizedBox(
                      width: size.width/20,
                      height: size.width/20,
                      child: const CircularProgressIndicator(),
                    ),
                  );
                }
              },
            ),
            Builder(builder: (context) {
              if (!downloading) {
                if (images.isEmpty) {
                    return const SizedBox.shrink();
                }

                return Expanded(
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: size.height - (size.width / (1920/1080)),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enableInfiniteScroll: true,
                      viewportFraction: 1,
                      padEnds: false,
                      autoPlay: true,
                      autoPlayInterval: const Duration(milliseconds: 10000)
                    ),
                    items: images.map<Widget>((item) => Container(
                      // margin: const EdgeInsets.only(right: 5),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(0)),
                        child: Image.file(File(item), fit: BoxFit.cover, width: size.width*1, height: size.height,)
                      ),
                    )).toList()
                  )
                );
              }

              return Expanded(
                child: Container(
                  alignment: Alignment.center,
                  width: size.width,
                  child: Text('downloading $percent% ($downloaded/$fileLength)'),
                ),
              );
            }),
          ],
        ),
      )
    );
  }
}