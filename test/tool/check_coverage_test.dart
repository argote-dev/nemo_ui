import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('check_coverage.dart', () {
    test('accepts coverage equal to the covered-lines baseline', () async {
      final _CoverageFixture fixture = await _CoverageFixture.create(
        lcov: 'SF:lib/example.dart\nLH:709\nend_of_record\n',
        baseline: '{"coveredLines":709,"foundLines":797}',
      );
      addTearDown(fixture.delete);

      final ProcessResult result = await _runChecker(<String>[
        fixture.lcov.path,
        fixture.baseline.path,
      ]);

      expect(result.exitCode, 0);
      expect(result.stdout, isEmpty);
      expect(result.stderr, isEmpty);
    });

    test(
      'accepts an increase and sums LH records across source files',
      () async {
        final _CoverageFixture fixture = await _CoverageFixture.create(
          lcov:
              'SF:lib/one.dart\nLH:400\nend_of_record\n'
              'SF:lib/two.dart\nLH:310\nend_of_record\n',
          baseline: '{"coveredLines":709,"foundLines":797}',
        );
        addTearDown(fixture.delete);

        final ProcessResult result = await _runChecker(<String>[
          fixture.lcov.path,
          fixture.baseline.path,
        ]);

        expect(result.exitCode, 0);
        expect(result.stderr, isEmpty);
      },
    );

    test('rejects a decrease with an actionable regression message', () async {
      final _CoverageFixture fixture = await _CoverageFixture.create(
        lcov: 'SF:lib/example.dart\nLH:708\nend_of_record\n',
        baseline: '{"coveredLines":709,"foundLines":797}',
      );
      addTearDown(fixture.delete);

      final ProcessResult result = await _runChecker(<String>[
        fixture.lcov.path,
        fixture.baseline.path,
      ]);

      expect(result.exitCode, isNonZero);
      expect(result.stderr, contains('Coverage regression'));
      expect(result.stderr, contains('708 covered lines'));
      expect(result.stderr, contains('baseline of 709'));
    });

    test('rejects malformed LCOV and baseline JSON inputs', () async {
      final _CoverageFixture malformedLcov = await _CoverageFixture.create(
        lcov: 'SF:lib/example.dart\nLH:not-a-number\nend_of_record\n',
        baseline: '{"coveredLines":709,"foundLines":797}',
      );
      final _CoverageFixture unsupportedRecord = await _CoverageFixture.create(
        lcov: 'SF:lib/example.dart\nUNKNOWN:709\nLH:709\nend_of_record\n',
        baseline: '{"coveredLines":709,"foundLines":797}',
      );
      final _CoverageFixture noLhRecord = await _CoverageFixture.create(
        lcov: 'SF:lib/example.dart\nLF:797\nend_of_record\n',
        baseline: '{"coveredLines":709,"foundLines":797}',
      );
      final _CoverageFixture malformedJson = await _CoverageFixture.create(
        lcov: 'SF:lib/example.dart\nLH:709\nend_of_record\n',
        baseline: '{"coveredLines":"709","foundLines":797}',
      );
      final _CoverageFixture negativeBaseline = await _CoverageFixture.create(
        lcov: 'SF:lib/example.dart\nLH:709\nend_of_record\n',
        baseline: '{"coveredLines":709,"foundLines":-1}',
      );
      addTearDown(malformedLcov.delete);
      addTearDown(unsupportedRecord.delete);
      addTearDown(noLhRecord.delete);
      addTearDown(malformedJson.delete);
      addTearDown(negativeBaseline.delete);

      final ProcessResult lcovResult = await _runChecker(<String>[
        malformedLcov.lcov.path,
        malformedLcov.baseline.path,
      ]);
      final ProcessResult unsupportedResult = await _runChecker(<String>[
        unsupportedRecord.lcov.path,
        unsupportedRecord.baseline.path,
      ]);
      final ProcessResult noLhResult = await _runChecker(<String>[
        noLhRecord.lcov.path,
        noLhRecord.baseline.path,
      ]);
      final ProcessResult jsonResult = await _runChecker(<String>[
        malformedJson.lcov.path,
        malformedJson.baseline.path,
      ]);
      final ProcessResult negativeResult = await _runChecker(<String>[
        negativeBaseline.lcov.path,
        negativeBaseline.baseline.path,
      ]);

      expect(lcovResult.exitCode, isNonZero);
      expect(lcovResult.stderr, contains('LH must be a nonnegative integer'));
      expect(unsupportedResult.exitCode, isNonZero);
      expect(unsupportedResult.stderr, contains('unsupported record'));
      expect(noLhResult.exitCode, isNonZero);
      expect(noLhResult.stderr, contains('no valid LH records'));
      expect(jsonResult.exitCode, isNonZero);
      expect(jsonResult.stderr, contains('coveredLines'));
      expect(negativeResult.exitCode, isNonZero);
      expect(negativeResult.stderr, contains('foundLines'));
    });

    test('rejects missing inputs and wrong arguments', () async {
      final _CoverageFixture fixture = await _CoverageFixture.create(
        lcov: 'SF:lib/example.dart\nLH:709\nend_of_record\n',
        baseline: '{"coveredLines":709,"foundLines":797}',
      );
      addTearDown(fixture.delete);

      final ProcessResult missingResult = await _runChecker(<String>[
        '${fixture.directory.path}/missing-lcov.info',
        fixture.baseline.path,
      ]);
      final ProcessResult argumentsResult = await _runChecker(const <String>[]);

      expect(missingResult.exitCode, isNonZero);
      expect(missingResult.stderr, contains('Cannot read LCOV report'));
      expect(argumentsResult.exitCode, isNonZero);
      expect(argumentsResult.stderr, contains('Usage:'));
    });
  });
}

class _CoverageFixture {
  _CoverageFixture._(this.directory, this.lcov, this.baseline);

  final Directory directory;
  final File lcov;
  final File baseline;

  static Future<_CoverageFixture> create({
    required String lcov,
    required String baseline,
  }) async {
    final Directory directory = await Directory.systemTemp.createTemp(
      'nemo-ui-coverage-check-',
    );
    final File lcovFile = File('${directory.path}/lcov.info')
      ..writeAsStringSync(lcov);
    final File baselineFile = File('${directory.path}/baseline.json')
      ..writeAsStringSync(baseline);
    return _CoverageFixture._(directory, lcovFile, baselineFile);
  }

  Future<void> delete() => directory.delete(recursive: true);
}

Future<ProcessResult> _runChecker(List<String> arguments) {
  return Process.run('dart', <String>[
    'run',
    'tool/check_coverage.dart',
    ...arguments,
  ], workingDirectory: Directory.current.path);
}
