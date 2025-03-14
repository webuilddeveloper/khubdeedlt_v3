import 'package:weconnect/component/material/custom_alert_dialog.dart';
import 'package:weconnect/pages/blank_page/dialog_fail.dart';
import 'package:weconnect/pages/profile/edit_user_information.dart';
import 'package:weconnect/pages/profile/id_card_verification.dart';
import 'package:weconnect/pages/profile/identity_verification.dart';
import 'package:weconnect/pages/profile/setting_notification.dart';
import 'package:weconnect/shared/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'car_registration.dart';
import 'change_password.dart';
import 'connect_social.dart';

class UserInformationPage extends StatefulWidget {
  const UserInformationPage({super.key});

  @override
  // ignore: library_private_typses_in_public_api, library_private_types_in_public_api
  _UserInformationPageState createState() => _UserInformationPageState();
}

class _UserInformationPageState extends State<UserInformationPage> {
  final storage = const FlutterSecureStorage();
  late Future<dynamic> _futureProfile;
  final dynamic _tempData = {'imageUrl': '', 'firstName': '', 'lastName': ''};

  @override
  void initState() {
    _read();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: header(context, _goBack, title: 'ข้อมูลผู้ใช้งาน'),
      backgroundColor: Colors.white,
      body: FutureBuilder<dynamic>(
        future: _futureProfile,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return card(snapshot.data);
          } else if (snapshot.hasError) {
            return dialogFail(context);
          } else {
            return card(_tempData);
          }
        },
      ),
    );
  }

  _read() async {
    //read profile
    var profileCode = await storage.read(key: 'profileCode2');
    if (profileCode != '' && profileCode != null) {
      setState(() {
        _futureProfile = postDio(profileReadApi, {"code": profileCode});
      });
    }
  }

  _goBack() async {
    Navigator.pop(context, true);
    // Navigator.of(context).pushAndRemoveUntil(
    //   MaterialPageRoute(
    //     builder: (context) => HomePage(),
    //   ),
    //   (Route<dynamic> route) => false,
    // );
  }

  card(dynamic model) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return SingleChildScrollView(
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 270,
                    width: double.infinity,
                    child: Image.asset(
                      'assets/bg_header.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: statusBarHeight + 5),
                    alignment: Alignment.topLeft,
                    width: 80,
                    height: 60,
                    child: InkWell(
                      onTap: () => _goBack(),
                      child: Container(
                        margin: const EdgeInsets.all(17),
                        child: Image.asset(
                          'assets/icons/arrow_left_1.png',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: 96,
                width: 96,
                margin: const EdgeInsets.only(top: 100),
                // padding: EdgeInsets.all(10.0),
                // decoration: BoxDecoration(
                //   border: Border.all(color: Colors.white70, width: 1),
                //   borderRadius: BorderRadius.circular(80.0),
                // ),
                child: model['imageUrl'] != ''
                    ? CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: model['imageUrl'] != null
                            ? NetworkImage(
                                model['imageUrl'],
                              )
                            : null,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(80.0),
                        child: Container(
                          color: Colors.white12,
                          padding: const EdgeInsets.all(20.0),
                          child: Image.asset(
                            'assets/images/user_not_found.png',
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
              Container(
                height: 60,
                margin: const EdgeInsets.only(
                    top: 200.0, left: 20.0, right: 20.0, bottom: 30.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          model['firstName'] + ' ' + model['lastName'],
                          style: const TextStyle(
                            fontFamily: 'Sarabun',
                            fontSize: 25.0,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(top: 270.0, bottom: 30.0),
                constraints: const BoxConstraints(
                  minHeight: 200,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditUserInformationPage(),
                        ),
                      ),
                      child: buttonMenuUser(
                          'assets/icons/person.png', 'ข้อมูลผู้ใช้งาน'),
                    ),
                    // InkWell(
                    //   onTap: () async {
                    //     final msg = model['idcard'] == ''
                    //         ? await showDialog(
                    //             context: context,
                    //             builder: (BuildContext context) {
                    //               return _buildDialogRegister();
                    //             },
                    //           )
                    //         : await Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //               builder: (context) => IDCardInfo(),
                    //             ),
                    //           );
                    //     if (!msg) {
                    //       _read();
                    //     }
                    //   },
                    //   child: buttonMenuUser(
                    //       'assets/icons/id_card.png', 'ข้อมูลบัตรประชาชน'),
                    // ),
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IdentityVerificationPage(),
                        ),
                      ),
                      child: buttonMenuUser(
                          'assets/icons/papers.png', 'ข้อมูลสมาชิก'),
                    ),
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingNotificationPage(),
                        ),
                      ),
                      child: buttonMenuUser(
                          'assets/icons/bell.png', 'ตั้งค่าการแจ้งเตือน'),
                    ),
                    // InkWell(
                    //   onTap: () async {
                    //     final msg = model['idcard'] == ''
                    //         ? await showDialog(
                    //             context: context,
                    //             builder: (BuildContext context) {
                    //               return _buildDialogRegister();
                    //             })
                    //         : model['isDF'] != true
                    //             ? await showDialog(
                    //                 context: context,
                    //                 builder: (BuildContext context) {
                    //                   return _buildDialogdriverLicence();
                    //                 })
                    //             : await Navigator.push(
                    //                 context,
                    //                 MaterialPageRoute(
                    //                   builder: (context) => DriversInfo(),
                    //                 ),
                    //               );
                    //     if (!msg) {
                    //       _read();
                    //     }
                    //   },
                    //   child:
                    //       buttonMenuUser('assets/car.png', 'ข้อมูลใบขับขี่'),
                    // ),
                
                    // InkWell(
                    //   onTap: () => Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => AboutUsForm(
                    //         model: _futureAboutUs,
                    //         title: 'ติดต่อเรา',
                    //       ),
                    //     ),
                    //   ),
                    //   child: buttonMenuUser(
                    //       'assets/icons/phone.png', 'ติดต่อเรา'),
                    // ),
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConnectSocialPage(),
                        ),
                      ),
                      child: buttonMenuUser(
                          'assets/icons/link.png', 'การเชื่อมต่อ'),
                    ),
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangePasswordPage(),
                        ),
                      ),
                      child: buttonMenuUser(
                          'assets/icons/lock.png', 'เปลี่ยนรหัสผ่าน'),
                    ),
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CarRegistration(
                            type: 'C',
                          ),
                        ),
                      ),
                      child: buttonMenuUser(
                          'assets/icons/papers.png', 'ชำระภาษีรถตนเอง'),
                    ),
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CarRegistration(
                            type: 'V',
                          ),
                        ),
                      ),
                      child: buttonMenuUser(
                          'assets/icons/papers.png', 'ตรวจสภาพรถ'),
                    ),
                    // InkWell(
                    //   onTap: () => Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => ImageBinaryPage(),
                    //     ),
                    //   ),
                    //   child: buttonMenuUser(
                    //       'assets/icons/link.png', 'ดึงรูปใบสั่ง (เบต้า)'),
                    // ),
                    Container(
                      alignment: Alignment.centerRight,
                      child: const Text(
                        versionName,
                        style: TextStyle(
                          fontSize: 9,
                        ),
                      ),
                    ),
                    Container(
                      // color: Colors.red,
                      // width: 200,
                      margin: const EdgeInsets.only(top: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () => logout(context),
                            child: const Icon(
                              Icons.power_settings_new,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          InkWell(
                            onTap: () => logout(context),
                            child: const Text(
                              'ออกจากระบบ',
                              style: TextStyle(
                                fontFamily: 'Sarabun',
                                fontSize: 15,
                                color: Colors.red,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  buttonMenuUser(String image, String title) {
    return Container(
      padding: const EdgeInsets.only(bottom: 2.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
      ),
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
            decoration: BoxDecoration(
              // color: Theme.of(context).primaryColor,
              color: const Color(0xFF6F267B),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Image.asset(
              image,
              width: 20,
              height: 15,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Sarabun',
                fontSize: 15.0,
                color: Color(0xFF4A4A4A),
              ),
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Color(0xFF4A4A4A),
            size: 20,
          ),
        ],
      ),
    );
  }


}
