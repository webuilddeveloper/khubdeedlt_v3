import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weconnect/component/gallery_view.dart';
import 'package:weconnect/shared/api_provider.dart';

import 'package:weconnect/shared/extension.dart';

// ignore: must_be_immutable
class ContentCarousel extends StatefulWidget {
  ContentCarousel({
    Key? key,
    this.code,
    this.url,
    this.model,
    this.urlGallery,
  }) : super(key: key);

  final String? code;
  final String? url;
  final dynamic model;
  final String? urlGallery;

  @override
  _ContentCarousel createState() => _ContentCarousel();
}

class _ContentCarousel extends State<ContentCarousel> {
  late Future<dynamic> _futureModel;

  // String _urlShared = '';
  List urlImage = [];
  List<ImageProvider> urlImageProvider = [];

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
        await postObjectData(widget.urlGallery!, {'code': widget.code});

    if (result['status'] == 'S') {
      List data = [];
      List<ImageProvider> dataPro = [];

      for (var item in result['objectData']) {
        data.add(item['imageUrl']);

        dataPro.add(NetworkImage(item['imageUrl']));
      }
      setState(() {
        urlImage = data;
        urlImageProvider = dataPro;
      });
    }
  }

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
          return myContent(
            snapshot.data[0],
          ); //   return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return myContent(
            widget.model,
          );
          // return myContent(widget.model);
        }
      },
    );
  }

  myContent(dynamic model) {
    List image = [model['imageUrl']];
    List<ImageProvider> imagePro = [NetworkImage(model['imageUrl'])];
    return ListView(
      shrinkWrap: true, // 1st add
      physics: const ClampingScrollPhysics(), // 2nd
      children: [
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
              fontSize: 20,
              fontFamily: 'Sarabun',
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
                    backgroundImage:
                        NetworkImage('${model['imageUrlCreateBy']}'),
                    // child: Image.network(
                    //     '${snapshot.data[0]['imageUrlCreateBy']}'),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${model['createBy']}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontFamily: 'Sarabun',
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              dateStringToDate(model['createDate']),
                              style: const TextStyle(
                                fontSize: 10,
                                fontFamily: 'Sarabun',
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
          color: const Color(0x0fffffff),
          child: GalleryView(
            imageUrl: [...image, ...urlImage],
            imageProvider: [...imagePro, ...urlImageProvider],
          ),
        ),
        Container(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(
            right: 10,
            left: 10,
          ),
          child: Html(
              data: '${model['description']}',
              onLinkTap: (url, context, attributes) {
                // ignore: deprecated_member_use
                launch(url!);
              }),
        ),
      ],
    );
  }
}
