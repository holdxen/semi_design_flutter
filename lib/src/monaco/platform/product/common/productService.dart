// 1:1 port of vs/platform/product/common/productService.ts
import '../../../base/common/product.dart' show IProductConfiguration;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;

/// 1:1: `export const IProductService = createDecorator<IProductService>('productService')`
final ServiceIdentifier<IProductServiceType> IProductService =
    createDecorator<IProductServiceType>('productService');

/// 1:1: `export interface IProductService extends Readonly<IProductConfiguration>`
/// TS `Readonly<T>` is structural; Dart carries it by extending the config
/// type's fields through a [IProductConfiguration] field plus the brand.
abstract class IProductServiceType implements IProductConfiguration {
  // ignore: unused_element
  Object? get _serviceBrand;
}

/// 1:1: `export const productSchemaId = 'vscode://schemas/vscode-product'`
const String productSchemaId = 'vscode://schemas/vscode-product';
