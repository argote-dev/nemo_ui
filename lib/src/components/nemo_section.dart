import 'package:flutter/material.dart';

import '../foundation/nemo_theme.dart';
import '../foundation/nemo_theme_data.dart';

/// A semantic content section with a heading, optional description, and slot.
///
/// This widget establishes hierarchy and tokenized spacing only. It does not
/// create a material plane, impose typography, or manage interactions.
class NemoSection extends StatelessWidget {
  /// Creates a semantic section.
  const NemoSection({
    required this.heading,
    required this.child,
    this.description,
    super.key,
  });

  /// The caller-owned heading, exposed as a semantic header.
  final Widget heading;

  /// Optional supporting copy displayed below [heading].
  final Widget? description;

  /// The caller-owned section content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Semantics(header: true, child: heading),
          if (description case final Widget value) ...<Widget>[
            SizedBox(height: theme.foundation.space8),
            DefaultTextStyle.merge(
              style: TextStyle(color: theme.semantic.mutedForeground),
              child: value,
            ),
          ],
          SizedBox(height: theme.foundation.space16),
          child,
        ],
      ),
    );
  }
}
