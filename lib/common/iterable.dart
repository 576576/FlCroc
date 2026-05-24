extension IterableExt<T> on Iterable<T> {
  Iterable<T> separated(T separator) sync* {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return;
    yield iterator.current;
    while (iterator.moveNext()) {
      yield separator;
      yield iterator.current;
    }
  }

  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
