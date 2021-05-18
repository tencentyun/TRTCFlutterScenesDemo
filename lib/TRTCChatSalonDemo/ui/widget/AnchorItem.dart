import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trtc_scenes_demo/utils/TxUtils.dart';
import '../../../i10n/localization_intl.dart';

class AnchorItem extends StatefulWidget {
  AnchorItem({
    Key? key,
    this.userName = "",
    this.userImgUrl = "",
    this.isAdministrator = false,
    this.onKickOutUser,
    this.roomOwnerId,
    this.isMute = false,
    this.userId,
    this.isVolumeUpdate = false,
  }) : super(key: key);

  final String userName;
  final String userImgUrl;
  final bool isAdministrator;
  final int? roomOwnerId;
  final Function? onKickOutUser;
  final bool isMute;
  final String? userId;
  final bool isVolumeUpdate;
  @override
  State<StatefulWidget> createState() => _AnchorItemState();
}

class _AnchorItemState extends State<AnchorItem>
    with SingleTickerProviderStateMixin {
  handleShowKickOutUser(context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setState) => Container(
                color: Color.fromRGBO(19, 35, 63, 1),
                height: 160,
                child: Column(
                  children: [
                    ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        if (widget.onKickOutUser != null) {
                          widget.onKickOutUser?.call();
                        }
                      },
                      title: Text(
                        Languages.of(context)!.kickMic,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromRGBO(235, 240, 250, 1),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          height: 2,
                          width: MediaQuery.of(context).size.width,
                          color: Color.fromRGBO(0, 9, 22, 1),
                          child: Text(''),
                        ),
                      ],
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      title: Text(
                        Languages.of(context)!.cancelText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromRGBO(235, 240, 250, 0.5),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                )));
      },
    );
  }

  @override
  initState() {
    super.initState();
  }

  _isCanShowKicUser(userId) async {
    String loginUserId = await TxUtils.getLoginUserId();
    if (!widget.isAdministrator &&
        widget.roomOwnerId.toString() == loginUserId) {
      this.handleShowKickOutUser(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  widget.isVolumeUpdate
                      ? InkWell(
                          onTap: () {
                            this._isCanShowKicUser(widget.userId);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: new Border.all(
                                color: Color.fromRGBO(15, 169, 104, 1),
                                width: 2,
                              ),
                              image: DecorationImage(
                                image: NetworkImage(widget.userImgUrl),
                                fit: BoxFit.fitWidth,
                              ),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            width: 80,
                            height: 80,
                          ),
                        )
                      : InkWell(
                          onTap: () {
                            this._isCanShowKicUser(widget.userId);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(widget.userImgUrl),
                                fit: BoxFit.fitWidth,
                              ),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            width: 80,
                            height: 80,
                          ),
                        ),
                  Positioned(
                    left: 55,
                    top: 55,
                    child: InkWell(
                      onTap: () {},
                      child: widget.isMute
                          ? Image.asset(
                              "assets/images/sound_off.png",
                              height: 24,
                            )
                          : Text(''),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Container(
                height: 10,
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                child: widget.isAdministrator
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/Administrator.png",
                            height: 14,
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 5),
                            constraints: BoxConstraints(
                              maxWidth: 61,
                            ),
                            child: Text(
                              widget.userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        widget.userName,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
