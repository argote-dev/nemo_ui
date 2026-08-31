import 'dart:convert';
import 'dart:io';

/// Checks LCOV covered lines against the committed coverage baseline.
Future<void> main(List<String> arguments) async {
  if (arguments.length != 2) {
    _fail(
      'Usage: dart run tool/check_coverage.dart <lcov.info> <baseline.json>',
    );
  }

  final File lcovFile = File(arguments[0]);
  final File baselineFile = File(arguments[1]);

  final String lcov = await _readFile(lcovFile, 'LCOV report');
  final String baselineContents = await _readFile(
    baselineFile,
    'coverage baseline',
  );
  final int actualCoveredLines = _parseCoveredLines(lcov);
  final int baselineCoveredLines = _parseBaselineCoveredLines(baselineContents);

  if (actualCoveredLines < baselineCoveredLines) {
    _fail(
      'Coverage regression: $actualCoveredLines covered lines is below the '
      'baseline of $baselineCoveredLines. Add targeted tests, or use the '
      'documented intentional-exception process before updating the baseline.',
    );
  }
}

Future<String> _readFile(File file, String description) async {
  try {
    return await file.readAsString();
  } on FileSystemException catch (error) {
    _fail('Cannot read $description at "${file.path}": ${error.message}');
  }
}

int _parseCoveredLines(String contents) {
  var inRecord = false;
  var hasSourceFile = false;
  var validLhCount = 0;
  var coveredLines = 0;

  for (final String rawLine in const LineSplitter().convert(contents)) {
    final String line = rawLine.trim();
    if (line.isEmpty) {
      continue;
    }

    if (line.startsWith('SF:')) {
      if (inRecord || line.length == 3) {
        _fail('Malformed LCOV report: invalid SF record.');
      }
      inRecord = true;
      hasSourceFile = true;
      continue;
    }

    if (line == 'end_of_record') {
      if (!inRecord || !hasSourceFile) {
        _fail('Malformed LCOV report: end_of_record without an SF record.');
      }
      inRecord = false;
      hasSourceFile = false;
      continue;
    }

    if (line.startsWith('LH:')) {
      if (!inRecord) {
        _fail('Malformed LCOV report: LH record outside an SF record.');
      }
      final int? value = int.tryParse(line.substring(3));
      if (value == null || value < 0) {
        _fail('Malformed LCOV report: LH must be a nonnegative integer.');
      }
      coveredLines += value;
      validLhCount += 1;
      continue;
    }

    if (line.startsWith('TN:')) {
      continue;
    }

    if (_isSupportedDetailRecord(line)) {
      if (!inRecord) {
        _fail('Malformed LCOV report: detail record outside an SF record.');
      }
      continue;
    }

    _fail('Malformed LCOV report: unsupported record "$line".');
  }

  if (inRecord) {
    _fail('Malformed LCOV report: missing end_of_record.');
  }
  if (validLhCount == 0) {
    _fail('Malformed LCOV report: no valid LH records were found.');
  }

  return coveredLines;
}

int _parseBaselineCoveredLines(String contents) {
  final Object? decoded;
  try {
    decoded = jsonDecode(contents);
  } on FormatException catch (error) {
    _fail('Malformed coverage baseline JSON: ${error.message}');
  }

  if (decoded is! Map<String, dynamic>) {
    _fail('Malformed coverage baseline JSON: expected an object.');
  }

  final Object? coveredLines = decoded['coveredLines'];
  if (coveredLines is! int || coveredLines < 0) {
    _fail(
      'Malformed coverage baseline JSON: "coveredLines" must be a '
      'nonnegative integer.',
    );
  }

  final Object? foundLines = decoded['foundLines'];
  if (foundLines is! int || foundLines < 0) {
    _fail(
      'Malformed coverage baseline JSON: "foundLines" must be a '
      'nonnegative integer.',
    );
  }

  return coveredLines;
}

Never _fail(String message) {
  stderr.writeln(message);
  exit(1);
}

bool _isSupportedDetailRecord(String line) {
  return line.startsWith('FN:') ||
      line.startsWith('FNDA:') ||
      line.startsWith('FNF:') ||
      line.startsWith('FNH:') ||
      line.startsWith('DA:') ||
      line.startsWith('LF:') ||
      line.startsWith('BRDA:') ||
      line.startsWith('BRF:') ||
      line.startsWith('BRH:');
}
