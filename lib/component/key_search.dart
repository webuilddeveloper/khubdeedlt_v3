import 'package:flutter/material.dart';

class KeySearch extends StatefulWidget {
  const KeySearch(
      {super.key, required this.show, required this.onKeySearchChange});

//  final VoidCallback onTabCategory;
  final bool show;
  final Function(String) onKeySearchChange;

  @override
  // ignore: library_private_types_in_public_api
  _SearchBox createState() =>
      // ignore: no_logic_in_create_state
      _SearchBox(show: show, onKeySearchChange: onKeySearchChange);
}

class _SearchBox extends State<KeySearch> {
  final txtDescription = TextEditingController();
  bool show;
  Function(String) onKeySearchChange;

  _SearchBox({required this.show, required this.onKeySearchChange});

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtDescription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;
    // double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 0,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 45.0,
              width: width - 90.0,
              child: TextField(
                autofocus: false,
                cursorColor: Colors.blue,
                controller: txtDescription,
                onChanged: (text) {
                  onKeySearchChange(txtDescription.text);
                },
                keyboardType: TextInputType.multiline,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'Sarabun',
                ),
                textAlign: TextAlign.left,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  hintText: 'ใส่คำที่ต้องการค้นหา',
                  contentPadding: EdgeInsets.only(left: 5.0, right: 5.0),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                onKeySearchChange(txtDescription.text);
                setState(() {
                  show = !show;
                });
              },
              child: Container(
                color: Colors.transparent,
                child: Image.asset(
                  'assets/images/search.png',
                  height: 20.0,
                  width: 20.0,
                ),
              ),
            )
          ],
        ));
  }
}
