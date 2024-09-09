import 'package:flutter/material.dart';

class CustomDialog {
  void alert(
    BuildContext context,
    String type,
    String title, 
    String contentText,
    VoidCallback? callback
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Size size = MediaQuery.of(context).size;
        return AlertDialog(
          backgroundColor: Colors.white,
          shadowColor: Colors.black,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          // title: const Text('Alert Title'),
          content: SizedBox(
            height: size.width/2.2,
            child: Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  height: size.height/15,
                  child: Builder(
                    builder: (context) {
                      switch(type) {
                        case 'ERROR'  : return const Image( image: AssetImage("assets/images/error.png") );
                        case 'INFO'   : return const Image( image: AssetImage("assets/images/info.png") );
                        default       : return const Image( image: AssetImage("assets/images/success.png") );
                      }

                      
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Text(title, style: TextStyle(fontSize: size.width/20, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                Text(contentText, textAlign: TextAlign.center, style: TextStyle(fontSize: size.width/30, fontWeight: FontWeight.w400, color: const Color(0xFF49454F))),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: size.width*0.8,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (callback != null) {
                     callback();
                    return;
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:  Colors.white,
                  // shadowColor: Color,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // side: const BorderSide(color: Color(0xFF090909), width: 1)
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    color: Color(0xFF090909)
                  ),
                )
              ),
            )
          ],
        );
      },
    );
  }



  void confirm(
    BuildContext context,
    String title, 
    String contentText,
    void Function(bool date) callback
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Size size = MediaQuery.of(context).size;
        return AlertDialog(
          backgroundColor: Colors.white,
          shadowColor: Colors.black,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          // title: const Text('Alert Title'),
          content: SizedBox(
            height: size.width/2.2,
            child: Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  height: size.height/15,
                  child: const Image( image: AssetImage("assets/images/info.png") )
                ),
                const SizedBox(height: 10),
                Text(title, style: TextStyle(fontSize: size.width/20, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                Text(contentText, textAlign: TextAlign.center, style: TextStyle(fontSize: size.width/30, fontWeight: FontWeight.w400, color: const Color(0xFF49454F))),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: size.width*0.8,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  callback(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:  Colors.white,
                  // shadowColor: Color,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // side: const BorderSide(color: Color(0xFF090909), width: 1)
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    color: Color.fromARGB(255, 199, 62, 62)
                  ),
                )
              ),
            ),
            SizedBox(
              width: size.width*0.8,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  callback(false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:  Colors.white,
                  // shadowColor: Color,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // side: const BorderSide(color: Color(0xFF090909), width: 1)
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFF090909)
                  ),
                )
              ),
            )
          ],
        );
      },
    );
  }
}