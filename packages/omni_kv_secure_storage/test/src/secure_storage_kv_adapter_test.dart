import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omni_kv/omni_kv.dart';
import 'package:omni_kv_secure_storage/omni_kv_secure_storage.dart';
import 'package:omni_kv_testing/omni_kv_testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureStorageKvAdapter conformance', () {
    runPersistentKvAdapterTests<SecureStorageKvAdapter>(
      createAdapter: () async {
        FlutterSecureStorage.setMockInitialValues({});
        return const SecureStorageKvAdapter(FlutterSecureStorage());
      },
    );
  });

  group('SecureStorageKvAdapter semantics', () {
    late KeyValue<SecureStorageKvAdapter> kv;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      const storage = FlutterSecureStorage();
      kv = const KeyValue(SecureStorageKvAdapter(storage));
    });

    test('automatically JSON encodes and decodes structured values', () async {
      await kv.test(.pinCode).write(1234);
      expect(await kv.test(.pinCode).read(), 1234);

      await kv.test(.metadata).write({'role': 'admin'});
      expect((await kv.test(.metadata).read())['role'], 'admin');
    });
  });
}
