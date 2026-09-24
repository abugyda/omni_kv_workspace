import '../capabilities/batchable_capability.dart';
import '../capabilities/clearable_capability.dart';
import '../capabilities/closable_capability.dart';
import '../capabilities/readable_capability.dart';
import '../capabilities/removable_capability.dart';
import '../capabilities/watchable_capability.dart';
import '../capabilities/writable_capability.dart';
import '../core/kv_capability.dart';

/// Composite adapter contract for read/write/remove stores.
abstract interface class ReadWriteKvAdapter<TCapability extends ReadWriteKvCapability>
    implements
        ReadKvAdapter<TCapability>,
        WriteKvAdapter<TCapability>,
        RemoveKvAdapter<TCapability> {}

/// Composite adapter contract for common persistent key-value stores.
abstract interface class ReadWriteClearBatchKvAdapter<
  TCapability extends ReadWriteClearBatchKvCapability
>
    implements
        ReadWriteKvAdapter<TCapability>,
        ClearKvAdapter<TCapability>,
        BatchKvAdapter<TCapability>,
        ClosableKvAdapter<TCapability> {}

/// Composite adapter contract for full local/reactive key-value stores.
abstract interface class FullKvAdapter<TCapability extends FullKvCapability>
    implements
        ReadWriteClearBatchKvAdapter<TCapability>,
        WatchKvAdapter<TCapability>,
        NamespaceWatchKvAdapter<TCapability> {}
