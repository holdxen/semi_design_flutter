// 1:1 port of vscode/src/vs/platform/theme/browser/iconsStyleSheet.ts
//
// Tagged templates are expressed as `css.inline(strings, values)` (see
// base/browser/cssValue.dart); `IIconsStyleSheet` is a Dart interface and the
// object literal returned by getIconsStyleSheet becomes [_IconsStyleSheet].

import '../../../base/browser/cssValue.dart' as css;
import '../../../base/common/event.dart' show Event, Emitter;
import '../../../base/common/lifecycle.dart' show DisposableStore, IDisposable;
import '../../../base/common/themables.dart' show ThemeIcon;
import '../common/iconRegistry.dart'
    show
        IconContribution,
        IconDefinition,
        IconFontContribution,
        IconFontDefinition,
        IIconRegistry,
        getIconRegistry;
import '../common/themeService.dart'
    show IProductIconTheme, IThemeServiceType;

/// Injectable seam (Dart port only): defaults to the real icon registry.
IIconRegistry Function() iconRegistryProvider = getIconRegistry;

/// 1:1: `export interface IIconsStyleSheet extends IDisposable`
abstract class IIconsStyleSheet implements IDisposable {
  css.CssFragment getCSS();
  Event<void> get onDidChange;
}

class _IconsStyleSheet implements IIconsStyleSheet {
  _IconsStyleSheet(this._themeService, this._disposable, this._onDidChangeEmitter);

  final IThemeServiceType? _themeService;
  final DisposableStore _disposable;
  final Emitter<void> _onDidChangeEmitter;

  @override
  Event<void> get onDidChange => _onDidChangeEmitter.event;

  @override
  void dispose() => _disposable.dispose();

  @override
  css.CssFragment getCSS() {
    final IProductIconTheme productIconTheme = _themeService != null
        ? _themeService.getProductIconTheme()
        : UnthemedProductIconTheme();
    final Map<String, IconFontDefinition> usedFontIds =
        <String, IconFontDefinition>{};

    final css.Builder rules = css.Builder();
    final css.Builder rootAttribs = css.Builder();
    for (final IconContribution contribution in iconRegistryProvider().getIcons()) {
      final IconDefinition? definition = productIconTheme.getIcon(contribution);
      if (definition == null) {
        continue;
      }

      final Object? fontContribution = definition.font;
      final css.CssFragment fontFamilyVar = css.inline(
          <String>['--vscode-icon-', '-font-family'],
          <Object?>[css.className(contribution.id)]);
      final css.CssFragment contentVar = css.inline(
          <String>['--vscode-icon-', '-content'],
          <Object?>[css.className(contribution.id)]);
      if (fontContribution != null) {
        final IconFontContribution font = fontContribution as IconFontContribution;
        usedFontIds[font.id] = font.definition;
        rootAttribs.push(<css.CssFragment>[
          css.inline(<String>['', ': ', ';'],
              <Object?>[fontFamilyVar, css.stringValue(font.id)]),
          css.inline(<String>['', ': ', ';'],
              <Object?>[contentVar, css.stringValue(definition.fontCharacter)]),
        ]);
        rules.push(<css.CssFragment>[
          css.inline(
              <String>[
                '.codicon-',
                ':before { content: ',
                '; font-family: ',
                '; }'
              ],
              <Object?>[
                css.className(contribution.id),
                css.stringValue(definition.fontCharacter),
                css.stringValue(font.id),
              ]),
        ]);
      } else {
        rootAttribs.push(<css.CssFragment>[
          css.inline(<String>['', ': ', '; ', ": 'codicon';"], <Object?>[
            contentVar,
            css.stringValue(definition.fontCharacter),
            fontFamilyVar,
          ]),
        ]);
        rules.push(<css.CssFragment>[
          css.inline(<String>['.codicon-', ':before { content: ', '; }'],
              <Object?>[
                css.className(contribution.id),
                css.stringValue(definition.fontCharacter),
              ]),
        ]);
      }
    }

    for (final MapEntry<String, IconFontDefinition> entry
        in usedFontIds.entries) {
      final String id = entry.key;
      final IconFontDefinition definition = entry.value;
      final css.CssFragment fontWeight = definition.weight != null
          ? css.inline(<String>['font-weight: ', ';'],
              <Object?>[css.identValue(definition.weight!)])
          : css.inline(<String>[''], <Object?>[]);
      final css.CssFragment fontStyle = definition.style != null
          ? css.inline(<String>['font-style: ', ';'],
              <Object?>[css.identValue(definition.style!)])
          : css.inline(<String>[''], <Object?>[]);

      final css.Builder src = css.Builder();
      for (final dynamic l in definition.src) {
        src.push(<css.CssFragment>[
          css.inline(<String>['', ' format(', ')'], <Object?>[
            css.asCSSUrl(l.location),
            css.stringValue(l.format),
          ]),
        ]);
      }
      rules.push(<css.CssFragment>[
        css.inline(
            <String>[
              '@font-face { src: ',
              '; font-family: ',
              ';',
              '',
              ' font-display: block; }'
            ],
            <Object?>[
              src.join(', '),
              css.stringValue(id),
              fontWeight,
              fontStyle,
            ]),
      ]);
    }

    rules.push(<css.CssFragment>[
      css.inline(<String>[':root { ', ' }'], <Object?>[rootAttribs.join(' ')]),
    ]);

    return rules.join('\n');
  }
}

/// 1:1: `export function getIconsStyleSheet(themeService)`
IIconsStyleSheet getIconsStyleSheet(IThemeServiceType? themeService) {
  final DisposableStore disposable = DisposableStore();

  final Emitter<void> onDidChangeEmmiter =
      disposable.add(Emitter<void>());
  final dynamic iconRegistry = iconRegistryProvider();
  disposable.add(iconRegistry.onDidChange((dynamic _) {
    onDidChangeEmmiter.fire(null);
  }));
  if (themeService != null) {
    disposable.add(themeService.onDidProductIconThemeChange((dynamic _) {
      onDidChangeEmmiter.fire(null);
    }));
  }

  return _IconsStyleSheet(themeService, disposable, onDidChangeEmmiter);
}

/// 1:1: `export class UnthemedProductIconTheme`
class UnthemedProductIconTheme implements IProductIconTheme {
  @override
  IconDefinition? getIcon(IconContribution contribution) {
    final dynamic iconRegistry = iconRegistryProvider();
    Object definition = contribution.defaults;
    while (ThemeIcon.isThemeIcon(definition)) {
      final IconContribution? c =
          iconRegistry.getIcon((definition as ThemeIcon).id) as IconContribution?;
      if (c == null) {
        return null;
      }
      definition = c.defaults;
    }
    return definition as IconDefinition?;
  }
}
