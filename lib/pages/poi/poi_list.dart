import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:weconnect/component/key_search.dart';
import 'package:weconnect/component/tab_category.dart';
import 'package:weconnect/pages/blank_page/blank_data.dart';
import 'package:weconnect/pages/blank_page/blank_loading.dart';
import 'package:weconnect/pages/poi/poi_form.dart';
import 'package:weconnect/shared/extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:weconnect/component/header.dart';
import 'package:weconnect/pages/poi/poi_list_vertical.dart';
import 'package:weconnect/shared/api_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PoiList extends StatefulWidget {
  PoiList({Key? key, required this.title, required this.latLng})
      : super(key: key);
  final String title;
  final LatLng latLng;

  @override
  _PoiList createState() => _PoiList();
}

class _PoiList extends State<PoiList> {
  Completer<GoogleMapController> _mapController = Completer();

  late PoiListVertical gridView;
  final txtDescription = TextEditingController();
  bool hideSearch = true;
  String keySearch = '';
  String category = '';
  int _limit = 10;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  late Future<dynamic> _futureModel;
  late LatLngBounds initLatLngBounds;

  // ให้ initialize ค่านี้เพื่อป้องกัน null error
  double positionScroll = 0.0;
  bool showMap = true;
  bool _mapInitialized =
      false; // เพิ่มตัวแปรเพื่อติดตามว่า map ถูก initialize แล้วหรือไม่

  late Future<dynamic> futureCategory;
  List<dynamic> listTemp = [
    {
      'code': '',
      'title': '',
      'imageUrl': '',
      'createDate': '',
      'userList': [
        {'imageUrl': '', 'firstName': '', 'lastName': ''}
      ]
    }
  ];
  bool showLoadingItem = true;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtDescription.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // ป้องกัน error จาก latitude/longitude ที่อาจเป็น null หรือค่าไม่ถูกต้อง
    try {
      _futureModel = post('${poiApi}read', {
        'skip': 0,
        'limit': 10,
        'latitude': widget.latLng.latitude,
        'longitude': widget.latLng.longitude
      });

      // ปรับปรุงการสร้าง LatLngBounds ให้ถูกต้อง
      double lat = widget.latLng.latitude;
      double lng = widget.latLng.longitude;

      // ต้องแน่ใจว่า southwest มีค่าน้อยกว่า northeast เสมอ
      double southwestLat = lat - 0.2;
      double southwestLng = lng - 0.15;
      double northeastLat = lat + 0.1;
      double northeastLng = lng + 0.1;

      initLatLngBounds = LatLngBounds(
          southwest: LatLng(southwestLat, southwestLng),
          northeast: LatLng(northeastLat, northeastLng));
    } catch (e) {
      print("Error initializing map data: $e");
      // กำหนดค่าเริ่มต้นเพื่อป้องกัน crash
      initLatLngBounds =
          LatLngBounds(southwest: LatLng(0, 0), northeast: LatLng(1, 1));

      // ถ้าเกิด error ให้แสดงหน้า list แทน map
      showMap = false;

      _futureModel = Future.value([]);
    }

    futureCategory = postCategory(
      '${poiCategoryApi}read',
      {'skip': 0, 'limit': 100},
    );

    gridView = PoiListVertical(
      model: _futureModel,
    );
  }

  void _onLoading() async {
    setState(
      () {
        _limit = _limit + 10;
        _futureModel = post('${poiApi}read', {
          'skip': 0,
          'limit': _limit,
          'category': category,
          "keySearch": keySearch,
          'latitude': widget.latLng.latitude,
          'longitude': widget.latLng.longitude
        });
        gridView = PoiListVertical(
          model: _futureModel,
        );
      },
    );

    await Future.delayed(Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

  void goBack() async {
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: header(
        context,
        goBack,
        title: 'จุดบริการ',
        isButtonRight: true,
        imageRightButton:
            showMap ? 'assets/icons/menu.png' : 'assets/icons/location.png',
        rightButton: () => setState(
          () {
            showMap = !showMap;
            _limit = 10;
          },
        ),
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification overScroll) {
          overScroll.disallowIndicator();
          return false;
        },
        child: showMap ? _buildMap() : _buildList(),
      ),
    );
  }

// show map
  SlidingUpPanel _buildMap() {
    double _panelHeightOpen = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).padding.top + 50);
    double _panelHeightClosed = 90;
    return SlidingUpPanel(
      maxHeight: _panelHeightOpen,
      minHeight: _panelHeightClosed,
      parallaxEnabled: true,
      parallaxOffset: .5,
      body: Container(
        padding: EdgeInsets.only(
            bottom:
                _panelHeightClosed + MediaQuery.of(context).padding.top + 50),
        child: googleMap(_futureModel),
      ),
      panelBuilder: (sc) => _panel(sc),
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(5.0), topRight: Radius.circular(5.0)),
      onPanelSlide: (double pos) => {
        setState(
          () {
            positionScroll = pos;
          },
        ),
      },
    );
  }

  Widget googleMap(Future<dynamic> modelData) {
    return FutureBuilder<dynamic>(
      future: modelData,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // เพิ่มการจัดการกรณี error และ loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print("Error loading map data: ${snapshot.error}");
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 50, color: Colors.red),
                SizedBox(height: 10),
                Text("เกิดข้อผิดพลาดในการโหลดแผนที่",
                    style: TextStyle(fontFamily: 'Sarabun')),
                TextButton(
                  onPressed: () => setState(() {
                    _futureModel = post('${poiApi}read', {
                      'skip': 0,
                      'limit': 10,
                      'latitude': widget.latLng.latitude,
                      'longitude': widget.latLng.longitude
                    });
                  }),
                  child:
                      Text("ลองใหม่", style: TextStyle(fontFamily: 'Sarabun')),
                )
              ],
            ),
          );
        } else if (snapshot.hasData) {
          List<Marker> _markers = <Marker>[];

          try {
            if (snapshot.data != null && snapshot.data.length > 0) {
              for (var item in snapshot.data) {
                try {
                  // ใช้ try-catch เพื่อจัดการกรณีที่ข้อมูล lat/lng ไม่ถูกต้อง
                  double lat = double.parse(item['latitude'] ?? "0.0");
                  double lng = double.parse(item['longitude'] ?? "0.0");

                  if (lat != 0.0 && lng != 0.0) {
                    _markers.add(
                      Marker(
                        markerId:
                            MarkerId(item['code'] ?? DateTime.now().toString()),
                        position: LatLng(lat, lng),
                        infoWindow: InfoWindow(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PoiForm(
                                  code: item['code'],
                                  model: item,
                                  urlComment: '',
                                  url: '',
                                  urlGallery: '',
                                ),
                              ),
                            );
                          },
                          title: item['title']?.toString() ?? "",
                        ),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed,
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  print("Error creating marker: $e");
                  // ข้ามไปสร้าง marker ตัวถัดไป
                  continue;
                }
              }
            }
          } catch (e) {
            print("Error processing map data: $e");
          }

          return GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            tiltGesturesEnabled: false,
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: widget.latLng,
              zoom: 15,
            ),
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            ].toSet(),
            onMapCreated: (GoogleMapController controller) {
              try {
                if (!_mapInitialized) {
                  // ใช้ try-catch เพื่อป้องกัน error จากการเรียกใช้ animation
                  try {
                    controller.moveCamera(
                      CameraUpdate.newLatLngBounds(
                        initLatLngBounds,
                        5.0,
                      ),
                    );
                  } catch (e) {
                    print("Error moving camera: $e");
                  }

                  try {
                    controller.animateCamera(CameraUpdate.newCameraPosition(
                        CameraPosition(target: widget.latLng, zoom: 15)));
                  } catch (e) {
                    print("Error animating camera: $e");
                  }

                  _mapController.complete(controller);
                  _mapInitialized = true;
                }
              } catch (e) {
                print("Error initializing map: $e");
              }
            },
            markers: _markers.isNotEmpty
                ? _markers.toSet()
                : <Marker>[]
                    .toSet(), // ไม่ต้องสร้าง default marker ที่ 0,0 ถ้าไม่มีข้อมูล
          );
        } else {
          return Center(
              child: Text("ไม่พบข้อมูลแผนที่",
                  style: TextStyle(fontFamily: 'Sarabun')));
        }
      },
    );
  }

  LatLngBounds _createBounds() {
    try {
      List<LatLng> positions = [];
      positions.add(widget.latLng);

      final southwestLat = positions
          .map((p) => p.latitude)
          .reduce((value, element) => value < element ? value : element);
      final southwestLon = positions
          .map((p) => p.longitude)
          .reduce((value, element) => value < element ? value : element);
      final northeastLat = positions
          .map((p) => p.latitude)
          .reduce((value, element) => value > element ? value : element);
      final northeastLon = positions
          .map((p) => p.longitude)
          .reduce((value, element) => value > element ? value : element);

      return LatLngBounds(
          southwest: LatLng(southwestLat, southwestLon),
          northeast: LatLng(northeastLat, northeastLon));
    } catch (e) {
      print("Error creating bounds: $e");
      // ส่งคืนค่า default bounds เพื่อป้องกัน crash
      return LatLngBounds(
          southwest: LatLng(
              widget.latLng.latitude - 0.1, widget.latLng.longitude - 0.1),
          northeast: LatLng(
              widget.latLng.latitude + 0.1, widget.latLng.longitude + 0.1));
    }
  }

  Widget _panel(ScrollController sc) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: SmartRefresher(
        enablePullDown: false,
        enablePullUp: true,
        footer: const ClassicFooter(
          loadingText: ' ',
          canLoadingText: ' ',
          idleText: ' ',
          idleIcon: Icon(
            Icons.arrow_upward,
            color: Colors.transparent,
          ),
        ),
        controller: _refreshController,
        onLoading: _onLoading,
        child: ListView(
          controller: sc,
          children: <Widget>[
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 10),
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey,
                ),
                height: 4,
              ),
            ),
            Container(
              height: 35,
              width: double.infinity,
              alignment: Alignment.center,
              child: const Text(
                'จุดบริการ',
                style: TextStyle(
                  fontFamily: 'Sarabun',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              child: gridView,
            ),
          ],
        ),
      ),
    );
  }
// end show map

// -------------------------------

// show content
  Container _buildList() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          SizedBox(height: 5),
          CategorySelector(
            model: futureCategory,
            onChange: (String val) {
              setData(val, keySearch);
            },
          ),
          SizedBox(height: 5),
          KeySearch(
            show: hideSearch,
            onKeySearchChange: (String val) {
              setData(category, val);
            },
          ),
          SizedBox(height: 10),
          Expanded(
            child: buildList(),
          )
        ],
      ),
    );
  }

  // ส่วนที่เหลือคงเดิม...

  FutureBuilder buildList() {
    return FutureBuilder<dynamic>(
      future: _futureModel,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          if (showLoadingItem) {
            return blankListData(context, height: 300);
          } else {
            return refreshList(listTemp);
          }
        } else if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            return Container(
              alignment: Alignment.center,
              height: 200,
              child: Text(
                'ไม่พบข้อมูล',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Sarabun',
                  color: Colors.grey,
                ),
              ),
            );
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  showLoadingItem = false;
                  listTemp = snapshot.data;
                });
              }
            });
            return refreshList(snapshot.data);
          }
        } else if (snapshot.hasError) {
          return InkWell(
            onTap: () {
              setState(() {
                _futureModel = post('${poiApi}read', {
                  'skip': 0,
                  'limit': _limit,
                  'category': category,
                  "keySearch": keySearch,
                  'latitude': widget.latLng.latitude,
                  'longitude': widget.latLng.longitude
                });
                futureCategory = futureCategory;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, size: 50.0, color: Colors.blue),
                Text('ลองใหม่อีกครั้ง', style: TextStyle(fontFamily: 'Sarabun'))
              ],
            ),
          );
        } else {
          return refreshList(listTemp);
        }
      },
    );
  }

  SmartRefresher refreshList(List<dynamic> model) {
    return SmartRefresher(
      enablePullDown: false,
      enablePullUp: true,
      footer: ClassicFooter(
        loadingText: ' ',
        canLoadingText: ' ',
        idleText: ' ',
        idleIcon: Icon(Icons.arrow_upward, color: Colors.transparent),
      ),
      controller: _refreshController,
      onLoading: _onLoading,
      child: ListView.builder(
        physics: ScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: model.length,
        itemBuilder: (context, index) {
          return card(context, model[index]);
        },
      ),
    );
  }

  Container card(BuildContext context, dynamic model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PoiForm(
                code: model['code'],
                model: model,
                url: '',
                urlComment: '',
                urlGallery: '',
              ),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 0,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  margin: EdgeInsets.only(bottom: 5.0),
                  width: 600,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(5.0),
                            topRight: const Radius.circular(5.0),
                          ),
                          color: Colors.grey,
                        ),
                        constraints: BoxConstraints(
                          minHeight: 200,
                          maxHeight: 200,
                          minWidth: double.infinity,
                        ),
                        child: model['imageUrl'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(5.0),
                                  topRight: const Radius.circular(5.0),
                                ),
                                child: Image.network(
                                  '${model['imageUrl']}',
                                  fit: BoxFit.cover,
                                ))
                            : BlankLoading(
                                height: 200,
                              ),
                      ),
                      Container(
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: const Radius.circular(5.0),
                            bottomRight: const Radius.circular(5.0),
                          ),
                          color: Color(0xFFFFFFFF),
                        ),
                        padding: EdgeInsets.all(5.0),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 8),
                              child: Column(
                                children: [
                                  Text(
                                    '${model['title'] ?? ""}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Sarabun',
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.normal,
                                      color: Color(0xFF4D4D4D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 8),
                              child: Column(
                                children: [
                                  Text(
                                    'วันที่ ' +
                                        dateStringToDate(
                                            model['createDate'] ?? ""),
                                    style: TextStyle(
                                      color: Color(0xFF8F8F8F),
                                      fontFamily: 'Sarabun',
                                      fontSize: 15.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  setData(String categorych, String keySearkch) {
    setState(
      () {
        if (keySearch != "") {
          showLoadingItem = true;
        }
        keySearch = keySearkch;
        category = categorych;
        _limit = 10;
        _futureModel = post('${poiApi}read', {
          'skip': 0,
          'limit': _limit,
          'category': category,
          "keySearch": keySearch,
          'latitude': widget.latLng.latitude,
          'longitude': widget.latLng.longitude
        });
      },
    );
  }
}
