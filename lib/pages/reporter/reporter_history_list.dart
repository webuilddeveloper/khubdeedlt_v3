import 'package:flutter/material.dart';
import 'package:weconnect/component/header.dart';
import 'package:weconnect/pages/reporter/reporter_history_list_vertical.dart';

import 'package:weconnect/shared/api_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ReporterHistoryList extends StatefulWidget {
  ReporterHistoryList({Key? key, this.title, this.username}) : super(key: key);

  final String? title;
  final String? username;

  @override
  _ReporterHistoryList createState() => _ReporterHistoryList();
}

class _ReporterHistoryList extends State<ReporterHistoryList> {
  late ReporterHistoryListVertical reporterHistory;
  bool hideSearch = true;
  final txtDescription = TextEditingController();
  late String keySearch;
  late String category;
  int _limit = 10;

  RefreshController _refreshController =
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

    reporterHistory = new ReporterHistoryListVertical(
      site: "DDPM",
      model: post('${reporterApi}read',
          {'skip': 0, 'limit': _limit, 'createBy': widget.username}),
      url: '${reporterApi}read',
      urlGallery: '${reporterGalleryApi}read',
    );
  }

  void _onLoading() async {
    setState(() {
      _limit = _limit + 10;

      reporterHistory = new ReporterHistoryListVertical(
        site: 'DDPM',
        model: post('${reporterApi}read',
            {'skip': 0, 'limit': _limit, 'createBy': widget.username}),
        url: '${reporterApi}read',
        urlGallery: '${reporterGalleryApi}read',
      );
    });

    await Future.delayed(Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

  void goBack() async {
    Navigator.pop(context);
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
            physics: ScrollPhysics(),
            shrinkWrap: true,
            // controller: _controller,
            children: [
              reporterHistory,
            ],
          ),
        ),
      ),
    );
  }
}
