import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../authentication/signin.dart';
import '../community/newsFeed.dart';
import '../community/Sleep.dart';

class Routes {
  Map<String, Widget Function(BuildContext)> getRoutes(BuildContext context) {
    return {
      '/'                   : (context) => const MyHomePage(),
      'signin'              : (context) => const SignInPage(),
      'slide'               : (context) => const NewsfeedPage(),
      'sleep'               : (context) => const Sleep(),
    };
  }


  void to(BuildContext context, String path, Map<String, dynamic>? params) async {
    List required = ['slide'];
    List unrequired = ['signin'];
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      if (required.contains(path)) {
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, 'signin');
      } else {
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, path);
      }
    } else {
      if (unrequired.contains(path)) {
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, 'slide', arguments: params);
      } else { 
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, path, arguments: params);
      }
    }
  }
}