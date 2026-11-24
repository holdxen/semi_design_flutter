// 1:1 truth-driven tests for abstractKeybindingService.ts.
// Truth: tool/ts2dart/batch158_truth.json (real transpiled TypeScript runtime).
import 'dart:convert';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/event.dart' as event;
import 'package:semi_design_flutter/src/monaco/base/common/ime.dart' as ime;
import 'package:semi_design_flutter/src/monaco/base/common/keyCodes.dart' as keyCodes;
import 'package:semi_design_flutter/src/monaco/base/common/keybindings.dart' as kb;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart' as lifecycle;
import 'package:semi_design_flutter/src/monaco/platform/commands/common/commands.dart' as commands;
import 'package:semi_design_flutter/src/monaco/platform/contextkey/common/contextkey.dart' as contextkey;
import 'package:semi_design_flutter/src/monaco/platform/keybinding/common/abstractKeybindingService.dart' as aks;
import 'package:semi_design_flutter/src/monaco/platform/keybinding/common/keybinding.dart' as keybinding;
import 'package:semi_design_flutter/src/monaco/platform/keybinding/common/keybindingResolver.dart' as resolver;
import 'package:semi_design_flutter/src/monaco/platform/keybinding/common/resolvedKeybindingItem.dart' as resolvedItem;
import 'package:semi_design_flutter/src/monaco/platform/keybinding/test/common/mockKeybindingService.dart' as mock;
import 'package:semi_design_flutter/src/monaco/platform/log/common/log.dart' as log;
import 'package:semi_design_flutter/src/monaco/platform/notification/common/notification.dart' as notification;
import 'package:semi_design_flutter/src/monaco/platform/telemetry/common/telemetry.dart' as telemetry;
import 'package:semi_design_flutter/src/monaco/platform/telemetry/common/telemetryUtils.dart' as telemetryUtils;

final Map<String, dynamic> T =
    jsonDecode(r"""{
  "exports": [
    "AbstractKeybindingService"
  ],
  "simple": {
    "result": {
      "prevent": true,
      "inChordMode": false,
      "chords": []
    },
    "log": {
      "exec": [
        {
          "commandId": "myCommand",
          "args": [
            null
          ]
        }
      ],
      "status": [],
      "statusClosed": [],
      "showMessage": [],
      "telemetry": [
        {
          "name": "workbenchActionExecuted",
          "data": {
            "id": "myCommand",
            "from": "keybinding",
            "detail": "ctrl+k"
          }
        }
      ],
      "info": [],
      "trace": [
        [
          "KeybindingService#dispatch",
          "Ctrl+K",
          "[ Will dispatch command myCommand ]"
        ]
      ],
      "resolveCalls": [
        {
          "context": {},
          "currentChords": [],
          "chord": "ctrl+k"
        }
      ],
      "lookupCalls": [],
      "userBindingCalls": [],
      "ime": [],
      "timers": [],
      "warns": []
    }
  },
  "multiChord": {
    "result": {
      "first": {
        "prevent": true,
        "inChordMode": true,
        "chords": [
          "ctrl+k"
        ]
      },
      "second": {
        "prevent": true,
        "inChordMode": false,
        "chords": []
      }
    },
    "log": {
      "exec": [
        {
          "commandId": "myCommand",
          "args": [
            null
          ]
        }
      ],
      "status": [
        {
          "message": "(Ctrl+K) was pressed. Waiting for second key of chord...",
          "options": null
        }
      ],
      "statusClosed": [
        "(Ctrl+K) was pressed. Waiting for second key of chord..."
      ],
      "showMessage": [],
      "telemetry": [
        {
          "name": "workbenchActionExecuted",
          "data": {
            "id": "myCommand",
            "from": "keybinding",
            "detail": "ctrl+i"
          }
        }
      ],
      "info": [],
      "trace": [
        [
          "KeybindingService#dispatch",
          "Ctrl+K",
          "[ Several keybindings match - more chords needed ]"
        ],
        [
          "KeybindingService#dispatch",
          "Ctrl+I",
          "[ Will dispatch command myCommand ]"
        ]
      ],
      "resolveCalls": [
        {
          "context": {},
          "currentChords": [],
          "chord": "ctrl+k"
        },
        {
          "context": {},
          "currentChords": [
            "ctrl+k"
          ],
          "chord": "ctrl+i"
        }
      ],
      "lookupCalls": [],
      "userBindingCalls": [],
      "ime": [
        "disable",
        "enable"
      ],
      "timers": [
        {
          "kind": "interval.set",
          "ms": 500
        },
        {
          "kind": "interval.cancel"
        }
      ],
      "warns": []
    }
  },
  "emptyCommandSingle": {
    "result": {
      "prevent": false
    },
    "log": {
      "exec": [],
      "status": [],
      "statusClosed": [],
      "showMessage": [],
      "telemetry": [],
      "info": [],
      "trace": [
        [
          "KeybindingService#dispatch",
          "Ctrl+K",
          "[ Will dispatch command  ]"
        ]
      ],
      "resolveCalls": [
        {
          "context": {},
          "currentChords": [],
          "chord": "ctrl+k"
        }
      ],
      "lookupCalls": [],
      "userBindingCalls": [],
      "ime": [],
      "timers": [],
      "warns": []
    }
  },
  "nullCommandSingle": {
    "result": {
      "prevent": false
    },
    "log": {
      "exec": [],
      "status": [],
      "statusClosed": [],
      "showMessage": [],
      "telemetry": [],
      "info": [],
      "trace": [
        [
          "KeybindingService#dispatch",
          "Ctrl+K",
          "[ Will dispatch command null ]"
        ]
      ],
      "resolveCalls": [
        {
          "context": {},
          "currentChords": [],
          "chord": "ctrl+k"
        }
      ],
      "lookupCalls": [],
      "userBindingCalls": [],
      "ime": [],
      "timers": [],
      "warns": []
    }
  },
  "emptyCommandMulti": {
    "result": {
      "first": true,
      "second": true,
      "chords": []
    },
    "log": {
      "exec": [],
      "status": [
        {
          "message": "(Ctrl+K) was pressed. Waiting for second key of chord...",
          "options": null
        },
        {
          "message": "The key combination (Ctrl+K, Ctrl+I) is not a command.",
          "options": {
            "hideAfter": 10000
          }
        }
      ],
      "statusClosed": [
        "(Ctrl+K) was pressed. Waiting for second key of chord..."
      ],
      "showMessage": [],
      "telemetry": [],
      "info": [],
      "trace": [
        [
          "KeybindingService#dispatch",
          "Ctrl+K",
          "[ Several keybindings match - more chords needed ]"
        ],
        [
          "KeybindingService#dispatch",
          "Ctrl+I",
          "[ Will dispatch command  ]"
        ]
      ],
      "resolveCalls": [
        {
          "context": {},
          "currentChords": [],
          "chord": "ctrl+k"
        },
        {
          "context": {},
          "currentChords": [
            "ctrl+k"
          ],
          "chord": "ctrl+i"
        }
      ],
      "lookupCalls": [],
      "userBindingCalls": [],
      "ime": [
        "disable",
        "enable"
      ],
      "timers": [
        {
          "kind": "interval.set",
          "ms": 500
        },
        {
          "kind": "interval.cancel"
        }
      ],
      "warns": []
    }
  },
  "nullCommandMulti": {
    "result": {
      "first": true,
      "second": true,
      "chords": []
    },
    "log": {
      "exec": [],
      "status": [
        {
          "message": "(Ctrl+K) was pressed. Waiting for second key of chord...",
          "options": null
        },
        {
          "message": "The key combination (Ctrl+K, Ctrl+I) is not a command.",
          "options": {
            "hideAfter": 10000
          }
        }
      ],
      "statusClosed": [
        "(Ctrl+K) was pressed. Waiting for second key of chord..."
      ],
      "showMessage": [],
      "telemetry": [],
      "info": [],
      "trace": [
        [
          "KeybindingService#dispatch",
          "Ctrl+K",
          "[ Several keybindings match - more chords needed ]"
        ],
        [
          "KeybindingService#dispatch",
          "Ctrl+I",
          "[ Will dispatch command null ]"
        ]
      ],
      "resolveCalls": [
        {
          "context": {},
          "currentChords": [],
          "chord": "ctrl+k"
        },
        {
          "context": {},
          "currentChords": [
            "ctrl+k"
          ],
          "chord": "ctrl+i"
        }
      ],
      "lookupCalls": [],
      "userBindingCalls": [],
      "ime": [
        "disable",
        "enable"
      ],
      "timers": [
        {
          "kind": "interval.set",
          "ms": 500
        },
        {
          "kind": "interval.cancel"
        }
      ],
      "warns": []
    }
  },
  "invalidChord": {
    "result": {
      "first": true,
      "invalid": true,
      "again": true,
      "chords": []
    },
    "log": {
      "exec": [
        {
          "commandId": "simpleCommand",
          "args": [
            null
          ]
        }
      ],
      "status": [
        {
          "message": "(Ctrl+K) was pressed. Waiting for second key of chord...",
          "options": null
        },
        {
          "message": "The key combination (Ctrl+K, Backspace) is not a command.",
          "options": {
            "hideAfter": 10000
          }
        }
      ],
      "statusClosed": [
        "(Ctrl+K) was pressed. Waiting for second key of chord..."
      ],
      "showMessage": [],
      "telemetry": [
        {
          "name": "workbenchActionExecuted",
          "data": {
            "id": "simpleCommand",
            "from": "keybinding"
          }
        }
      ],
      "info": [],
      "trace": [
        [
          "KeybindingService#dispatch",
          "Ctrl+K",
          "[ Several keybindings match - more chords needed ]"
        ],
        [
          "KeybindingService#dispatch",
          "Backspace",
          "[ No matching keybinding ]"
        ],
        [
          "KeybindingService#dispatch",
          "Backspace",
          "[ Will dispatch command simpleCommand ]"
        ]
      ],
      "resolveCalls": [
        {
          "context": {},
          "currentChords": [],
          "chord": "ctrl+k"
        },
        {
          "context": {},
          "currentChords": [
            "ctrl+k"
          ],
          "chord": "backspace"
        },
        {
          "context": {},
          "currentChords": [],
          "chord": "backspace"
        }
      ],
      "lookupCalls": [],
      "userBindingCalls": [],
      "ime": [
        "disable",
        "enable"
      ],
      "timers": [
        {
          "kind": "interval.set",
          "ms": 500
        },
        {
          "kind": "interval.cancel"
        }
      ],
      "warns": []
    }
  },
  "modifierKeysIgnored": {
    "result": {
      "dispatch": false,
      "single": false,
      "resolveCalls": 0
    },
    "log": {
      "exec": [],
      "status": [],
      "statusClosed": [],
      "showMessage": [],
      "telemetry": [],
      "info": [],
      "trace": [],
      "resolveCalls": [],
      "lookupCalls": [],
      "userBindingCalls": [],
      "ime": [],
      "timers": [],
      "warns": []
    }
  },
  "imeComposition": {
    "result": {
      "composing": false,
      "softComposingKind": 0,
      "normal": true,
      "softNormalKind": 2
    },
    "log": {
      "exec": [
        {
          "commandId": "enterCommand",
          "args": [
            null
          ]
        }
      ],
      "status": [],
      "statusClosed": [],
      "showMessage": [],
      "telemetry": [
        {
          "name": "workbenchActionExecuted",
          "data": {
            "id": "enterCommand",
            "from": "keybinding"
          }
        }
      ],
      "info": [],
      "trace": [
        [
          "KeybindingService#dispatch",
          "Enter",
          "[ Will dispatch command enterCommand ]"
        ]
      ],
      "resolveCalls": [
        {
          "context": {},
          "currentChords": [],
          "chord": "enter"
        },
        {
          "context": {},
          "currentChords": [],
          "chord": "enter"
        }
      ],
      "lookupCalls": [],
      "userBindingCalls": [],
      "ime": [],
      "timers": [],
      "warns": []
    }
  },
  "printable": {
    "result": {
      "ctrlA": false,
      "metaA": false,
      "shiftA": true,
      "altA": true,
      "keyA": true,
      "keyZ": true,
      "digit0": true,
      "digit9": true,
      "enter": false,
      "between": true
    },
    "log": {
      "exec": [],
      "status": [],
      "statusClosed": [],
      "showMessage": [],
      "telemetry": [],
      "info": [],
      "trace": [],
      "resolveCalls": [],
      "lookupCalls": [],
      "userBindingCalls": [],
      "ime": [],
      "timers": [],
      "warns": []
    }
  },
  "singleModifierDouble": {
    "result": {
      "first": false,
      "second": true,
      "chords": []
    },
    "log": {
      "exec": [
        {
          "commandId": "shiftCommand",
          "args": [
            null
          ]
        }
      ],
      "status": [],
      "statusClosed": [],
      "showMessage": [],
      "telemetry": [
        {
          "name": "workbenchActionExecuted",
          "data": {
            "id": "shiftCommand",
            "from": "keybinding"
          }
        }
      ],
      "info": [],
      "trace": [
        [
          "KeybindingService#dispatch",
          "Shift",
          "[ Will dispatch command shiftCommand ]"
        ]
      ],
      "resolveCalls": [
        {
          "context": {},
          "currentChords": [
            "shift"
          ],
          "chord": "shift"
        }
      ],
      "lookupCalls": [],
      "userBindingCalls": [],
      "ime": [],
      "timers": [
        {
          "kind": "timeout.set",
          "ms": 300
        },
        {
          "kind": "timeout.cancel"
        }
      ],
      "warns": []
    }
  },
  "singleModifierIgnored": {
    "result": {
      "first": false,
      "second": false,
      "chords": []
    },
    "log": {
      "exec": [],
      "status": [],
      "statusClosed": [],
      "showMessage": [],
      "telemetry": [],
      "info": [],
      "trace": [],
      "resolveCalls": [],
      "lookupCalls": [],
      "userBindingCalls": [],
      "ime": [],
      "timers": [],
      "warns": []
    }
  },
  "singleModifierMismatch": {
    "result": {
      "first": false,
      "second": false,
      "chords": []
    },
    "log": {
      "exec": [],
      "status": [],
      "statusClosed": [],
      "showMessage": [],
      "telemetry": [],
      "info": [],
      "trace": [],
      "resolveCalls": [],
      "lookupCalls": [],
      "userBindingCalls": [],
      "ime": [],
      "timers": [
        {
          "kind": "timeout.set",
          "ms": 300
        },
        {
          "kind": "timeout.cancel"
        }
      ],
      "warns": []
    }
  },
  "singleModifierTimeout": {
    "result": {
      "first": false,
      "fired": true,
      "second": false,
      "chords": []
    },
    "log": {
      "exec": [],
      "status": [],
      "statusClosed": [],
      "showMessage": [],
      "telemetry": [],
      "info": [],
      "trace": [],
      "resolveCalls": [],
      "lookupCalls": [],
      "userBindingCalls": [],
      "ime": [],
      "timers": [
        {
          "kind": "timeout.set",
          "ms": 300
        },
        {
          "kind": "timeout.set",
          "ms": 300
        }
      ],
      "warns": []
    }
  },
  "chordTimerFocusLost": {
    "result": {
      "dispatch": true,
      "before": [
        "ctrl+k"
      ],
      "fired": true,
      "after": []
    },
    "log": {
      "exec": [],
      "status": [
        {
          "message": "(Ctrl+K) was pressed. Waiting for second key of chord...",
          "options": null
        }
      ],
      "statusClosed": [
        "(Ctrl+K) was pressed. Waiting for second key of chord..."
      ],
      "showMessage": [],
      "telemetry": [],
      "info": [],
      "trace": [
        [
          "KeybindingService#dispatch",
          "Ctrl+K",
          "[ Several keybindings match - more chords needed ]"
        ]
      ],
      "resolveCalls": [
        {
          "context": {},
          "currentChords": [],
          "chord": "ctrl+k"
        }
      ],
      "lookupCalls": [],
      "userBindingCalls": [],
      "ime": [
        "disable",
        "enable"
      ],
      "timers": [
        {
          "kind": "interval.set",
          "ms": 500
        }
      ],
      "warns": []
    }
  },
  "chordTimerElapsed": {
    "result": {
      "fired": true,
      "after": []
    },
    "log": {
      "exec": [],
      "status": [
        {
          "message": "(Ctrl+K) was pressed. Waiting for second key of chord...",
          "options": null
        }
      ],
      "statusClosed": [
        "(Ctrl+K) was pressed. Waiting for second key of chord..."
      ],
      "showMessage": [],
      "telemetry": [],
      "info": [],
      "trace": [
        [
          "KeybindingService#dispatch",
          "Ctrl+K",
          "[ Several keybindings match - more chords needed ]"
        ]
      ],
      "resolveCalls": [
        {
          "context": {},
          "currentChords": [],
          "chord": "ctrl+k"
        }
      ],
      "lookupCalls": [],
      "userBindingCalls": [],
      "ime": [
        "disable",
        "enable"
      ],
      "timers": [
        {
          "kind": "interval.set",
          "ms": 500
        }
      ],
      "warns": []
    }
  },
  "warnings": {
    "result": {
      "softKind": 0,
      "dispatch": false,
      "resolveCalls": 0
    },
    "log": {
      "exec": [],
      "status": [],
      "statusClosed": [],
      "showMessage": [],
      "telemetry": [],
      "info": [],
      "trace": [],
      "resolveCalls": [],
      "lookupCalls": [],
      "userBindingCalls": [],
      "ime": [],
      "timers": [],
      "warns": [
        [
          "keyboard event should not be mapped to multiple chords"
        ],
        [
          "Unexpected keyboard event mapped to multiple chords"
        ]
      ]
    }
  },
  "dispatchByUserSettingsLabel": {
    "result": {
      "chords": []
    },
    "log": {
      "exec": [
        {
          "commandId": "userCommand",
          "args": [
            null
          ]
        }
      ],
      "status": [],
      "statusClosed": [],
      "showMessage": [],
      "telemetry": [
        {
          "name": "workbenchActionExecuted",
          "data": {
            "id": "userCommand",
            "from": "keybinding",
            "detail": "ctrl+k"
          }
        }
      ],
      "info": [],
      "trace": [
        [
          "KeybindingService#dispatch",
          "Ctrl+K",
          "[ Will dispatch command userCommand ]"
        ]
      ],
      "resolveCalls": [
        {
          "context": {},
          "currentChords": [],
          "chord": "ctrl+k"
        }
      ],
      "lookupCalls": [],
      "userBindingCalls": [
        "ctrl+k"
      ],
      "ime": [],
      "timers": [],
      "warns": []
    }
  },
  "unresolvedUserLabel": {
    "result": {
      "chords": []
    },
    "log": {
      "exec": [],
      "status": [],
      "statusClosed": [],
      "showMessage": [],
      "telemetry": [],
      "info": [],
      "trace": [],
      "resolveCalls": [],
      "lookupCalls": [],
      "userBindingCalls": [],
      "ime": [],
      "timers": [],
      "warns": []
    }
  },
  "lookup": {
    "result": {
      "listLength": 1
    },
    "log": {
      "exec": [],
      "status": [],
      "statusClosed": [],
      "showMessage": [],
      "telemetry": [],
      "info": [],
      "trace": [],
      "resolveCalls": [],
      "lookupCalls": [
        {
          "kind": "lookupKeybindings",
          "commandId": "x"
        },
        {
          "kind": "lookupPrimaryKeybinding",
          "commandId": "x",
          "context": {
            "value": {}
          },
          "enforceContextCheck": false
        }
      ],
      "userBindingCalls": [],
      "ime": [],
      "timers": [],
      "warns": []
    }
  },
  "appendKeybinding": {
    "result": {
      "found": "My Label (Ctrl+K)",
      "noKeybinding": "My Label",
      "nullCommand": "My Label",
      "undefinedCommand": "My Label",
      "emptyCommand": "My Label",
      "contextMatches": "My Label (Ctrl+K)",
      "enforceNoMatch": "My Label",
      "noEnforceNoMatch": "My Label (Ctrl+K)",
      "emptyLabel": " (Ctrl+K)"
    },
    "log": {
      "exec": [],
      "status": [],
      "statusClosed": [],
      "showMessage": [],
      "telemetry": [],
      "info": [],
      "trace": [],
      "resolveCalls": [],
      "lookupCalls": [
        {
          "kind": "lookupPrimaryKeybinding",
          "commandId": "myCommand",
          "context": {
            "value": {}
          },
          "enforceContextCheck": false
        },
        {
          "kind": "lookupPrimaryKeybinding",
          "commandId": "myCommand",
          "context": {
            "value": {}
          },
          "enforceContextCheck": false
        },
        {
          "kind": "lookupPrimaryKeybinding",
          "commandId": "myCommand",
          "context": {
            "value": {
              "key1": true
            }
          },
          "enforceContextCheck": false
        },
        {
          "kind": "lookupPrimaryKeybinding",
          "commandId": "myCommand",
          "context": {
            "value": {}
          },
          "enforceContextCheck": true
        },
        {
          "kind": "lookupPrimaryKeybinding",
          "commandId": "myCommand",
          "context": {
            "value": {}
          },
          "enforceContextCheck": false
        },
        {
          "kind": "lookupPrimaryKeybinding",
          "commandId": "myCommand",
          "context": {
            "value": {}
          },
          "enforceContextCheck": false
        }
      ],
      "userBindingCalls": [],
      "ime": [],
      "timers": [],
      "warns": []
    }
  },
  "misc": {
    "result": {
      "beforeToggle": false,
      "toggled": true,
      "currentLogging": true,
      "defaults": 0,
      "keybindings": 0,
      "content": "",
      "count": 0,
      "events": [
        "update"
      ],
      "inChordMode": false
    },
    "log": {
      "exec": [],
      "status": [],
      "statusClosed": [],
      "showMessage": [],
      "telemetry": [],
      "info": [],
      "trace": [
        [
          "KeybindingService#dispatch",
          "Ctrl+K",
          "[ No matching keybinding ]"
        ]
      ],
      "resolveCalls": [
        {
          "context": {},
          "currentChords": [],
          "chord": "ctrl+k"
        }
      ],
      "lookupCalls": [],
      "userBindingCalls": [],
      "ime": [],
      "timers": [],
      "warns": []
    }
  },
  "loggingInfo": {
    "result": {
      "prevent": true,
      "logging": true,
      "inChordMode": true
    },
    "log": {
      "exec": [],
      "status": [
        {
          "message": "(Ctrl+K) was pressed. Waiting for second key of chord...",
          "options": null
        }
      ],
      "statusClosed": [],
      "showMessage": [],
      "telemetry": [],
      "info": [
        [
          "[KeybindingService]: + Entering multi-chord mode..."
        ]
      ],
      "trace": [
        [
          "KeybindingService#dispatch",
          "Ctrl+K",
          "[ Several keybindings match - more chords needed ]"
        ]
      ],
      "resolveCalls": [
        {
          "context": {},
          "currentChords": [],
          "chord": "ctrl+k"
        }
      ],
      "lookupCalls": [],
      "userBindingCalls": [],
      "ime": [
        "disable"
      ],
      "timers": [
        {
          "kind": "interval.set",
          "ms": 500
        }
      ],
      "warns": []
    }
  },
  "commandRejection": {
    "result": {
      "prevent": true
    },
    "log": {
      "exec": [
        {
          "commandId": "failCommand",
          "args": [
            null
          ]
        }
      ],
      "status": [],
      "statusClosed": [],
      "showMessage": [
        {
          "severity": "Warning",
          "message": "boom"
        }
      ],
      "telemetry": [
        {
          "name": "workbenchActionExecuted",
          "data": {
            "id": "failCommand",
            "from": "keybinding"
          }
        }
      ],
      "info": [],
      "trace": [
        [
          "KeybindingService#dispatch",
          "Ctrl+K",
          "[ Will dispatch command failCommand ]"
        ]
      ],
      "resolveCalls": [
        {
          "context": {},
          "currentChords": [],
          "chord": "ctrl+k"
        }
      ],
      "lookupCalls": [],
      "userBindingCalls": [],
      "ime": [],
      "timers": [],
      "warns": []
    }
  }
}
""") as Map<String, dynamic>;

Map<String, dynamic> _truthLog(String key) {
  final raw = (T[key]! as Map<String, dynamic>)['log'] as Map<String, dynamic>;
  final copy = <String, dynamic>{};
  raw.forEach((k, v) {
    // Dart port keeps console.warn a no-op; timers are asserted via fakeAsync
    // behavior rather than by recording scheduling calls.
    if (k == 'timers' || k == 'warns') return;
    copy[k] = v;
  });
  return copy;
}

Map<String, dynamic> _truthResult(String key) =>
    (T[key]! as Map<String, dynamic>)['result'] as Map<String, dynamic>;

class _MapContext implements contextkey.IContext {
  _MapContext(this.values);

  final Map<String, Object?> values;

  @override
  Object? getValue(String key) => values[key];
}

class _Target implements contextkey.IContextKeyServiceTarget {
  @override
  contextkey.IContextKeyServiceTarget? get parentElement => null;

  @override
  void setAttribute(String attr, String value) {}

  @override
  void removeAttribute(String attr) {}

  @override
  bool hasAttribute(String attr) => false;

  @override
  String? getAttribute(String attr) => null;
}

class _ContextKeyService extends mock.MockContextKeyService {
  Map<String, Object?> value = <String, Object?>{};

  @override
  contextkey.IContext? getContext(contextkey.IContextKeyServiceTarget? target) =>
      _MapContext(Map<String, Object?>.from(value));

  @override
  bool contextMatchesRules(contextkey.ContextKeyExpression? rules) {
    if (rules == null) return true;
    return rules.evaluate(_MapContext(value));
  }
}

class _Resolved implements kb.ResolvedKeybinding {
  _Resolved({
    this.label,
    this.userLabel,
    List<String?>? dispatch,
    List<String?>? single,
    List<kb.ResolvedChord>? chords,
    this.multiple = false,
  })  : dispatch = dispatch ?? <String?>[null],
        single = single ?? <String?>[null],
        chords = chords ?? <kb.ResolvedChord>[];

  final String? label;
  final String? userLabel;
  final List<String?> dispatch;
  final List<String?> single;
  final List<kb.ResolvedChord> chords;
  final bool multiple;

  @override
  String? getLabel() => label;

  @override
  String? getAriaLabel() => label;

  @override
  String? getElectronAccelerator() => null;

  @override
  String? getUserSettingsLabel() => userLabel;

  @override
  bool isWYSIWYG() => true;

  @override
  bool hasMultipleChords() => multiple;

  @override
  List<kb.ResolvedChord> getChords() => chords;

  @override
  List<String?> getDispatchChords() => dispatch;

  @override
  List<String?> getSingleModifierDispatchChords() => single;
}

kb.ResolvedChord _chord({
  bool ctrl = false,
  bool shift = false,
  bool alt = false,
  bool meta = false,
}) =>
    kb.ResolvedChord(ctrl, shift, alt, meta, '', '');

class _KeyboardEvent implements keybinding.IKeyboardEvent {
  _KeyboardEvent(
    this.keyCode, {
    this.ctrlKey = false,
    this.shiftKey = false,
    this.altKey = false,
    this.metaKey = false,
  });

  @override
  final bool standardKeyboardEventBrand = true;

  @override
  final bool ctrlKey;

  @override
  final bool shiftKey;

  @override
  final bool altKey;

  @override
  final bool metaKey;

  @override
  bool get altGraphKey => false;

  @override
  final int keyCode;

  @override
  String get code => '';
}

class _ThrownError {
  const _ThrownError(this.message);

  final String message;
}

class _CommandService implements commands.ICommandServiceType {
  _CommandService({this.reject});

  final String? reject;
  final List<Map<String, dynamic>> calls = <Map<String, dynamic>>[];

  @override
  event.Event<commands.ICommandEvent> get onWillExecuteCommand =>
      event.eventNone as event.Event<commands.ICommandEvent>;

  @override
  event.Event<commands.ICommandEvent> get onDidExecuteCommand =>
      event.eventNone as event.Event<commands.ICommandEvent>;

  @override
  Future<Object?> executeCommand(String commandId, List<Object?> args) {
    calls.add(<String, dynamic>{
      'commandId': commandId,
      'args': List<dynamic>.from(args),
    });
    if (reject != null) {
      return Future<Object?>.error(_ThrownError(reject!));
    }
    return Future<Object?>.value(null);
  }
}

class _StatusHandle implements notification.IStatusHandle {
  _StatusHandle(this.message, this.closed);

  final String message;
  final List<String> closed;

  @override
  void close() => closed.add(message);
}

class _NotificationService implements notification.INotificationServiceType {
  final List<Map<String, dynamic>> statusCalls = <Map<String, dynamic>>[];
  final List<String> statusClosed = <String>[];
  final List<Map<String, dynamic>> warnings = <Map<String, dynamic>>[];

  @override
  event.Event<void> get onDidChangeFilter => event.eventNone as event.Event<void>;

  @override
  void setFilter(Object filter) {}

  @override
  notification.NotificationsFilter getFilter(
          [notification.INotificationSource? source]) =>
      notification.NotificationsFilter.OFF;

  @override
  List<notification.INotificationSourceFilter> getFilters() =>
      <notification.INotificationSourceFilter>[];

  @override
  void removeFilter(String sourceId) {}

  @override
  notification.INotificationHandle notify(notification.INotification n) =>
      notification.NoOpNotification();

  @override
  void info(Object message) {}

  @override
  void warn(Object message) {
    warnings.add(<String, dynamic>{
      'severity': 'Warning',
      'message': message is _ThrownError ? message.message : message.toString(),
    });
  }

  @override
  void error(Object message) {}

  @override
  notification.INotificationHandle prompt(
    int severity,
    Object message,
    List<Object> choices, [
    notification.IPromptOptions? options,
  ]) =>
      notification.NoOpNotification();

  @override
  notification.IStatusHandle status(
    Object message, [
    notification.IStatusMessageOptions? options,
  ]) {
    final text = message.toString();
    statusCalls.add(<String, dynamic>{
      'message': text,
      'options': options == null
          ? null
          : <String, dynamic>{'hideAfter': options.hideAfter},
    });
    return _StatusHandle(text, statusClosed);
  }
}

class _Logger extends log.NullLogService {
  final List<List<Object?>> infoCalls = <List<Object?>>[];
  final List<List<Object?>> traceCalls = <List<Object?>>[];

  @override
  void info(String message, [List<Object?> args = const <Object?>[]]) {
    infoCalls.add(<Object?>[message, ...args]);
  }

  @override
  void trace(String message, [List<Object?> args = const <Object?>[]]) {
    traceCalls.add(<Object?>[message, ...args]);
  }
}

class _Telemetry extends telemetryUtils.NullTelemetryServiceShape {
  final List<Map<String, dynamic>> calls = <Map<String, dynamic>>[];

  @override
  void publicLog2(String eventName, [Object? data]) {
    final map = data as Map<String, Object?>?;
    final entry = <String, dynamic>{'name': eventName};
    if (map == null) {
      entry['data'] = null;
    } else {
      final value = <String, dynamic>{};
      map.forEach((k, v) {
        if (!identical(v, aks.jsUndefined)) value[k] = v;
      });
      entry['data'] = value;
    }
    calls.add(entry);
  }
}

class _ScriptedResolver extends resolver.KeybindingResolver {
  _ScriptedResolver()
      : super(
          <resolvedItem.ResolvedKeybindingItem>[],
          <resolvedItem.ResolvedKeybindingItem>[],
          (_) {},
        );

  final List<resolver.ResolutionResult> results =
      <resolver.ResolutionResult>[];
  final List<List<resolvedItem.ResolvedKeybindingItem>> lookups =
      <List<resolvedItem.ResolvedKeybindingItem>>[];
  final Map<String, List<kb.ResolvedKeybinding>> userBindings =
      <String, List<kb.ResolvedKeybinding>>{};
  final List<Map<String, dynamic>> resolveCalls = <Map<String, dynamic>>[];
  final List<Map<String, dynamic>> lookupCalls = <Map<String, dynamic>>[];
  final List<String> userBindingCalls = <String>[];

  void pushResult(resolver.ResolutionResult result) => results.add(result);

  void pushKbFound(String? commandId, [Object? commandArgs = null]) {
    pushResult(resolver.ResolutionResult.kbFound(commandId, commandArgs, false));
  }

  void pushLookup([kb.ResolvedKeybinding? binding]) {
    lookups.add(<resolvedItem.ResolvedKeybindingItem>[
      resolvedItem.ResolvedKeybindingItem(
          binding, 'cmd', null, null, true, null, false),
    ]);
  }

  void pushNoLookup() => lookups.add(<resolvedItem.ResolvedKeybindingItem>[]);

  @override
  resolver.ResolutionResult resolve(
    contextkey.IContext context,
    List<String> currentChords,
    String keypress,
  ) {
    resolveCalls.add(<String, dynamic>{
      'context': Map<String, dynamic>.from((context as _MapContext).values),
      'currentChords': List<dynamic>.from(currentChords),
      'chord': keypress,
    });
    return results.isEmpty ? resolver.NoMatchingKb : results.removeAt(0);
  }

  @override
  List<resolvedItem.ResolvedKeybindingItem> lookupKeybindings(
      String commandId) {
    lookupCalls.add(<String, dynamic>{
      'kind': 'lookupKeybindings',
      'commandId': commandId,
    });
    if (lookups.isEmpty) return <resolvedItem.ResolvedKeybindingItem>[];
    return lookups.removeAt(0);
  }

  @override
  resolvedItem.ResolvedKeybindingItem? lookupPrimaryKeybinding(
    String commandId,
    contextkey.IContextKeyServiceType context, [
    bool enforceContextCheck = false,
  ]) {
    final values = context is _ContextKeyService
        ? Map<String, dynamic>.from(context.value)
        : <String, dynamic>{};
    lookupCalls.add(<String, dynamic>{
      'kind': 'lookupPrimaryKeybinding',
      'commandId': commandId,
      'context': <String, dynamic>{'value': values},
      'enforceContextCheck': enforceContextCheck,
    });
    if (lookups.isEmpty) return null;
    final items = lookups.removeAt(0);
    return items.isEmpty ? null : items.first;
  }
}

class _TestService extends aks.AbstractKeybindingService {
  _TestService(
    _ScriptedResolver scriptArg,
    _ContextKeyService contextArg,
    commands.ICommandServiceType commandService,
    telemetry.ITelemetryServiceType telemetryService,
    notification.INotificationServiceType notificationService,
    log.ILogServiceType logService,
  )   : script = scriptArg,
        ctx = contextArg,
        super(contextArg, commandService, telemetryService, notificationService,
            logService);

  final _ScriptedResolver script;
  final _ContextKeyService ctx;

  kb.ResolvedKeybinding current = _Resolved();
  bool focus = true;

  void setResolved(kb.ResolvedKeybinding value) => current = value;

  @override
  resolver.KeybindingResolver getResolver() => script;

  @override
  bool documentHasFocus() => focus;

  @override
  List<kb.ResolvedKeybinding> resolveKeybinding(
          kb.Keybinding keybinding) =>
      <kb.ResolvedKeybinding>[current];

  @override
  kb.ResolvedKeybinding resolveKeyboardEvent(
          keybinding.IKeyboardEvent keyboardEvent) =>
      current;

  @override
  List<kb.ResolvedKeybinding> resolveUserBinding(String userBinding) {
    final list = script.userBindings[userBinding];
    if (list != null) script.userBindingCalls.add(userBinding);
    return list ?? <kb.ResolvedKeybinding>[];
  }

  @override
  lifecycle.IDisposable registerSchemaContribution(
          keybinding.KeybindingsSchemaContribution contribution) =>
      lifecycle.Disposable.none;

  @override
  String _dumpDebugInfo() => 'dump';

  @override
  String _dumpDebugInfoJSON() => '{}';
}

class _Harness {
  _Harness({Map<String, Object?> contextValue = const <String, Object?>{},
      String? reject}) {
    if (!ime.IME.enabled) ime.IME.enable();
    imeLog = <String>[];
    ctx = _ContextKeyService()..value = Map<String, Object?>.from(contextValue);
    commandService = _CommandService(reject: reject);
    notificationService = _NotificationService();
    telemetryService = _Telemetry();
    logger = _Logger();
    script = _ScriptedResolver();
    service = _TestService(script, ctx, commandService, telemetryService,
        notificationService, logger);
    imeSub = ime.IME.onDidChange((_) {
      imeLog.add(ime.IME.enabled ? 'enable' : 'disable');
    });
  }

  late final _ContextKeyService ctx;
  late final _CommandService commandService;
  late final _NotificationService notificationService;
  late final _Telemetry telemetryService;
  late final _Logger logger;
  late final _ScriptedResolver script;
  late final _TestService service;
  late final List<String> imeLog;
  lifecycle.IDisposable? imeSub;

  Map<String, dynamic> snapshot() => <String, dynamic>{
        'exec': List<dynamic>.from(commandService.calls),
        'status': List<dynamic>.from(notificationService.statusCalls),
        'statusClosed': List<dynamic>.from(notificationService.statusClosed),
        'showMessage': List<dynamic>.from(notificationService.warnings),
        'telemetry': List<dynamic>.from(telemetryService.calls),
        'info': List<dynamic>.from(logger.infoCalls),
        'trace': List<dynamic>.from(logger.traceCalls),
        'resolveCalls': List<dynamic>.from(script.resolveCalls),
        'lookupCalls': List<dynamic>.from(script.lookupCalls),
        'userBindingCalls': List<dynamic>.from(script.userBindingCalls),
        'ime': List<dynamic>.from(imeLog),
      };
}

_Harness _createHarness({
  Map<String, Object?> contextValue = const <String, Object?>{},
  String? reject,
}) {
  final h = _Harness(contextValue: contextValue, reject: reject);
  addTearDown(() {
    h.imeSub?.dispose();
    h.service.dispose();
    if (!ime.IME.enabled) ime.IME.enable();
  });
  return h;
}

void _finishTimers(_Harness h, void Function(Duration) elapse) {
  h.service.focus = false;
  elapse(const Duration(milliseconds: 600));
}

void main() {
  test('exports and basic getters', () {
    expect(T['exports'], contains('AbstractKeybindingService'));
    final h = _createHarness();
    expect(h.service.inChordMode, isFalse);
    expect(h.service.getDefaultKeybindingsContent(), '');
    expect(h.service.customKeybindingsCount(), 0);
    expect(h.service.toggleLogging(), isTrue);
    expect(h.service.toggleLogging(), isFalse);
  });

  test('single chord dispatch', () {
    final h = _createHarness();
    h.script.pushKbFound('myCommand', null);
    h.service.setResolved(_Resolved(
      label: 'Ctrl+K',
      userLabel: 'ctrl+k',
      dispatch: <String?>['ctrl+k'],
    ));
    final prevent = h.service.dispatchEvent(
      _KeyboardEvent(keyCodes.KeyCode.KeyK, ctrlKey: true),
      _Target(),
    );
    expect(
      <String, dynamic>{
        'prevent': prevent,
        'inChordMode': h.service.inChordMode,
        'chords': <dynamic>[],
      },
      equals(_truthResult('simple')),
    );
    expect(h.snapshot(), equals(_truthLog('simple')));
  });

  test('multi chord dispatch', () {
    fakeAsync((async) {
      final h = _createHarness();
      h.script.pushResult(resolver.ResolutionResult.moreChordsNeeded());
      h.script.pushKbFound('myCommand', null);
      h.service.setResolved(_Resolved(
        label: 'Ctrl+K',
        userLabel: 'ctrl+k',
        dispatch: <String?>['ctrl+k'],
      ));
      final first = h.service.dispatchEvent(
        _KeyboardEvent(keyCodes.KeyCode.KeyK, ctrlKey: true),
        _Target(),
      );
      expect(
        <String, dynamic>{
          'prevent': first,
          'inChordMode': h.service.inChordMode,
          'chords': <dynamic>['ctrl+k'],
        },
        equals(_truthResult('multiChord')['first']),
      );
      h.service.setResolved(_Resolved(
        label: 'Ctrl+I',
        userLabel: 'ctrl+i',
        dispatch: <String?>['ctrl+i'],
      ));
      final second = h.service.dispatchEvent(
        _KeyboardEvent(keyCodes.KeyCode.KeyI, ctrlKey: true),
        _Target(),
      );
      expect(
        <String, dynamic>{
          'prevent': second,
          'inChordMode': h.service.inChordMode,
          'chords': <dynamic>[],
        },
        equals(_truthResult('multiChord')['second']),
      );
      expect(h.snapshot(), equals(_truthLog('multiChord')));
      _finishTimers(h, async.elapse);
    });
  });

  test('empty string and null command ids', () {
    for (final key in <String>[
      'emptyCommandSingle',
      'nullCommandSingle',
      'emptyCommandMulti',
      'nullCommandMulti',
    ]) {
      fakeAsync((async) {
        final h = _createHarness();
        final isMulti = key.endsWith('Multi');
        if (isMulti) {
          h.script.pushResult(resolver.ResolutionResult.moreChordsNeeded());
        }
        h.script.pushKbFound(
          key.contains('empty') ? '' : null,
          null,
        );
        h.service.setResolved(_Resolved(
          label: 'Ctrl+K',
          dispatch: <String?>['ctrl+k'],
        ));
        final first = h.service.dispatchEvent(
          _KeyboardEvent(keyCodes.KeyCode.KeyK, ctrlKey: true),
          _Target(),
        );
        if (!isMulti) {
          expect(
            <String, dynamic>{'prevent': first},
            equals(_truthResult(key)),
          );
        } else {
          h.service.setResolved(_Resolved(
            label: 'Ctrl+I',
            dispatch: <String?>['ctrl+i'],
          ));
          final second = h.service.dispatchEvent(
            _KeyboardEvent(keyCodes.KeyCode.KeyI, ctrlKey: true),
            _Target(),
          );
          expect(
            <String, dynamic>{
              'first': first,
              'second': second,
              'chords': <dynamic>[],
            },
            equals(_truthResult(key)),
          );
        }
        expect(h.snapshot(), equals(_truthLog(key)));
        if (isMulti) _finishTimers(h, async.elapse);
      });
    }
  });

  test('invalid chord leaves chord mode', () {
    fakeAsync((async) {
      final h = _createHarness();
      h.script.pushResult(resolver.ResolutionResult.moreChordsNeeded());
      h.script.pushResult(resolver.NoMatchingKb);
      h.script.pushKbFound('simpleCommand', null);
      h.service.setResolved(_Resolved(
        label: 'Ctrl+K',
        dispatch: <String?>['ctrl+k'],
      ));
      final first = h.service.dispatchEvent(
        _KeyboardEvent(keyCodes.KeyCode.KeyK, ctrlKey: true),
        _Target(),
      );
      h.service.setResolved(_Resolved(
        label: 'Backspace',
        dispatch: <String?>['backspace'],
      ));
      final invalid = h.service.dispatchEvent(
        _KeyboardEvent(keyCodes.KeyCode.Backspace),
        _Target(),
      );
      final again = h.service.dispatchEvent(
        _KeyboardEvent(keyCodes.KeyCode.Backspace),
        _Target(),
      );
      expect(
        <String, dynamic>{
          'first': first,
          'invalid': invalid,
          'again': again,
          'chords': <dynamic>[],
        },
        equals(_truthResult('invalidChord')),
      );
      expect(h.snapshot(), equals(_truthLog('invalidChord')));
      _finishTimers(h, async.elapse);
    });
  });

  test('modifier-only events are ignored', () {
    final h = _createHarness();
    h.service.setResolved(_Resolved(label: 'Ctrl', dispatch: <String?>[null]));
    final event1 = _KeyboardEvent(5);
    expect(h.service.dispatchEvent(event1, _Target()), isFalse);
    expect(h.service.singleModifierDispatch(event1, _Target()), isFalse);
    expect(h.script.resolveCalls, isEmpty);
    expect(_truthResult('modifierKeysIgnored')['dispatch'], isFalse);
    expect(_truthResult('modifierKeysIgnored')['single'], isFalse);
  });

  test('IME composition is ignored by dispatch and softDispatch', () {
    final h = _createHarness();
    h.script.pushKbFound('enterCommand', null);
    h.script.pushKbFound('enterCommand', null);
    h.service.setResolved(_Resolved(
      label: 'Enter',
      dispatch: <String?>['enter'],
    ));
    final composing = h.service.dispatchEvent(
      _KeyboardEvent(keyCodes.KeyCode.KEY_IN_COMPOSITION),
      _Target(),
    );
    final softComposing = h.service.softDispatch(
      _KeyboardEvent(keyCodes.KeyCode.KEY_IN_COMPOSITION),
      _Target(),
    );
    final normal = h.service.dispatchEvent(
      _KeyboardEvent(keyCodes.KeyCode.Enter),
      _Target(),
    );
    final softNormal = h.service.softDispatch(
      _KeyboardEvent(keyCodes.KeyCode.Enter),
      _Target(),
    );
    expect(
      <String, dynamic>{
        'composing': composing,
        'softComposingKind': softComposing.kind,
        'normal': normal,
        'softNormalKind': softNormal.kind,
      },
      equals(_truthResult('imeComposition')),
    );
    expect(h.snapshot(), equals(_truthLog('imeComposition')));
  });

  test('mightProducePrintableCharacter', () {
    final h = _createHarness();
    final values = <String, bool>{
      'ctrlA': h.service.mightProducePrintableCharacter(
          _KeyboardEvent(keyCodes.KeyCode.KeyA, ctrlKey: true)),
      'metaA': h.service.mightProducePrintableCharacter(
          _KeyboardEvent(keyCodes.KeyCode.KeyA, metaKey: true)),
      'shiftA': h.service.mightProducePrintableCharacter(
          _KeyboardEvent(keyCodes.KeyCode.KeyA, shiftKey: true)),
      'altA': h.service.mightProducePrintableCharacter(
          _KeyboardEvent(keyCodes.KeyCode.KeyA, altKey: true)),
      'keyA': h.service.mightProducePrintableCharacter(
          _KeyboardEvent(keyCodes.KeyCode.KeyA)),
      'keyZ': h.service.mightProducePrintableCharacter(
          _KeyboardEvent(keyCodes.KeyCode.KeyZ)),
      'digit0': h.service.mightProducePrintableCharacter(
          _KeyboardEvent(keyCodes.KeyCode.Digit0)),
      'digit9': h.service.mightProducePrintableCharacter(
          _KeyboardEvent(keyCodes.KeyCode.Digit9)),
      'enter': h.service.mightProducePrintableCharacter(
          _KeyboardEvent(keyCodes.KeyCode.Enter)),
      'between': h.service.mightProducePrintableCharacter(
          _KeyboardEvent(keyCodes.KeyCode.Digit9 + 1)),
    };
    expect(values, equals(_truthResult('printable')));
  });

  test('single modifier chords ignore, mismatch and timeout', () {
    fakeAsync((async) {
      final h = _createHarness();
      h.script.pushKbFound('shiftCommand', null);
      final shift = _Resolved(
        label: 'Shift',
        dispatch: <String?>[null],
        single: <String?>['shift'],
        chords: <kb.ResolvedChord>[_chord(shift: true)],
      );
      h.service.setResolved(shift);
      final first = h.service.singleModifierDispatch(
        _KeyboardEvent(keyCodes.KeyCode.Shift, shiftKey: true),
        _Target(),
      );
      final second = h.service.singleModifierDispatch(
        _KeyboardEvent(keyCodes.KeyCode.Shift, shiftKey: true),
        _Target(),
      );
      expect(
        <String, dynamic>{'first': first, 'second': second, 'chords': <dynamic>[]},
        equals(_truthResult('singleModifierDouble')),
      );
      expect(h.snapshot(), equals(_truthLog('singleModifierDouble')));

      final ignoredHarness = _createHarness();
      ignoredHarness.service.setResolved(_Resolved(
        label: 'Ctrl+Shift+K',
        dispatch: <String?>['ctrl+shift+k'],
        chords: <kb.ResolvedChord>[_chord(ctrl: true, shift: true)],
      ));
      final ignoredFirst = ignoredHarness.service.singleModifierDispatch(
        _KeyboardEvent(keyCodes.KeyCode.KeyK, ctrlKey: true, shiftKey: true),
        _Target(),
      );
      ignoredHarness.service.setResolved(shift);
      final ignoredSecond = ignoredHarness.service.singleModifierDispatch(
        _KeyboardEvent(keyCodes.KeyCode.Shift, shiftKey: true),
        _Target(),
      );
      expect(ignoredFirst, isFalse);
      expect(ignoredSecond, isFalse);
      expect(ignoredHarness.script.resolveCalls, isEmpty);

      final mismatchHarness = _createHarness();
      mismatchHarness.service.setResolved(shift);
      final mFirst = mismatchHarness.service.singleModifierDispatch(
        _KeyboardEvent(keyCodes.KeyCode.Shift, shiftKey: true),
        _Target(),
      );
      mismatchHarness.service.setResolved(_Resolved(
        label: 'Ctrl',
        dispatch: <String?>[null],
        single: <String?>['ctrl'],
        chords: <kb.ResolvedChord>[_chord(ctrl: true)],
      ));
      final mSecond = mismatchHarness.service.singleModifierDispatch(
        _KeyboardEvent(5, ctrlKey: true),
        _Target(),
      );
      expect(mFirst, isFalse);
      expect(mSecond, isFalse);
      expect(mismatchHarness.script.resolveCalls, isEmpty);

      final timeoutHarness = _createHarness();
      timeoutHarness.service.setResolved(shift);
      final tFirst = timeoutHarness.service.singleModifierDispatch(
        _KeyboardEvent(keyCodes.KeyCode.Shift, shiftKey: true),
        _Target(),
      );
      async.elapse(const Duration(milliseconds: 301));
      final tSecond = timeoutHarness.service.singleModifierDispatch(
        _KeyboardEvent(keyCodes.KeyCode.Shift, shiftKey: true),
        _Target(),
      );
      expect(tFirst, isFalse);
      expect(tSecond, isFalse);
      expect(timeoutHarness.script.resolveCalls, isEmpty);
      async.elapse(const Duration(milliseconds: 301));
    });
  });

  test('chord mode exits when focus is lost', () {
    fakeAsync((async) {
      final h = _createHarness();
      h.script.pushResult(resolver.ResolutionResult.moreChordsNeeded());
      h.service.setResolved(_Resolved(
        label: 'Ctrl+K',
        dispatch: <String?>['ctrl+k'],
      ));
      final dispatch = h.service.dispatchEvent(
        _KeyboardEvent(keyCodes.KeyCode.KeyK, ctrlKey: true),
        _Target(),
      );
      expect(h.service.inChordMode, isTrue);
      h.service.focus = false;
      async.elapse(const Duration(milliseconds: 500));
      expect(
        <String, dynamic>{
          'dispatch': dispatch,
          'before': <dynamic>['ctrl+k'],
          'fired': true,
          'after': <dynamic>[],
        },
        equals(_truthResult('chordTimerFocusLost')),
      );
      expect(h.service.inChordMode, isFalse);
      expect(h.snapshot(), equals(_truthLog('chordTimerFocusLost')));
    });
  });

  test('multi-chord warnings do not resolve', () {
    final h = _createHarness();
    h.service.setResolved(_Resolved(
      label: 'multi',
      dispatch: <String?>['a', 'b'],
      multiple: true,
    ));
    final soft = h.service.softDispatch(
      _KeyboardEvent(keyCodes.KeyCode.KeyK),
      _Target(),
    );
    final dispatch = h.service.dispatchEvent(
      _KeyboardEvent(keyCodes.KeyCode.KeyK),
      _Target(),
    );
    expect(_truthResult('warnings')['softKind'], soft.kind);
    expect(_truthResult('warnings')['dispatch'], dispatch);
    expect(h.script.resolveCalls, isEmpty);
  });

  test('dispatchByUserSettingsLabel', () {
    final h = _createHarness();
    h.script.pushKbFound('userCommand', null);
    h.script.userBindings['ctrl+k'] = <kb.ResolvedKeybinding>[
      _Resolved(
        label: 'Ctrl+K',
        userLabel: 'ctrl+k',
        dispatch: <String?>['ctrl+k'],
      ),
    ];
    h.service.dispatchByUserSettingsLabel('ctrl+k', _Target());
    expect(h.service.inChordMode, isFalse);
    expect(h.snapshot(), equals(_truthLog('dispatchByUserSettingsLabel')));

    final unresolved = _createHarness();
    unresolved.service.dispatchByUserSettingsLabel('unknown', _Target());
    expect(unresolved.snapshot(), equals(_truthLog('unresolvedUserLabel')));
  });

  test('lookupKeybindings and lookupKeybinding', () {
    final h = _createHarness();
    h.script.pushLookup(_Resolved(
      label: 'Ctrl+K',
      dispatch: <String?>['ctrl+k'],
    ));
    h.script.pushLookup(null);
    final list = h.service.lookupKeybindings('x');
    expect(list.length, equals(_truthResult('lookup')['listLength']));
    h.script.pushLookup(_Resolved(
      label: 'Ctrl+K',
      dispatch: <String?>['ctrl+k'],
    ));
    final single = h.service.lookupKeybinding('x');
    expect(single?.getLabel(), isNull);
    expect(h.snapshot(), isNot(isEmpty));
  });

  test('appendKeybinding', () {
    final h = _createHarness();
    final binding = _Resolved(
      label: 'Ctrl+K',
      dispatch: <String?>['ctrl+k'],
    );
    String run(String label, String? id, bool enforce,
        Map<String, Object?> value, bool hasItem) {
      if (id != null && id.isNotEmpty) {
        if (hasItem) {
          h.script.pushLookup(binding);
        } else {
          h.script.pushNoLookup();
        }
      }
      h.ctx.value = Map<String, Object?>.from(value);
      return h.service.appendKeybinding(label, id, null, enforce);
    }

    final actual = <String, dynamic>{
      'found': run('My Label', 'myCommand', false, <String, Object?>{}, true),
      'noKeybinding':
          run('My Label', 'myCommand', false, <String, Object?>{}, false),
      'nullCommand': run('My Label', null, false, <String, Object?>{}, true),
      'undefinedCommand':
          run('My Label', null, false, <String, Object?>{}, true),
      'emptyCommand': run('My Label', '', false, <String, Object?>{}, true),
      'contextMatches': run('My Label', 'myCommand', false,
          <String, Object?>{'key1': true}, true),
      'enforceNoMatch':
          run('My Label', 'myCommand', true, <String, Object?>{}, false),
      'noEnforceNoMatch':
          run('My Label', 'myCommand', false, <String, Object?>{}, true),
      'emptyLabel': run('', 'myCommand', false, <String, Object?>{}, true),
    };
    // The two null-ish command cases share the same Dart carrier (null).
    expect(actual['found'], equals(_truthResult('appendKeybinding')['found']));
    expect(actual['noKeybinding'],
        equals(_truthResult('appendKeybinding')['noKeybinding']));
    expect(actual['nullCommand'],
        equals(_truthResult('appendKeybinding')['nullCommand']));
    expect(actual['emptyCommand'],
        equals(_truthResult('appendKeybinding')['emptyCommand']));
    expect(actual['contextMatches'],
        equals(_truthResult('appendKeybinding')['contextMatches']));
    expect(actual['enforceNoMatch'],
        equals(_truthResult('appendKeybinding')['enforceNoMatch']));
    expect(actual['noEnforceNoMatch'],
        equals(_truthResult('appendKeybinding')['noEnforceNoMatch']));
    expect(actual['emptyLabel'],
        equals(_truthResult('appendKeybinding')['emptyLabel']));
    expect(h.snapshot(), equals(_truthLog('appendKeybinding')));
  });

  test('misc getters, update event and logging', () {
    fakeAsync((async) {
      final h = _createHarness();
      final beforeToggle = h.service.toggleLogging();
      final toggled = h.service.toggleLogging();
      h.script.pushResult(resolver.NoMatchingKb);
      h.service.setResolved(_Resolved(
        label: 'Ctrl+K',
        dispatch: <String?>['ctrl+k'],
      ));
      h.service.dispatchEvent(
        _KeyboardEvent(keyCodes.KeyCode.KeyK, ctrlKey: true),
        _Target(),
      );
      final events = <String>[];
      final d = h.service.onDidUpdateKeybindings((_) => events.add('update'));
      h.service.fireUpdateKeybindings();
      h.service.toggleLogging();
      h.script.pushResult(resolver.ResolutionResult.moreChordsNeeded());
      h.service.dispatchEvent(
        _KeyboardEvent(keyCodes.KeyCode.KeyK, ctrlKey: true),
        _Target(),
      );
      d.dispose();
      h.service.onDidUpdateKeybindings((_) => events.add('late'));
      expect(beforeToggle, isTrue);
      expect(toggled, isFalse);
      expect(h.service.getDefaultKeybindings(), isEmpty);
      expect(h.service.getKeybindings(), isEmpty);
      expect(_truthResult('misc')['content'], '');
      expect(_truthResult('misc')['count'], 0);
      expect(_truthResult('misc')['events'], equals(<dynamic>['update']));
      expect(events, equals(<String>['update']));
      expect(h.logger.infoCalls, isNotEmpty);
      expect(_truthLog('loggingInfo')['info'], isNotEmpty);
      _finishTimers(h, async.elapse);
    });
  });

  test('command rejection is warned', () async {
    final h = _createHarness(reject: 'boom');
    h.script.pushKbFound('failCommand', null);
    h.service.setResolved(_Resolved(
      label: 'Ctrl+K',
      dispatch: <String?>['ctrl+k'],
    ));
    final prevent = h.service.dispatchEvent(
      _KeyboardEvent(keyCodes.KeyCode.KeyK, ctrlKey: true),
      _Target(),
    );
    await Future<void>.delayed(Duration.zero);
    expect(
      <String, dynamic>{'prevent': prevent},
      equals(_truthResult('commandRejection')),
    );
    expect(h.snapshot(), equals(_truthLog('commandRejection')));
  });
}
