import 'package:flutter/material.dart';
import 'package:weconnect/component/button_close_back.dart';
import 'package:weconnect/component/comment.dart';
import 'package:weconnect/component/content.dart';
import 'package:weconnect/shared/api_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// ignore: must_be_immutable
class WelfareForm extends StatefulWidget {
  WelfareForm({
    Key? key,
    required this.url,
    required this.code,
    this.model,
    required this.urlComment,
    required this.urlGallery,
  }) : super(key: key);

  final String url;
  final String code;
  final dynamic model;
  final String urlComment;
  final String urlGallery;

  @override
  _WelfareForm createState() => _WelfareForm();
}

class _WelfareForm extends State<WelfareForm> {
  late Comment comment;
  late int _limit;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onLoading() async {
    setState(() {
      _limit = _limit + 10;

      comment = Comment(
        code: widget.code,
        url: welfareCommentApi,
        model: post('${welfareCommentApi}read',
            {'skip': 0, 'limit': _limit, 'code': widget.code}),
        limit: _limit,
      );
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

  @override
  void initState() {
    setState(() {
      _limit = 10;
    });

    comment = Comment(
      code: widget.code,
      url: welfareCommentApi,
      model: post('${welfareCommentApi}read',
          {'skip': 0, 'limit': _limit, 'code': widget.code}),
      limit: _limit,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.white,
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
            shrinkWrap: true,
            children: [
              Stack(
                children: [
                  Content(
                    pathShare: 'content/welfare/',
                    code: widget.code,
                    url: widget.url,
                    model: widget.model,
                    urlGallery: widget.urlGallery,
                  ),
                  Positioned(
                    right: 0,
                    top: statusBarHeight + 5,
                    child: Container(
                      child: buttonCloseBack(context),
                    ),
                  ),
                ],
              ),
              // ),
              widget.urlComment != '' ? comment : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
