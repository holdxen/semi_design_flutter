import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/platform/configuration/common/configurationRegistry.dart'
    as cr;
import 'package:semi_design_flutter/src/monaco/platform/product/common/product.dart'
    as product;

final Map<String, dynamic> _truth =
    jsonDecode(File('tool/ts2dart/batch117_truth.json').readAsStringSync())
        as Map<String, dynamic>;

Object? _source(Object? value) {
  if (value is cr.IExtensionInfo) {
    return <String, Object?>{
      'id': value.id,
      if (value.displayName != null) 'displayName': value.displayName,
    };
  }
  if (value is Map) {
    return value.map<String, Object?>((Object? key, Object? v) =>
        MapEntry<String, Object?>(key.toString(), v));
  }
  return value;
}

Object? _normalize(Object? value, [String? field]) {
  if (field == 'defaultValueSource' && value is Map) {
    return <String, Object?>{
      '__map': value.entries
          .map((MapEntry<Object?, Object?> entry) => <Object?>[
                entry.key.toString(),
                _source(entry.value),
              ])
          .toList(),
    };
  }
  if (value is Set) {
    final List<Object?> items =
        value.map((Object? item) => _normalize(item)).toList();
    items.sort();
    return items;
  }
  if (value is Map) {
    return value.map<String, Object?>((Object? key, Object? v) =>
        MapEntry<String, Object?>(key.toString(), _normalize(v)));
  }
  if (value is List) {
    return value.map((Object? item) => _normalize(item)).toList();
  }
  return value;
}

Map<String, Object?>? _prop(
  cr.ConfigurationRegistry registry,
  String key,
  List<String> fields,
) {
  final cr.IRegisteredConfigurationPropertySchema? property =
      registry.getConfigurationProperties()[key];
  if (property == null) return null;
  final Map<String, Object?> result = <String, Object?>{};
  for (final String field in fields) {
    if (property.containsKey(field)) {
      result[field] = _normalize(property[field], field);
    }
  }
  return result;
}

Map<String, Object?> _props(
  cr.ConfigurationRegistry registry,
  Iterable<String> keys,
  List<String> fields,
) {
  final Map<String, Object?> result = <String, Object?>{};
  for (final String key in keys) {
    result[key] = _prop(registry, key, fields);
  }
  return result;
}

Map<String, Object?> _eventJson(
    cr.IConfigurationUpdateConfigurationEvent event) {
  final Map<String, Object?> result = <String, Object?>{
    'properties': event.properties.toList()..sort(),
  };
  if (event.defaultsOverrides is bool) {
    result['defaultsOverrides'] = event.defaultsOverrides;
  }
  return result;
}

void main() {
  setUpAll(() {
    product.resetProductForTest();
    product.vscodeProductJsonProvider = () => <String, Object?>{
          'defaultChatAgent': <String, Object?>{
            'extensionId': 'GitHub.Copilot',
            'chatExtensionId': 'GitHub.Copilot-Chat',
          },
        };
    product.vscodePackageJsonProvider = () => <String, Object?>{
          'version': '1.0.0',
        };
  });

  test('batch117 helpers follow TypeScript runtime truth', () {
    final Map<String, dynamic> t =
        _truth['helpers'] as Map<String, dynamic>;

    expect(cr.EditPresentationTypes.Multiline, t['editPresentation']['Multiline']);
    expect(cr.EditPresentationTypes.Singleline,
        t['editPresentation']['Singleline']);
    expect(cr.AgentHostConfigurationSyncScope.All, t['agentHostScope']['All']);
    expect(cr.AgentHostConfigurationSyncScope.Local, t['agentHostScope']['Local']);
    expect(cr.AgentHostConfigurationSyncScope.Ambient,
        t['agentHostScope']['Ambient']);
    expect(cr.Extensions.Configuration, t['extensions']['Configuration']);
    expect(cr.resourceLanguageSettingsSchemaId, t['schemaIds'][0]);
    expect(cr.configurationDefaultsSchemaId, t['schemaIds'][1]);

    final List<Object?> types = <Object?>[
      'boolean', 'integer', 'number', 'string', 'array', 'object', 'unknown', null
    ];
    for (int i = 0; i < types.length; i++) {
      expect(_normalize(cr.getDefaultValue(types[i])),
          _normalize(t['getDefaultValue'][i] as Object?));
    }

    final List<String> scopes = <String>[
      'application', 'machine', 'resource', 'machine-overridable',
      'language-overridable', 'window', 'other'
    ];
    expect(scopes.map(cr.parseScope).toList(), t['parseScope']);

    expect(
      cr.getConfigurationExperimentName('a.b', null),
      (t['experimentNames'] as List)[0],
    );
    expect(
      cr.getConfigurationExperimentName(
          'a.b', <String, Object?>{'name': 'exp'}),
      (t['experimentNames'] as List)[1],
    );
    expect(
      cr.getConfigurationKeyExperimentName('a.b', null, 'k'),
      (t['experimentNames'] as List)[2],
    );

    final List<String> keys = <String>[
      '[lang]', '[ lang ][ts]', 'plain', '[a][b][a]'
    ];
    expect(keys.map(cr.overrideIdentifiersFromKey).toList(),
        t['overrideIdentifiersFromKey']);
    expect(
      <List<String>>[
        <String>[],
        <String>['lang'],
        <String>['lang', 'ts'],
      ].map(cr.keyFromOverrideIdentifiers).toList(),
      t['keyFromOverrideIdentifiers'],
    );

    final List<bool> sourceEquals = <bool>[
      cr.isConfigurationDefaultSourceEquals(null, null),
      cr.isConfigurationDefaultSourceEquals('a', 'a'),
      cr.isConfigurationDefaultSourceEquals('a', 'b'),
      cr.isConfigurationDefaultSourceEquals(null, 'a'),
      cr.isConfigurationDefaultSourceEquals(
          cr.IExtensionInfo('x'), cr.IExtensionInfo('x')),
      cr.isConfigurationDefaultSourceEquals(
          cr.IExtensionInfo('x'), cr.IExtensionInfo('y')),
      cr.isConfigurationDefaultSourceEquals('x', cr.IExtensionInfo('x')),
    ];
    expect(sourceEquals, t['sourceEquals']);

    final Map<String, Object?> all = _normalize(
            cr.getAllConfigurationProperties(<cr.IConfigurationNode>[
          cr.IConfigurationNode(
            properties: <String, cr.IConfigurationPropertySchema>{
              'a': <String, Object?>{'type': 'string'},
            },
            allOf: <cr.IConfigurationNode>[
              cr.IConfigurationNode(
                properties: <String, cr.IConfigurationPropertySchema>{
                  'b': <String, Object?>{'type': 'number'},
                },
              ),
            ],
          ),
          cr.IConfigurationNode(
            properties: <String, cr.IConfigurationPropertySchema>{
              'c': <String, Object?>{'type': 'boolean'},
            },
          ),
        ]))! as Map<String, Object?>;
    expect(all, t['getAllConfigurationProperties']);

    expect(cr.OVERRIDE_PROPERTY_PATTERN, t['pattern'][0]);
    expect(cr.OVERRIDE_PROPERTY_REGEX.pattern, t['pattern'][1]);
  });

  test('batch117 registration and schema maps follow TypeScript runtime truth', () {
    final Map<String, dynamic> t =
        _truth['registration'] as Map<String, dynamic>;
    final Map<String, dynamic> before =
        (t['before'] as Map<String, dynamic>);
    final Map<String, dynamic> after =
        (t['after'] as Map<String, dynamic>);
    final cr.ConfigurationRegistry registry = cr.ConfigurationRegistry();

    final cr.IConfigurationNode node = cr.IConfigurationNode(
      id: 'grp',
      title: 'Group',
      order: 5,
      scope: cr.ConfigurationScope.RESOURCE,
      restrictedProperties: <String>['restricted'],
      properties: <String, cr.IConfigurationPropertySchema>{
        'app': <String, Object?>{
          'type': 'boolean',
          'scope': cr.ConfigurationScope.APPLICATION,
          'default': true,
        },
        'num': <String, Object?>{'type': 'number'},
        'str': <String, Object?>{'type': 'string'},
        'arr': <String, Object?>{'type': 'array'},
        'obj': <String, Object?>{'type': <Object?>['object', 'null']},
        'unknown': <String, Object?>{},
        'restricted': <String, Object?>{'type': 'boolean'},
        'lang': <String, Object?>{
          'type': 'string',
          'scope': cr.ConfigurationScope.LANGUAGE_OVERRIDABLE,
        },
        'deprecated': <String, Object?>{
          'type': 'string',
          'markdownDeprecationMessage': 'md',
        },
        'experiment': <String, Object?>{
          'type': 'boolean',
          'experiment': <String, Object?>{'mode': 'auto'},
        },
        'hidden': <String, Object?>{'type': 'string', 'included': false},
      },
      allOf: <cr.IConfigurationNode>[
        cr.IConfigurationNode(
          id: 'sub',
          properties: <String, cr.IConfigurationPropertySchema>{
            'sub.key': <String, Object?>{'type': 'string'},
          },
        ),
      ],
    );

    const List<String> fields = <String>[
      'default', 'scope', 'restricted', 'section', 'tags',
      'deprecationMessage', 'source'
    ];
    final List<String> keys = <String>[
      'app', 'num', 'str', 'arr', 'obj', 'unknown', 'restricted',
      'lang', 'deprecated', 'experiment', 'sub.key'
    ];

    registry.registerConfiguration(node);
    expect(
      _props(registry, keys, fields),
      before['properties'],
    );
    expect(
        registry.getExcludedConfigurationProperties().keys.toList()..sort(),
        before['excluded']);
    expect(node.properties!.keys.toList(), before['nodePropertyKeys']);
    expect(registry.getConfigurations().map((cr.IConfigurationNode n) => n.id).toList(),
        before['contributors']);
    expect(cr.allSettings.properties.keys.toList()..sort(),
        before['allSettings']);
    expect(cr.applicationSettings.properties.keys.toList()..sort(),
        before['applicationSettings']);
    expect(cr.resourceSettings.properties.keys.toList()..sort(),
        before['resourceSettings']);
    expect(cr.windowSettings.properties.keys.toList()..sort(),
        before['windowSettings']);

    registry.deregisterConfigurations(<cr.IConfigurationNode>[node]);
    expect(_props(registry, keys, fields), after['properties']);
    expect(registry.getConfigurations().map((cr.IConfigurationNode n) => n.id).toList(),
        after['contributors']);
    expect(cr.allSettings.properties.keys.toList()..sort(),
        after['allSettings']);
    expect(cr.resourceSettings.properties.keys.toList()..sort(),
        after['resourceSettings']);
  });

  test('batch117 default overrides merge and deregistration follow TypeScript runtime truth', () {
    final Map<String, dynamic> t =
        _truth['defaults'] as Map<String, dynamic>;
    final cr.ConfigurationRegistry registry = cr.ConfigurationRegistry();
    registry.registerConfiguration(cr.IConfigurationNode(
      id: 'test',
      type: 'object',
      properties: <String, cr.IConfigurationPropertySchema>{
        'config': <String, Object?>{'type': 'object'},
        'config.preventDefaultValueOverride': <String, Object?>{
          'type': 'object',
          'default': <String, Object?>{'a': 0},
          'disallowConfigurationDefault': true,
        },
        'scalar': <String, Object?>{'type': 'string', 'default': 'base'},
      },
    ));

    const List<String> fields = <String>[
      'default', 'defaultDefaultValue', 'defaultValueSource',
      'section', 'type', 'description', r'$ref'
    ];

    registry.registerDefaultConfigurations(<cr.IConfigurationDefaults>[
      cr.IConfigurationDefaults(<String, Object?>{
        'config': <String, Object?>{'a': 1, 'b': 2},
      }),
    ]);
    expect(_prop(registry, 'config', fields), t['afterFirst']);

    registry.registerDefaultConfigurations(<cr.IConfigurationDefaults>[
      cr.IConfigurationDefaults(<String, Object?>{
        '[lang]': <String, Object?>{'a': 2, 'c': 3},
      }),
    ]);
    expect(_prop(registry, '[lang]', fields), t['afterLang']);

    registry.registerDefaultConfigurations(<cr.IConfigurationDefaults>[
      cr.IConfigurationDefaults(<String, Object?>{
        'config': <String, Object?>{'a': 2, 'c': 3},
      }),
    ]);
    expect(_prop(registry, 'config', fields), t['afterMerge']);

    registry.registerDefaultConfigurations(<cr.IConfigurationDefaults>[
      cr.IConfigurationDefaults(<String, Object?>{
        'config.preventDefaultValueOverride': <String, Object?>{
          'a': 1,
          'b': 2,
        },
      }),
    ]);
    expect(_prop(registry, 'config.preventDefaultValueOverride', fields),
        t['prevented']);

    registry.registerDefaultConfigurations(<cr.IConfigurationDefaults>[
      cr.IConfigurationDefaults(<String, Object?>{'scalar': 'override'}),
    ]);
    expect(_prop(registry, 'scalar', fields), t['scalar']);

    final List<cr.IConfigurationDefaults> o1 =
        <cr.IConfigurationDefaults>[
      cr.IConfigurationDefaults(
        <String, Object?>{
          'config': <String, Object?>{'a': 1, 'b': 2},
        },
        source: cr.IExtensionInfo('s1', 's1'),
      ),
    ];
    final List<cr.IConfigurationDefaults> o2 =
        <cr.IConfigurationDefaults>[
      cr.IConfigurationDefaults(
        <String, Object?>{
          'config': <String, Object?>{'a': 2, 'c': 3},
        },
        source: cr.IExtensionInfo('s2', 's2'),
      ),
    ];
    registry.registerDefaultConfigurations(o1);
    registry.registerDefaultConfigurations(o2);
    expect(_prop(registry, 'config', fields), t['withSources']);

    registry.deregisterDefaultConfigurations(o2);
    expect(_prop(registry, 'config', fields), t['afterDereg2']);

    registry.deregisterDefaultConfigurations(o1);
    expect(_prop(registry, 'config', fields), t['afterDereg1']);
    expect(registry.getRegisteredDefaultConfigurations().length,
        t['registeredCount']);
    expect(
      _normalize(registry.getConfigurationDefaultsOverrides()
          .map((String key, cr.IConfigurationDefaultOverrideValue value) {
            final Object? source = value.source;
            return MapEntry<String, Object?>(key, <String, Object?>{
              'value': _normalize(value.value),
              if (source is Map || source is String ||
                  source is cr.IExtensionInfo)
                'source': _normalize(source, 'defaultValueSource'),
            });
          })),
      t['overrides'],
    );
    expect(cr.overrideIdentifiersFromKey('[lang]'), t['overrideIdentifiers']);
  });

  test('batch117 policy, excluded properties and events follow TypeScript runtime truth', () {
    final Map<String, dynamic> policyTruth =
        _truth['policy'] as Map<String, dynamic>;
    Map<String, Object?> policyDef(String name) =>
        <String, Object?>{
          'name': name,
          'category': 'Extensions',
          'minimumVersion': '1.0.0',
          'localization': <String, Object?>{
            'description': <String, Object?>{'key': name, 'value': ''},
          },
        };
    final cr.ConfigurationRegistry registry = cr.ConfigurationRegistry();
    final cr.IConfigurationNode node = cr.IConfigurationNode(
      id: 'test',
      properties: <String, cr.IConfigurationPropertySchema>{
        'policy.1': <String, Object?>{'type': 'boolean', 'policy': policyDef('duplicate')},
        'policy.2': <String, Object?>{'type': 'boolean', 'policy': policyDef('duplicate')},
        'policy.owner': <String, Object?>{'type': 'boolean', 'policy': policyDef('shared')},
        'policy.subordinate': <String, Object?>{
          'type': 'boolean',
          'policyReference': <String, Object?>{'name': 'shared'},
        },
        'policy.orphan': <String, Object?>{
          'type': 'boolean',
          'policyReference': <String, Object?>{'name': 'external'},
        },
        'policy.both': <String, Object?>{
          'type': 'boolean',
          'policy': policyDef('both'),
          'policyReference': <String, Object?>{'name': 'bothRef'},
        },
        'hidden.sync': <String, Object?>{
          'type': 'string',
          'included': false,
          'agentHost': <String, Object?>{'key': 'host.key'},
        },
        'hidden.policy': <String, Object?>{
          'type': 'string',
          'included': false,
          'policy': policyDef('hiddenPolicy'),
        },
        'hidden.exp': <String, Object?>{
          'type': 'string',
          'included': false,
          'experiment': <String, Object?>{'mode': 'startup'},
        },
      },
    );
    registry.registerConfiguration(node);

    expect(
      _props(
        registry,
        registry.getConfigurationProperties().keys,
        <String>[
          'policy', 'policyReference', 'included', 'experiment', 'tags', 'agentHost'
        ],
      ),
      policyTruth['properties'],
    );
    expect(registry.getExcludedConfigurationProperties().keys.toList()..sort(),
        policyTruth['excluded']);
    expect(registry.getPolicyConfigurations(), policyTruth['policies']);
    expect(
      registry.getPolicyReferenceConfigurations().map(
          (String key, Set<String> value) =>
              MapEntry<String, Object?>(key, value.toList()..sort())),
      policyTruth['references'],
    );
    expect(registry.getAgentHostSyncConfigurations().keys.toList()..sort(),
        policyTruth['agentHosts']);
    expect(node.properties!.keys.toList()..sort(),
        policyTruth['nodePropertyKeys']);

    final Map<String, dynamic> eventTruth =
        _truth['events'] as Map<String, dynamic>;
    final cr.ConfigurationRegistry eventRegistry = cr.ConfigurationRegistry();
    int schema = 0;
    final List<Map<String, Object?>> updates = <Map<String, Object?>>[];
    eventRegistry.onDidSchemaChange((Object? _) {
      schema++;
    });
    eventRegistry.onDidUpdateConfiguration((Object? e) {
      updates.add(_eventJson(e as cr.IConfigurationUpdateConfigurationEvent));
    });
    final cr.IConfigurationNode a = cr.IConfigurationNode(
      id: 'a',
      properties: <String, cr.IConfigurationPropertySchema>{
        'a': <String, Object?>{'type': 'boolean'},
      },
    );
    final cr.IConfigurationNode b = cr.IConfigurationNode(
      id: 'b',
      properties: <String, cr.IConfigurationPropertySchema>{
        'b': <String, Object?>{'type': 'boolean'},
      },
    );
    final cr.IConfigurationDefaults aDefault = cr.IConfigurationDefaults(
        <String, Object?>{'a': true});
    final cr.IConfigurationDefaults bDefault = cr.IConfigurationDefaults(
        <String, Object?>{'b': false});
    eventRegistry.registerConfiguration(a);
    eventRegistry.registerDefaultConfigurations(<cr.IConfigurationDefaults>[
      aDefault
    ]);
    eventRegistry.notifyConfigurationSchemaUpdated(<cr.IConfigurationNode>[a]);
    eventRegistry.registerOverrideIdentifiers(<String>['lang']);
    eventRegistry.updateConfigurations(
      add: <cr.IConfigurationNode>[b],
      remove: <cr.IConfigurationNode>[a],
    );
    eventRegistry.deltaConfiguration(cr.IConfigurationDelta(
      removedDefaults: <cr.IConfigurationDefaults>[aDefault],
      addedDefaults: <cr.IConfigurationDefaults>[bDefault],
      removedConfigurations: <cr.IConfigurationNode>[b],
      addedConfigurations: <cr.IConfigurationNode>[a],
    ));
    expect(schema, eventTruth['schema']);
    expect(updates, eventTruth['updates']);
  });

  test('batch117 validateProperty follows TypeScript runtime truth', () {
    final Map<String, dynamic> t =
        _truth['validate'] as Map<String, dynamic>;
    final cr.IConfigurationNode base = cr.IConfigurationNode(
      id: 'base',
      properties: <String, cr.IConfigurationPropertySchema>{
        'foo': <String, Object?>{'type': 'boolean'},
      },
    );
    Map<String, Object?> policy(String name) => <String, Object?>{
          'name': name,
          'category': 'Extensions',
          'minimumVersion': '1.0.0',
          'localization': <String, Object?>{
            'description': <String, Object?>{'key': name, 'value': ''},
          },
        };
    final cr.IConfigurationNode policyOwner = cr.IConfigurationNode(
      id: 'policyOwner',
      properties: <String, cr.IConfigurationPropertySchema>{
        'owner': <String, Object?>{
          'type': 'boolean',
          'policy': policy('existing'),
        },
      },
    );
    final cr.IConfigurationNode agentOwner = cr.IConfigurationNode(
      id: 'agentOwner',
      properties: <String, cr.IConfigurationPropertySchema>{
        'mirror': <String, Object?>{
          'type': 'string',
          'agentHost': <String, Object?>{'key': 'host.key'},
        },
      },
    );
    final cr.ConfigurationRegistry registry = cr.configurationRegistry;
    registry.registerConfiguration(base);
    registry.registerConfiguration(policyOwner);
    registry.registerConfiguration(agentOwner);

    const cr.IConfigurationPropertySchema p = <String, Object?>{'type': 'boolean'};
    expect(cr.validateProperty(' ', p), t['empty']);
    expect(cr.validateProperty('[lang]', p), t['overridePattern']);
    expect(cr.validateProperty('foo', p), t['duplicate']);
    expect(cr.validateProperty('foo', p, 'GitHub.Copilot'),
        t['duplicateUnified']);
    expect(cr.validateProperty('foo', p, 'other.ext'), t['duplicateOther']);
    expect(
      cr.validateProperty('bar', <String, Object?>{
        'type': 'boolean',
        'policy': policy('new'),
        'policyReference': <String, Object?>{'name': 'ref'},
      }),
      t['both'],
    );
    expect(
      cr.validateProperty('baz', <String, Object?>{
        'type': 'boolean',
        'policy': policy('existing'),
      }),
      t['duplicatePolicy'],
    );
    expect(
      cr.validateProperty('other.mirror', <String, Object?>{
        'type': 'string',
        'agentHost': <String, Object?>{'key': 'host.key'},
      }),
      t['duplicateAgentHost'],
    );
    expect(cr.validateProperty('new.key', p), t['valid']);
    expect(cr.EXTENSION_UNIFICATION_EXTENSION_IDS.toList()..sort(),
        t['unificationIds']);

    registry.deregisterConfigurations(<cr.IConfigurationNode>[
      base,
      policyOwner,
      agentOwner,
    ]);
  });
}
