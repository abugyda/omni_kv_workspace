import 'dart:convert';

import '../core/kv_codec.dart';
import '../utilities/kv_exception.dart';

/// Wraps a [KvCodec] and encrypts its encoded values before persistence.
///
/// The encrypted payload contains a versioned JSON envelope so primitive,
/// list, and map values retain their encoded type instead of being flattened
/// through `toString()`.
///
/// [allowPlaintextFallback] is intended only for explicit migrations from an
/// unencrypted store. Corrupt data that already carries the OmniKV encrypted
/// marker never falls back to plaintext.
final class EncryptedKvCodec implements KvCodec {
  const EncryptedKvCodec({
    required this.delegate,
    required this.onEncrypt,
    required this.onDecrypt,
    this.allowPlaintextFallback = false,
  });

  static const _marker = 'omnikv:enc:v1:';

  final KvCodec delegate;
  final String Function(String payload) onEncrypt;
  final String Function(String payload) onDecrypt;
  final bool allowPlaintextFallback;

  @override
  bool get isScoped => delegate.isScoped;

  @override
  String storageKey(String logicalKey) => delegate.storageKey(logicalKey);

  @override
  String logicalKey(Object? storageKey) => delegate.logicalKey(storageKey);

  @override
  bool ownsKey(Object? storageKey) => delegate.ownsKey(storageKey);

  @override
  Object? encode(Object? value) {
    if (value == null) return null;

    final encoded = delegate.encode(value);
    if (encoded == null) return null;

    try {
      final envelope = jsonEncode(<String, Object?>{
        'version': 1,
        'payload': encoded,
      });
      return '$_marker${onEncrypt(envelope)}';
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(
        SerializationKvException(
          'Failed to serialize a value before encryption. Ensure the wrapped '
          'codec produces JSON-compatible values.',
          cause: error,
        ),
        stackTrace,
      );
    }
  }

  @override
  Object? decode(Object? value) {
    if (value == null) return null;

    if (value case final String stored when stored.startsWith(_marker)) {
      try {
        final decrypted = onDecrypt(stored.substring(_marker.length));
        final decodedEnvelope = jsonDecode(decrypted);
        if (decodedEnvelope is! Map<String, dynamic> ||
            decodedEnvelope['version'] != 1 ||
            !decodedEnvelope.containsKey('payload')) {
          throw const FormatException('Invalid OmniKV encrypted envelope.');
        }
        return delegate.decode(decodedEnvelope['payload']);
      } on Object catch (error, stackTrace) {
        Error.throwWithStackTrace(
          SerializationKvException(
            'Failed to decrypt or decode an OmniKV encrypted value.',
            cause: error,
          ),
          stackTrace,
        );
      }
    }

    if (allowPlaintextFallback) {
      return delegate.decode(value);
    }

    throw SerializationKvException(
      'Expected an OmniKV encrypted value. Enable allowPlaintextFallback only '
      'while migrating legacy plaintext data.',
    );
  }
}
