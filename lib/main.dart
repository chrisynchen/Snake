import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:snake/floor_painter.dart';
import 'package:snake/pair.dart';

void main() => runApp(SnakeApp());

class SnakeApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: Scaffold(body: SnakeHome()));
  }
}

class SnakeHome extends StatefulWidget {
  SnakeHome({Key key}) : super(key: key);

  @override
  _SnakeHomeState createState() => _SnakeHomeState();
}

class _SnakeHomeState extends State<SnakeHome> with WidgetsBindingObserver {
  final _cellSize = 16;

  List<List<int>> _cells;

  Queue snakeQueue = Queue<Pair<int, int>>();

  StreamSubscription _observable;

  Direction _currentDirection = Direction.RIGHT;

  Pair<int, int> currentHead;

  Pair<int, int> _eatPoint;

  double _widgetWidth;

  double _widgetHeight;

  GameStatus status = GameStatus.START;

  @override
  void initState() {
    print("initState");
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _observable =
        Observable.periodic(Duration(milliseconds: 500), (_) => snakeQueue)
            .skipWhile((Queue snakeQueue) => snakeQueue.length <= 0)
            .listen(_updateView);
  }

  @override
  void dispose() {
    print("dispose");
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      print("paused");
      _observable.pause();
    } else if (state == AppLifecycleState.resumed) {
      print("resumed");
      _observable.resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      title: Text('Snake Game By Chris'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.pause),
          onPressed: () {
            status = GameStatus.PAUSE;
            _observable.pause();
          },
        ),
        IconButton(
          icon: Icon(Icons.play_arrow),
          onPressed: () {
            status = GameStatus.PAUSE;
            _observable.resume();
          },
        ),
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () {
            status = GameStatus.RESET;
            _observable.pause();
            _reset();
            status = GameStatus.START;
            _observable.resume();
          },
        )
      ],
    );

    if (_widgetWidth == null || _widgetHeight == null) {
      _widgetWidth = MediaQuery.of(context).size.width;
      _widgetHeight = MediaQuery.of(context).size.height -
          MediaQuery.of(context).padding.top -
          appBar.preferredSize.height;
    }

    FloorPainter painter = _initPainter(context, _widgetWidth, _widgetHeight);

    return Scaffold(
        appBar: appBar,
        body: GestureDetector(
            onTapDown: (TapDownDetails details) => _onTapDown(context, details),
            child: Container(
                width: _widgetWidth,
                height: _widgetHeight,
                child: CustomPaint(painter: painter))));
  }

  void _onTapDown(BuildContext context, TapDownDetails details) {
    var xCell = details.globalPosition.dx / _cellSize;
    var yCell = details.globalPosition.dy / _cellSize;
    if (_currentDirection == Direction.UP ||
        _currentDirection == Direction.DOWN) {
      if (currentHead.left - xCell > 0) {
        _currentDirection = Direction.LEFT;
      } else {
        _currentDirection = Direction.RIGHT;
      }
    } else {
      if ((currentHead.right - yCell) < 0) {
        _currentDirection = Direction.DOWN;
      } else {
        _currentDirection = Direction.UP;
      }
    }
  }

  void _updateView(Queue snakeQueue) {
    if (_currentDirection == Direction.LEFT) {
      currentHead = Pair<int, int>(currentHead.left - 1, currentHead.right);
    } else if (_currentDirection == Direction.RIGHT) {
      currentHead = Pair<int, int>(currentHead.left + 1, currentHead.right);
    } else if (_currentDirection == Direction.UP) {
      currentHead = Pair<int, int>(currentHead.left, currentHead.right - 1);
    } else if (_currentDirection == Direction.DOWN) {
      currentHead = Pair<int, int>(currentHead.left, currentHead.right + 1);
    }

    setState(() {
      //generate eat point
      _eatPoint = _getEatPoint();

      _cells[_eatPoint.left][_eatPoint.right] = 1;
      _cells[currentHead.left][currentHead.right] = 1;
      snakeQueue.add(currentHead);

      if (currentHead == _eatPoint) {
        _eatPoint = null;
      } else {
        Pair first = snakeQueue.removeFirst();
        _cells[first.left][first.right] = 0;
      }
    });
  }

  FloorPainter _initPainter(
      BuildContext context, double widgetWidth, double widgetHeight) {
    if (_cells == null) {
      _reset();
    }

    return FloorPainter(
        _cellSize / 2, Colors.blue, _cells, _cellSize, _eatPoint);
  }

  Pair<int, int> _getEatPoint() {
    if (_eatPoint != null) return _eatPoint;

    var random = Random();
    var row = random.nextInt(_cells.length);
    var column = random.nextInt(_cells[0].length);
    return Pair<int, int>(row, column);
  }

  void _reset() {
    int _columnSize = (_widgetWidth / _cellSize).round();
    int _rowSize = (_widgetHeight / _cellSize).round();

    var middleRow = _rowSize ~/ 2;
    var middleColumn = _columnSize ~/ 2;

    _initQueue(middleRow, middleColumn);

    _cells = List<List<int>>.generate(
        _columnSize,
        (i) => List<int>.generate(_rowSize, (j) {
              return 0;
            }));

    _cells[middleColumn - 2][middleRow] = 1;
    _cells[middleColumn - 1][middleRow] = 1;
    _cells[middleColumn][middleRow] = 1;

    Pair last = snakeQueue.last;
    currentHead = Pair<int, int>(last.left, last.right);
    _eatPoint = null;

    _currentDirection = Direction.RIGHT;
  }

  void _initQueue(int middleRow, int middleColumn) {
    snakeQueue.clear();
    snakeQueue.add(Pair<int, int>(middleColumn - 2, middleRow));
    snakeQueue.add(Pair<int, int>(middleColumn - 1, middleRow));
    snakeQueue.add(Pair<int, int>(middleColumn, middleRow));
  }
}

enum Direction { LEFT, RIGHT, UP, DOWN }

enum GameStatus { START, PAUSE, RESET }
