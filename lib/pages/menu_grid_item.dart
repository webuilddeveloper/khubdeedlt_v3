import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MenuGridItem extends StatefulWidget {
  MenuGridItem(
      {super.key,
      this.title,
      this.imageUrl,
      this.isPrimaryColor,
      this.nav,
      @required this.isCenter,
      this.subTitle = ''});

  final Function? nav;
  final bool? isPrimaryColor;
  final String? imageUrl;
  final String? title;
  final String? subTitle;
  final bool? isCenter;

  @override
  _MenuGridItem createState() => _MenuGridItem();
}

class _MenuGridItem extends State<MenuGridItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Expanded(
      flex: 3,
      child: InkWell(
        onTap: () {
          widget.nav!();
        },
        child: Container(
          color: Colors.transparent,
          height: (width / 3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.only(top: (height * 1) / 100),
                padding: EdgeInsets.all((width * 3) / 100),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      !widget.isPrimaryColor!
                          ? const Color(0xFFFF7900)
                          : const Color(0xFF000070),
                      !widget.isPrimaryColor!
                          ? const Color(0xFFFF7900)
                          : const Color(0xFF000070),
                    ],
                    begin: Alignment.topLeft,
                    end: const Alignment(1, 0.0),
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
                height: (width * 20) / 100,
                width: (width * 20) / 100,
                child: Image.network(
                  widget.imageUrl!,
                  fit: BoxFit.fill,
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Text(
                      widget.title!,
                      style: const TextStyle(
                        fontSize: 12.00,
                        fontFamily: 'Sarabun',
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  widget.subTitle != null
                      ? Text(
                          widget.subTitle != null ? widget.subTitle! : '',
                          style: const TextStyle(
                            fontSize: 13.0,
                            fontFamily: 'Sarabun',
                            // color: Theme.of(context).primaryColorDark,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        )
                      : const SizedBox(height: 0.0),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
