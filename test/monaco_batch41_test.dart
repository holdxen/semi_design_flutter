import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/standalone/common/monarch/monarchTypes.dart';
import 'package:semi_design_flutter/src/monaco/languages/definitions/_.contribution.dart';
import 'package:semi_design_flutter/src/monaco/languages/definitions/register.all.dart';
import 'package:semi_design_flutter/src/monaco/languages/definitions/ini/register.dart'
    as ini_reg;
import 'package:semi_design_flutter/src/monaco/languages/definitions/javascript/register.dart'
    as js_reg;
import 'package:semi_design_flutter/src/monaco/languages/definitions/freemarker2/register.dart'
    as fm2_reg;

void main() {
  setUp(() {
    resetLanguageContributionForTest();
    languagesRegister = (def) {};
    languagesRegisterTokensProviderFactory = (id, create) {};
    languagesOnLanguageEncountered = (id, cb) {};
    languagesSetLanguageConfiguration = (id, conf) {};
    editorCreateModel = (value, languageId) => ILangModel();
  });

  test('registerLanguage stores def and installs all three hooks 1:1', () {
    final seenDefs = <ILang>[];
    final factories = <String>[];
    final encountered = <String>[];
    languagesRegister = (def) => seenDefs.add(def);
    languagesRegisterTokensProviderFactory = (id, create) => factories.add(id);
    languagesOnLanguageEncountered = (id, cb) => encountered.add(id);

    ini_reg.register();

    expect(seenDefs.length, 1);
    expect(seenDefs.single.id, 'ini');
    expect(seenDefs.single.extensions,
        <String>['.ini', '.properties', '.gitconfig']);
    expect(seenDefs.single.filenames,
        <String>['config', '.gitattributes', '.gitconfig', '.editorconfig']);
    expect(seenDefs.single.aliases, <String>['Ini', 'ini']);
    expect(factories, <String>['ini']);
    expect(encountered, <String>['ini']);
    expect(languageDefinitions.containsKey('ini'), isTrue);
  });

  test('javascript literals incl. firstLine / mimetypes preserved', () {
    js_reg.register();
    final def = languageDefinitions['javascript']!;
    expect(def.extensions, <String>['.js', '.es6', '.jsx', '.mjs', '.cjs']);
    expect(def.firstLine, '^#!.*\\bnode');
    expect(def.filenames, <String>['jakefile']);
    expect(def.aliases, <String>['JavaScript', 'javascript', 'js']);
    expect(def.mimetypes, <String>['text/javascript']);
  });

  test('loader returns batch40 conf/language data (async)', () async {
    ini_reg.register();
    final impl = await languageDefinitions['ini']!.loader();
    expect(impl.conf.containsKey('brackets'), isTrue);
    expect(impl.language, isA<IMonarchLanguage>());
    expect(impl.language.tokenizer.containsKey('root'), isTrue);
  });

  test('tokens-provider factory resolves language; onLanguage sets conf',
      () async {
    ILangTokensProviderFactoryCreate? create;
    Future<void> Function()? onEncountered;
    final confSet = <Map<String, Object?>>[];
    languagesRegisterTokensProviderFactory = (id, c) => create = c;
    languagesOnLanguageEncountered = (id, cb) => onEncountered = cb;
    languagesSetLanguageConfiguration = (id, conf) => confSet.add(conf);

    ini_reg.register();
    final lang = await create!();
    expect(lang, isA<IMonarchLanguage>());
    expect(lang.tokenizer.containsKey('root'), isTrue);

    await onEncountered!();
    expect(confSet.length, 1);
    expect(confSet.single.containsKey('brackets'), isTrue);
  });

  test('LazyLanguageLoader caches one load across repeated calls', () async {
    var loaderCalls = 0;
    ini_reg.register();
    final def = languageDefinitions['ini']!;
    languageDefinitions['ini'] = ILang(
      id: def.id,
      extensions: def.extensions,
      filenames: def.filenames,
      aliases: def.aliases,
      loader: () {
        loaderCalls++;
        return def.loader();
      },
    );
    resetLazyForIni();
    final loader = LazyLanguageLoader.getOrCreate('ini');
    final a = loader.load();
    final b = loader.load();
    await Future.wait([a, b]);
    expect(loaderCalls, 1);
    expect(identical(a, b), isTrue);
  });

  test('loadLanguage creates and disposes a model 1:1', () async {
    final created = <String>[];
    final disposed = <String>[];
    editorCreateModel = (value, languageId) {
      created.add('$value|$languageId');
      return _SpyModel(() => disposed.add(languageId));
    };
    ini_reg.register();
    await loadLanguage('ini');
    expect(created, <String>['|ini']);
    expect(disposed, <String>['ini']);
  });

  test('freemarker2 registers 7 variants with correct data objects', () async {
    fm2_reg.register();
    expect(languageDefinitions.length, 7);
    final ids = languageDefinitions.keys.toList();
    expect(ids, contains('freemarker2'));
    expect(ids, contains('freemarker2.tag-angle.interpolation-dollar'));
    expect(ids, contains('freemarker2.tag-auto.interpolation-bracket'));
    // Default variant resolves TagAutoInterpolationDollar data.
    final d = await languageDefinitions['freemarker2']!.loader();
    expect(d.language, isA<IMonarchLanguage>());
    expect(d.language.tokenizer.isNotEmpty, isTrue);
  });

  test('registerAll registers all 81 modules (89 unique ids incl. variants)', () {
    registerAll();
    // 81 register modules eval to 89 registerLanguage defs (cpp adds 'c',
    // systemverilog adds 'verilog', freemarker2 adds 6 tagged variants), all
    // with distinct ids — exactly what the TS source produces.
    expect(languageDefinitions.length, 89);
    expect(languageDefinitions.containsKey('ini'), isTrue);
    expect(languageDefinitions.containsKey('typescript'), isTrue);
    expect(languageDefinitions.containsKey('objective-c'), isTrue);
    expect(languageDefinitions.containsKey('c'), isTrue);
    expect(languageDefinitions.containsKey('verilog'), isTrue);
    expect(languageDefinitions.containsKey('freemarker2'), isTrue);
    expect(languageDefinitions.containsKey('freemarker2.tag-auto.interpolation-bracket'),
        isTrue);
  });
}

/// Remove only the ini lazy loader so the cache test starts fresh.
void resetLazyForIni() {
  lazyLanguageLoaders.remove('ini');
}

class _SpyModel extends ILangModel {
  _SpyModel(this._onDispose);
  final void Function() _onDispose;
  @override
  void dispose() => _onDispose();
}
