import 'dart:convert';

import '../core/kv_converter.dart';

final class JsonKvConverter<T> implements KvConverter<T?, Object?> {
  const JsonKvConverter.toObject() : _kind = _JsonKind.object;

  const JsonKvConverter.toList() : _kind = _JsonKind.list;

  final _JsonKind _kind;

  @override
  Object? encode(T? value) => value == null ? null : jsonEncode(value);

  @override
  T? decode(Object? value) {
    if (value == null) return null;

    final decoded = switch (_kind) {
      _JsonKind.object => switch (value) {
        final Map<dynamic, dynamic> map => map.cast<String, Object?>(),
        final String string =>
          (jsonDecode(string) as Map<dynamic, dynamic>).cast<String, Object?>(),
        _ => throw FormatException('Expected JSON object, got $value'),
      },

      _JsonKind.list => switch (value) {
        final List<dynamic> list => list.cast<Object?>(),
        final String string => (jsonDecode(string) as List<dynamic>).cast<Object?>(),
        _ => throw FormatException('Expected JSON list, got $value'),
      },
    };

    return decoded as T;
  }
}

enum _JsonKind { object, list }
