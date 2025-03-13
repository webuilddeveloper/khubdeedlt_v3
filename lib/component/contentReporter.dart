import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as GMap;
import 'package:url_launcher/url_launcher.dart';
import 'package:weconnect/component/gallery_view.dart';
import 'package:weconnect/shared/api_provider.dart';
import 'package:weconnect/shared/extension.dart';

class ContentReporter extends StatefulWidget {
  ContentReporter({
    super.key,
    this.code,
    this.url,
    this.model,
    this.urlGallery,
  });

  final String? code;
  final String? url;
  final dynamic model;
  final String? urlGallery;

  @override
  _ContentReporter createState() => _ContentReporter();
}

class _ContentReporter extends State<ContentReporter> {
  Future<dynamic>? _futureModel;

  // String _urlShared = '';
  List urlImage = [];
  List<ImageProvider> urlImageProvider = [];

  Completer<GMap.GoogleMapController> _mapController = Completer();

  @override
  void initState() {
    super.initState();
    _futureModel =
        post(widget.url!, {'skip': 0, 'limit': 1, 'code': widget.code});

    readGallery();
    // sharedApi();
  }

  Future<dynamic> readGallery() async {
    final result =
        await postObjectData('m/Reporter/gallery/read', {'code': widget.code});

    if (result['status'] == 'S') {
      List data = [];
      List<ImageProvider> dataPro = [];

      for (var item in result['objectData']) {
        data.add(item['imageUrl']);

        dataPro.add(item['imageUrl'] != null
            ? NetworkImage(item['imageUrl'])
            : NetworkImage(""));
      }
      setState(() {
        urlImage = data;
        urlImageProvider = dataPro;
      });
    }
  }

  // Future<dynamic> sharedApi() async {
  //   final result = await postObjectData('configulation/shared/read',
  //       {'skip': 0, 'limit': 1, 'code': widget.code});

  //   if (result['status'] == 's') {
  //     setState(() {
  //       _urlShared = result['objectData']['description'].toString();
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _futureModel, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>

        if (snapshot.hasData) {
          // setState(() {
          //   urlImage = [snapshot.data[0].imageUrl];
          // });
          return myContentReporter(
            snapshot.data[0],
          ); //   return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          // return Container();
          return myContentReporter(
            widget.model,
          );
          // return myContentReporter(widget.model);
        }
      },
    );
  }

  myContentReporter(dynamic model) {
    List image = [];
    List<ImageProvider> imagePro = [];
    return ListView(
      shrinkWrap: true, // 1st add
      physics: ClampingScrollPhysics(), // 2nd
      children: [
        Container(
          // width: 500.0,
          color: Color(0xFFFFFFF),
          child: GalleryView(
            imageUrl: [...image, ...urlImage],
            imageProvider: [...imagePro, ...urlImageProvider],
          ),
        ),
        Container(
          // color: Colors.green,
          padding: EdgeInsets.only(
            right: 10.0,
            left: 10.0,
          ),
          margin: EdgeInsets.only(right: 50.0, top: 10.0),
          child: Text(
            '${model['title']}',
            style: TextStyle(
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
                    backgroundImage: '${model['imageUrlCreateBy']}' != null
                        ? NetworkImage('${model['imageUrlCreateBy']}')
                        : null,
                    // child: Image.network(
                    //     '${snapshot.data[0]['imageUrlCreateBy']}'),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${model['firstName']} ${model['lastName']}',
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Sarabun',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              dateStringToDate(model['createDate']) + ' | ',
                              style: TextStyle(
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
        Padding(
          padding: const EdgeInsets.only(
            right: 10,
            left: 10,
          ),
          child: new Html(
              data: model['description'],
              onLinkTap: (url, context, attributes) {
                // ignore: deprecated_member_use
                launch(url!);
              }),

          // HtmlView(
          //   data: model['description'],
          //   scrollable:
          //       false, //false to use MarksownBody and true to use Marksown
          // ),
        ),
        Container(
          height: 250,
          width: double.infinity,
          child: googleMap(
              model['latitude'] != ''
                  ? double.parse(model['latitude'])
                  : 13.8462512,
              model['longitude'] != ''
                  ? double.parse(model['longitude'])
                  : 100.5234803),
        ),
      ],
    );
  }

  googleMap(double lat, double lng) {
    return GMap.GoogleMap(
      myLocationEnabled: true,
      compassEnabled: true,
      tiltGesturesEnabled: false,
      mapType: GMap.MapType.normal,
      initialCameraPosition: GMap.CameraPosition(
        target: GMap.LatLng(lat, lng),
        zoom: 16,
      ),
      // gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
      //   new Factory<OneSequenceGestureRecognizer>(
      //     () => new EagerGestureRecognizer(),
      //   ),
      // ].toSet(),
      onMapCreated: (GMap.GoogleMapController controller) {
        _mapController.complete(controller);
      },
      // onTap: _handleTap,
      markers: <GMap.Marker>[
        GMap.Marker(
          markerId: GMap.MarkerId('1'),
          position: GMap.LatLng(lat, lng),
          icon: GMap.BitmapDescriptor.defaultMarkerWithHue(
              GMap.BitmapDescriptor.hueRed),
        ),
      ].toSet(),
    );
  }
}
