import 'package:omni_kv/omni_kv.dart';
import 'package:test/test.dart';

import '../../helpers/app_key_fixture.dart';

void main() {
  group('KvBatch', () {
    test('kv batch collects ordered operations', () async {
      final collector = KvOperationRecorder();
      final kv = KeyValue(collector);

      await kv.write(AppKey.theme, 'light');
      await kv.remove(AppKey.theme);

      expect(collector.operations, hasLength(2));
      expect(collector.operations[0], isA<WriteKvOperation>());
      expect(collector.operations[1], isA<RemoveKvOperation>());
      expect(collector.operations[0].key, 'theme');
    });
  });
}
