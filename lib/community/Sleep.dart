import 'dart:async';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../libs/routes.dart';
import './newsFeed.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Sleep extends StatefulWidget {
  const Sleep({Key? key}) : super(key: key);
  @override
  _SleepState createState() => _SleepState();
}


class _SleepState extends State<Sleep> {


  DateTime? _poweron;
  final Routes routes = Routes();

  Future<String> get powerOnTime async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var t = prefs.getString('poweron');
    if(t != null) {
      return t;
    } else {
      return 'none';
    }
  }

  void checkSecond() {
    Timer.periodic(Duration(seconds: 60), (timer) {
      final c = DateTime.now();
      final time = DateTime(c.year, c.month, c.day, c.hour, c.minute);
      if(time.isAfter(_poweron!)) {
        timer.cancel();
        routes.to(context, 'slide', null);
      } else {
        print('${_poweron} =============== ${time}');
      }
    });
  }

  @override
  void initState() {
    super.initState();

    powerOnTime.then((value) {
      final curr = DateTime.now();
      if(value == 'none') {
        _poweron = DateTime(curr.year, curr.month, curr.day + 1, 18, 00);
      } else {
        _poweron = DateTime(curr.year, curr.month, curr.day + 1, int.parse(value.split(':')[0]), int.parse(value.split(':')[1]));
        // _poweron = DateTime(curr.year, curr.month, curr.day, 20, 43);
      }
    });

    checkSecond();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      body: Column(
        children: [
          Container(
              decoration: BoxDecoration(
                  color: Colors.black),
              width: size.width,
              height: size.height
          ),
        ],
      ),
    );
  }
}