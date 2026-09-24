import 'package:omni_kv/omni_kv.dart';
import 'package:test/test.dart';

void main() {
  group('KvKey', () {
    test('returns default value when not present in storage', () {
      const key = KvKey<int>('age', defaultValue: 18);
      expect(key.decode(null, isPresent: false), 18);
    });

    test('nullable keys may use null as their missing default', () {
      const key = KvKey<String?>('bio', defaultValue: null);
      expect(key.decode(null, isPresent: false), isNull);
    });

    test('throws MissingValueKvException when required and missing', () {
      const key = KvKey<String>.required('token');
      expect(
        () => key.decode(null, isPresent: false),
        throwsA(isA<MissingValueKvException>()),
      );
    });

    test('rejects a present null because null writes mean removal', () {
      const key = KvKey<String?>('bio', defaultValue: null);
      expect(
        () => key.decode(null, isPresent: true),
        throwsA(isA<TypeKvException>()),
      );
    });
  });
}
