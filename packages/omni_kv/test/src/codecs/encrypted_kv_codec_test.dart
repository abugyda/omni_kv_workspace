import 'dart:convert';

import 'package:omni_kv/omni_kv.dart';
import 'package:test/test.dart';

String _encrypt(String value) => base64Encode(utf8.encode(value));
String _decrypt(String value) => utf8.decode(base64Decode(value));

void main() {
  group('EncryptedKvCodec', () {
    late EncryptedKvCodec codec;

    setUp(() {
      codec = EncryptedKvCodec(
        delegate: const MemoryKvCodec(),
        onEncrypt: _encrypt,
        onDecrypt: _decrypt,
      );
    });

    test('preserves primitive and structured encoded types', () {
      for (final value in <Object>[
        42,
        3.14,
        true,
        'hello',
        <Object?>['a', 1, false],
        <String, Object?>{'name': 'Omni', 'count': 2},
      ]) {
        final stored = codec.encode(value);
        expect(stored, isA<String>());
        expect(codec.decode(stored), equals(value));
      }
    });

    test('plaintext fallback must be explicitly enabled', () {
      expect(() => codec.decode(42), throwsA(isA<SerializationKvException>()));

      final migrationCodec = EncryptedKvCodec(
        delegate: const MemoryKvCodec(),
        onEncrypt: _encrypt,
        onDecrypt: _decrypt,
        allowPlaintextFallback: true,
      );
      expect(migrationCodec.decode(42), 42);
    });

    test('corrupt marked ciphertext never falls back to plaintext', () {
      final migrationCodec = EncryptedKvCodec(
        delegate: const MemoryKvCodec(),
        onEncrypt: _encrypt,
        onDecrypt: _decrypt,
        allowPlaintextFallback: true,
      );

      expect(
        () => migrationCodec.decode('omnikv:enc:v1:not-valid-base64'),
        throwsA(isA<SerializationKvException>()),
      );
    });
  });
}
