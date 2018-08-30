import 'package:flutter/material.dart';
import 'package:flutter_minesweeper/game-board.dart';

void main() => runApp(new MineSweeper());

class MineSweeper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Minesweeper',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
//      home: new GameBoard(columns: 10, rows: 10, mines: 10),
      home: new GameMenu()
    );
  }
}

class GameMenu extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          backgroundColor: Colors.black,
          title: new Text("Choose a difficult")
      ),
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.symmetric(vertical: 5.0),
                child: new ButtonTheme(
                  minWidth: 300.0,
                  child: new FlatButton(
                      color: Colors.green,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GameBoard(mines: 10, columns: 8, rows: 8)),
                        );
                      },
                      textColor: Colors.white,
                      child: new Text("Beginning")
                  ),
                )
              )
            ],
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.symmetric(vertical: 5.0),
                child: new ButtonTheme(
                  minWidth: 300.0,
                  child: new FlatButton(
                      color: Colors.blue,
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GameBoard(mines: 40, columns: 16, rows: 16)),
                        );
                      },
                      child: new Text("Intermediate")
                  ),
                )
              )
            ],
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.symmetric(vertical: 5.0),
                child: new ButtonTheme(
                  minWidth: 300.0,
                  child: new FlatButton(
                    color: Colors.red,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GameBoard(mines: 99, columns: 30, rows: 16)),
                      );
                    },
                    child: new Text("Expert"),
                    textColor: Colors.white,
                  ),
                )
              )
            ],
          ),
        ],
      ),
    );
  }
}
