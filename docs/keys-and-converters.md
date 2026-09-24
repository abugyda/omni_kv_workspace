# Keys and converters

## `KvKey<T>`

`KvKey<T>` defines the logical schema of a stored value.

### Default value

```dart
const theme = KvKey<String>('theme', defaultValue: 'system');
```

The constructor requires a value of `T`. This prevents a non-nullable key such as `KvKey<int>` from accidentally declaring a null default.

### Lazy default

```dart
final generated = KvKey<DateTime>.builder(
  'first_seen',
  defaultBuilder: DateTime.now,
);
```

The builder runs only when the key is missing.

### Required key

```dart
const token = KvKey<String>.required('token');
```

Missing required values throw `MissingValueKvException`.

### Namespace

```dart
const locale = KvKey<String>(
  'locale',
  namespace: 'settings',
  defaultValue: 'en',
);
```

Use `key.name`, not `key.id`, when implementing adapter-level operations. `KeyValue` does this automatically.

## Key converters versus adapter codecs

These layers solve different problems.

A `KvConverter<T, S>` converts an application type into a logical storable representation for one key. A `KvCodec` converts logical keys and values into the physical representation required by an entire backend.

The order for writes is:

```text
T -> KvKey converter -> logical value -> adapter codec -> physical backend value
```

Reads run the reverse path.

## Built-in converters

`omni_kv` exports the following converters:

- `EnumKvConverter` — enum name or index representation.
- `DateTimeKvConverter` — date/time storage conversion.
- `DurationKvConverter` — duration conversion.
- `BigIntKvConverter` — `BigInt` conversion.
- `UriKvConverter` — URI conversion.
- `JsonKvConverter` — JSON-compatible object conversion.
- `ModelKvConverter` — model serialization callbacks.
- `RecordKvConverter` — record conversion callbacks.
- `InlineKvConverter` — arbitrary inline encode/decode callbacks.
- `ListKvConverter` — element-wise list conversion.
- `SetKvConverter` — element-wise set conversion with a list storage representation.

## Example enum key

```dart
enum AppTheme { system, light, dark }

const theme = KvKey<AppTheme>(
  'theme',
  defaultValue: AppTheme.system,
  converter: EnumKvConverter.toName(AppTheme.values),
);
```

## Custom conversion

```dart
final pointConverter = InlineKvConverter<Point, Map<String, Object?>>(
  onEncode: (value) => <String, Object?>{
    'x': value.x,
    'y': value.y,
  },
  onDecode: (value) {
    final map = value!;
    return Point(map['x']! as double, map['y']! as double);
  },
);
```

Keep backend constraints in mind. `SharedPreferencesKvCodec`, for example, accepts only its native primitive types after the key converter has run.
