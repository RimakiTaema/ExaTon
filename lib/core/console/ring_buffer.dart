/// Fixed-capacity buffer that keeps the newest [capacity] items.
///
/// Index 0 is the oldest kept item. [totalAdded] lets a list view keep a
/// stable key per line as old ones fall off.
class RingBuffer<T> {
  RingBuffer(this.capacity) : assert(capacity > 0), _items = List<T?>.filled(capacity, null);

  final int capacity;
  final List<T?> _items;
  int _start = 0;
  int _length = 0;
  int _totalAdded = 0;

  int get length => _length;
  bool get isEmpty => _length == 0;

  /// Count of items ever added, including evicted ones.
  int get totalAdded => _totalAdded;

  /// Sequence number of the item at [index] (stable across evictions).
  int sequenceOf(int index) => _totalAdded - _length + index;

  void add(T item) {
    final end = (_start + _length) % capacity;
    _items[end] = item;
    if (_length < capacity) {
      _length++;
    } else {
      _start = (_start + 1) % capacity;
    }
    _totalAdded++;
  }

  void addAll(Iterable<T> items) => items.forEach(add);

  T operator [](int index) {
    RangeError.checkValidIndex(index, this, 'index', _length);
    return _items[(_start + index) % capacity] as T;
  }

  void clear() {
    _items.fillRange(0, capacity, null);
    _start = 0;
    _length = 0;
  }

  List<T> toList() => [for (var i = 0; i < _length; i++) this[i]];
}
