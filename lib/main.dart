import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:snake/floor_painter.dart';
import 'package:snake/point_of_cell.dart';

///
///Can custom your property here.
///
const CELL_SIZE = 30;
const GAME_WIDTH_MOBILE = 360;
const GAME_HEIGHT_MOBILE = 600;
const GAME_WIDTH_OTHERS = 1920;
const GAME_HEIGHT_OTHERS = 1080;
const SNAKE_COLOR = Colors.blue;
const EAT_COLOR = Colors.pink;
const SHAPE = Shape.CIRCLE;
const DEFAULT_TIME_PER_FEET = 300;
const MINIMUM_TIME_PER_FEET = DEFAULT_TIME_PER_FEET / 10;

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
  List<List<int>> _cells;

  Queue _snakeQueue = Queue<PointOfCell>();

  StreamSubscription _observable;

  Direction _currentDirection = Direction.RIGHT;

  PointOfCell _currentHead;

  PointOfCell _eatPoint;

  double _widgetWidth;

  double _widgetHeight;

  int _timePerFeet = DEFAULT_TIME_PER_FEET;

  final _onTapSubject = PublishSubject<TapDownDetails>();

  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    print("initState");
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _observable = Observable.periodic(
            Duration(milliseconds: _timePerFeet), (_) => _snakeQueue)
        .skipWhile((Queue snakeQueue) => snakeQueue.length <= 0)
        .listen(_updateView);

    _onTapSubject
        .distinct()
        .throttleTime(Duration(milliseconds: 300))
        .listen(_onTapDown);
  }

  @override
  void dispose() {
    print("dispose");
    _onTapSubject.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      print("paused");
      _updateGameByStatus(GameStatus.PAUSE);
    } else if (state == AppLifecycleState.resumed) {
      print("resumed");
      _updateGameByStatus(GameStatus.START);
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
            _updateGameByStatus(GameStatus.PAUSE);
          },
        ),
        IconButton(
          icon: Icon(Icons.play_arrow),
          onPressed: () {
            _updateGameByStatus(GameStatus.START);
          },
        ),
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () {
            _updateGameByStatus(GameStatus.RESET);
          },
        )
      ],
    );

    if (_widgetWidth == null || _widgetHeight == null) {
      var screenWidth = MediaQuery.of(context).size.width;
      var screenHeight = MediaQuery.of(context).size.height -
          MediaQuery.of(context).padding.top -
          appBar.preferredSize.height;

      // TODO need refine this because web not support dart.io for now.
      var gameDefaultWidth =
          screenWidth < 1080 ? GAME_WIDTH_MOBILE : GAME_WIDTH_OTHERS;
      var gameDefaultHeight =
          screenWidth < 1080 ? GAME_HEIGHT_MOBILE : GAME_HEIGHT_OTHERS;
      _widgetWidth = gameDefaultWidth <= 0 || gameDefaultWidth > screenWidth
          ? screenWidth
          : gameDefaultWidth.toDouble();
      _widgetHeight = gameDefaultHeight <= 0 || gameDefaultHeight > screenHeight
          ? screenHeight
          : gameDefaultHeight.toDouble();
      print('platform: ${Theme.of(context).platform}');
    }

    FloorPainter painter = _initPainter(context, _widgetWidth, _widgetHeight);

    return Scaffold(
        key: _scaffoldKey,
        appBar: appBar,
        backgroundColor: Colors.black,
        body: Center(
            child: GestureDetector(
                onTapDown: (TapDownDetails details) =>
                    _onTapSubject.add(details),
                child: Container(
                    color: Colors.white,
                    width: _widgetWidth,
                    height: _widgetHeight,
                    child: CustomPaint(painter: painter)))));
  }

  void _onTapDown(TapDownDetails details) {
    var xCell = details.localPosition.dx / CELL_SIZE;
    var yCell = details.localPosition.dy / CELL_SIZE;

    var diffX = _currentHead.row - xCell + 1;
    var diffY = _currentHead.column - yCell + 1;
    if (_currentDirection == Direction.UP ||
        _currentDirection == Direction.DOWN) {
      if (diffX > 1) {
        _currentDirection = Direction.LEFT;
      } else if (diffX < 0) {
        _currentDirection = Direction.RIGHT;
      }
    } else {
      if (diffY > 1) {
        _currentDirection = Direction.UP;
      } else if (diffY < 0) {
        _currentDirection = Direction.DOWN;
      }
    }
  }

  void _updateView(Queue snakeQueue) {
    var nextHead;
    if (_currentDirection == Direction.LEFT) {
      nextHead = PointOfCell(_currentHead.row - 1, _currentHead.column);
    } else if (_currentDirection == Direction.RIGHT) {
      nextHead = PointOfCell(_currentHead.row + 1, _currentHead.column);
    } else if (_currentDirection == Direction.UP) {
      nextHead = PointOfCell(_currentHead.row, _currentHead.column - 1);
    } else if (_currentDirection == Direction.DOWN) {
      nextHead = PointOfCell(_currentHead.row, _currentHead.column + 1);
    }

    if (!_isValidStatus(nextHead)) {
      return;
    }

    setState(() {
      _currentHead = nextHead;
      //generate eat point
      _eatPoint = _getEatPoint();

      _cells[_eatPoint.row][_eatPoint.column] = 1;
      _cells[_currentHead.row][_currentHead.column] = 1;
      snakeQueue.add(_currentHead);

      if (_currentHead == _eatPoint) {
        _eatPoint = null;
        if (snakeQueue.length % 5 == 0) {
          _addSpeed();
          _showSnackBar('Speed up!!!!!');
        }
      } else {
        PointOfCell first = snakeQueue.removeFirst();
        _cells[first.row][first.column] = 0;
      }
    });
  }

  FloorPainter _initPainter(
      BuildContext context, double widgetWidth, double widgetHeight) {
    if (_cells == null) {
      _reset();
    }

    return FloorPainter(SNAKE_COLOR, EAT_COLOR, _cells, CELL_SIZE, _eatPoint,
        shape: SHAPE, direction: _currentDirection);
  }

  PointOfCell _getEatPoint() {
    if (_eatPoint != null) return _eatPoint;

    var random = Random();
    var row = random.nextInt(_cells.length);
    var column = random.nextInt(_cells[0].length);
    final newEatPoint = PointOfCell(row, column);
    if (_snakeQueue.contains(newEatPoint)) {
      // need generate again since it's snake body.
      return _getEatPoint();
    } else {
      return newEatPoint;
    }
  }

  void _reset() {
    int _columnSize = (_widgetWidth / CELL_SIZE).round();
    int _rowSize = (_widgetHeight / CELL_SIZE).round();

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

    PointOfCell last = _snakeQueue.last;
    _currentHead = PointOfCell(last.row, last.column);
    _eatPoint = null;

    _currentDirection = Direction.RIGHT;
  }

  void _addSpeed() {
    _observable.cancel();
    _observable = Observable.periodic(
            Duration(milliseconds: _timePerFeet), (_) => _snakeQueue)
        .skipWhile((Queue snakeQueue) => snakeQueue.length <= 0)
        .listen(_updateView);
    final expectedTimePerFeet =
        _timePerFeet - (DEFAULT_TIME_PER_FEET / 10).floor();
    _timePerFeet = expectedTimePerFeet > 0 ? expectedTimePerFeet : _timePerFeet;
  }

  void _initQueue(int middleRow, int middleColumn) {
    _snakeQueue.clear();
    _snakeQueue.add(PointOfCell(middleColumn - 2, middleRow));
    _snakeQueue.add(PointOfCell(middleColumn - 1, middleRow));
    _snakeQueue.add(PointOfCell(middleColumn, middleRow));
  }

  void _updateGameByStatus(GameStatus status) {
    switch (status) {
      case GameStatus.START:
        _observable.resume();
        break;

      case GameStatus.PAUSE:
        if (!_observable.isPaused) {
          _observable.pause();
        }
        break;

      case GameStatus.RESET:
        if (!_observable.isPaused) {
          _observable.pause();
        }
        _reset();
        _observable.resume();
        break;
    }
  }

  void _showSnackBar(String text) {
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  bool _isValidStatus(PointOfCell nextHead) {
    if (nextHead.row < 0 ||
        nextHead.row >= _cells.length ||
        nextHead.column < 0 ||
        nextHead.column >= _cells[0].length ||
        _snakeQueue.contains(nextHead)) {
      _updateGameByStatus(GameStatus.PAUSE);
      _showSnackBar('Game over. Please with try reload button');
      return false;
    }

    return true;
  }
}

enum GameStatus { START, PAUSE, RESET }
