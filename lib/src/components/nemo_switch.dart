import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/nemo_localizations.dart';
import '../foundation/nemo_theme.dart';
import '../foundation/nemo_theme_data.dart';

/// A controlled binary selection with tactile feedback and switch semantics.
///
/// The caller owns [value], [onChanged], and visible [child] content. Nemo owns
/// the localized on/off state announcement, interaction feedback, and minimum
/// touch target.
class NemoSwitch extends StatefulWidget {
  /// Creates a controlled binary selection.
  const NemoSwitch({
    required this.value,
    required this.child,
    this.onChanged,
    this.semanticLabel,
    this.autofocus = false,
    this.focusNode,
    super.key,
  });

  /// Whether the selection is on.
  final bool value;

  /// Called with the requested value after an enabled interaction.
  final ValueChanged<bool>? onChanged;

  /// Visible caller-owned content describing the selection.
  final Widget child;

  /// Optional caller-owned accessible name.
  final String? semanticLabel;

  /// Whether this control receives focus when first built.
  final bool autofocus;

  /// Optional focus node owned by the caller.
  final FocusNode? focusNode;

  @override
  State<NemoSwitch> createState() => _NemoSwitchState();
}

class _NemoSwitchState extends State<NemoSwitch> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  bool get _enabled => widget.onChanged != null;

  void _toggle() {
    if (_enabled) widget.onChanged!(!widget.value);
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    if (!_enabled ||
        (event.logicalKey != LogicalKeyboardKey.enter &&
            event.logicalKey != LogicalKeyboardKey.space)) {
      return KeyEventResult.ignored;
    }
    if (event is KeyDownEvent) {
      setState(() => _pressed = true);
    }
    if (event is KeyUpEvent) {
      setState(() => _pressed = false);
      _toggle();
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    final NemoSwitchTokens tokens = theme.components.switchControl;
    final bool enabled = _enabled;
    final Duration duration = theme.motion.resolveFor(context).quick;
    final String stateLabel = widget.value
        ? NemoLocalizations.of(context).on
        : NemoLocalizations.of(context).off;
    final Color active = widget.value
        ? theme.semantic.primary
        : theme.semantic.surfaceVariant;
    final Color interactiveTone = widget.value
        ? Color.lerp(active, theme.semantic.onPrimary, .12)!
        : Color.lerp(active, theme.semantic.primary, .12)!;
    final Color track = _pressed
        ? Color.lerp(interactiveTone, theme.semantic.foreground, .12)!
        : _hovered || _focused
        ? interactiveTone
        : active;

    return MergeSemantics(
      child: Semantics(
        toggled: widget.value,
        enabled: enabled,
        label: widget.semanticLabel,
        value: stateLabel,
        onTap: enabled ? _toggle : null,
        child: Focus(
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          canRequestFocus: enabled,
          skipTraversal: !enabled,
          onFocusChange: (value) => setState(() => _focused = value),
          onKeyEvent: _onKey,
          child: MouseRegion(
            cursor: enabled
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            onEnter: enabled ? (_) => setState(() => _hovered = true) : null,
            onExit: enabled ? (_) => setState(() => _hovered = false) : null,
            child: GestureDetector(
              excludeFromSemantics: true,
              behavior: HitTestBehavior.opaque,
              onTap: enabled ? _toggle : null,
              onTapDown: enabled
                  ? (_) => setState(() => _pressed = true)
                  : null,
              onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
              onTapCancel: enabled
                  ? () => setState(() => _pressed = false)
                  : null,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: theme.components.controlMinHeight,
                ),
                child: Opacity(
                  opacity: enabled ? 1 : tokens.disabledOpacity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Flexible(
                        child: widget.semanticLabel == null
                            ? widget.child
                            : ExcludeSemantics(child: widget.child),
                      ),
                      SizedBox(width: theme.foundation.space12),
                      AnimatedContainer(
                        key: const ValueKey<String>('nemo-switch-track'),
                        duration: duration,
                        curve: theme.motion.standardCurve,
                        width: tokens.trackWidth,
                        height: tokens.trackHeight,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: track,
                          borderRadius: BorderRadius.circular(
                            tokens.trackHeight / 2,
                          ),
                          border: Border.all(
                            color: _focused
                                ? theme.semantic.focusRing
                                : theme.semantic.outline.withValues(
                                    alpha: tokens.trackOutlineOpacity,
                                  ),
                            width: _focused
                                ? theme.components.focusRingWidth
                                : theme.components.outlineWidth,
                          ),
                          boxShadow:
                              _pressed ||
                                  !enabled ||
                                  theme.semantic.lowlightShadow ==
                                      Colors.transparent
                              ? null
                              : <BoxShadow>[
                                  BoxShadow(
                                    color: theme.semantic.lowlightShadow
                                        .withValues(alpha: .25),
                                    blurRadius:
                                        theme.foundation.shadowBlur * .3,
                                    offset: Offset(
                                      0,
                                      theme.foundation.shadowOffset * .2,
                                    ),
                                  ),
                                ],
                        ),
                        child: AnimatedAlign(
                          duration: duration,
                          curve: theme.motion.standardCurve,
                          alignment: widget.value
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            width: tokens.thumbDiameter,
                            height: tokens.thumbDiameter,
                            decoration: BoxDecoration(
                              color: widget.value
                                  ? theme.semantic.onPrimary
                                  : theme.semantic.foreground,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.value ? Icons.check : Icons.remove,
                              size: 16,
                              color: widget.value
                                  ? theme.semantic.primary
                                  : theme.semantic.surface,
                              semanticLabel: null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
