import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'libs/routes.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  SystemChrome.setEnabledSystemUIMode(
    // SystemUiMode.immersive
    SystemUiMode.immersiveSticky
  );
  runApp( const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'huree design',
      routes: Routes().getRoutes(context),
      initialRoute: '/',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white
      )
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key, 
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  bool isLoaded             = false;
  bool initialized          = false;
  final Routes routes       = Routes();
  String? token;


  void _setLoader() {
    if (isLoaded) {
      return;
    }
    
    Timer(const Duration(milliseconds: 3000), () {
      setState(() {
        isLoaded = true;
      });
    });
  }

  void getRequiredData() async {
    if (initialized) return;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
      print(token);
      initialized = true;
    });

    _setLoader();
  }

  void worked() {
    if (token == null) return;


    Timer(const Duration(milliseconds: 500), () {
      routes.to(context, 'slide', null);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    getRequiredData();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            // margin: !isLoaded ? null : EdgeInsets.only(top: size.height/4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              onEnd: worked,
              width: !isLoaded ? size.width / 3 : size.width / 4,
              child:  const Image(
                image: AssetImage("assets/images/logo.png"),
                fit: BoxFit.fill,
              )
              // child: Text('HUREE DESIGN', style: TextStyle(fontWeight: FontWeight.w500, fontSize: size.width / 25),)
            )
          ),
          Positioned(
            bottom: 40,
            width: size.width,
            child: Builder(builder: (context) {
              if (token == null) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: !isLoaded ? 0 : 1,
                    child: Column(
                    children: <Widget>[
                      SizedBox(
                        width: size.width*0.8,
                        child: ElevatedButton(
                          onPressed: (){ routes.to(context, 'signin', null); },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15), // Custom border radius
                            ),
                          ),
                          child: const Text('Log In', style: TextStyle(color: Colors.black),)
                        ),
                      ),
                    ],
                  ),
                  )
                );
              }
              return const SizedBox.shrink();
            })
          )
        ],
      )
    );
  }
}