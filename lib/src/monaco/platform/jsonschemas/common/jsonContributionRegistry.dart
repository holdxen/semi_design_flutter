// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/jsonschemas/common/jsonContributionRegistry.ts
// Translated 1:1 from TypeScript. `{ [id: string]: T }` -> `Map<String, T>`;
// the anonymous `Extensions` const object -> a class with a static const;
// interfaces -> abstract classes; `void` event -> `Event<void>` with `fire(null)`.
// ---------------------------------------------------------------------------

import '../../../base/common/event.dart' show Emitter, Event;
import '../../../base/common/jsonSchema.dart'
    show IJSONSchema, getCompressedContent;
import '../../../base/common/lifecycle.dart'
    show Disposable, DisposableStore, IDisposable, toDisposable;
import '../../registry/common/platform.dart' as platform;

/// 1:1: `export const Extensions = { JSONContribution: 'base.contributions.json' }`
class Extensions {
  static const String JSONContribution = 'base.contributions.json';
}

/// 1:1: `export interface ISchemaContributions { schemas: { [id: string]: IJSONSchema } }`
abstract class ISchemaContributions {
  Map<String, IJSONSchema> get schemas;
}

/// 1:1: `export interface IJSONContributionRegistry`
abstract class IJSONContributionRegistry {
  Event<String> get onDidChangeSchema;
  Event<void> get onDidChangeSchemaAssociations;

  /// Register a schema to the registry.
  void registerSchema(String uri, IJSONSchema unresolvedSchemaContent,
      [DisposableStore? store]);

  IDisposable registerSchemaAssociation(String uri, String glob);

  /// Notifies all listeners that the content of the given schema has changed.
  void notifySchemaChanged(String uri);

  /// Get all schemas
  ISchemaContributions getSchemaContributions();

  Map<String, List<String>> getSchemaAssociations();

  /// Gets the (compressed) content of the schema with the given schema ID (if any)
  String? getSchemaContent(String uri);

  /// Returns true if there's a schema that matches the given schema ID
  bool hasSchemaContent(String uri);
}

/// 1:1: `function normalizeId(id)`
String normalizeId(String id) {
  if (id.isNotEmpty && id[id.length - 1] == '#') {
    return id.substring(0, id.length - 1);
  }
  return id;
}

/// 1:1: `class JSONContributionRegistry extends Disposable implements IJSONContributionRegistry`
class JSONContributionRegistry extends Disposable
    implements IJSONContributionRegistry {
  final Map<String, IJSONSchema> schemasById = <String, IJSONSchema>{};
  final Map<String, List<String>> schemaAssociations =
      <String, List<String>>{};

  final Emitter<String> _onDidChangeSchema = Emitter<String>();
  @override
  late final Event<String> onDidChangeSchema = _onDidChangeSchema.event;

  final Emitter<void> _onDidChangeSchemaAssociations = Emitter<void>();
  @override
  late final Event<void> onDidChangeSchemaAssociations =
      _onDidChangeSchemaAssociations.event;

  JSONContributionRegistry() : super() {
    register(_onDidChangeSchema);
    register(_onDidChangeSchemaAssociations);
  }

  @override
  void registerSchema(String uri, IJSONSchema unresolvedSchemaContent,
      [DisposableStore? store]) {
    final String normalizedUri = normalizeId(uri);
    schemasById[normalizedUri] = unresolvedSchemaContent;
    _onDidChangeSchema.fire(uri);

    if (store != null) {
      store.add(toDisposable(() {
        schemasById.remove(normalizedUri);
        _onDidChangeSchema.fire(uri);
      }));
    }
  }

  @override
  IDisposable registerSchemaAssociation(String uri, String glob) {
    final String normalizedUri = normalizeId(uri);
    if (schemaAssociations[normalizedUri] == null) {
      schemaAssociations[normalizedUri] = <String>[];
    }
    if (!schemaAssociations[normalizedUri]!.contains(glob)) {
      schemaAssociations[normalizedUri]!.add(glob);
      _onDidChangeSchemaAssociations.fire(null);
    }

    return toDisposable(() {
      final List<String>? associations = schemaAssociations[normalizedUri];
      if (associations != null) {
        final int index = associations.indexOf(glob);
        if (index != -1) {
          associations.removeAt(index);
          if (associations.isEmpty) {
            schemaAssociations.remove(normalizedUri);
          }
          _onDidChangeSchemaAssociations.fire(null);
        }
      }
    });
  }

  @override
  void notifySchemaChanged(String uri) {
    _onDidChangeSchema.fire(uri);
  }

  @override
  ISchemaContributions getSchemaContributions() {
    return _SchemaContributions(schemasById);
  }

  @override
  String? getSchemaContent(String uri) {
    final IJSONSchema? schema = schemasById[uri];
    return schema != null ? getCompressedContent(schema) : null;
  }

  @override
  bool hasSchemaContent(String uri) {
    return schemasById[uri] != null;
  }

  @override
  Map<String, List<String>> getSchemaAssociations() {
    return schemaAssociations;
  }
}

/// Carrier for the object literal returned by `getSchemaContributions()`.
class _SchemaContributions implements ISchemaContributions {
  @override
  final Map<String, IJSONSchema> schemas;
  _SchemaContributions(this.schemas);
}

/// 1:1: `const jsonContributionRegistry = new JSONContributionRegistry();`
final JSONContributionRegistry jsonContributionRegistry =
    JSONContributionRegistry();

/// 1:1: the module top-level side effect
/// `platform.Registry.add(Extensions.JSONContribution, jsonContributionRegistry);`
/// A top-level initializer stands in for the TS module-level statement (Dart
/// has no top-level statements). It runs once, lazily, on first library use.
// ignore: unused_element
final Object? _registryRegistration = () {
  platform.Registry.add(Extensions.JSONContribution, jsonContributionRegistry);
  return null;
}();
