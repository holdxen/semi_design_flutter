// Port of `packages/core/src/data-editor/group-rename.tsx`.
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../components/semi_input.dart';
import '../common/semi_data_grid_theme.dart';
import '../internal/data_grid/semi_types.dart';

/// `GroupRename` (`group-rename.tsx:32-67`): an inline input that replaces the
/// group header while it is open.
class SemiGroupRename extends StatefulWidget {
  const SemiGroupRename({
    super.key,
    required this.bounds,
    required this.group,
    required this.theme,
    required this.onClose,
    required this.onFinish,
  });

  /// The group header's bounds, in grid coordinates.
  final SemiRectangle bounds;
  final String group;
  final SemiDataGridTheme theme;
  final VoidCallback onClose;
  final ValueChanged<String> onFinish;

  @override
  State<SemiGroupRename> createState() => _SemiGroupRenameState();
}

class _SemiGroupRenameState extends State<SemiGroupRename> {
  late final TextEditingController _controller;

  /// Key-event scope for Enter/Escape.
  final FocusNode _focusNode = FocusNode();

  /// The actual EditableText node; separate because a FocusNode can only
  /// belong to one Focus widget (the wrapper above owns [_focusNode]).
  final FocusNode _inputFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.group);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
      _inputFocusNode.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final bounds = widget.bounds;

    return Positioned(
      left: bounds.x + 1,
      top: bounds.y,
      width: bounds.width - 2,
      height: bounds.height,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        color: theme.bgHeader,
        alignment: Alignment.centerLeft,
        child: Focus(
          focusNode: _focusNode,
          onKeyEvent: (node, event) {
            if (event is! KeyDownEvent) return KeyEventResult.ignored;
            if (event.logicalKey == LogicalKeyboardKey.enter) {
              widget.onFinish(_controller.text);
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              widget.onClose();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: SemiInput(
            controller: _controller,
            focusNode: _inputFocusNode,
            bare: true,
            size: SemiInputSize.small,
            inputStyle: TextStyle(
              color: theme.textGroupHeader ?? theme.textHeader,
              fontSize: theme.headerFontSize,
              fontWeight: theme.headerFontWeight,
            ),
          ),
        ),
      ),
    );
  }
}
