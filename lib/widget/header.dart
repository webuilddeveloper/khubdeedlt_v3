import 'package:flutter/material.dart';

header(BuildContext? context, void Function() goBack, {String? title}) {
  return AppBar(
    backgroundColor: const Color(0xFFFF7900),
    title: Row(
      children: [
        Image.asset(
          'assets/logo/logo.png',
          height: 50,
        ),
        const Padding(
          padding: EdgeInsets.only(
            left: 10,
          ),
          child: Text(
            'Khub Dee',
            style: TextStyle(
              fontFamily: 'Sarabun',
            ),
          ),
        )
      ],
    ),
  );
}
