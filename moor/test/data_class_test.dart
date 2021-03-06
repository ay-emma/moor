import 'package:moor/moor.dart';
import 'package:test/test.dart';

import 'data/tables/todos.dart';

void main() {
  test('data classes can be serialized', () {
    final entry = TodoEntry(
      id: 13,
      title: 'Title',
      content: 'Content',
      targetDate: DateTime.now(),
    );

    final serialized = entry.toJsonString();
    final deserialized = TodoEntry.fromJsonString(serialized);

    expect(deserialized, equals(deserialized));
  });

  test('can deserialize ints as doubles', () {
    final entry = TableWithoutPKData.fromJson({
      'notReallyAnId': 3,
      'someFloat': 4,
    });

    expect(entry,
        TableWithoutPKData(notReallyAnId: 3, someFloat: 4, custom: null));
  });

  test('default serializer can be overridden globally', () {
    final old = moorRuntimeOptions.defaultSerializer;
    moorRuntimeOptions.defaultSerializer = _MySerializer();

    final entry = TodoEntry(
      id: 13,
      title: 'Title',
      content: 'Content',
      category: 3,
      targetDate: DateTime.now(),
    );
    expect(
      entry.toJson(),
      {
        'id': 'foo',
        'title': 'foo',
        'content': 'foo',
        'category': 'foo',
        'target_date': 'foo',
      },
    );

    moorRuntimeOptions.defaultSerializer = old;
  });

  test('can serialize and deserialize blob columns', () {
    final user = User(
      id: 3,
      name: 'Username',
      isAwesome: true,
      profilePicture: Uint8List.fromList([1, 2, 3, 4]),
      creationTime: DateTime.now(),
    );

    final recovered = User.fromJsonString(user.toJsonString());

    // Note: Some precision is lost when serializing DateTimes, so we're using
    // custom expects instead of expect(recovered, user)
    expect(recovered.id, user.id);
    expect(recovered.name, user.name);
    expect(recovered.isAwesome, user.isAwesome);
    expect(recovered.profilePicture, user.profilePicture);
  });
}

class _MySerializer extends ValueSerializer {
  @override
  T fromJson<T>(dynamic json) {
    throw StateError('Should not be called');
  }

  @override
  dynamic toJson<T>(T value) {
    return 'foo';
  }
}
