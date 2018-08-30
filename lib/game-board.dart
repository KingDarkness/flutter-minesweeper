import 'package:flutter/material.dart';
import 'package:flutter_minesweeper/game-control.dart';
import 'package:flutter_minesweeper/bidirectional-scroll-view.dart';
import 'dart:math';
import 'dart:async';

class BoardState {
  int rows = 12;
  int columns = 20;
  int mines = 50;
  bool _gameOver = false;
  bool _won = false;
  int mineRemaining = 0;
  int realMineRemaining = 0;
  int covered = 0;
  Stopwatch stopwatch = new Stopwatch();

  List<List<ControlState>> gameState = [[]];
  List<Map> minePosition = [];

  BoardState ({int rows, int columns, int mines}) {
    if(rows != null) this.rows = rows;
    if(columns != null) this.columns = columns;
    if(mines != null) this.mines = mines;
  }

  initState() {
    this.covered = this.rows * this.columns - this.mines;
    this.realMineRemaining = this.mines;
    this.mineRemaining = this.mines;
    this.generateState();
    this.generateMine();
    this.caculatorMine();
    this.stopwatch.isRunning ? this.stopwatch.reset() : this.stopwatch.start();
  }

  generateState() {
    this.gameState = List.generate(
        this.rows, (int row) =>
    new List<ControlState>.generate(
        this.columns, (int col) => new ControlState(row, col)
    )
    );
  }

  generateMine() {
    var randomer = new Random();
    int mineRemaining = this.mines;

    while (mineRemaining > 0) {
      int row = randomer.nextInt(this.rows);
      int col = randomer.nextInt(this.columns);
      this.setValue(row, col, ControlState.MINE);
      this.minePosition.add({ "row": row, "col": col});
      mineRemaining--;
    }
  }

  int getValue(int row, int col) {
    return this.gameState[row][col].value;
  }

  ControlState getState(int row, int col) {
    return this.gameState[row][col];
  }

  void setValue(int row, int col, int value) {
    this.gameState[row][col].value = value;
  }

  bool inBoard(int x, int y) {
    return x >= 0 && x < this.rows && y >= 0 && y < this.columns;
  }

  void caculatorMine() {
    for (var row = 0; row < this.rows; row++) {
      for (var col = 0; col < this.columns; col++) {
        if (!this.isMine(row, col)) this.setValue(row, col, this.countMine(row, col));
      }
    }
  }

  int countMine (int x, int y) {
    int count = 0;
    count += this.isMine(x + 1, y) ? 1 : 0;
    count += this.isMine(x - 1, y) ? 1 : 0;
    count += this.isMine(x, y + 1) ? 1 : 0;
    count += this.isMine(x, y - 1) ? 1 : 0;
    count += this.isMine(x + 1, y + 1) ? 1 : 0;
    count += this.isMine(x + 1, y - 1) ? 1 : 0;
    count += this.isMine(x - 1, y + 1) ? 1 : 0;
    count += this.isMine(x - 1, y - 1) ? 1 : 0;
    return count;
  }

  void open (int x, int y) {
    if (this.isGameOver()) return;
    if (!this.inBoard(x, y)) return;
    if (this.getState(x, y).isFlag()) return;
    if (this.getState(x, y).isOpened()) return;
    this.getState(x, y).open();
    if (this.getValue(x, y) == ControlState.MINE) {
      this.gameOver();
      return;
    } else {
      this.covered--;
      if(this.covered == 0) this.won();
    }
    if (this.getValue(x, y) > 0) return;
    this.open(x + 1, y);
    this.open(x - 1, y);
    this.open(x, y + 1);
    this.open(x, y - 1);
    this.open(x + 1, y + 1);
    this.open(x + 1, y - 1);
    this.open(x - 1, y + 1);
    this.open(x - 1, y - 1);
  }

  void flag (ControlState control) {
    if (control.isOpened()) return;
    bool isFlag = control.toggleFlag();
    if (isFlag) {
      this.mineRemaining--;
      if (this.isMine(control.x, control.y)) this.realMineRemaining--;
    } else {
      this.mineRemaining++;
      if (this.isMine(control.x, control.y)) this.realMineRemaining++;
    }
    if (this.realMineRemaining == 0) this.won();
  }

  bool isMine (int x, int y) {
    return this.inBoard(x, y) && this.getValue(x, y) == ControlState.MINE;
  }

  bool isWon () {
    return this._won;
  }

  bool isGameOver () {
    return this._gameOver;
  }

  void won () {
    this._won = true;
    this.minePosition.forEach((pos) {
      if (!this.getState(pos["row"], pos["col"]).isFlag()) this.flag(this.getState(pos["row"], pos["col"]));
    });
    this.stopwatch.stop();
  }

  void gameOver () {
    this._gameOver = true;
    this.stopwatch.stop();
  }

  int getActiveSecond () {
    return this.stopwatch.elapsedMilliseconds ~/ 1000;
  }
}

class GameBoard extends StatefulWidget {
  GameBoard({Key key, this.rows, this.columns, this.mines}) : super(key: key);
  final int rows;
  final int columns;
  final int mines;

  BoardState state;

  @override
  _GameBoard createState() => new _GameBoard();
}

class _GameBoard extends State<GameBoard> {
  @override
  void initState() {
    super.initState();
    this.startGame();
    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {});
    });
  }

  void startGame() {
    setState(() {
      widget.state = new BoardState(rows: widget.rows, columns: widget.columns, mines: widget.mines);
      widget.state.initState();
    });
  }

  List<Widget> buildBoard(BoardState state) {
    List<Widget> board = [];
    for(var row = 0; row < state.rows; row++) {
      board.add(
        new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: this.buildColumns(row, state)
        )
      );
    }
    return board;
  }

  List<Widget> buildColumns(int row, BoardState state) {
    List<Widget> columns = [];
    for(var col = 0; col < state.columns; col++) {
      columns.add(
        new GameControl(
          state: state.getState(row, col),
          tap: (control) {
            if (state.isGameOver()) return;
            setState(() {
              state.open(control.x, control.y);
            });
          },
            longTap: (control) {
              if (state.isGameOver()) return;
              setState(() {
                state.flag(control);
              });
            }
        ),
      );
    }
    return columns;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.black,
          title: new IconButton(
              icon: new Icon(Icons.insert_emoticon, color: widget.state.isGameOver() ? Colors.red : widget.state.isWon() ? Colors.green : Colors.white,),
              onPressed: () {
                this.startGame();
              },
              color: Colors.white,
          ),
          leading: new Center(child: new Text(widget.state.mineRemaining.toString())),
          actions: <Widget>[
            new Container(child: new Center(child: new Text(widget.state.getActiveSecond().toString())), padding: const EdgeInsets.only(right: 20.0),)
          ],
        ),
        body: new BidirectionalScrollView(
            child: new Center(
              child: new Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: this.buildBoard(widget.state),
              ),
            )
        )
    );
  }
}