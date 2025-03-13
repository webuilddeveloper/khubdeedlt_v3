import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weconnect/pages/privilege/privilege_main.dart';
import 'package:weconnect/shared/api_provider.dart';

class PolicyPrivilege extends StatefulWidget {
  const PolicyPrivilege(
      {super.key,
      required this.username,
      required this.title,
      required this.fromPolicy});
  final String username;
  final String title;
  final bool fromPolicy;

  @override
  // ignore: library_private_types_in_public_api
  _PolicyPrivilegeState createState() => _PolicyPrivilegeState();
}

class _PolicyPrivilegeState extends State<PolicyPrivilege> {
  final storage = const FlutterSecureStorage();

  // String _username;
  List<dynamic> _dataPolicy = [];
  late Future<dynamic> futureModel;
  ScrollController scrollController = ScrollController();
  // final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    setState(() {
      futureModel = readPolicy();
    });

    super.initState();
  }

  Future<dynamic> readPolicy() async {
    final result = await postObjectData("m/policy/read", {
      "category": "marketing",
      "username": widget.username,
    });

    if (result['status'] == 'S') {
      if (result['objectData'].length > 0) {
        for (int i = 0; i < result['objectData'].length; i++) {
          result['objectData'][i]['isActive'] = "";
          result['objectData'][i]['agree'] = false;
          result['objectData'][i]['noAgree'] = false;
        }
        setState(() {
          _dataPolicy = result['objectData'];
        });
      }
    }
  }

  Future<dynamic> updatePolicy() async {
    if (_dataPolicy.isNotEmpty) {
      for (int i = 0; i < _dataPolicy.length; i++) {
        await postObjectData("m/policy/create", {
          "username": widget.username.toString(),
          "reference": _dataPolicy[i]['code'].toString(),
          "isActive": _dataPolicy[i]['isActive'] != ""
              ? _dataPolicy[i]['isActive']
              : false,
        });
      }
    }
    return showDialog(
      barrierDismissible: false,
      // ignore: use_build_context_synchronously
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text(
            'บันทึกข้อมูลเรียบร้อย',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Sarabunun',
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
          content: const Text(''),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text(
                "ตกลง",
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Sarabunun',
                  color: Color(0xFF000070),
                  fontWeight: FontWeight.normal,
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PrivilegeMain(
                      title: widget.title,
                      fromPolicy: true,
                    ),
                  ),
                );
                // Navigator.of(context).pushAndRemoveUntil(
                //   MaterialPageRoute(
                //     builder: (context) => PrivilegeMain(title: widget.title),
                //   ),
                //   (Route<dynamic> route) => false,
                // );
              },
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> sendPolicy() async {
    var index = _dataPolicy
        .indexWhere((c) => c['isActive'] == "" && c['isRequired'] == true);

    if (index == -1) {
      updatePolicy();
    } else {
      return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text(
              'กรุณาตรวจสอบและยอมรับนโยบายทั้งหมด',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Sarabunun',
                color: Colors.black,
                fontWeight: FontWeight.normal,
              ),
            ),
            content: const Text(''),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text(
                  "ตกลง",
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Sarabunun',
                    color: Color(0xFF000070),
                    fontWeight: FontWeight.normal,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void checkIsActivePolicy(index, isActive) async {
    if (isActive) {
      _dataPolicy[index].agree = _dataPolicy[index].agree ? false : true;
      _dataPolicy[index].isActive = _dataPolicy[index].agree ? true : "";
      _dataPolicy[index].noAgree = false;
    } else {
      _dataPolicy[index].noAgree = _dataPolicy[index].noAgree ? false : true;
      _dataPolicy[index].isActive = _dataPolicy[index].noAgree ? false : "";
      _dataPolicy[index].agree = false;
    }
    setState(() {
      _dataPolicy = _dataPolicy;
    });
  }

  card() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child:
          Padding(padding: const EdgeInsets.all(10), child: formContentStep1()),
    );
  }

  formContentStep1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (var item in _dataPolicy)
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 0.5,
                    width: MediaQuery.of(context).size.width,
                    child: Image.network(
                      item['imageUrl'],
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    item['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Sarabunun',
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Html(
                      data: '${item['description']}',
                      onLinkTap: (url, context, attributes) {
                        // ignore: deprecated_member_use
                        launch(url!);
                      }),
                  if (item['isRequired'])
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(
                                  color: item['agree'] == true
                                      ? Colors.red
                                      : Colors.white,
                                ),
                              ),
                              backgroundColor: item['agree'] == true
                                  ? Colors.red
                                  : Colors.white,
                              foregroundColor: item['agree'] == true
                                  ? Colors.white
                                  : Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                item['noAgree'] = false;
                                item['agree'] = true;
                                item['isActive'] = item[
                                    'agree']; // Ensures boolean consistency
                              });
                            },
                            child: const Text(
                              'ยินยอม',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontFamily: 'Sarabun', // Fixed font name
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(
                                  color: item['noAgree'] == true
                                      ? Colors.red
                                      : Colors.white,
                                ),
                              ),
                              backgroundColor: item['noAgree'] == true
                                  ? Colors.red
                                  : Colors.white,
                              foregroundColor: item['noAgree'] == true
                                  ? Colors.white
                                  : Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                item['agree'] = false;
                                item['noAgree'] = true;
                                item['isActive'] = item[
                                    'noAgree']; // Ensures boolean consistency
                              });
                            },
                            child: const Text(
                              'ไม่ยินยอม',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Sarabun', // Fixed font name
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: const BorderSide(
                  color: Color(0xFF000070),
                ),
              ),
              backgroundColor:
                  const Color(0xFF000070), // Button background color
              foregroundColor: Colors.white, // Text color
            ),
            onPressed: () {
              sendPolicy();
            },
            child: const Text(
              'ตกลง',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Sarabun', // Fixed font name
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void goBack() async {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: futureModel,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Image.asset(
              "assets/background/login.png",
              fit: BoxFit.cover,
            ),
          );
        } else {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/background/login.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Scaffold(
                // appBar: header(context, goBack),
                backgroundColor: Colors.transparent,
                body: ListView(
                  controller: scrollController,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(10.0),
                  children: <Widget>[
                    Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[
                        card(),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        }
      },
    );
  }
}
