# Typography 组件颜色主题

`SemiTypographyThemeData` 是 19 个可空 Color 的不可变覆盖配置，字体度量继续使用 `SemiTypographyTokens`。不增加 CSS manifest 的 383 个变量，也不迁移 Button。

```dart
const app = SemiThemeData.light(
  components: SemiComponentThemes(
    typography: SemiTypographyThemeData(linkTextColor: Color(0xff006644)),
  ),
);
SemiTheme(
  data: app,
  child: const SemiTypographyTheme(
    data: SemiTypographyThemeData(markBackgroundColor: Color(0xffffeebb)),
    child: SemiText('局部标记，链接仍继承应用配置', mark: true),
  ),
);
final dark = app.copyWith(dark: true); // 保留 components
```

`SemiTypographyTheme.of(context)` 返回应用级与全部祖先局部补丁合并后的 overrides，不解析默认色；`maybeOf` 仅在既无 SemiTheme 也无局部主题时返回 null。组件统一调用 `SemiTypographyTheme.resolve(context)` 获取所有非空颜色，并订阅当前全局主题及所有祖先局部变化。最近局部非空值优先，其次祖先局部、当前最近 SemiTheme.components、当前全局 tokens 默认引用。跨 SemiTheme 边界保留局部补丁，但重新采用当前应用级 components；不会携带旧应用级默认值。InheritedTheme.capture 可捕获并重放局部主题。

构造的 null 表示未覆盖，默认引用始终读取当前全局 tokens，亮暗使用相同解析逻辑。copyWith 的 null 保留原覆盖，merge 仅应用非空补丁。恢复应用级默认可替换 `components.typography` 为新的空实例；恢复局部继承可替换该局部 data 为空实例或移除该层。局部 null 不能屏蔽祖先覆盖，需在祖先移除相应值；不提供单字段 null 清除 API，可重建配置保留其他字段。

颜色状态优先级为 type → code → link → disabled → 显式 TextStyle。disabled 普通文本使用 disabledTextColor；disabled 链接使用 linkDisabledColor，默认与正常链接相同，仍禁止点击、键盘及语义激活。focusBorder 始终读取全局 colorFocusBorder。code 背景及边框通过组件配置，mark 在非 code 时使用文字背景；显式 style.backgroundColor 只覆盖文字背景，不覆盖 code 外框。copied 两字段仅提供配置与 resolve，尚未实现 copyable。

所有字段来源均为 `packages/semi-foundation/typography/variables.scss`。

| Dart 字段 | Sass 变量 | 默认 CSS 引用 |
| --- | --- | --- |
| `defaultTextColor` | `$color-typography_default-text-default` | `var(--semi-color-text-0)` |
| `secondaryTextColor` | `$color-typography_secondary-text-default` | `var(--semi-color-text-1)` |
| `tertiaryTextColor` | `$color-typography_tertiary-text-default` | `var(--semi-color-text-2)` |
| `quaternaryTextColor` | `$color-typography_quaternary-text-default` | `var(--semi-color-text-3)` |
| `warningTextColor` | `$color-typography_warning-text-default` | `var(--semi-color-warning)` |
| `dangerTextColor` | `$color-typography_danger-text-default` | `var(--semi-color-danger)` |
| `successTextColor` | `$color-typography_success-text-default` | `var(--semi-color-success)` |
| `disabledTextColor` | `$color-typography_disabled-text-default` | `var(--semi-color-disabled-text)` |
| `markBackgroundColor` | `$color-typography_mark-bg-default` | `var(--semi-color-primary-light-default)` |
| `codeBackgroundColor` | `$color-typography_code-bg-default` | `var(--semi-color-fill-1)` |
| `codeTextColor` | `$color-typography_code-text-default` | `var(--semi-color-text-2)` |
| `linkTextColor` | `$color-typography_link-text-default` | `var(--semi-color-link)` |
| `linkVisitedColor` | `$color-typography_link-text-visited` | `var(--semi-color-link-visited)` |
| `linkHoverColor` | `$color-typography_link-text-hover` | `var(--semi-color-link-hover)` |
| `linkActiveColor` | `$color-typography_link-text-active` | `var(--semi-color-link-active)` |
| `linkDisabledColor` | `$color-typography_link-text-disabled` | `var(--semi-color-link)` |
| `copiedTextColor` | `$color-typography_copied-text-success` | `var(--semi-color-text-2)` |
| `copiedIconColor` | `$color-typography_copied-icon-success` | `var(--semi-color-success)` |
| `codeBorderColor` | `$color-typography_code-border-default` | `var(--semi-color-border)` |
