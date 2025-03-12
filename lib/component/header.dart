import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

header(
  BuildContext context,
  Function functionGoBack, {
  String title = '',
  bool isButtonRight = false,
  String imageRightButton = 'assets/images/task_list.png',
  Function? rightButton,
  String menu = '',
}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(50),
    child: AppBar(
      centerTitle: true,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg_header.png'),
            fit: BoxFit.cover,
          ),
        ),
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     begin: Alignment.centerLeft,
        //     end: Alignment.centerRight,
        //     colors: <Color>[
        //       Color(0xFFFF7900),
        //       Color(0xFFFF7900),
        //     ],
        //   ),
        // ),
      ),
      backgroundColor: Color(0xFFFF7900),
      elevation: 0.0,
      titleSpacing: 5,
      automaticallyImplyLeading: false,
      title: Text(
        title ?? '',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          fontFamily: 'Sarabun',
        ),
      ),
      leading: InkWell(
        onTap: () => functionGoBack(),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Image.asset(
            "assets/icons/arrow_left_1.png",
            color: Colors.white,
          ),
        ),
      ),
      actions: <Widget>[
        isButtonRight
            ? Container(
                width: 42.0,
                height: 42.0,
                margin:
                    const EdgeInsets.only(top: 6.0, right: 10.0, bottom: 6.0),
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () => rightButton!(),
                  child: Image.asset(
                    imageRightButton,
                    color: Colors.white,
                  ),
                ),
              )
            : Container(),
      ],
    ),
  );
}
