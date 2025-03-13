import 'package:flutter/material.dart';
import 'package:weconnect/component/key_search.dart';
import 'package:weconnect/component/header.dart';
import 'package:weconnect/component/tab_category.dart';
import 'package:weconnect/pages/warning/warning_list_vertical.dart';
import 'package:weconnect/shared/api_provider.dart' as service;
import 'package:pull_to_refresh/pull_to_refresh.dart';

class WarningList extends StatefulWidget {
  WarningList({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _WarningList createState() => _WarningList();
}

class _WarningList extends State<WarningList> {
  late WarningListVertical warning;
  bool hideSearch = true;
  final txtDescription = TextEditingController();
  String? keySearch;
  String? category;
  int _limit = 10;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  // final ScrollController _controller = ScrollController();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtDescription.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // _controller.addListener(_scrollListener);
    super.initState();

    warning = new WarningListVertical(
      // warning = new WarningListVertical(
      site: "DDPM",
      model: service
          .post('${service.warningApi}read', {'skip': 0, 'limit': _limit}),
      url: '${service.warningApi}read',
      urlComment: '${service.warningCommentApi}read',
      urlGallery: '${service.warningGalleryApi}',
    );
  }

  void _onLoading() async {
    setState(() {
      _limit = _limit + 10;

      warning = WarningListVertical(
        site: 'DDPM',
        model: service.post('${service.warningApi}read', {
          'skip': 0,
          'limit': _limit,
          "keySearch": keySearch,
          'category': category
        }),
        url: '${service.warningApi}read',
        urlGallery: '${service.warningGalleryApi}',
      );
    });

    await Future.delayed(Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

  void goBack() async {
    Navigator.pop(context, false);
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => Menu(),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: header(context, goBack, title: widget.title!),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification overScroll) {
          overScroll.disallowIndicator();
          return false;
        },
        child: SmartRefresher(
          enablePullDown: false,
          enablePullUp: true,
          footer: const ClassicFooter(
            loadingText: ' ',
            canLoadingText: ' ',
            idleText: ' ',
            idleIcon: Icon(Icons.arrow_upward, color: Colors.transparent),
          ),
          controller: _refreshController,
          onLoading: _onLoading,
          child: ListView(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            children: [
              const SizedBox(height: 5),
              CategorySelector(
                model: service.postCategory(
                  '${service.warningCategoryApi}read',
                  {'skip': 0, 'limit': 100},
                ),
                onChange: (String val) {
                  setState(
                    () {
                      category = val;
                      warning = new WarningListVertical(
                        site: 'DDPM',
                        model: service.post('${service.warningApi}read', {
                          'skip': 0,
                          'limit': _limit,
                          "category": category,
                          "keySearch": keySearch
                        }),
                        url: '${service.warningApi}read',
                        urlGallery: '${service.warningGalleryApi}',
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 5),
              KeySearch(
                show: hideSearch,
                onKeySearchChange: (String val) {
                  // warningList(context, service.post('${service.warningApi}read', {'skip': 0, 'limit': 100,"keySearch": val}),'');
                  setState(
                    () {
                      keySearch = val;
                      warning = WarningListVertical(
                        site: 'DDPM',
                        model: service.post('${service.warningApi}read', {
                          'skip': 0,
                          'limit': _limit,
                          "keySearch": keySearch,
                          'category': category
                        }),
                        url: '${service.warningApi}read',
                        urlGallery: '${service.warningGalleryApi}',
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 10),
              warning,
            ],
          ),
        ),
      ),
    );
  }
}
