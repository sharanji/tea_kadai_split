import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 50,
            width: 50,
            child: Image.asset('assets/tea_glass.png'),
          ),
          Text(
            'Tea Kadai ',
            style: TextStyle(
              fontSize: 30,
              color: HexColor('#ff9f16'),
              fontWeight: FontWeight.bold,
              fontFamily: 'NerkoOne',
            ),
          ),
          const Text(
            'Split',
            style: TextStyle(
              fontSize: 30,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontFamily: 'NerkoOne',
            ),
          ),
        ],
      ),
    );
  }
}
