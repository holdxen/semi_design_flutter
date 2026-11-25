// 1:1 port of vs/editor/contrib/codeAction/common/types.ts
// Erased TS interfaces (CodeAction / CodeActionProvider / ...) are local
// carriers; runtime enums/classes are ported verbatim.
// Runtime truth: tool/ts2dart/_batch269_truth.cjs (recursive TS transpile+vm).

import '../../../../base/common/cancellation.dart' show CancellationToken;
import '../../../../base/common/errors.dart' as errors;
import '../../../../base/common/hierarchicalKind.dart' show HierarchicalKind;
import '../../../common/core/position.dart' show Position;

/// 1:1: `CodeActionKind` (values mirrored 1:1)
class CodeActionKind {
  static final HierarchicalKind QuickFix = HierarchicalKind('quickfix');

  static final HierarchicalKind Refactor = HierarchicalKind('refactor');
  static final HierarchicalKind RefactorExtract = Refactor.append(['extract']);
  static final HierarchicalKind RefactorInline = Refactor.append(['inline']);
  static final HierarchicalKind RefactorMove = Refactor.append(['move']);
  static final HierarchicalKind RefactorRewrite = Refactor.append(['rewrite']);

  static final HierarchicalKind Notebook = HierarchicalKind('notebook');

  static final HierarchicalKind Source = HierarchicalKind('source');
  static final HierarchicalKind SourceOrganizeImports =
      Source.append(['organizeImports']);
  static final HierarchicalKind SourceFixAll = Source.append(['fixAll']);
  static final HierarchicalKind SurroundWith = Refactor.append(['surround']);
}

/// 1:1: `const enum CodeActionAutoApply`
class CodeActionAutoApply {
  static const String IfSingle = 'ifSingle';
  static const String First = 'first';
  static const String Never = 'never';
}

/// 1:1: `enum CodeActionTriggerSource`
class CodeActionTriggerSource {
  static const String Refactor = 'refactor';
  static const String RefactorPreview = 'refactor preview';
  static const String Lightbulb = 'lightbulb';
  static const String Default = 'other (default)';
  static const String SourceAction = 'source action';
  static const String QuickFix = 'quick fix action';
  static const String FixAll = 'fix all';
  static const String OrganizeImports = 'organize imports';
  static const String AutoFix = 'auto fix';
  static const String QuickFixHover = 'quick fix hover window';
  static const String OnSave = 'save participants';
  static const String ProblemsView = 'problems view';
}

/// 1:1: `CodeActionFilter`
class CodeActionFilter {
  final HierarchicalKind? include;
  final List<HierarchicalKind>? excludes;
  final bool? includeSourceActions;
  final bool? onlyIncludePreferredActions;

  CodeActionFilter({
    this.include,
    this.excludes,
    this.includeSourceActions,
    this.onlyIncludePreferredActions,
  });
}

/// 1:1: erased `languages.CodeAction` members used here.
abstract class ICodeAction {
  String? get kind;
  bool? get isPreferred;
  Object? get edit;
  set edit(Object? value);
}

/// 1:1: erased `languages.CodeActionProvider.resolveCodeAction`.
abstract class ICodeActionProvider {
  Future<ICodeAction?> resolveCodeAction(
      ICodeAction action, CancellationToken token);
}

/// 1:1: `mayIncludeActionsOfKind(filter, providedKind)`
bool mayIncludeActionsOfKind(
    CodeActionFilter filter, HierarchicalKind providedKind) {
  if (filter.include != null && !filter.include!.intersects(providedKind)) {
    return false;
  }

  if (filter.excludes != null) {
    if (filter.excludes!.any((exclude) =>
        _excludesAction(providedKind, exclude, filter.include))) {
      return false;
    }
  }

  if (filter.includeSourceActions != true &&
      CodeActionKind.Source.contains(providedKind)) {
    return false;
  }

  return true;
}

/// 1:1: `filtersAction(filter, action)`
bool filtersAction(CodeActionFilter filter, ICodeAction action) {
  final HierarchicalKind? actionKind =
      action.kind != null ? HierarchicalKind(action.kind!) : null;

  if (filter.include != null) {
    if (actionKind == null || !filter.include!.contains(actionKind)) {
      return false;
    }
  }

  if (filter.excludes != null) {
    if (actionKind != null &&
        filter.excludes!.any((exclude) =>
            _excludesAction(actionKind, exclude, filter.include))) {
      return false;
    }
  }

  if (filter.includeSourceActions != true) {
    if (actionKind != null && CodeActionKind.Source.contains(actionKind)) {
      return false;
    }
  }

  if (filter.onlyIncludePreferredActions == true) {
    if (action.isPreferred != true) {
      return false;
    }
  }

  return true;
}

/// 1:1: `excludesAction(providedKind, exclude, include)`
bool _excludesAction(HierarchicalKind providedKind, HierarchicalKind exclude,
    HierarchicalKind? include) {
  if (!exclude.contains(providedKind)) {
    return false;
  }
  if (include != null && exclude.contains(include)) {
    return false;
  }
  return true;
}

/// 1:1: `CodeActionTrigger` (type carrier)
class CodeActionTrigger {
  final int type;
  final String triggerAction;
  final CodeActionFilter? filter;
  final String? autoApply;
  final ({String notAvailableMessage, Position position})? context;

  CodeActionTrigger({
    required this.type,
    required this.triggerAction,
    this.filter,
    this.autoApply,
    this.context,
  });
}

/// 1:1: `CodeActionCommandArgs`
class CodeActionCommandArgs {
  final HierarchicalKind kind;
  final String apply;
  final bool preferred;

  CodeActionCommandArgs._(this.kind, this.apply, this.preferred);

  /// 1:1: `static fromUser(arg, defaults)`
  static CodeActionCommandArgs fromUser(Object? arg,
      {required HierarchicalKind kind, required String apply}) {
    if (arg == null || arg is! Map) {
      return CodeActionCommandArgs._(kind, apply, false);
    }
    return CodeActionCommandArgs._(
      _getKindFromUser(arg, kind),
      _getApplyFromUser(arg, apply),
      _getPreferredUser(arg),
    );
  }

  static String _getApplyFromUser(Map arg, String defaultAutoApply) {
    final Object? raw = arg['apply'];
    final String apply = raw is String ? raw.toLowerCase() : '';
    switch (apply) {
      case 'first':
        return CodeActionAutoApply.First;
      case 'never':
        return CodeActionAutoApply.Never;
      case 'ifsingle':
        return CodeActionAutoApply.IfSingle;
      default:
        return defaultAutoApply;
    }
  }

  static HierarchicalKind _getKindFromUser(
      Map arg, HierarchicalKind defaultKind) {
    final Object? kind = arg['kind'];
    return kind is String ? HierarchicalKind(kind) : defaultKind;
  }

  static bool _getPreferredUser(Map arg) {
    final Object? preferred = arg['preferred'];
    return preferred is bool ? preferred : false;
  }
}

/// 1:1: `CodeActionItem`
class CodeActionItem {
  final ICodeAction action;
  final ICodeActionProvider? provider;
  bool? highlightRange;

  CodeActionItem(this.action, this.provider, [this.highlightRange]);

  /// 1:1: `async resolve(token): Promise<this>`
  Future<CodeActionItem> resolve(CancellationToken token) async {
    if (provider != null && action.edit == null) {
      ICodeAction? resolved;
      try {
        resolved = await provider!.resolveCodeAction(action, token);
      } catch (err) {
        errors.onUnexpectedExternalError(err);
      }
      if (resolved != null) {
        action.edit = resolved.edit;
      }
    }
    return this;
  }
}

/// 1:1: `CodeActionSet` (erased interface carrier)
abstract class ICodeActionSet {
  List<CodeActionItem> get validActions;
  List<CodeActionItem> get allActions;
  List<Object?> get documentation;
}
