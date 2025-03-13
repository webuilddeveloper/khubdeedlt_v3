import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

buttonCloseBack(BuildContext context) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      MaterialButton(
        minWidth: 29,
        onPressed: () {
          Navigator.pop(context);
        },
        color: Theme.of(context).primaryColor,
        textColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.close,
          size: 29,
        ),
      ),
    ],
  );
}
