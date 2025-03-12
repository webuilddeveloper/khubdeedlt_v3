import 'package:flutter/material.dart';

labelTextField(String label, Icon icon) {
  return Row(
    children: <Widget>[
      icon,
      Text(
        ' $label',
        style: TextStyle(
          fontSize: 15.000,
          fontFamily: 'Sarabun',
        ),
      ),
    ],
  );
}

textField(
  TextEditingController model,
  TextEditingController? modelMatch, // เปลี่ยนเป็น nullable
  String hintText,
  String validator,
  bool enabled,
  bool isPassword,
) {
  return SizedBox(
    height: 45.0,
    child: TextField(
      obscureText: isPassword,
      controller: model,
      enabled: enabled,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.normal,
        fontFamily: 'Sarabun',
        fontSize: 15.00,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFC5DAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}
