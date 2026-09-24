import 'package:omni_kv/omni_kv.dart';
import 'package:test/test.dart';

enum Role { admin, user }

void main() {
  group('CollectionConverter', () {
    test('ListConverter converts elements', () {
      const converter = ListKvConverter<Role>(EnumKvConverter.toName(Role.values));
      final list = [Role.admin, Role.user];

      final encoded = converter.encode(list);
      expect(encoded, ['admin', 'user']);
      expect(converter.decode(encoded), list);
    });

    test('SetConverter converts elements and restores Set', () {
      const converter = SetKvConverter<Role>(EnumKvConverter.toName(Role.values));
      final set = {Role.admin, Role.user};

      final encoded = converter.encode(set);
      expect(encoded, ['admin', 'user']); // Stored as a list!
      expect(converter.decode(encoded), set); // Restored as a Set!
    });
  });
}
