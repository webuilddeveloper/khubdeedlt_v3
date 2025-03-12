import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weconnect/component/header.dart';
import 'package:weconnect/shared/api_provider.dart';
import 'package:weconnect/widget/text_form_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final txtEmail = TextEditingController();

  @override
  void dispose() {
    txtEmail.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<dynamic> submitForgotPassword() async {
    postObjectData('m/Register/forgot/password', {
      'email': txtEmail.text,
    });
    // final result = await postObjectData('m/Register/forgot/password', {
    //   'email': txtEmail.text,
    // });

    setState(() {
      txtEmail.text = '';
    });
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text(
            'เปลี่ยนรหัสผ่านเรียบร้อยแล้ว',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Sarabun',
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
          content: const Text(" "),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text(
                "ตกลง",
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Sarabun',
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

  void goBack() async {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Scaffold(
        appBar: header(context, goBack, title: 'ลืมรหัสผ่าน'),
        backgroundColor: Colors.transparent,
        body: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 10.0,
                ),
                child: Container(
                  color: Colors.white,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
                            child: Text(
                              'กรอกอีเมลเพื่อรับรหัสผ่านใหม่ ระบบจะส่งรหัสผ่านใหม่ไปยังอีเมลของคุณ',
                              style: TextStyle(
                                fontSize: 18.00,
                                fontFamily: 'Sarabun',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          labelTextFormField('อีเมล'),
                          textFormField(
                            txtEmail,
                            '',
                            'อีเมล',
                            'อีเมล',
                            true,
                            false,
                            true,
                          ),
                          Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              margin: const EdgeInsets.only(
                                top: 20.0,
                                bottom: 10.0,
                              ),
                              child: Material(
                                elevation: 5.0,
                                borderRadius: BorderRadius.circular(10.0),
                                color: Theme.of(context).primaryColor,
                                child: MaterialButton(
                                  height: 40,
                                  onPressed: () {
                                    final form = _formKey.currentState;
                                    if (form!.validate()) {
                                      form.save();
                                      submitForgotPassword();
                                    }
                                  },
                                  child: const Text(
                                    'ยืนยัน',
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                      fontFamily: 'Sarabun',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
