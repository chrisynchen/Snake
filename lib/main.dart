import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:snake/floor_painter.dart';
import 'package:snake/pair.dart';

///
///Can custom your property here.
///
const CELL_SIZE = 30;
const GAME_WIDTH = 360;
const GAME_HEIGHT = 600;
const SNAKE_COLOR = Colors.blue;
const EAT_COLOR = Colors.pink;
const SHAPE = Shape.CIRCLE;

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

  Queue snakeQueue = Queue<Pair<int, int>>();

  StreamSubscription _observable;

  Direction _currentDirection = Direction.RIGHT;

  Pair<int, int> currentHead;

  Pair<int, int> _eatPoint;

  double _widgetWidth;

  double _widgetHeight;

  int speedDuration = 300;

  final onTapSubject = PublishSubject<TapDownDetails>();

  @override
  void initState() {
    print("initState");
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _observable = Observable.periodic(
            Duration(milliseconds: speedDuration), (_) => snakeQueue)
        .skipWhile((Queue snakeQueue) => snakeQueue.length <= 0)
        .listen(_updateView);

    onTapSubject
        .distinct()
        .throttleTime(const Duration(milliseconds: 300))
        .listen(_onTapDown);
  }

  @override
  void dispose() {
    print("dispose");
    onTapSubject.close();
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
      _widgetWidth = GAME_WIDTH <= 0 || GAME_WIDTH > screenWidth
          ? screenWidth
          : GAME_WIDTH.toDouble();
      _widgetHeight = GAME_HEIGHT <= 0 || GAME_HEIGHT > screenHeight
          ? screenHeight
          : GAME_HEIGHT.toDouble();
    }

    FloorPainter painter = _initPainter(context, _widgetWidth, _widgetHeight);

    return Scaffold(
        appBar: appBar,
        backgroundColor: Colors.black,
        body: Center(
            child: GestureDetector(
                onTapDown: (TapDownDetails details) =>
                    onTapSubject.add(details),
                child: Container(
                  color: Colors.white,
                    width: _widgetWidth,
                    height: _widgetHeight,
                    child: CustomPaint(painter: painter)))));
  }

  void _onTapDown(TapDownDetails details) {
    var xCell = details.localPosition.dx / CELL_SIZE;
    var yCell = details.localPosition.dy / CELL_SIZE;

    var diffX = currentHead.left - xCell + 1;
    var diffY = currentHead.right - yCell + 1;
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
    if (_currentDirection == Direction.LEFT) {
      currentHead = Pair<int, int>(currentHead.left - 1, currentHead.right);
    } else if (_currentDirection == Direction.RIGHT) {
      currentHead = Pair<int, int>(currentHead.left + 1, currentHead.right);
    } else if (_currentDirection == Direction.UP) {
      currentHead = Pair<int, int>(currentHead.left, currentHead.right - 1);
    } else if (_currentDirection == Direction.DOWN) {
      currentHead = Pair<int, int>(currentHead.left, currentHead.right + 1);
    }

    if (!_isValidStatus()) {
      return;
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

    return FloorPainter(SNAKE_COLOR, EAT_COLOR, _cells, CELL_SIZE, _eatPoint,
        shape: SHAPE, direction: _currentDirection);
  }

  Pair<int, int> _getEatPoint() {
    if (_eatPoint != null) return _eatPoint;

    var random = Random();
    var row = random.nextInt(_cells.length);
    var column = random.nextInt(_cells[0].length);
    return Pair<int, int>(row, column);
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

  bool _isValidStatus() {
    if (currentHead.left < 0 ||
        currentHead.left >= _cells.length ||
        currentHead.right < 0 ||
        currentHead.right >= _cells[0].length) {
      _updateGameByStatus(GameStatus.PAUSE);
      return false;
    }

    return true;
  }
}

enum GameStatus { START, PAUSE, RESET }
