import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:weconnect/component/carousel_rotation.dart';
import 'package:weconnect/component/material/check_avatar.dart';
import 'package:weconnect/component/menu/build_verify_ticket.dart';
import 'package:weconnect/component/menu/color_item.dart';
import 'package:weconnect/component/menu/image_item.dart';
import 'package:weconnect/component/v2/button_menu_full.dart';
import 'package:weconnect/login.dart';
import 'package:weconnect/pages/blank_page/blank_loading.dart';
import 'package:weconnect/pages/blank_page/toast_fail.dart';
import 'package:weconnect/pages/dispute_an_allegation.dart';
import 'package:weconnect/pages/reporter/reporter_main.dart';
import 'package:weconnect/pages/warning/warning_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weconnect/component/carousel_banner.dart';
import 'package:weconnect/pages/about_us/about_us_form.dart';
import 'package:weconnect/pages/menu_grid_item.dart';
import 'package:weconnect/pages/notification/notification_list.dart';
import 'package:weconnect/pages/poi/poi_list.dart';
import 'package:weconnect/pages/poll/poll_list.dart';
import 'package:weconnect/pages/welfare/welfare_list.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:weconnect/component/link_url_in.dart';
import 'package:weconnect/profile.dart';
import 'package:weconnect/pages/contact /contact_list_category.dart';
import 'package:weconnect/pages/news/news_list.dart';
import 'package:weconnect/pages/privilege/privilege_main.dart';
import 'package:weconnect/pages/profile/user_information.dart';
import 'package:weconnect/shared/api_provider.dart';
import 'package:weconnect/component/carousel_form.dart';
import 'pages/event_calendar/event_calendar_main.dart';
import 'pages/knowledge/knowledge_list.dart';
import 'pages/main_popup/dialog_main_popup.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final storage = const FlutterSecureStorage();
  late DateTime currentBackPressTime;

  late Future<dynamic> _futureBanner;
  late Future<dynamic> _futureProfile;
  late Future<dynamic> _futureMenu;
  late Future<dynamic> _futureRotation;
  late Future<dynamic> _futureAboutUs;
  late Future<dynamic> _futureMainPopUp;
  late Future<dynamic> _futureVerifyTicket;

  String profileCode = '';
  String currentLocation = '-';
  final seen = <String>{};
  List unique = [];
  List imageLv0 = [];

  bool notShowOnDay = false;
  bool hiddenMainPopUp = false;
  bool checkDirection = false;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  LatLng latLng = const LatLng(13.743989326935178, 100.53754006134743);

  @override
  void initState() {
    _read();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildHeader(),
      // ignore: deprecated_member_use
      body: WillPopScope(child: _buildBackground(), onWillPop: confirmExit),
    );
  }

  Future<bool> confirmExit() {
    DateTime now = DateTime.now();
    if (now.difference(currentBackPressTime) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      toastFail(
        context,
        text: 'กดอีกครั้งเพื่อออก',
        color: Colors.black,
        fontColor: Colors.white,
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  _buildBackground() {
    return Container(
      child: _buildNotificationListener(),
    );
  }

  _buildNotificationListener() {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (OverscrollIndicatorNotification overScroll) {
        overScroll.disallowIndicator();
        return false;
      },
      child: _buildSmartRefresher(),
    );
  }

  _buildSmartRefresher() {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: false,
      header: const WaterDropHeader(
        complete: Text(''),
        completeDuration: Duration(milliseconds: 0),
      ),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = const Text("pull up load");
          } else if (mode == LoadStatus.loading) {
            body = const Text("loading");
          } else if (mode == LoadStatus.failed) {
            body = const Text("Load Failed!Click retry!");
          } else if (mode == LoadStatus.canLoading) {
            body = const Text("release to load more");
          } else {
            body = const Text("No more Data");
          }
          return SizedBox(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: _buildMenu(),
    );
  }

  _buildMenu() {
    return ListView(
      children: [
        _buildBanner(),
        _buildCurrentLocationBar(),
        _buildProfile(),
        _buildVerifyTicket(),
        _buildDispute(),
        const SizedBox(height: 5),
        _buildRotation(),
        const SizedBox(height: 5),
        _buildCardFirst(),
        _buildCardSecond(),
        _buildCardThird(),
        _buildRotation(),
        _buildFooter(),
      ],
    );
  }

  _buildHeader() {
    return PreferredSize(
      preferredSize: Size.fromHeight(70 + MediaQuery.of(context).padding.top),
      child: AppBar(
        flexibleSpace: Container(
          width: double.infinity,
          // height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background/background_header.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'สำนักงานตำรวจแห่งชาติ',
                style: TextStyle(
                    fontSize: 22.0, color: Colors.white, fontFamily: 'Mitr'),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      alignment: Alignment.centerLeft,
                      height: 50,
                      child: Image.asset(
                        'assets/logo/headlogo.png',
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationList(
                            title: 'แจ้งเตือน',
                          ),
                        ),
                      );
                    },
                    child: SizedBox(
                      height: 30,
                      child: Image.asset('assets/icons/bell.png'),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () async {
                      final msg = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserInformationPage(),
                        ),
                      );

                      if (!msg) {
                        _read();
                      }
                    },
                    child: FutureBuilder<dynamic>(
                      future: _futureProfile,
                      builder: (BuildContext context,
                          AsyncSnapshot<dynamic> snapshot) {
                        if (snapshot.hasData) {
                          if (profileCode == snapshot.data['code']) {
                            return Container(
                              height: 50,
                              padding: const EdgeInsets.only(right: 10),
                              child: checkAvatar(
                                  context, '${snapshot.data['imageUrl']}'),
                            );
                          } else {
                            return const BlankLoading(
                              width: 20,
                              height: 20,
                            );
                          }
                        } else if (snapshot.hasError) {
                          return const BlankLoading();
                        } else {
                          return const BlankLoading();
                        }
                      },
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _buildDispute() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DisputeAnAllegation(),
          ),
        );
      },
      child: Container(
        height: 120,
        padding: const EdgeInsets.symmetric(horizontal: 25),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.grey,
          image: DecorationImage(
            // image: NetworkImage('${model['imageUrl']}'),
            image: AssetImage('assets/background/background_dispute.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ยื่นอุทธรณ์',
                    style: TextStyle(
                      fontFamily: 'Sarabun',
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                  ),
                  Text(
                    '(Dispute)',
                    style: TextStyle(
                        fontFamily: 'Sarabun',
                        color: Colors.white,
                        fontSize: 15.0),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'สำนักงานตำรวจแห่งชาติอำนวยความสะดวกให้ท่าน สามารถตรวจสอบใบสั่งย้อนหลังได้สูงสุด 1 ปี',
                    style: TextStyle(
                      fontFamily: 'Sarabun',
                      color: Colors.white,
                      fontSize: 11.0,
                    ),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildCardFirst() {
    return Container(
      height: 125,
      color: Colors.white,
      child: Row(
        children: [
          imageItem('ข่าวประชาสัมพันธ์', '(News)',
              'assets/background/news_background.png', 2, titleStart: true,
              callback: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NewsList(
                  title: 'ข่าวประชาสัมพันธ์',
                ),
              ),
            );
          }),
          imageItem(
              'เบอร์โทรฉุกเฉิน', '(SOS)', 'assets/background/hotline.png', 1,
              callback: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContactListCategory(
                  title: 'เบอร์โทรฉุกเฉิน',
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  _buildCardSecond() {
    return Container(
      height: 125,
      color: Colors.white,
      child: Row(
        children: [
          colorItem('ปฏิทินกิจกรรม', '(Calendar)',
              'assets/icons/icon_calendar.png', 1, callback: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventCalendarMain(
                  title: 'ปฏิทินกิจกรรม',
                ),
              ),
            );
          }),
          imageItem('ความรู้คู่การขับขี่', '(Driving Knowledge)',
              'assets/background/info_background.png', 2, callback: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const KnowledgeList(
                  title: 'ความรู้คู่การขับขี่',
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  _buildCardThird() {
    return Container(
      height: 125,
      color: Colors.white,
      child: Row(
        children: [
          imageItem(
            'จุดบริการ',
            '(Service Station)',
            'assets/background/service_background.png',
            2,
            callback: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PoiList(
                    title: 'จุดบริการ',
                    latLng: latLng,
                  ),
                ),
              );
            },
          ),
          colorItem(
              'ติดต่อเรา', '(Contact us)', 'assets/images/icon_info.png', 1,
              linearGradient: const LinearGradient(
                colors: [
                  Color(0xFF5B1800),
                  Color(0xFF5B1800),
                ],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ), callback: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AboutUsForm(
                  model: _futureAboutUs,
                  title: 'ติดต่อเรา',
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  _buildVerifyTicket() {
    return VerifyTicket(
      model: _futureVerifyTicket,
    );
  }

  _buildBanner() {
    return CarouselBanner(
      model: _futureBanner,
      nav: (String path, String action, dynamic model, String code,
          String urlGallery) {
        if (action == 'out') {
          launchInWebViewWithJavaScript(path);
          // launchURL(path);
        } else if (action == 'in') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CarouselForm(
                code: code,
                model: model,
                url: mainBannerApi,
                urlGallery: bannerGalleryApi,
              ),
            ),
          );
        }
      },
    );
  }

  _buildCurrentLocationBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          // color: Color(0xFF000070),
          // padding: EdgeInsets.symmetric(horizontal: 5),
          alignment: Alignment.center,
          padding: const EdgeInsets.only(left: 10),
          child: const Row(
            children: [
              Icon(Icons.credit_card),
              Text(
                ' ใบอนุญาตขับขี่',
                style: TextStyle(
                  fontFamily: 'Sarabun',
                  // fontSize: 10,
                  // color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(right: 10),
          height: 40,
          child: Row(
            children: [
              Icon(
                Icons.pin_drop,
                color: Colors.orange[400],
              ),
              Text(
                ' $currentLocation',
                style: TextStyle(
                  fontFamily: 'Sarabun', color: Colors.orange[400],
                  // fontSize: 10,
                  // color: Colors.white,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  _buildProfile() {
    return Profile(
      model: _futureProfile,
    );
  }

  _buildGridMenu1() {
    return FutureBuilder<dynamic>(
      future: _futureMenu, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return Row(
            children: [
              MenuGridItem(
                title: snapshot.data[0]['title'],
                imageUrl: snapshot.data[0]['imageUrl'],
                isCenter: false,
                isPrimaryColor: true,
                nav: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventCalendarMain(
                        title: snapshot.data[0]['title'],
                      ),
                    ),
                  );
                  // if (checkDirection) {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => EventCalendarMain(
                  //         title: snapshot.data[0]['title'],
                  //       ),
                  //     ),
                  //   );
                  // } else {
                  //   _showDialogDirection();
                  // }
                },
              ),
              MenuGridItem(
                title: snapshot.data[1]['title'] != ''
                    ? snapshot.data[1]['title']
                    : '',
                imageUrl: snapshot.data[1]['imageUrl'],
                subTitle: '',
                isCenter: true,
                isPrimaryColor: true,
                nav: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => KnowledgeList(
                        title: snapshot.data[1]['title'],
                      ),
                    ),
                  );
                  // if (checkDirection) {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => KnowledgeList(
                  //         title: snapshot.data[1]['title'],
                  //       ),
                  //     ),
                  //   );
                  // } else {
                  //   _Direction();
                  // }
                },
              ),
              MenuGridItem(
                title: snapshot.data[2]['title'] != ''
                    ? snapshot.data[2]['title']
                    : '',
                imageUrl: snapshot.data[2]['imageUrl'],
                subTitle: '',
                isCenter: false,
                isPrimaryColor: true,
                nav: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReporterMain(
                        title: snapshot.data[2]['title'],
                      ),
                    ),
                  );
                  // if (checkDirection) {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => ReporterMain(
                  //         title: snapshot.data[2]['title'],
                  //       ),
                  //     ),
                  //   );
                  // } else {
                  //   _showDialogDirection();
                  // }
                },
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Container();
        } else {
          return Container();
        }
      },
    );
  }

  _buildGridMenu2() {
    return FutureBuilder<dynamic>(
      future: _futureMenu, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return Row(
            children: [
              MenuGridItem(
                title: snapshot.data[3]['title'] != ''
                    ? snapshot.data[3]['title']
                    : '',
                imageUrl: snapshot.data[3]['imageUrl'],
                subTitle: '',
                isCenter: false,
                isPrimaryColor: true,
                nav: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WarningList(
                        title: snapshot.data[3]['title'],
                      ),
                    ),
                  );
                  // if (checkDirection) {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => WarningList(
                  //         title: snapshot.data[3]['title'],
                  //       ),
                  //     ),
                  //   );
                  // } else {
                  //   _showDialogDirection();
                  // }
                },
              ),
              MenuGridItem(
                title: snapshot.data[4]['title'] != ''
                    ? snapshot.data[4]['title']
                    : '',
                imageUrl: snapshot.data[4]['imageUrl'],
                subTitle: '',
                isCenter: true,
                isPrimaryColor: true,
                nav: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WelfareList(
                        title: snapshot.data[4]['title'],
                      ),
                    ),
                  );
                  // if (checkDirection) {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => WelfareList(
                  //         title: snapshot.data[4]['title'],
                  //       ),
                  //     ),
                  //   );
                  // } else {
                  //   _showDialogDirection();
                  // }
                },
              ),
              MenuGridItem(
                title: snapshot.data[5]['title'] != ''
                    ? snapshot.data[5]['title']
                    : '',
                imageUrl: snapshot.data[5]['imageUrl'],
                subTitle: '',
                isCenter: false,
                isPrimaryColor: true,
                nav: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsList(
                        title: snapshot.data[5]['title'],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Container();
        } else {
          return Container();
        }
      },
    );
  }

  _buildRotation() {
    return CarouselRotation(
      model: _futureRotation,
      nav: (String path, String action, dynamic model, String code) {
        if (action == 'out') {
          launchInWebViewWithJavaScript(path);
        } else if (action == 'in') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CarouselForm(
                code: code,
                model: model,
                url: mainBannerApi,
                urlGallery: bannerGalleryApi,
              ),
            ),
          );
        }
      },
    );
  }

  _buildPrivilegeMenu() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 3, bottom: 3),
      child: FutureBuilder<dynamic>(
        future: _futureMenu, // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return ButtonMenuFull(
              title: snapshot.data[7]['title'] != ''
                  ? snapshot.data[7]['title']
                  : '',
              imageUrl: snapshot.data[7]['imageUrl'],
              model: _futureMenu,
              subTitle: 'สำหรับสมาชิก',
              nav: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrivilegeMain(
                      title: snapshot.data[7]['title'],
                      fromPolicy: false,
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Container();
          } else {
            return Container();
          }
        },
      ),
    );
  }

  _buildContactMenu() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 3, bottom: 3),
      child: FutureBuilder<dynamic>(
        future: _futureMenu, // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return ButtonMenuFull(
              title: snapshot.data[6]['title'] != ''
                  ? snapshot.data[6]['title']
                  : '',
              imageUrl: snapshot.data[6]['imageUrl'],
              model: _futureMenu,
              subTitle: 'สำหรับสมาชิก',
              nav: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactListCategory(
                      title: snapshot.data[6]['title'],
                    ),
                  ),
                );
                // if (checkDirection) {
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => ContactListCategory(
                //         title: snapshot.data[6]['title'],
                //       ),
                //     ),
                //   );
                // } else {
                //   _showDialogDirection();
                // }
              },
            );
          } else if (snapshot.hasError) {
            return Container();
          } else {
            return Container();
          }
        },
      ),
    );
  }

  _buildPoiMenu() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 3, bottom: 3),
      child: FutureBuilder<dynamic>(
        future: _futureMenu, // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return ButtonMenuFull(
              title: snapshot.data[8]['title'] != ''
                  ? snapshot.data[8]['title']
                  : '',
              imageUrl: snapshot.data[8]['imageUrl'],
              model: _futureMenu,
              subTitle: 'สำหรับสมาชิก',
              nav: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PoiList(
                      title: snapshot.data[8]['title'],
                      latLng: latLng,
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Container();
          } else {
            return Container();
          }
        },
      ),
    );
  }

  _buildPollMenu() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 3, bottom: 3),
      child: FutureBuilder<dynamic>(
        future: _futureMenu, // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return ButtonMenuFull(
              title: snapshot.data[9]['title'] != ''
                  ? snapshot.data[9]['title']
                  : '',
              imageUrl: snapshot.data[9]['imageUrl'],
              model: _futureMenu,
              subTitle: 'สำหรับสมาชิก',
              nav: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PollList(
                      title: snapshot.data[9]['title'],
                    ),
                  ),
                );
                // if (checkDirection) {
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => PollList(
                //         title: snapshot.data[9]['title'],
                //       ),
                //     ),
                //   );
                // } else {
                //   _showDialogDirection();
                // }
              },
            );
          } else if (snapshot.hasError) {
            return Container();
          } else {
            return Container();
          }
        },
      ),
    );
  }

  _buildFooter() {
    return Container(
      // height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
      child: Image.asset(
        'assets/background/background_mics_webuilds.png',
        fit: BoxFit.cover,
      ),
    );
  }

  _read() async {
    // print('-------------start response------------');

    _getLocation();

    //read profile
    profileCode = (await storage.read(key: 'profileCode2'))!;
    if (profileCode != '') {
      setState(() {
        _futureProfile = postDio(profileReadApi, {"code": profileCode});
      });
      _futureMenu = postDio('${menuApi}read', {'limit': 10});
      _futureBanner = postDio('${mainBannerApi}read', {'limit': 10});
      _futureRotation = postDio('${mainRotationApi}read', {'limit': 10});
      _futureMainPopUp = postDio('${mainPopupHomeApi}read', {'limit': 10});
      _futureAboutUs = postDio('${aboutUsApi}read', {});

      _futureVerifyTicket = postDio(getNotpaidTicketListApi,
          {"createBy": "createBy", "updateBy": "updateBy"});
      // getMainPopUp();
      // _getLocation();
      // print('-------------end response------------');
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => LoginPage(
            title: '',
          ),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  getMainPopUp() async {
    var result =
        await post('${mainPopupHomeApi}read', {'skip': 0, 'limit': 100});

    if (result.length > 0) {
      var valueStorage = await storage.read(key: 'mainPopupDDPM');
      var dataValue;
      if (valueStorage != null) {
        dataValue = json.decode(valueStorage);
      } else {
        dataValue = null;
      }

      var now = DateTime.now();
      DateTime date = DateTime(now.year, now.month, now.day);

      if (dataValue != null) {
        var index = dataValue.indexWhere(
          (c) =>
              // c['username'] == userData.username &&
              c['date'].toString() ==
                  DateFormat("ddMMyyyy").format(date).toString() &&
              c['boolean'] == "true",
        );

        if (index == -1) {
          this.setState(() {
            hiddenMainPopUp = false;
          });
          return showDialog(
            barrierDismissible: false, // close outside
            context: context,
            builder: (_) {
              return WillPopScope(
                onWillPop: () {
                  return Future.value(false);
                },
                child: MainPopupDialog(
                  model: _futureMainPopUp,
                  type: 'mainPopup',
                  url: '',
                  urlGallery: '',
                  username: '',
                ),
              );
            },
          );
        } else {
          this.setState(() {
            hiddenMainPopUp = true;
          });
        }
      } else {
        this.setState(() {
          hiddenMainPopUp = false;
        });
        return showDialog(
          barrierDismissible: false, // close outside
          context: context,
          builder: (_) {
            return WillPopScope(
              onWillPop: () {
                return Future.value(false);
              },
              child: MainPopupDialog(
                model: _futureMainPopUp,
                type: 'mainPopup',
                url: '',
                urlGallery: '',
                username: '',
              ),
            );
          },
        );
      }
    }
  }

  void _onRefresh() async {
    // getCurrentUserData();
    _read();

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
    // _refreshController.loadComplete();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    print('🔍 กำลังตรวจสอบสิทธิ์ GPS...');

    // ✅ 1. เช็คว่า GPS เปิดอยู่หรือไม่
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("❌ กรุณาเปิด GPS ก่อนใช้งาน");
      return;
    }

    // ✅ 2. ตรวจสอบสิทธิ์ GPS
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("❌ ผู้ใช้ปฏิเสธสิทธิ์ Location");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("❌ ผู้ใช้ปฏิเสธถาวร ต้องไปเปิดที่ Settings");
      openAppSettings(); // เปิดหน้า Settings ให้ผู้ใช้
      return;
    }

    try {
      // ✅ 3. ดึงพิกัดปัจจุบัน
      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.best,
      );

      print("📍 พิกัดที่ได้: ${position.latitude}, ${position.longitude}");

      // ✅ 4. แปลงพิกัดเป็นชื่อสถานที่
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        print("🏙️ ตำแหน่ง: ${place.administrativeArea}, ${place.country}");

        setState(() {
          latLng = LatLng(position.latitude, position.longitude);
          currentLocation = (placemarks.isNotEmpty &&
                  placemarks.first.administrativeArea != null)
              ? placemarks.first.administrativeArea!
              : "ไม่ทราบที่อยู่";
        });
      } else {
        print("❌ ไม่พบข้อมูลสถานที่จากพิกัดนี้");
      }
    } catch (e) {
      print("❌ เกิดข้อผิดพลาด: $e");
    }
  }
}
