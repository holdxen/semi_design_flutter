// 1:1 port of vscode/src/vs/base/common/validation.ts
// 严格 1:1 翻译，勿改类名/API。TS 编译期类型层（mapped/conditional types）在 Dart 中
// 用 dynamic/Map 承载；运行时的 validator 组合语义保持逐字对应。
import 'arrays.dart' show mapFilter;
import 'jsonSchema.dart' show IJSONSchema, IJSONSchemaMap;

/// 1:1: `export interface ValidationError { message: string }`
class ValidationError {
  final String message;
  const ValidationError(this.message);

  @override
  String toString() => message;
}

/// 1:1: `export interface IValidator<T>` 的 validate 返回 union
/// `{ content: T; error: undefined } | { content: undefined; error: ValidationError }`
/// Dart 用 carrier 承载两支：`error != null` 即失败支，否则 `content` 为结果。
class ValidationResult<T> {
  final T? content;
  final ValidationError? error;

  /// 成功支（error: undefined）
  const ValidationResult.ok(T content) : content = content, error = null;
  /// 失败支（content: undefined）
  const ValidationResult.fail(ValidationError error) : content = null, error = error;

  bool get isError => error != null;
}

/// 1:1: `export interface IValidator<T>`
abstract class IValidator<T> {
  ValidationResult<T> validate(dynamic content);
  IJSONSchema getJSONSchema();
}

/// 1:1: `export abstract class ValidatorBase<T> implements IValidator<T>`
abstract class ValidatorBase<T> implements IValidator<T> {
  @override
  ValidationResult<T> validate(dynamic content);

  @override
  IJSONSchema getJSONSchema();

  /// 1:1: `validateOrThrow`
  T validateOrThrow(dynamic content) {
    final ValidationResult<T> result = validate(content);
    if (result.error != null) {
      throw Exception(result.error!.message);
    }
    return result.content as T;
  }
}

/// JS `typeof` 语义的最小承载。Dart 无 JS 的 undefined，用 null 代表 undefined。
/// 注意 JS `typeof null === 'object'`，但此处入参的 null 承载的是 undefined，
/// 故返回 'undefined'（与 `UndefinedValidator` 的语义一致）。
String _jsTypeOf(dynamic content) {
  if (content == null) return 'undefined';
  if (content is String) return 'string';
  if (content is bool) return 'boolean';
  if (content is num) return 'number';
  if (content is Function) return 'function';
  // JS typeof 对 object/array/map 均为 'object'
  return 'object';
}

/// 1:1: `class TypeofValidator<TKey extends keyof TypeOfMap> extends ValidatorBase`
class TypeofValidator<T> extends ValidatorBase<T> {
  final String type;
  TypeofValidator(this.type);

  @override
  ValidationResult<T> validate(dynamic content) {
    if (_jsTypeOf(content) != type) {
      return ValidationResult.fail(
        ValidationError('Expected $type, but got ${_jsTypeOf(content)}'),
      );
    }
    return ValidationResult.ok(content as T);
  }

  @override
  IJSONSchema getJSONSchema() => <String, Object?>{'type': type};
}

final TypeofValidator<String> _vStringValidator = TypeofValidator<String>('string');

/// 1:1: `export function vString()`
ValidatorBase<String> vString() => _vStringValidator;

final TypeofValidator<num> _vNumberValidator = TypeofValidator<num>('number');

/// 1:1: `export function vNumber()`
ValidatorBase<num> vNumber() => _vNumberValidator;

final TypeofValidator<bool> _vBooleanValidator = TypeofValidator<bool>('boolean');

/// 1:1: `export function vBoolean()`
ValidatorBase<bool> vBoolean() => _vBooleanValidator;

final TypeofValidator<Object?> _vObjAnyValidator = TypeofValidator<Object?>('object');

/// 1:1: `export function vObjAny()`
ValidatorBase<Object?> vObjAny() => _vObjAnyValidator;

/// 1:1: `class UncheckedValidator<T>`
class UncheckedValidator<T> extends ValidatorBase<T> {
  @override
  ValidationResult<T> validate(dynamic content) => ValidationResult.ok(content as T);

  @override
  IJSONSchema getJSONSchema() => <String, Object?>{};
}

/// 1:1: `export function vUnchecked<T>()`
ValidatorBase<T> vUnchecked<T>() => UncheckedValidator<T>();

/// 1:1: `class UndefinedValidator`
class UndefinedValidator extends ValidatorBase<Object?> {
  @override
  ValidationResult<Object?> validate(dynamic content) {
    if (content != null) {
      return ValidationResult.fail(
        ValidationError('Expected undefined, but got ${_jsTypeOf(content)}'),
      );
    }
    return ValidationResult.ok(null);
  }

  @override
  IJSONSchema getJSONSchema() => <String, Object?>{};
}

/// 1:1: `export function vUndefined()`
ValidatorBase<Object?> vUndefined() => UndefinedValidator();

/// 1:1: `export function vUnknown()`
ValidatorBase<Object?> vUnknown() => vUnchecked<Object?>();

/// 1:1: `export type ObjectProperties = Record<string, unknown>`
typedef ObjectProperties = Map<String, dynamic>;

/// 1:1: `export class Optional<T extends IValidator<unknown>>`
class Optional<T> {
  final T validator;
  const Optional(this.validator);
}

/// 1:1: `export function vOptionalProp`
Optional<IValidator<T>> vOptionalProp<T>(IValidator<T> validator) => Optional(validator);

/// 1:1: `class ObjValidator`
class ObjValidator extends ValidatorBase<Map<String, dynamic>> {
  /// 源码 `properties: T`（Record<string, IValidator | Optional>）。
  /// Dart 用 Map<String, Object?> 承载，值为 IValidator 或 Optional。
  final Map<String, Object?> properties;
  ObjValidator(this.properties);

  @override
  ValidationResult<Map<String, dynamic>> validate(dynamic content) {
    if (_jsTypeOf(content) != 'object') {
      return const ValidationResult.fail(ValidationError('Expected object'));
    }

    final Map<String, dynamic> result = <String, dynamic>{};
    final Map<dynamic, dynamic> source = content as Map<dynamic, dynamic>;

    for (final String key in properties.keys) {
      final Object? prop = properties[key];
      final dynamic fieldValue = source[key];

      final bool isOptional = prop is Optional;
      final IValidator<dynamic> validator = prop is Optional
          ? prop.validator as IValidator<dynamic>
          : prop! as IValidator<dynamic>;

      if (isOptional && fieldValue == null) {
        // Optional field not provided, skip validation
        continue;
      }

      final ValidationResult<dynamic> validation = validator.validate(fieldValue);
      if (validation.error != null) {
        return ValidationResult.fail(
          ValidationError("Error in property '$key': ${validation.error!.message}"),
        );
      }

      result[key] = validation.content;
    }

    return ValidationResult.ok(result);
  }

  @override
  IJSONSchema getJSONSchema() {
    final List<String> requiredFields = <String>[];
    final IJSONSchemaMap schemaProperties = <String, IJSONSchema>{};

    for (final MapEntry<String, Object?> entry in properties.entries) {
      final Object? prop = entry.value;
      final bool isOptional = prop is Optional;
      final IValidator<dynamic> validator = prop is Optional
          ? prop.validator as IValidator<dynamic>
          : prop! as IValidator<dynamic>;
      schemaProperties[entry.key] = validator.getJSONSchema();
      if (!isOptional) {
        requiredFields.add(entry.key);
      }
    }

    final IJSONSchema schema = <String, Object?>{
      'type': 'object',
      'properties': schemaProperties,
    };
    if (requiredFields.isNotEmpty) {
      schema['required'] = requiredFields;
    }
    return schema;
  }
}

/// 1:1: `export function vObj`
ValidatorBase<Map<String, dynamic>> vObj(Map<String, Object?> properties) =>
    ObjValidator(properties);

/// 1:1: `class ArrayValidator<T>`
class ArrayValidator<T> extends ValidatorBase<List<T>> {
  final IValidator<T> validator;
  ArrayValidator(this.validator);

  @override
  ValidationResult<List<T>> validate(dynamic content) {
    if (content is! List) {
      return const ValidationResult.fail(ValidationError('Expected array'));
    }

    final List<T> result = <T>[];
    for (int i = 0; i < content.length; i++) {
      final ValidationResult<T> validation = validator.validate(content[i]);
      if (validation.error != null) {
        return ValidationResult.fail(
          ValidationError('Error in element $i: ${validation.error!.message}'),
        );
      }
      result.add(validation.content as T);
    }

    return ValidationResult.ok(result);
  }

  @override
  IJSONSchema getJSONSchema() => <String, Object?>{
        'type': 'array',
        'items': validator.getJSONSchema(),
      };
}

/// 1:1: `export function vArray<T>`
ValidatorBase<List<T>> vArray<T>(IValidator<T> validator) => ArrayValidator<T>(validator);

/// 1:1: `class TupleValidator`
class TupleValidator extends ValidatorBase<List<dynamic>> {
  final List<IValidator<dynamic>> validators;
  TupleValidator(this.validators);

  @override
  ValidationResult<List<dynamic>> validate(dynamic content) {
    if (content is! List) {
      return const ValidationResult.fail(ValidationError('Expected array'));
    }

    if (content.length != validators.length) {
      return ValidationResult.fail(
        ValidationError(
          'Expected tuple of length ${validators.length}, but got ${content.length}',
        ),
      );
    }

    final List<dynamic> result = <dynamic>[];
    for (int i = 0; i < validators.length; i++) {
      final ValidationResult<dynamic> validation = validators[i].validate(content[i]);
      if (validation.error != null) {
        return ValidationResult.fail(
          ValidationError('Error in element $i: ${validation.error!.message}'),
        );
      }
      result.add(validation.content);
    }

    return ValidationResult.ok(result);
  }

  @override
  IJSONSchema getJSONSchema() => <String, Object?>{
        'type': 'array',
        'items': validators.map((IValidator<dynamic> v) => v.getJSONSchema()).toList(),
      };
}

/// 1:1: `export function vTuple`
ValidatorBase<List<dynamic>> vTuple(List<IValidator<dynamic>> validators) =>
    TupleValidator(validators);

/// 1:1: `class UnionValidator`
class UnionValidator<T> extends ValidatorBase<T> {
  final List<IValidator<dynamic>> validators;
  UnionValidator(this.validators);

  @override
  ValidationResult<T> validate(dynamic content) {
    ValidationError? lastError;
    for (final IValidator<dynamic> validator in validators) {
      final ValidationResult<dynamic> validation = validator.validate(content);
      if (validation.error == null) {
        return ValidationResult.ok(validation.content as T);
      }
      lastError = validation.error;
    }

    return ValidationResult.fail(lastError ?? const ValidationError(''));
  }

  @override
  IJSONSchema getJSONSchema() => <String, Object?>{
        'oneOf': mapFilter<IValidator<dynamic>, IJSONSchema>(validators, (validator) {
          if (validator is UndefinedValidator) {
            return null;
          }
          return validator.getJSONSchema();
        }),
      };
}

/// 1:1: `export function vUnion`
ValidatorBase<T> vUnion<T>(List<IValidator<dynamic>> validators) =>
    UnionValidator<T>(validators);

/// 1:1: `class EnumValidator`
class EnumValidator<T> extends ValidatorBase<T> {
  final List<String> values;
  EnumValidator(this.values);

  @override
  ValidationResult<T> validate(dynamic content) {
    if (content is! String || !values.contains(content)) {
      return ValidationResult.fail(
        ValidationError('Expected one of: ${values.join(', ')}'),
      );
    }
    return ValidationResult.ok(content as T);
  }

  @override
  IJSONSchema getJSONSchema() => <String, Object?>{'enum': values};
}

/// 1:1: `export function vEnum`
ValidatorBase<T> vEnum<T>(List<String> values) => EnumValidator<T>(values);

/// 1:1: `class LiteralValidator`
class LiteralValidator<T> extends ValidatorBase<T> {
  final String value;
  LiteralValidator(this.value);

  @override
  ValidationResult<T> validate(dynamic content) {
    if (content != value) {
      return ValidationResult.fail(ValidationError('Expected: $value'));
    }
    return ValidationResult.ok(content as T);
  }

  @override
  IJSONSchema getJSONSchema() => <String, Object?>{'const': value};
}

/// 1:1: `export function vLiteral`
ValidatorBase<T> vLiteral<T>(String value) => LiteralValidator<T>(value);

/// 1:1: `class LazyValidator`
class LazyValidator<T> extends ValidatorBase<T> {
  final IValidator<T> Function() fn;
  LazyValidator(this.fn);

  @override
  ValidationResult<T> validate(dynamic content) => fn().validate(content);

  @override
  IJSONSchema getJSONSchema() => fn().getJSONSchema();
}

/// 1:1: `export function vLazy`
ValidatorBase<T> vLazy<T>(IValidator<T> Function() fn) => LazyValidator<T>(fn);

/// 1:1: `class UseRefSchemaValidator`
class UseRefSchemaValidator<T> extends ValidatorBase<T> {
  final String ref;
  final IValidator<T> validator;
  UseRefSchemaValidator(this.ref, this.validator);

  @override
  ValidationResult<T> validate(dynamic content) => validator.validate(content);

  @override
  IJSONSchema getJSONSchema() => <String, Object?>{'\$ref': ref};
}

/// 1:1: `export function vWithJsonSchemaRef`
ValidatorBase<T> vWithJsonSchemaRef<T>(String ref, IValidator<T> validator) =>
    UseRefSchemaValidator<T>(ref, validator);
