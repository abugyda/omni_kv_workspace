import '../utilities/kv_exception.dart';
import 'kv_converter.dart';

/// Strongly typed logical key used by the `KeyValue` facade.
///
/// OmniKV uses one null rule across all bundled adapters: writing `null`
/// removes the key. A missing nullable key may still resolve to a `null`
/// default when `T` itself is nullable.
class KvKey<T> {
  const KvKey(
    this.id, {
    required T defaultValue,
    this.namespace,
    this.converter,
  }) : defaultValue = defaultValue,
       defaultBuilder = null,
       hasDefaultValue = true;

  const KvKey.builder(
    this.id, {
    required this.defaultBuilder,
    this.namespace,
    this.converter,
  }) : defaultValue = null,
       hasDefaultValue = true;

  const KvKey.required(
    this.id, {
    this.namespace,
    this.converter,
  }) : defaultValue = null,
       defaultBuilder = null,
       hasDefaultValue = false;

  final String id;
  final String? namespace;
  final T? defaultValue;
  final T Function()? defaultBuilder;
  final bool hasDefaultValue;
  final KvConverter<T?, Object?>? converter;

  /// Fully qualified logical key name, for example `app.launch_count`.
  String get name => namespace != null && namespace!.isNotEmpty ? '$namespace.$id' : id;

  /// Converts a typed value to the logical adapter value.
  Object? encode(T value) {
    if (value == null) return null;
    final converter = this.converter;
    return converter == null ? value : converter.encode(value);
  }

  /// Decodes a logical adapter value and applies missing-value semantics.
  T decode(Object? value, {required bool isPresent}) {
    if (!isPresent) {
      if (defaultBuilder != null) return defaultBuilder!();
      if (hasDefaultValue) return defaultValue as T;
      throw MissingValueKvException(name);
    }

    // Bundled adapters define a null write as removal. A present key yielding
    // null therefore indicates an adapter/codec contract violation rather than
    // a stored null value.
    if (value == null) {
      throw TypeKvException('Adapter returned null for present key "$name".');
    }

    try {
      final converter = this.converter;
      return converter == null ? value as T : converter.decode(value) as T;
    } on KvException {
      rethrow;
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(
        TypeKvException(
          'Failed to decode key "$name" as $T.',
          cause: error,
        ),
        stackTrace,
      );
    }
  }

  @override
  String toString() => 'KvKey<$T>($name)';
}
