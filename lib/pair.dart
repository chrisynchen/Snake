class Pair<T1, T2> {
  Pair(this.left, this.right);

  final T1 left;
  final T2 right;

  @override
  String toString() => 'Pair[$left, $right]';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pair<T1, T2> &&
          runtimeType == other.runtimeType &&
          left == other.left &&
          right == other.right;

  @override
  int get hashCode => left.hashCode ^ right.hashCode;
}
