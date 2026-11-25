// 1:1 port of vs/editor/common/services/model.ts
// Declaration-only module: 1 decorator + IModelService interface + alias.
// ITextModel / ITextBufferFactory / ITextModelCreationOptions come from the
// still-pending ../model.ts, so opaque local carriers are used.
// Runtime truth: tool/ts2dart/_batch272_truth.cjs (recursive TS transpile+vm).

import '../../../base/common/event.dart' show Event;
import '../../../base/common/uri.dart' show URI;
import '../../../platform/instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
import '../languages/language.dart' show ILanguageSelection;
import '../textModelEditSource.dart' show TextModelEditSource;

/// 1:1: `export const IModelService = createDecorator<...>('modelService')`
final ServiceIdentifier<IModelServiceType> IModelService =
    createDecorator<IModelServiceType>('modelService');

/// 1:1: `DocumentTokensProvider = DocumentSemanticTokensProvider | DocumentRangeSemanticTokensProvider`
/// (erased union of pending provider interfaces)
typedef DocumentTokensProvider = Object?;

/// 1:1: `ITextModel` (from `../model.ts`, pending) — opaque carrier.
abstract class ITextModelForModelService {}

/// 1:1: `ITextBufferFactory` (from `../model.ts`, pending) — opaque carrier.
abstract class ITextBufferFactoryForModelService {}

/// 1:1: `ITextModelCreationOptions` (from `../model.ts`, pending) — opaque carrier.
abstract class ITextModelCreationOptionsForModelService {}

/// 1:1: `IModelService` (const keeps bare name)
abstract class IModelServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  ITextModelForModelService createModel(
    Object value,
    ILanguageSelection? languageSelection, [
    URI? resource,
    bool isForSimpleWidget = false,
  ]);

  void updateModel(
    ITextModelForModelService model,
    Object value, [
    TextModelEditSource? reason,
  ]);

  void destroyModel(URI resource);

  List<ITextModelForModelService> getModels();

  ITextModelCreationOptionsForModelService getCreationOptions(
    String language,
    URI resource,
    bool isForSimpleWidget,
  );

  ITextModelForModelService? getModel(URI resource);

  Event<ITextModelForModelService> get onModelAdded;
  Event<ITextModelForModelService> get onModelRemoved;
  Event<({ITextModelForModelService model, String oldLanguageId})>
      get onModelLanguageChanged;
}
