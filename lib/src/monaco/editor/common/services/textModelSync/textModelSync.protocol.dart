// 1:1 port of vs/editor/common/services/textModelSync/textModelSync.protocol.ts

import '../../model/mirrorTextModel.dart' show IModelChangedEvent;

/// 1:1: `export interface IWorkerTextModelSyncChannelServer`
abstract class IWorkerTextModelSyncChannelServer {
  void acceptNewModel(IRawModelData data);
  void acceptModelChanged(String strURL, IModelChangedEvent e);
  void acceptRemovedModel(String strURL);
}

/// 1:1: `export interface IRawModelData`
abstract class IRawModelData {
  String get url;
  int get versionId;
  List<String> get lines;
  String get EOL;
}

/// 1:1 default value carrier for [IRawModelData].
class RawModelData implements IRawModelData {
  @override
  final String url;
  @override
  final int versionId;
  @override
  final List<String> lines;
  @override
  final String EOL;

  RawModelData({
    required this.url,
    required this.versionId,
    required this.lines,
    required this.EOL,
  });
}
