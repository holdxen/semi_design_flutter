// 1:1 port of vs/base/browser/ui/aria/aria.ts
import '../../dom.dart' as dom;
import '../../dom.dart' show DomElement;

// Use a max length since we are inserting the whole msg in the DOM and that can cause browsers to freeze for long messages #94233
const int MAX_MESSAGE_LENGTH = 20000;

DomElement? ariaContainer;
DomElement? alertContainer;
DomElement? alertContainer2;
DomElement? statusContainer;
DomElement? statusContainer2;

/// 1:1: `setARIAContainer`
void setARIAContainer(DomElement parent) {
  ariaContainer = dom.document.createElement('div');
  ariaContainer!.className = 'monaco-aria-container';

  DomElement createAlertContainer() {
    final DomElement element = dom.document.createElement('div');
    element.className = 'monaco-alert';
    element.setAttribute('role', 'alert');
    element.setAttribute('aria-atomic', 'true');
    ariaContainer!.appendChild(element);
    return element;
  }

  alertContainer = createAlertContainer();
  alertContainer2 = createAlertContainer();

  DomElement createStatusContainer() {
    final DomElement element = dom.document.createElement('div');
    element.className = 'monaco-status';
    element.setAttribute('aria-live', 'polite');
    element.setAttribute('aria-atomic', 'true');
    ariaContainer!.appendChild(element);
    return element;
  }

  statusContainer = createStatusContainer();
  statusContainer2 = createStatusContainer();

  parent.appendChild(ariaContainer!);
}

/// Given the provided message, will make sure that it is read as alert to screen readers.
void alert(String msg) {
  final DomElement? container = ariaContainer;
  if (container == null) return;

  // Use alternate containers such that duplicated messages get read out by screen readers #99466
  if (alertContainer!.textContent != msg) {
    dom.clearNode(alertContainer2!);
    insertMessage(alertContainer!, msg);
  } else {
    dom.clearNode(alertContainer!);
    insertMessage(alertContainer2!, msg);
  }
}

/// Given the provided message, will make sure that it is read as status to screen readers.
void status(String msg) {
  final DomElement? container = ariaContainer;
  if (container == null) return;

  if (statusContainer!.textContent != msg) {
    dom.clearNode(statusContainer2!);
    insertMessage(statusContainer!, msg);
  } else {
    dom.clearNode(statusContainer!);
    insertMessage(statusContainer2!, msg);
  }
}

void insertMessage(DomElement target, String msg) {
  dom.clearNode(target);
  if (msg.length > MAX_MESSAGE_LENGTH) {
    msg = msg.substring(0, MAX_MESSAGE_LENGTH);
  }
  target.textContent = msg;

  // See https://www.paciellogroup.com/blog/2012/06/html5-accessibility-chops-aria-rolealert-browser-support/
  target.style.setProperty('visibility', 'hidden');
  target.style.setProperty('visibility', 'visible');
}

/// Copied from @types/react which original came from https://www.w3.org/TR/wai-aria-1.1/#role_definitions
typedef AriaRole = String;
