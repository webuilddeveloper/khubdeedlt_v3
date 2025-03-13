import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

import '../../component/button_close_back.dart';
import '../../component/gallery_view.dart';
import '../../component/link_url_out.dart';
import '../../shared/api_provider.dart';
import '../../shared/extension.dart';
import '../blank_page/blank_loading.dart';

class PrivilegeForm extends StatefulWidget {
  const PrivilegeForm({super.key, @required this.code, this.model});
  final String? code;
  final dynamic model;

  @override
  // ignore: library_private_types_in_public_api
  _PrivilegeDetailPageState createState() => _PrivilegeDetailPageState();
}

class _PrivilegeDetailPageState extends State<PrivilegeForm> {
  // _PrivilegeDetailPageState({});

  Future<dynamic>? _futureModel;
  // String _urlShared = '';
  String? code;
  List urlImage = [];
  List<ImageProvider> urlImageProvider = [];

  @override
  void initState() {
    super.initState();
    code = widget.code;
    _futureModel = post(
        '${privilegeApi}read', {'skip': 0, 'limit': 1, 'code': widget.code});
  }

  Future<dynamic> readGallery() async {
    final result =
        await postObjectData('m/news/gallery/read', {'code': widget.code});

    if (result['status'] == 'S') {
      List data = [];
      List<ImageProvider> dataPro = [];

      for (var item in result['objectData']) {
        data.add(item['imageUrl']);

        dataPro.add(item['imageUrl'] != null
            ? NetworkImage(item['imageUrl'])
            : const NetworkImage(""));
      }
      setState(() {
        urlImage = data;
        urlImageProvider = dataPro;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent,
    // ));

    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<dynamic>(
        future: _futureModel, // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          // AsyncSnapshot<Your object type>

          if (snapshot.hasData) {
            print(
                '------------------${snapshot.data.toString()}----------------');
            return myContent(snapshot.data[0]);
          } else {
            if (widget.model != null) {
              return myContent(widget.model);
            } else {
              return const BlankLoading();
            }
          }
        },
      ),
    );
  }

  myContent(dynamic model) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    List image = ['${model['imageUrl']}'];
    List<ImageProvider> imagePro = [
      model['imageUrl'] != null
          ? NetworkImage(model['imageUrl'])
          : const NetworkImage("")
    ];
    // return Container();
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView(
        shrinkWrap: true,
        children: [
          Stack(
            children: [
              Container(
                child: ListView(
                  shrinkWrap: true, // 1st add
                  physics: const ClampingScrollPhysics(), // 2nd
                  children: [
                    Container(
                      // width: 500.0,
                      color: const Color(0xFFFFFFF),
                      child: GalleryView(
                        imageUrl: [...image, ...urlImage],
                        imageProvider: [...imagePro, ...urlImageProvider],
                      ),
                    ),
                    Container(
                      // color: Colors.green,
                      padding: const EdgeInsets.only(
                        right: 10.0,
                        left: 10.0,
                      ),
                      margin: const EdgeInsets.only(right: 50.0, top: 10.0),
                      child: Text(
                        '${model['title']}',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontFamily: 'Sarabun',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 10,
                            left: 10,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: model['imageUrlCreateBy'] !=
                                        null
                                    ? NetworkImage(model['imageUrlCreateBy'])
                                    : null,
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      model['createBy'],
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'Sarabun',
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          dateStringToDate(
                                                  model['createDate']) +
                                              ' | ',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontFamily: 'Sarabun',
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        Text(
                                          'เข้าชม ' '${model['view']}' +
                                              ' ครั้ง',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontFamily: 'Sarabun',
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        right: 10,
                        left: 10,
                      ),
                      child: Html(
                          data: model['description'],
                          onLinkTap: (url, context, attributes) {
                            // ignore: deprecated_member_use
                            launch(url!);
                          }),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 80.0),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              border:
                                  Border.all(color: const Color(0xFFFF7514))),
                          child: MaterialButton(
                            minWidth: MediaQuery.of(context).size.width,
                            onPressed: () {
                              launchURL(model['linkUrl']);
                            },
                            child: const Text(
                              'อ่านข่าวต้นฉบับ',
                              style: TextStyle(
                                color: Color(0xFFFF7514),
                                fontFamily: 'Sarabun',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                top: statusBarHeight + 5,
                child: Container(
                  child: buttonCloseBack(context),
                ),
              ),
            ],
            // overflow: Overflow.clip,
          ),
        ],
      ),
    );
  }
}
