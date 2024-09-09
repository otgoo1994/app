import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../components/customInput.dart';
import '../hooks/ApiService.dart';
import '../components/alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../libs/routes.dart';
import '../libs/namespace.dart';
import '../types/types.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({
    super.key, 
    // required this.title
  });
  // final String title;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  @override
  void initState() {
    super.initState();
  }

  bool isShowed = true;
  final ApiService apiService = ApiService();
  final CustomDialog dialog = CustomDialog();
  final Routes routes = Routes();


  final Map<String, dynamic> _controllers = {
    "kioskId"                  : TextEditingController()
  };

  Future<void> _login() async {
    
    if (_controllers['kioskId'].text == '') {
      return;
    }
    
    Map<String, String> param = {
      'kioskId'              : _controllers['kioskId'].text
    };
    
    var res = await apiService.postDataRequest('kiosk/login', param);
    Login data = Login.fromJson(res);

    if (data.result == 'success') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _controllers['kioskId'].text);

      dialog.alert(
        context, 
        Namespace().DIALOG['SUCCESS']!,
        'Success Login', 
        'Thank you. Your account has been successfully logged.',
        () {
          routes.to(context, 'slide', null);
        }
      );
      return;
    }

    dialog.alert(
      context, 
      Namespace().DIALOG['ERROR']!,
      'Failed Login', 
      'No kiosk information found.',
      null
    );
    return;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: size.width*0.1,
              width: size.width*0.8,
              height: size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.topCenter,
                    child: const Text(
                      "Sign In",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)
                    )
                  ),
                  const SizedBox(height: 20),
                  CustomInput(
                    controller: _controllers['kioskId'], 
                    size: size.width/30, 
                    inputType: TextInputType.number,
                    hint: 'Enter kiosk ID', 
                    title: 'ID',
                  ),
                  TextButton(
                    onPressed: null,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Trouble logging in?",
                        style: TextStyle(
                          height: 1.0,
                          fontSize: size.width / 30,
                          color: Colors.black,
                        ),
                      ),
                    )
                  ),
                  SizedBox(
                    width: size.width*0.8,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:  Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Custom border radius
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white
                        ),
                      )
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}