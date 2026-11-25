// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/browser/controller/imeRecordedTypes.ts
// Translated 1:1 from TypeScript interfaces. TS interfaces become concrete
// Dart carriers; unions become an abstract marker implemented by members.
// ---------------------------------------------------------------------------

/// 1:1: `IRecordedTextareaState`.
class IRecordedTextareaState {
  String selectionDirection;
  int selectionEnd;
  int selectionStart;
  String value;

  IRecordedTextareaState({
    this.selectionDirection = 'none',
    this.selectionEnd = 0,
    this.selectionStart = 0,
    this.value = '',
  });
}

/// 1:1: `IRecordedEvent` union marker.
abstract class IRecordedEvent {}

/// 1:1: `IRecordedKeyboardEvent`.
class IRecordedKeyboardEvent extends IRecordedEvent {
  int timeStamp;
  IRecordedTextareaState state;
  String type;
  bool altKey;
  int charCode;
  String code;
  bool ctrlKey;
  bool isComposing;
  String key;
  int keyCode;
  int location;
  bool metaKey;
  bool repeat;
  bool shiftKey;

  IRecordedKeyboardEvent({
    this.timeStamp = 0,
    required this.state,
    this.type = 'keydown',
    this.altKey = false,
    this.charCode = 0,
    this.code = '',
    this.ctrlKey = false,
    this.isComposing = false,
    this.key = '',
    this.keyCode = 0,
    this.location = 0,
    this.metaKey = false,
    this.repeat = false,
    this.shiftKey = false,
  });
}

/// 1:1: `IRecordedCompositionEvent`.
class IRecordedCompositionEvent extends IRecordedEvent {
  int timeStamp;
  IRecordedTextareaState state;
  String type;
  String data;

  IRecordedCompositionEvent({
    this.timeStamp = 0,
    required this.state,
    this.type = 'compositionstart',
    this.data = '',
  });
}

/// 1:1: `IRecordedInputEvent`.
class IRecordedInputEvent extends IRecordedEvent {
  int timeStamp;
  IRecordedTextareaState state;
  String type;
  String? data;
  String inputType;
  bool? isComposing;

  IRecordedInputEvent({
    this.timeStamp = 0,
    required this.state,
    this.type = 'input',
    this.data,
    this.inputType = '',
    this.isComposing,
  });
}

/// 1:1: `IRecorded.env` carrier.
class IRecordedEnv {
  final Object OS;
  final Object browser;

  IRecordedEnv(this.OS, this.browser);
}

/// 1:1: `IRecorded`. `final` is a Dart keyword, so the source's `final`
/// field is carried as [finalState].
class IRecorded {
  IRecordedEnv env;
  IRecordedTextareaState initial;
  List<IRecordedEvent> events;
  IRecordedTextareaState finalState;

  IRecorded({
    required this.env,
    required this.initial,
    required this.events,
    required this.finalState,
  });
}
