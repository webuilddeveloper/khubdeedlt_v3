import 'package:weconnect/component/material/font_cus.dart';
import 'package:flutter/material.dart';

imageItem(String title, String subTItle, String imageUrl, int flex,
    {bool titleStart = false, required Function callback}) {
  return Expanded(
    flex: flex,
    child: InkWell(
      onTap: () {
        callback();
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey,
          image: DecorationImage(
            image: AssetImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              titleStart ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: titleStart
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontFamily: 'Sarabun',
                    ),
                  ),
                  Text(
                    subTItle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontFamily: 'Sarabun',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
