import 'package:flutter/material.dart';

typedef void Callback (ControlState state);

class ControlState{
  static const MINE = 9;

  int value = 0;
  bool opened = false;
  bool flag = false;
  int x;
  int y;

  ControlState(int x, int y, {int value = 0, bool opened = false, bool flag = false}) {
    this.x = x;
    this.y = y;
    this.value = value;
    this.opened = opened;
    this.flag = flag;
  }

  bool isDisplay () {
    return this.isFlag() || this.isOpened();
  }

  bool isFlag () {
    return this.flag;
  }

  bool isOpened () {
    return this.opened;
  }

  bool isMine () {
    return this.value == MINE;
  }

  bool canClick () {
    return !(this.isFlag() || this.isOpened());
  }

  bool toggleFlag([bool state]) {
    if (state != null) {
      this.flag = state;
    } else {
      this.flag = !this.flag;
    }
    return this.flag;
  }

  void open() {
    if (!this.canClick()) return;
    this.opened = true;
  }
}

class GameControl extends StatefulWidget{
  GameControl({ Key key, this.state, this.tap, this.longTap }) : super(key: key);
  ControlState state;
  final Callback tap;
  final Callback longTap;

  @override
  _GameControl createState() => new _GameControl();

}

class _GameControl extends State<GameControl> {

  Widget buildClose () {
    return new Text("", style: new TextStyle(color: Colors.white));
  }

  Widget buildFlag () {
    return new Icon(Icons.outlined_flag, color: Colors.brown);
  }

  Widget buildMine () {
    return new Icon(Icons.brightness_7, color: Colors.red,);
  }

  Widget buildNumber (int value) {
    var colors = [
      Color(0x00000000),
      Color(int.parse("0x0000ca")).withOpacity(1.0),
      Color(int.parse("0x004c00")).withOpacity(1.0),
      Color(int.parse("0x970000")).withOpacity(1.0),
      Color(int.parse("0x00004c")).withOpacity(1.0),
      Color(int.parse("0x791f10")).withOpacity(1.0),
      Color(int.parse("0x00004c")).withOpacity(1.0),
      Color(int.parse("0x171714")).withOpacity(1.0),
      Color(int.parse("0x838383")).withOpacity(1.0)
    ];

    return new Text(value.toString(), style: new TextStyle(color: colors[value], fontWeight: FontWeight.bold));
  }

  Widget display (ControlState state) {
    if (state.isFlag()) return this.buildFlag();
    if (!state.isOpened()) return this.buildClose();
    if (state.isMine()) {
      return this.buildMine();
    } else {
      return this.buildNumber(state.value);
    }
  }

  Color getBackground (state) {
    return state.isDisplay() ? Color.fromRGBO(225, 225, 225, 1.0) : Color.fromRGBO(172, 172, 172, 1.0);
  }

  @override
  Widget build(BuildContext context) {

    return new GestureDetector(
        onTap: () {
          setState(() {
            widget.tap(widget.state);
          });
        },
        onLongPress: () {
          setState(() {
            widget.longTap(widget.state);
          });
        },
        child: new Container(
          child: new Center(
              child: this.display(widget.state)
          ),
          padding: const EdgeInsets.fromLTRB(3.0, 0.5, 3.0, 0.5),
          color: this.getBackground(widget.state),
          height: 30.0,
          width: 30.0,
          margin: const EdgeInsets.all(0.5),
        )
    );
  }
}