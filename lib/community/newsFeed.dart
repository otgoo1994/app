import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import '../hooks/ApiService.dart';
import '../libs/routes.dart';
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
    checkInternet();
    checkFilesFromInternet();

    poweroffTime.then((value) {
      final curr = DateTime.now();
      if(value == 'none') {
        _poweroff = DateTime(curr.year, curr.month, curr.day, 18, 00);
      } else {
        _poweroff = DateTime(curr.year, curr.month, curr.day, int.parse(value.split(':')[0]), int.parse(value.split(':')[1]));
      }
    });
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final Dio _dio                            = Dio();
  List<String> images                       = [];
  List<String> videos                       = [];
  List<dynamic> downloadImages              = [];
  List<dynamic> downloadVideos              = [];
  int fileLength                            = 0;
  int downloaded                            = 1;
  bool downloading                          = false;
  String percent                            = '0';
  List<dynamic> storedImages                = [];
  List<dynamic> storedVideos                = [];
  DateTime? _poweroff;


  late VideoPlayerController _controller;
  Future<void>? _initializeVideoPlayerFuture;
  final ApiService apiService = ApiService();
  final Routes routes = Routes();

  Map<String, int> numbers = {
    'duration'        : 1,
    'currentSecond'   : 0,
    'length'          : 0,
    'currentVideo'    : 0
  }; 

  Future<String> _getDownloadDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<Map<String,dynamic>?> checkDuplicatedImages(String name) async {
    Map<String, dynamic>? file;
    for (var photo in storedImages) {
      if (photo['name'] == name) {
        file = photo;
      }
    }

    return file;
  }

  Future<String> get poweroffTime async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var t = prefs.getString('poweroff');
    if(t != null) {
      return t;
    } else {
      return 'none';
    }
  }

  Future<Map<String,dynamic>?> checkDuplicatedVideos(String name) async {
    Map<String, dynamic>? file;
    for (var video in storedVideos) {
      if (video['name'] == name) {
        file = video;
      }
    }

    return file;
  }

  void checkInternet() async {

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        checkFiles();
        return;
      }
    } on SocketException catch (_) {
      setLocalFiles();
    }

  }

  void setLocalFiles() async {
    setState(() {
      downloading = true;
    });

    final prefs = await SharedPreferences.getInstance();

    final String? img = prefs.getString('images');
    final String? vds = prefs.getString('videos');

    if (img != null) {
      setState(() {
        storedImages = jsonDecode(img);
      });
    }

    if (vds != null) {
      setState(() {
        storedVideos = jsonDecode(vds);
      });
    }
    
    String dir = await _getDownloadDirectory();

    for (var stored in storedImages) {
      String savePath = '$dir/${stored['name']}';
      File file = File(savePath);
      bool fileExists = await file.exists();
      if (fileExists) {
        setState(() {
          images.add(savePath);
        });
      }
    }    

    for (var stored in storedVideos) {
      String savePath = '$dir/${stored['name']}';

      File file = File(savePath);
      bool fileExists = await file.exists();
      if (fileExists) {
        setState(() {
          videos.add(savePath);
        });
      }
    }

    setState(() {
      downloading = false;
    });

    if (videos.isNotEmpty) {
      initialVideo(videos[numbers['currentVideo']!]);
      checkSecond();
    }
  }

  void checkFileInBackground() async {
    final prefs = await SharedPreferences.getInstance();

    final String? token = prefs.getString('token');

    Map<String, String> param = {
      'id'              : token!
    };

    var res = await apiService.postDataRequest('kiosk/get-photo', param);
    KioskContentList data = KioskContentList.fromJson(res);
    String baseUrl = dotenv.env['APP_URL']!;
    String dir = await _getDownloadDirectory();

    for (var photo in data.photos) {

      dynamic file = await checkDuplicatedImages(photo['name']);

      if (file == null) {
        Map<String, dynamic> current = {
          "url"   : '$baseUrl/contents/image/slide/${photo['name']}',
          "name"  : photo['name'],
          "extn"  : photo['extn']
        };
        String savePath = '$dir/${photo['name']}';
        await _dio.download('$baseUrl/contents/image/slide/${photo['name']}', savePath );

        setState(() {
          images.add(savePath);
        });

        storedImages.add(current);
      }
    }

    for (var video in data.videos) {
      dynamic file = await checkDuplicatedVideos(video['name']);
      if (file == null) {

        Map<String, dynamic> current = {
          "url"   : '$baseUrl/contents/image/slide/${video['name']}',
          "name"  : video['name'],
          "extn"  : video['extn']
        };
        String savePath = '$dir/${video['name']}';
        await _dio.download('$baseUrl/contents/image/slide/${video['name']}', savePath );

        setState(() {
          videos.add(savePath);
        });

        storedVideos.add(current);
      }
    }

    await prefs.setString('images', jsonEncode(storedImages));
    await prefs.setString('videos', jsonEncode(storedVideos));
  }

  void checkFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final String? img = prefs.getString('images');
    final String? vds = prefs.getString('videos');


    if (img != null) {
      setState(() {
        storedImages = jsonDecode(img);
      });
    }

    if (vds != null) {
      setState(() {
        storedVideos = jsonDecode(vds);
      });
    }


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

      dynamic file = await checkDuplicatedImages(photo['name']);
      if (file == null) {
        downloadImages.add(current);
      }
    }

    for (var video in data.videos) {
      Map<String, dynamic> current = {
        "url"   : '$baseUrl/contents/video/${video['name']}',
        "name"  : video['name'],
        "extn"  : video['extn']
      };

      dynamic file = await checkDuplicatedVideos(video['name']);
      if (file == null) {
        downloadVideos.add(current);
      }
    }


    for (var stored in storedImages) {
      bool find = false;
      for (var collection in data.photos) {
        if (collection['name'] == stored['name']) {
          find = true;
        }
      }

      if (!find) {
        await removeFile(stored['name']);
      } else {
        await _downloadFile(stored['url'], stored['name'], stored['extn']);
      }
    }

    for (var stored in storedVideos) {
      bool find = false;
      for (var collection in data.videos) {
        if (collection['name'] == stored['name']) {
          find = true;
        }
      }

      if (!find) {
        await removeFile(stored['name']);
      } else {
        await _downloadFile(stored['url'], stored['name'], stored['extn']);
      }
    }

    setState(() {
      numbers['length'] = data.videos.length;
    });


    downloadFiles();
  }

  Future<bool> removeFile(String name) async {
    String dir = await _getDownloadDirectory();

    String savePath = '$dir/$name';

    File file = File(savePath);
    bool fileExists = await file.exists();

    if (fileExists) {
      print('removed====$file');
      await file.delete();
    }

    return true;
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
      storedImages.add(file);
      downloaded++;
    }

    for (var file in downloadVideos) {
      await _downloadFile(file['url'], file['name'], file['extn']);
      storedVideos.add(file);
      downloaded++;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('images', jsonEncode(storedImages));
    await prefs.setString('videos', jsonEncode(storedVideos));

    setState(() {
      downloading = false;
    });

    if (videos.isNotEmpty) {
      initialVideo(videos[numbers['currentVideo']!]);
      checkSecond();
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
      numbers['currentSecond'] = 0;
      numbers['duration'] = _controller.value.duration.inSeconds;
      _controller.play();
    });

    _controller.addListener(() {
      setState(() {
        numbers['currentSecond'] = _controller.value.position.inSeconds;
      });
    });
  }

  void checkSecond() {
    Timer.periodic(const Duration(seconds: 3), (timer) {
      
      final c = DateTime.now();
      final time = DateTime(c.year, c.month, c.day, c.hour, c.minute);

      if(time.isAfter(_poweroff!)) {
        timer.cancel();
        _controller.pause();
        _controller.dispose();
       routes.to(context, 'sleep', null);
      }

      if (numbers['currentSecond'] == numbers['duration']) {
        _clearPrevious().then((_) {
          if(numbers['currentVideo']! < videos.length - 1) {
            setState(() {
              numbers['currentVideo'] = numbers['currentVideo']! + 1;
            });
          } else {
            setState(() {
              numbers['currentVideo'] = 0;
            });
          }
          initialVideo(videos[numbers['currentVideo']!]);
        });
      }
    });

  }

  void checkFilesFromInternet() async {
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          checkFileInBackground();
        }
      } on SocketException catch (_) {
        print('no internet connected');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
      child: Builder(builder: (context) {
        if (downloading) {
          return Expanded(
            child: Container(
              alignment: Alignment.center,
              width: size.width,
              child: Builder(builder: (context) {
                if (fileLength > 0) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Checking for file updates...'),
                      Text('downloading $percent% ($downloaded/$fileLength)')
                    ],
                  );
                }

                return const Text('Checking for file updates...');
              }) 
            ),
          );
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return AspectRatio(
                    aspectRatio: 1920/1080,
                    child: VideoPlayer(_controller),
                  );
                } 

                return Container(
                  alignment: Alignment.center,
                  width: size.width,
                  height: size.width/(1920/1080),
                  child: SizedBox(
                    width: size.width/20,
                    height: size.width/20,
                    child: const CircularProgressIndicator(
                      strokeWidth: .5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  ),
                );
              },
            ),
            Builder(builder: (context) {
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
            })
          ],
        );
      })
      )
    );
  }
}