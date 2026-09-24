import 'dart:io';

const _forbiddenDirectoryNames = <String>{
  '.dart_tool',
  '.melos_tool',
  'build',
  'coverage',
};

const _forbiddenFileNames = <String>{
  '.packages',
  'pubspec.lock',
  'filedump_manifest.json',
};

void main() {
  final result = Process.runSync(
    'git',
    const <String>['ls-files', '-z'],
    runInShell: Platform.isWindows,
  );

  if (result.exitCode != 0) {
    stdout.writeln(
      'Workspace cleanliness check skipped: this directory is not a Git checkout.',
    );
    return;
  }

  final trackedPaths = (result.stdout as String)
      .split('\u0000')
      .where((path) => path.isNotEmpty);
  final violations = <String>[];

  for (final path in trackedPaths) {
    final normalized = path.replaceAll('\\', '/');
    final segments = normalized.split('/');
    if (segments.any(_forbiddenDirectoryNames.contains) ||
        _forbiddenFileNames.contains(segments.last)) {
      violations.add(path);
    }
  }

  if (violations.isNotEmpty) {
    stderr
      ..writeln('Generated/local artifacts must not be tracked:')
      ..writeln(violations.join('\n'));
    exitCode = 1;
    return;
  }

  stdout.writeln('OmniKV tracked-artifact cleanliness check passed.');
}
