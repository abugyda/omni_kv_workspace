import '../core/kv_converter.dart';

/// Converts a List of items, applying the [elementConverter] to each item.
final class ListKvConverter<T> implements KvConverter<List<T>?, Object?> {
  const ListKvConverter(this.elementConverter);

  final KvConverter<T?, Object?> elementConverter;

  @override
  Object? encode(List<T>? value) {
    if (value == null) return null;
    return value.map(elementConverter.encode).toList();
  }

  @override
  List<T>? decode(Object? value) {
    if (value == null) return null;
    final list = value as List;
    return list.map((e) => elementConverter.decode(e) as T).toList();
  }
}

/// Converts a Set of items, safely storing them as a List in the database.
final class SetKvConverter<T> implements KvConverter<Set<T>?, Object?> {
  const SetKvConverter(this.elementConverter);

  final KvConverter<T?, Object?> elementConverter;

  @override
  Object? encode(Set<T>? value) {
    if (value == null) return null;
    return value.map(elementConverter.encode).toList();
  }

  @override
  Set<T>? decode(Object? value) {
    if (value == null) return null;
    final list = value as List;
    return list.map((e) => elementConverter.decode(e) as T).toSet();
  }
}
