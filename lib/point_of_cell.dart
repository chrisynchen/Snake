class PointOfCell {
  PointOfCell(this.row, this.column, {this.pointType});

  PointType pointType = PointType.SNAKE_POINT;
  final int row;
  final int column;

  @override
  String toString() => 'PointOfCell[$row, $column]';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PointOfCell &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          column == other.column;

  @override
  int get hashCode => row.hashCode ^ column.hashCode;
}

enum PointType { SNAKE_POINT, EAT_POINT, BLOCKERS }
