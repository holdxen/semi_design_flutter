// Truth-driven tests for platform/userDataProfile/common/userDataProfile.ts.
// Truth: tool/ts2dart/batch160_truth.json
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/errors.dart' as errors;
import 'package:semi_design_flutter/src/monaco/base/common/resources.dart' as resources;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' as uri;
import 'package:semi_design_flutter/src/monaco/platform/environment/common/environment.dart'
    as environment;
import 'package:semi_design_flutter/src/monaco/platform/files/common/files.dart'
    as files;
import 'package:semi_design_flutter/src/monaco/platform/log/common/log.dart'
    as log;
import 'package:semi_design_flutter/src/monaco/platform/uriIdentity/common/uriIdentity.dart'
    as uriIdentity;
import 'package:semi_design_flutter/src/monaco/platform/userDataProfile/common/userDataProfile.dart'
    as udp;

final Map<String, dynamic> T =
    jsonDecode(r"""{
  "constants": {
    "agentsWindowProfileId": "agents",
    "profileResourceType": {
      "Settings": "settings",
      "Keybindings": "keybindings",
      "Snippets": "snippets",
      "Prompts": "prompts",
      "Tasks": "tasks",
      "Extensions": "extensions",
      "GlobalState": "globalState",
      "Mcp": "mcp",
      "LanguageModels": "languageModels"
    }
  },
  "isUserDataProfile": {
    "valid": true,
    "undefined": false,
    "null": false,
    "string": false,
    "missingLocation": false,
    "wrongId": false,
    "wrongName": false
  },
  "pureProfiles": {
    "base": {
      "id": "id",
      "isDefault": false,
      "name": "name",
      "location": {
        "scheme": "file",
        "authority": "",
        "path": "/loc",
        "query": "",
        "fragment": "",
        "toString": "file:///loc"
      },
      "globalStorageHome": {
        "scheme": "file",
        "authority": "",
        "path": "/loc/globalStorage",
        "query": "",
        "fragment": "",
        "toString": "file:///loc/globalStorage"
      },
      "settingsResource": {
        "scheme": "file",
        "authority": "",
        "path": "/loc/settings.json",
        "query": "",
        "fragment": "",
        "toString": "file:///loc/settings.json"
      },
      "keybindingsResource": {
        "scheme": "file",
        "authority": "",
        "path": "/loc/keybindings.json",
        "query": "",
        "fragment": "",
        "toString": "file:///loc/keybindings.json"
      },
      "tasksResource": {
        "scheme": "file",
        "authority": "",
        "path": "/loc/tasks.json",
        "query": "",
        "fragment": "",
        "toString": "file:///loc/tasks.json"
      },
      "snippetsHome": {
        "scheme": "file",
        "authority": "",
        "path": "/loc/snippets",
        "query": "",
        "fragment": "",
        "toString": "file:///loc/snippets"
      },
      "promptsHome": {
        "scheme": "file",
        "authority": "",
        "path": "/loc/prompts",
        "query": "",
        "fragment": "",
        "toString": "file:///loc/prompts"
      },
      "extensionsResource": {
        "scheme": "file",
        "authority": "",
        "path": "/loc/extensions.json",
        "query": "",
        "fragment": "",
        "toString": "file:///loc/extensions.json"
      },
      "mcpResource": {
        "scheme": "file",
        "authority": "",
        "path": "/loc/mcp.json",
        "query": "",
        "fragment": "",
        "toString": "file:///loc/mcp.json"
      },
      "languageModelsResource": {
        "scheme": "file",
        "authority": "",
        "path": "/loc/chatLanguageModels.json",
        "query": "",
        "fragment": "",
        "toString": "file:///loc/chatLanguageModels.json"
      },
      "agentPluginsHome": {
        "scheme": "file",
        "authority": "",
        "path": "/loc/agent-plugins",
        "query": "",
        "fragment": "",
        "toString": "file:///loc/agent-plugins"
      },
      "cacheHome": {
        "scheme": "file",
        "authority": "",
        "path": "/cache/id",
        "query": "",
        "fragment": "",
        "toString": "file:///cache/id"
      },
      "isAgentsWindowProfile": false
    },
    "agents": {
      "id": "agents",
      "isDefault": false,
      "name": "Agents",
      "location": {
        "scheme": "file",
        "authority": "",
        "path": "/agents",
        "query": "",
        "fragment": "",
        "toString": "file:///agents"
      },
      "globalStorageHome": {
        "scheme": "file",
        "authority": "",
        "path": "/agents/globalStorage",
        "query": "",
        "fragment": "",
        "toString": "file:///agents/globalStorage"
      },
      "settingsResource": {
        "scheme": "file",
        "authority": "",
        "path": "/agents/settings.json",
        "query": "",
        "fragment": "",
        "toString": "file:///agents/settings.json"
      },
      "keybindingsResource": {
        "scheme": "file",
        "authority": "",
        "path": "/agents/keybindings.json",
        "query": "",
        "fragment": "",
        "toString": "file:///agents/keybindings.json"
      },
      "tasksResource": {
        "scheme": "file",
        "authority": "",
        "path": "/agents/tasks.json",
        "query": "",
        "fragment": "",
        "toString": "file:///agents/tasks.json"
      },
      "snippetsHome": {
        "scheme": "file",
        "authority": "",
        "path": "/agents/snippets",
        "query": "",
        "fragment": "",
        "toString": "file:///agents/snippets"
      },
      "promptsHome": {
        "scheme": "file",
        "authority": "",
        "path": "/agents/prompts",
        "query": "",
        "fragment": "",
        "toString": "file:///agents/prompts"
      },
      "extensionsResource": {
        "scheme": "file",
        "authority": "",
        "path": "/agents/extensions.json",
        "query": "",
        "fragment": "",
        "toString": "file:///agents/extensions.json"
      },
      "mcpResource": {
        "scheme": "file",
        "authority": "",
        "path": "/agents/mcp.json",
        "query": "",
        "fragment": "",
        "toString": "file:///agents/mcp.json"
      },
      "languageModelsResource": {
        "scheme": "file",
        "authority": "",
        "path": "/agents/chatLanguageModels.json",
        "query": "",
        "fragment": "",
        "toString": "file:///agents/chatLanguageModels.json"
      },
      "agentPluginsHome": {
        "scheme": "file",
        "authority": "",
        "path": "/loc/agent-plugins",
        "query": "",
        "fragment": "",
        "toString": "file:///loc/agent-plugins"
      },
      "cacheHome": {
        "scheme": "file",
        "authority": "",
        "path": "/cache/agents",
        "query": "",
        "fragment": "",
        "toString": "file:///cache/agents"
      },
      "isInternal": true,
      "isAgentsWindowProfile": true
    },
    "withFlags": {
      "id": "id2",
      "isDefault": false,
      "name": "name2",
      "icon": "icon",
      "location": {
        "scheme": "file",
        "authority": "",
        "path": "/loc2",
        "query": "",
        "fragment": "",
        "toString": "file:///loc2"
      },
      "globalStorageHome": {
        "scheme": "file",
        "authority": "",
        "path": "/loc/globalStorage",
        "query": "",
        "fragment": "",
        "toString": "file:///loc/globalStorage"
      },
      "settingsResource": {
        "scheme": "file",
        "authority": "",
        "path": "/loc/settings.json",
        "query": "",
        "fragment": "",
        "toString": "file:///loc/settings.json"
      },
      "keybindingsResource": {
        "scheme": "file",
        "authority": "",
        "path": "/loc/keybindings.json",
        "query": "",
        "fragment": "",
        "toString": "file:///loc/keybindings.json"
      },
      "tasksResource": {
        "scheme": "file",
        "authority": "",
        "path": "/loc2/tasks.json",
        "query": "",
        "fragment": "",
        "toString": "file:///loc2/tasks.json"
      },
      "snippetsHome": {
        "scheme": "file",
        "authority": "",
        "path": "/loc2/snippets",
        "query": "",
        "fragment": "",
        "toString": "file:///loc2/snippets"
      },
      "promptsHome": {
        "scheme": "file",
        "authority": "",
        "path": "/loc2/prompts",
        "query": "",
        "fragment": "",
        "toString": "file:///loc2/prompts"
      },
      "extensionsResource": {
        "scheme": "file",
        "authority": "",
        "path": "/loc2/extensions.json",
        "query": "",
        "fragment": "",
        "toString": "file:///loc2/extensions.json"
      },
      "mcpResource": {
        "scheme": "file",
        "authority": "",
        "path": "/loc2/mcp.json",
        "query": "",
        "fragment": "",
        "toString": "file:///loc2/mcp.json"
      },
      "languageModelsResource": {
        "scheme": "file",
        "authority": "",
        "path": "/loc2/chatLanguageModels.json",
        "query": "",
        "fragment": "",
        "toString": "file:///loc2/chatLanguageModels.json"
      },
      "agentPluginsHome": {
        "scheme": "file",
        "authority": "",
        "path": "/loc/agent-plugins",
        "query": "",
        "fragment": "",
        "toString": "file:///loc/agent-plugins"
      },
      "cacheHome": {
        "scheme": "file",
        "authority": "",
        "path": "/cache/id2",
        "query": "",
        "fragment": "",
        "toString": "file:///cache/id2"
      },
      "useDefaultFlags": {
        "settings": true,
        "keybindings": true,
        "globalState": true
      },
      "isInternal": true,
      "isTransient": true,
      "isAgentsWindowProfile": false,
      "workspaces": [
        {
          "scheme": "file",
          "authority": "",
          "path": "/w1",
          "query": "",
          "fragment": "",
          "toString": "file:///w1"
        }
      ]
    },
    "revived": {
      "id": "id",
      "isDefault": false,
      "name": "name",
      "icon": "ic",
      "location": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/loc",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/loc"
      },
      "globalStorageHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/loc/globalStorage",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/loc/globalStorage"
      },
      "settingsResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/loc/settings.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/loc/settings.json"
      },
      "keybindingsResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/loc/keybindings.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/loc/keybindings.json"
      },
      "tasksResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/loc/tasks.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/loc/tasks.json"
      },
      "snippetsHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/loc/snippets",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/loc/snippets"
      },
      "promptsHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/loc/prompts",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/loc/prompts"
      },
      "extensionsResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/loc/extensions.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/loc/extensions.json"
      },
      "mcpResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/loc/mcp.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/loc/mcp.json"
      },
      "languageModelsResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/loc/chatLanguageModels.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/loc/chatLanguageModels.json"
      },
      "agentPluginsHome": {
        "scheme": "file",
        "authority": "",
        "path": "/loc/agent-plugins",
        "query": "",
        "fragment": "",
        "toString": "file:///loc/agent-plugins"
      },
      "cacheHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/cache/id",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/cache/id"
      },
      "useDefaultFlags": {
        "settings": true
      },
      "isInternal": true,
      "isTransient": true,
      "isAgentsWindowProfile": false,
      "workspaces": [
        {
          "scheme": "file",
          "authority": "",
          "path": "/w1",
          "query": "",
          "fragment": "",
          "toString": "file:///w1"
        }
      ]
    },
    "revivedAgentPluginsScheme": "file"
  },
  "defaultProfile": {
    "profile": {
      "id": "__default__profile__",
      "isDefault": true,
      "name": "Default",
      "location": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User"
      },
      "globalStorageHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/globalStorage",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/globalStorage"
      },
      "settingsResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/settings.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/settings.json"
      },
      "keybindingsResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/keybindings.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/keybindings.json"
      },
      "tasksResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/tasks.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/tasks.json"
      },
      "snippetsHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/snippets",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/snippets"
      },
      "promptsHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/prompts",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/prompts"
      },
      "extensionsResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/extensions.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/extensions.json"
      },
      "mcpResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/mcp.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/mcp.json"
      },
      "languageModelsResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/chatLanguageModels.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/chatLanguageModels.json"
      },
      "agentPluginsHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/agent-plugins",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/agent-plugins"
      },
      "cacheHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/CachedProfilesData/__default__profile__",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/CachedProfilesData/__default__profile__"
      },
      "isAgentsWindowProfile": false
    },
    "profiles": [
      {
        "id": "__default__profile__",
        "isDefault": true,
        "name": "Default",
        "location": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User"
        },
        "globalStorageHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/globalStorage",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/globalStorage"
        },
        "settingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/settings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/settings.json"
        },
        "keybindingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/keybindings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/keybindings.json"
        },
        "tasksResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/tasks.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/tasks.json"
        },
        "snippetsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/snippets",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/snippets"
        },
        "promptsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/prompts",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/prompts"
        },
        "extensionsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/extensions.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/extensions.json"
        },
        "mcpResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/mcp.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/mcp.json"
        },
        "languageModelsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/chatLanguageModels.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/chatLanguageModels.json"
        },
        "agentPluginsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/agent-plugins",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/agent-plugins"
        },
        "cacheHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/CachedProfilesData/__default__profile__",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/CachedProfilesData/__default__profile__"
        },
        "isAgentsWindowProfile": false
      }
    ],
    "profilesHome": "vscodeUserData:/root/User/profiles"
  },
  "create": {
    "profile": {
      "ok": true,
      "value": {
        "id": "id",
        "isDefault": false,
        "name": "name",
        "location": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id"
        },
        "globalStorageHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/globalStorage",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/globalStorage"
        },
        "settingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/settings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/settings.json"
        },
        "keybindingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/keybindings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/keybindings.json"
        },
        "tasksResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/tasks.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/tasks.json"
        },
        "snippetsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/snippets",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/snippets"
        },
        "promptsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/prompts",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/prompts"
        },
        "extensionsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/extensions.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/extensions.json"
        },
        "mcpResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/mcp.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/mcp.json"
        },
        "languageModelsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/chatLanguageModels.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/chatLanguageModels.json"
        },
        "agentPluginsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/agent-plugins",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/agent-plugins"
        },
        "cacheHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/CachedProfilesData/id",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/CachedProfilesData/id"
        },
        "isAgentsWindowProfile": false
      }
    },
    "transient": {
      "ok": true,
      "value": {
        "id": "tid",
        "isDefault": false,
        "name": "tname",
        "location": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/tid",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/tid"
        },
        "globalStorageHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/tid/globalStorage",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/tid/globalStorage"
        },
        "settingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/tid/settings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/tid/settings.json"
        },
        "keybindingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/tid/keybindings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/tid/keybindings.json"
        },
        "tasksResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/tid/tasks.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/tid/tasks.json"
        },
        "snippetsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/tid/snippets",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/tid/snippets"
        },
        "promptsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/tid/prompts",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/tid/prompts"
        },
        "extensionsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/tid/extensions.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/tid/extensions.json"
        },
        "mcpResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/tid/mcp.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/tid/mcp.json"
        },
        "languageModelsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/tid/chatLanguageModels.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/tid/chatLanguageModels.json"
        },
        "agentPluginsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/agent-plugins",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/agent-plugins"
        },
        "cacheHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/CachedProfilesData/tid",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/CachedProfilesData/tid"
        },
        "isInternal": true,
        "isTransient": true,
        "isAgentsWindowProfile": false
      }
    },
    "duplicate": {
      "ok": false,
      "error": {
        "message": "Profile with name name already exists",
        "name": "Error"
      }
    },
    "missingName": {
      "ok": false,
      "error": {
        "message": "Name of the profile is mandatory and must be of type `string`",
        "name": "Error"
      }
    },
    "nonStringName": {
      "ok": false,
      "error": {
        "message": "Name of the profile is mandatory and must be of type `string`",
        "name": "Error"
      }
    },
    "profiles": [
      {
        "id": "__default__profile__",
        "isDefault": true,
        "name": "Default",
        "location": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User"
        },
        "globalStorageHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/globalStorage",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/globalStorage"
        },
        "settingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/settings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/settings.json"
        },
        "keybindingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/keybindings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/keybindings.json"
        },
        "tasksResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/tasks.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/tasks.json"
        },
        "snippetsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/snippets",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/snippets"
        },
        "promptsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/prompts",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/prompts"
        },
        "extensionsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/extensions.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/extensions.json"
        },
        "mcpResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/mcp.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/mcp.json"
        },
        "languageModelsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/chatLanguageModels.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/chatLanguageModels.json"
        },
        "agentPluginsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/agent-plugins",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/agent-plugins"
        },
        "cacheHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/CachedProfilesData/__default__profile__",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/CachedProfilesData/__default__profile__"
        },
        "isAgentsWindowProfile": false
      },
      {
        "id": "id",
        "isDefault": false,
        "name": "name",
        "location": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id"
        },
        "globalStorageHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/globalStorage",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/globalStorage"
        },
        "settingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/settings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/settings.json"
        },
        "keybindingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/keybindings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/keybindings.json"
        },
        "tasksResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/tasks.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/tasks.json"
        },
        "snippetsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/snippets",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/snippets"
        },
        "promptsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/prompts",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/prompts"
        },
        "extensionsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/extensions.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/extensions.json"
        },
        "mcpResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/mcp.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/mcp.json"
        },
        "languageModelsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/chatLanguageModels.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/chatLanguageModels.json"
        },
        "agentPluginsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/agent-plugins",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/agent-plugins"
        },
        "cacheHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/CachedProfilesData/id",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/CachedProfilesData/id"
        },
        "isAgentsWindowProfile": false
      },
      {
        "id": "tid",
        "isDefault": false,
        "name": "tname",
        "location": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/tid",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/tid"
        },
        "globalStorageHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/tid/globalStorage",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/tid/globalStorage"
        },
        "settingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/tid/settings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/tid/settings.json"
        },
        "keybindingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/tid/keybindings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/tid/keybindings.json"
        },
        "tasksResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/tid/tasks.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/tid/tasks.json"
        },
        "snippetsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/tid/snippets",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/tid/snippets"
        },
        "promptsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/tid/prompts",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/tid/prompts"
        },
        "extensionsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/tid/extensions.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/tid/extensions.json"
        },
        "mcpResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/tid/mcp.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/tid/mcp.json"
        },
        "languageModelsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/tid/chatLanguageModels.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/tid/chatLanguageModels.json"
        },
        "agentPluginsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/agent-plugins",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/agent-plugins"
        },
        "cacheHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/CachedProfilesData/tid",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/CachedProfilesData/tid"
        },
        "isInternal": true,
        "isTransient": true,
        "isAgentsWindowProfile": false
      }
    ],
    "ops": [
      [
        "createFolder",
        "vscodeUserData:/root/User/profiles/id"
      ],
      [
        "createFolder",
        "vscodeUserData:/root/User/profiles/tid"
      ]
    ],
    "changes": [
      {
        "added": [
          {
            "id": "id",
            "isDefault": false,
            "name": "name",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/id"
            },
            "isAgentsWindowProfile": false
          }
        ],
        "removed": [],
        "updated": [],
        "all": [
          {
            "id": "__default__profile__",
            "isDefault": true,
            "name": "Default",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/__default__profile__",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/__default__profile__"
            },
            "isAgentsWindowProfile": false
          },
          {
            "id": "id",
            "isDefault": false,
            "name": "name",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/id"
            },
            "isAgentsWindowProfile": false
          }
        ]
      },
      {
        "added": [
          {
            "id": "tid",
            "isDefault": false,
            "name": "tname",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/tid",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/tid"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/tid/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/tid/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/tid/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/tid/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/tid/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/tid/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/tid/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/tid/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/tid/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/tid/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/tid/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/tid/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/tid/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/tid/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/tid/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/tid/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/tid/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/tid/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/tid",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/tid"
            },
            "isInternal": true,
            "isTransient": true,
            "isAgentsWindowProfile": false
          }
        ],
        "removed": [],
        "updated": [],
        "all": [
          {
            "id": "__default__profile__",
            "isDefault": true,
            "name": "Default",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/__default__profile__",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/__default__profile__"
            },
            "isAgentsWindowProfile": false
          },
          {
            "id": "id",
            "isDefault": false,
            "name": "name",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/id"
            },
            "isAgentsWindowProfile": false
          },
          {
            "id": "tid",
            "isDefault": false,
            "name": "tname",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/tid",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/tid"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/tid/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/tid/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/tid/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/tid/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/tid/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/tid/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/tid/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/tid/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/tid/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/tid/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/tid/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/tid/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/tid/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/tid/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/tid/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/tid/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/tid/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/tid/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/tid",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/tid"
            },
            "isInternal": true,
            "isTransient": true,
            "isAgentsWindowProfile": false
          }
        ]
      }
    ],
    "willCreates": [
      {
        "profile": {
          "id": "id",
          "isDefault": false,
          "name": "name",
          "location": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/id",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/id"
          },
          "globalStorageHome": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/id/globalStorage",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/id/globalStorage"
          },
          "settingsResource": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/id/settings.json",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/id/settings.json"
          },
          "keybindingsResource": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/id/keybindings.json",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/id/keybindings.json"
          },
          "tasksResource": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/id/tasks.json",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/id/tasks.json"
          },
          "snippetsHome": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/id/snippets",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/id/snippets"
          },
          "promptsHome": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/id/prompts",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/id/prompts"
          },
          "extensionsResource": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/id/extensions.json",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/id/extensions.json"
          },
          "mcpResource": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/id/mcp.json",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/id/mcp.json"
          },
          "languageModelsResource": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/id/chatLanguageModels.json",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/id/chatLanguageModels.json"
          },
          "agentPluginsHome": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/agent-plugins",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/agent-plugins"
          },
          "cacheHome": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/CachedProfilesData/id",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/CachedProfilesData/id"
          },
          "isAgentsWindowProfile": false
        }
      },
      {
        "profile": {
          "id": "tid",
          "isDefault": false,
          "name": "tname",
          "location": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/tid",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/tid"
          },
          "globalStorageHome": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/tid/globalStorage",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/tid/globalStorage"
          },
          "settingsResource": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/tid/settings.json",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/tid/settings.json"
          },
          "keybindingsResource": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/tid/keybindings.json",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/tid/keybindings.json"
          },
          "tasksResource": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/tid/tasks.json",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/tid/tasks.json"
          },
          "snippetsHome": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/tid/snippets",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/tid/snippets"
          },
          "promptsHome": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/tid/prompts",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/tid/prompts"
          },
          "extensionsResource": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/tid/extensions.json",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/tid/extensions.json"
          },
          "mcpResource": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/tid/mcp.json",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/tid/mcp.json"
          },
          "languageModelsResource": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/tid/chatLanguageModels.json",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/tid/chatLanguageModels.json"
          },
          "agentPluginsHome": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/agent-plugins",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/agent-plugins"
          },
          "cacheHome": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/CachedProfilesData/tid",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/CachedProfilesData/tid"
          },
          "isInternal": true,
          "isTransient": true,
          "isAgentsWindowProfile": false
        }
      }
    ],
    "logs": {
      "warn": [],
      "error": [],
      "info": [],
      "trace": []
    }
  },
  "transientNames": {
    "names": [
      "Temp 1",
      "Temp 2",
      "Temp 3",
      "name"
    ],
    "transients": [
      true,
      true,
      true,
      true
    ],
    "profiles": [
      {
        "id": "__default__profile__",
        "isDefault": true,
        "name": "Default",
        "location": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User"
        },
        "globalStorageHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/globalStorage",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/globalStorage"
        },
        "settingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/settings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/settings.json"
        },
        "keybindingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/keybindings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/keybindings.json"
        },
        "tasksResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/tasks.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/tasks.json"
        },
        "snippetsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/snippets",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/snippets"
        },
        "promptsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/prompts",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/prompts"
        },
        "extensionsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/extensions.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/extensions.json"
        },
        "mcpResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/mcp.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/mcp.json"
        },
        "languageModelsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/chatLanguageModels.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/chatLanguageModels.json"
        },
        "agentPluginsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/agent-plugins",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/agent-plugins"
        },
        "cacheHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/CachedProfilesData/__default__profile__",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/CachedProfilesData/__default__profile__"
        },
        "isAgentsWindowProfile": false
      },
      {
        "id": "-54f7fec0",
        "isDefault": false,
        "name": "Temp 1",
        "location": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0"
        },
        "globalStorageHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/globalStorage",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/globalStorage"
        },
        "settingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/settings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/settings.json"
        },
        "keybindingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/keybindings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/keybindings.json"
        },
        "tasksResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/tasks.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/tasks.json"
        },
        "snippetsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/snippets",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/snippets"
        },
        "promptsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/prompts",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/prompts"
        },
        "extensionsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/extensions.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/extensions.json"
        },
        "mcpResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/mcp.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/mcp.json"
        },
        "languageModelsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/chatLanguageModels.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/chatLanguageModels.json"
        },
        "agentPluginsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/agent-plugins",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/agent-plugins"
        },
        "cacheHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/CachedProfilesData/-54f7fec0",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/CachedProfilesData/-54f7fec0"
        },
        "isInternal": true,
        "isTransient": true,
        "isAgentsWindowProfile": false
      },
      {
        "id": "-54f7febf",
        "isDefault": false,
        "name": "Temp 2",
        "location": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febf",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febf"
        },
        "globalStorageHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febf/globalStorage",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febf/globalStorage"
        },
        "settingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febf/settings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febf/settings.json"
        },
        "keybindingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febf/keybindings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febf/keybindings.json"
        },
        "tasksResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febf/tasks.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febf/tasks.json"
        },
        "snippetsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febf/snippets",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febf/snippets"
        },
        "promptsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febf/prompts",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febf/prompts"
        },
        "extensionsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febf/extensions.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febf/extensions.json"
        },
        "mcpResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febf/mcp.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febf/mcp.json"
        },
        "languageModelsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febf/chatLanguageModels.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febf/chatLanguageModels.json"
        },
        "agentPluginsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/agent-plugins",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/agent-plugins"
        },
        "cacheHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/CachedProfilesData/-54f7febf",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/CachedProfilesData/-54f7febf"
        },
        "isInternal": true,
        "isTransient": true,
        "isAgentsWindowProfile": false
      },
      {
        "id": "-54f7febe",
        "isDefault": false,
        "name": "Temp 3",
        "location": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febe",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febe"
        },
        "globalStorageHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febe/globalStorage",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febe/globalStorage"
        },
        "settingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febe/settings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febe/settings.json"
        },
        "keybindingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febe/keybindings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febe/keybindings.json"
        },
        "tasksResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febe/tasks.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febe/tasks.json"
        },
        "snippetsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febe/snippets",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febe/snippets"
        },
        "promptsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febe/prompts",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febe/prompts"
        },
        "extensionsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febe/extensions.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febe/extensions.json"
        },
        "mcpResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febe/mcp.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febe/mcp.json"
        },
        "languageModelsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febe/chatLanguageModels.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febe/chatLanguageModels.json"
        },
        "agentPluginsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/agent-plugins",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/agent-plugins"
        },
        "cacheHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/CachedProfilesData/-54f7febe",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/CachedProfilesData/-54f7febe"
        },
        "isInternal": true,
        "isTransient": true,
        "isAgentsWindowProfile": false
      },
      {
        "id": "id",
        "isDefault": false,
        "name": "name",
        "location": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id"
        },
        "globalStorageHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/globalStorage",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/globalStorage"
        },
        "settingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/settings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/settings.json"
        },
        "keybindingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/keybindings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/keybindings.json"
        },
        "tasksResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/tasks.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/tasks.json"
        },
        "snippetsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/snippets",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/snippets"
        },
        "promptsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/prompts",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/prompts"
        },
        "extensionsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/extensions.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/extensions.json"
        },
        "mcpResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/mcp.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/mcp.json"
        },
        "languageModelsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/chatLanguageModels.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/chatLanguageModels.json"
        },
        "agentPluginsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/agent-plugins",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/agent-plugins"
        },
        "cacheHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/CachedProfilesData/id",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/CachedProfilesData/id"
        },
        "isInternal": true,
        "isTransient": true,
        "isAgentsWindowProfile": false
      }
    ]
  },
  "transientAfterTemp": {
    "name": "Temp 2",
    "isTransient": true
  },
  "agentsProfile": {
    "profile": {
      "id": "agents",
      "isDefault": false,
      "name": "Agents",
      "location": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/builtin/agents",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/builtin/agents"
      },
      "globalStorageHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/builtin/agents/globalStorage",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/builtin/agents/globalStorage"
      },
      "settingsResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/settings.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/settings.json"
      },
      "keybindingsResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/keybindings.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/keybindings.json"
      },
      "tasksResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/tasks.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/tasks.json"
      },
      "snippetsHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/snippets",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/snippets"
      },
      "promptsHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/prompts",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/prompts"
      },
      "extensionsResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/extensions.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/extensions.json"
      },
      "mcpResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/mcp.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/mcp.json"
      },
      "languageModelsResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/chatLanguageModels.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/chatLanguageModels.json"
      },
      "agentPluginsHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/agent-plugins",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/agent-plugins"
      },
      "cacheHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/CachedProfilesData/agents",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/CachedProfilesData/agents"
      },
      "useDefaultFlags": {
        "settings": true,
        "keybindings": true,
        "prompts": true,
        "mcp": true,
        "languageModels": true,
        "snippets": true,
        "tasks": true,
        "extensions": true
      },
      "isInternal": true,
      "isAgentsWindowProfile": true
    },
    "useDefaultFlags": {
      "settings": true,
      "keybindings": true,
      "prompts": true,
      "mcp": true,
      "languageModels": true,
      "snippets": true,
      "tasks": true,
      "extensions": true
    },
    "isInternal": true,
    "location": "vscodeUserData:/root/User/profiles/builtin/agents"
  },
  "stored": {
    "profiles": [
      {
        "id": "__default__profile__",
        "isDefault": true,
        "name": "Default",
        "location": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User"
        },
        "globalStorageHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/globalStorage",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/globalStorage"
        },
        "settingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/settings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/settings.json"
        },
        "keybindingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/keybindings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/keybindings.json"
        },
        "tasksResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/tasks.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/tasks.json"
        },
        "snippetsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/snippets",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/snippets"
        },
        "promptsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/prompts",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/prompts"
        },
        "extensionsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/extensions.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/extensions.json"
        },
        "mcpResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/mcp.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/mcp.json"
        },
        "languageModelsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/chatLanguageModels.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/chatLanguageModels.json"
        },
        "agentPluginsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/agent-plugins",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/agent-plugins"
        },
        "cacheHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/CachedProfilesData/__default__profile__",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/CachedProfilesData/__default__profile__"
        },
        "isAgentsWindowProfile": false
      },
      {
        "id": "p1",
        "isDefault": false,
        "name": "P1",
        "icon": "i1",
        "location": {
          "scheme": "file",
          "authority": "",
          "path": "/root/User/profiles/p1",
          "query": "",
          "fragment": "",
          "toString": "file:///root/User/profiles/p1"
        },
        "globalStorageHome": {
          "scheme": "file",
          "authority": "",
          "path": "/root/User/profiles/p1/globalStorage",
          "query": "",
          "fragment": "",
          "toString": "file:///root/User/profiles/p1/globalStorage"
        },
        "settingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/settings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/settings.json"
        },
        "keybindingsResource": {
          "scheme": "file",
          "authority": "",
          "path": "/root/User/profiles/p1/keybindings.json",
          "query": "",
          "fragment": "",
          "toString": "file:///root/User/profiles/p1/keybindings.json"
        },
        "tasksResource": {
          "scheme": "file",
          "authority": "",
          "path": "/root/User/profiles/p1/tasks.json",
          "query": "",
          "fragment": "",
          "toString": "file:///root/User/profiles/p1/tasks.json"
        },
        "snippetsHome": {
          "scheme": "file",
          "authority": "",
          "path": "/root/User/profiles/p1/snippets",
          "query": "",
          "fragment": "",
          "toString": "file:///root/User/profiles/p1/snippets"
        },
        "promptsHome": {
          "scheme": "file",
          "authority": "",
          "path": "/root/User/profiles/p1/prompts",
          "query": "",
          "fragment": "",
          "toString": "file:///root/User/profiles/p1/prompts"
        },
        "extensionsResource": {
          "scheme": "file",
          "authority": "",
          "path": "/root/User/profiles/p1/extensions.json",
          "query": "",
          "fragment": "",
          "toString": "file:///root/User/profiles/p1/extensions.json"
        },
        "mcpResource": {
          "scheme": "file",
          "authority": "",
          "path": "/root/User/profiles/p1/mcp.json",
          "query": "",
          "fragment": "",
          "toString": "file:///root/User/profiles/p1/mcp.json"
        },
        "languageModelsResource": {
          "scheme": "file",
          "authority": "",
          "path": "/root/User/profiles/p1/chatLanguageModels.json",
          "query": "",
          "fragment": "",
          "toString": "file:///root/User/profiles/p1/chatLanguageModels.json"
        },
        "agentPluginsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/agent-plugins",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/agent-plugins"
        },
        "cacheHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/CachedProfilesData/p1",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/CachedProfilesData/p1"
        },
        "useDefaultFlags": {
          "settings": true
        },
        "isAgentsWindowProfile": false,
        "workspaces": [
          {
            "scheme": "file",
            "authority": "",
            "path": "/workspace1",
            "query": "",
            "fragment": "",
            "toString": "file:///workspace1"
          }
        ]
      },
      {
        "id": "agents",
        "isDefault": false,
        "name": "Agents",
        "location": {
          "scheme": "file",
          "authority": "",
          "path": "/root/User/profiles/agents",
          "query": "",
          "fragment": "",
          "toString": "file:///root/User/profiles/agents"
        },
        "globalStorageHome": {
          "scheme": "file",
          "authority": "",
          "path": "/root/User/profiles/agents/globalStorage",
          "query": "",
          "fragment": "",
          "toString": "file:///root/User/profiles/agents/globalStorage"
        },
        "settingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/settings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/settings.json"
        },
        "keybindingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/keybindings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/keybindings.json"
        },
        "tasksResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/tasks.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/tasks.json"
        },
        "snippetsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/snippets",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/snippets"
        },
        "promptsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/prompts",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/prompts"
        },
        "extensionsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/extensions.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/extensions.json"
        },
        "mcpResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/mcp.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/mcp.json"
        },
        "languageModelsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/chatLanguageModels.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/chatLanguageModels.json"
        },
        "agentPluginsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/agent-plugins",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/agent-plugins"
        },
        "cacheHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/CachedProfilesData/agents",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/CachedProfilesData/agents"
        },
        "useDefaultFlags": {
          "settings": true,
          "keybindings": true,
          "prompts": true,
          "mcp": true,
          "languageModels": true,
          "snippets": true,
          "tasks": true,
          "extensions": true
        },
        "isInternal": true,
        "isAgentsWindowProfile": true
      },
      {
        "id": "",
        "isDefault": false,
        "name": "NoLocation",
        "location": {
          "scheme": "file",
          "authority": "",
          "path": "",
          "query": "",
          "fragment": "",
          "toString": "file://"
        },
        "globalStorageHome": {
          "scheme": "file",
          "authority": "",
          "path": "/globalStorage",
          "query": "",
          "fragment": "",
          "toString": "file:///globalStorage"
        },
        "settingsResource": {
          "scheme": "file",
          "authority": "",
          "path": "/settings.json",
          "query": "",
          "fragment": "",
          "toString": "file:///settings.json"
        },
        "keybindingsResource": {
          "scheme": "file",
          "authority": "",
          "path": "/keybindings.json",
          "query": "",
          "fragment": "",
          "toString": "file:///keybindings.json"
        },
        "tasksResource": {
          "scheme": "file",
          "authority": "",
          "path": "/tasks.json",
          "query": "",
          "fragment": "",
          "toString": "file:///tasks.json"
        },
        "snippetsHome": {
          "scheme": "file",
          "authority": "",
          "path": "/snippets",
          "query": "",
          "fragment": "",
          "toString": "file:///snippets"
        },
        "promptsHome": {
          "scheme": "file",
          "authority": "",
          "path": "/prompts",
          "query": "",
          "fragment": "",
          "toString": "file:///prompts"
        },
        "extensionsResource": {
          "scheme": "file",
          "authority": "",
          "path": "/extensions.json",
          "query": "",
          "fragment": "",
          "toString": "file:///extensions.json"
        },
        "mcpResource": {
          "scheme": "file",
          "authority": "",
          "path": "/mcp.json",
          "query": "",
          "fragment": "",
          "toString": "file:///mcp.json"
        },
        "languageModelsResource": {
          "scheme": "file",
          "authority": "",
          "path": "/chatLanguageModels.json",
          "query": "",
          "fragment": "",
          "toString": "file:///chatLanguageModels.json"
        },
        "agentPluginsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/agent-plugins",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/agent-plugins"
        },
        "cacheHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/CachedProfilesData/",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/CachedProfilesData/"
        },
        "isAgentsWindowProfile": false
      }
    ],
    "logs": {
      "warn": [
        [
          "Skipping the invalid stored profile",
          {
            "scheme": "file",
            "authority": "",
            "path": "/root/User/profiles/invalid",
            "query": "",
            "fragment": ""
          }
        ],
        [
          "Skipping the invalid stored profile",
          {
            "scheme": "file",
            "authority": "",
            "path": "/root/User/profiles/invalid2",
            "query": "",
            "fragment": ""
          }
        ]
      ],
      "error": [],
      "info": [],
      "trace": []
    },
    "associationWorkspaces": [
      null,
      [
        {
          "scheme": "file",
          "authority": "",
          "path": "/workspace1",
          "query": "",
          "fragment": "",
          "toString": "file:///workspace1"
        }
      ],
      null,
      null
    ],
    "lookup": {
      "workspace": {
        "id": "p1",
        "isDefault": false,
        "name": "P1",
        "icon": "i1",
        "location": {
          "scheme": "file",
          "authority": "",
          "path": "/root/User/profiles/p1",
          "query": "",
          "fragment": "",
          "toString": "file:///root/User/profiles/p1"
        },
        "globalStorageHome": {
          "scheme": "file",
          "authority": "",
          "path": "/root/User/profiles/p1/globalStorage",
          "query": "",
          "fragment": "",
          "toString": "file:///root/User/profiles/p1/globalStorage"
        },
        "settingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/settings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/settings.json"
        },
        "keybindingsResource": {
          "scheme": "file",
          "authority": "",
          "path": "/root/User/profiles/p1/keybindings.json",
          "query": "",
          "fragment": "",
          "toString": "file:///root/User/profiles/p1/keybindings.json"
        },
        "tasksResource": {
          "scheme": "file",
          "authority": "",
          "path": "/root/User/profiles/p1/tasks.json",
          "query": "",
          "fragment": "",
          "toString": "file:///root/User/profiles/p1/tasks.json"
        },
        "snippetsHome": {
          "scheme": "file",
          "authority": "",
          "path": "/root/User/profiles/p1/snippets",
          "query": "",
          "fragment": "",
          "toString": "file:///root/User/profiles/p1/snippets"
        },
        "promptsHome": {
          "scheme": "file",
          "authority": "",
          "path": "/root/User/profiles/p1/prompts",
          "query": "",
          "fragment": "",
          "toString": "file:///root/User/profiles/p1/prompts"
        },
        "extensionsResource": {
          "scheme": "file",
          "authority": "",
          "path": "/root/User/profiles/p1/extensions.json",
          "query": "",
          "fragment": "",
          "toString": "file:///root/User/profiles/p1/extensions.json"
        },
        "mcpResource": {
          "scheme": "file",
          "authority": "",
          "path": "/root/User/profiles/p1/mcp.json",
          "query": "",
          "fragment": "",
          "toString": "file:///root/User/profiles/p1/mcp.json"
        },
        "languageModelsResource": {
          "scheme": "file",
          "authority": "",
          "path": "/root/User/profiles/p1/chatLanguageModels.json",
          "query": "",
          "fragment": "",
          "toString": "file:///root/User/profiles/p1/chatLanguageModels.json"
        },
        "agentPluginsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/agent-plugins",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/agent-plugins"
        },
        "cacheHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/CachedProfilesData/p1",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/CachedProfilesData/p1"
        },
        "useDefaultFlags": {
          "settings": true
        },
        "isAgentsWindowProfile": false,
        "workspaces": [
          {
            "scheme": "file",
            "authority": "",
            "path": "/workspace1",
            "query": "",
            "fragment": "",
            "toString": "file:///workspace1"
          }
        ]
      },
      "emptyWindow": {
        "id": "p1",
        "isDefault": false,
        "name": "P1",
        "icon": "i1",
        "location": {
          "scheme": "file",
          "authority": "",
          "path": "/root/User/profiles/p1",
          "query": "",
          "fragment": "",
          "toString": "file:///root/User/profiles/p1"
        },
        "globalStorageHome": {
          "scheme": "file",
          "authority": "",
          "path": "/root/User/profiles/p1/globalStorage",
          "query": "",
          "fragment": "",
          "toString": "file:///root/User/profiles/p1/globalStorage"
        },
        "settingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/settings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/settings.json"
        },
        "keybindingsResource": {
          "scheme": "file",
          "authority": "",
          "path": "/root/User/profiles/p1/keybindings.json",
          "query": "",
          "fragment": "",
          "toString": "file:///root/User/profiles/p1/keybindings.json"
        },
        "tasksResource": {
          "scheme": "file",
          "authority": "",
          "path": "/root/User/profiles/p1/tasks.json",
          "query": "",
          "fragment": "",
          "toString": "file:///root/User/profiles/p1/tasks.json"
        },
        "snippetsHome": {
          "scheme": "file",
          "authority": "",
          "path": "/root/User/profiles/p1/snippets",
          "query": "",
          "fragment": "",
          "toString": "file:///root/User/profiles/p1/snippets"
        },
        "promptsHome": {
          "scheme": "file",
          "authority": "",
          "path": "/root/User/profiles/p1/prompts",
          "query": "",
          "fragment": "",
          "toString": "file:///root/User/profiles/p1/prompts"
        },
        "extensionsResource": {
          "scheme": "file",
          "authority": "",
          "path": "/root/User/profiles/p1/extensions.json",
          "query": "",
          "fragment": "",
          "toString": "file:///root/User/profiles/p1/extensions.json"
        },
        "mcpResource": {
          "scheme": "file",
          "authority": "",
          "path": "/root/User/profiles/p1/mcp.json",
          "query": "",
          "fragment": "",
          "toString": "file:///root/User/profiles/p1/mcp.json"
        },
        "languageModelsResource": {
          "scheme": "file",
          "authority": "",
          "path": "/root/User/profiles/p1/chatLanguageModels.json",
          "query": "",
          "fragment": "",
          "toString": "file:///root/User/profiles/p1/chatLanguageModels.json"
        },
        "agentPluginsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/agent-plugins",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/agent-plugins"
        },
        "cacheHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/CachedProfilesData/p1",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/CachedProfilesData/p1"
        },
        "useDefaultFlags": {
          "settings": true
        },
        "isAgentsWindowProfile": false,
        "workspaces": [
          {
            "scheme": "file",
            "authority": "",
            "path": "/workspace1",
            "query": "",
            "fragment": "",
            "toString": "file:///workspace1"
          }
        ]
      }
    }
  },
  "updateRename": {
    "renamed": {
      "ok": true,
      "value": {
        "id": "-54f7fec0",
        "isDefault": false,
        "name": "name changed",
        "location": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0"
        },
        "globalStorageHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/globalStorage",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/globalStorage"
        },
        "settingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/settings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/settings.json"
        },
        "keybindingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/keybindings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/keybindings.json"
        },
        "tasksResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/tasks.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/tasks.json"
        },
        "snippetsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/snippets",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/snippets"
        },
        "promptsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/prompts",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/prompts"
        },
        "extensionsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/extensions.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/extensions.json"
        },
        "mcpResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/mcp.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/mcp.json"
        },
        "languageModelsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/chatLanguageModels.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/chatLanguageModels.json"
        },
        "agentPluginsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/agent-plugins",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/agent-plugins"
        },
        "cacheHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/CachedProfilesData/-54f7fec0",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/CachedProfilesData/-54f7fec0"
        },
        "isAgentsWindowProfile": false
      }
    },
    "profiles": [
      {
        "id": "__default__profile__",
        "isDefault": true,
        "name": "Default",
        "location": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User"
        },
        "globalStorageHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/globalStorage",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/globalStorage"
        },
        "settingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/settings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/settings.json"
        },
        "keybindingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/keybindings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/keybindings.json"
        },
        "tasksResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/tasks.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/tasks.json"
        },
        "snippetsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/snippets",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/snippets"
        },
        "promptsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/prompts",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/prompts"
        },
        "extensionsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/extensions.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/extensions.json"
        },
        "mcpResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/mcp.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/mcp.json"
        },
        "languageModelsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/chatLanguageModels.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/chatLanguageModels.json"
        },
        "agentPluginsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/agent-plugins",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/agent-plugins"
        },
        "cacheHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/CachedProfilesData/__default__profile__",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/CachedProfilesData/__default__profile__"
        },
        "isAgentsWindowProfile": false
      },
      {
        "id": "-54f7fec0",
        "isDefault": false,
        "name": "name changed",
        "location": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0"
        },
        "globalStorageHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/globalStorage",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/globalStorage"
        },
        "settingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/settings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/settings.json"
        },
        "keybindingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/keybindings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/keybindings.json"
        },
        "tasksResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/tasks.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/tasks.json"
        },
        "snippetsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/snippets",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/snippets"
        },
        "promptsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/prompts",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/prompts"
        },
        "extensionsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/extensions.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/extensions.json"
        },
        "mcpResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/mcp.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/mcp.json"
        },
        "languageModelsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/chatLanguageModels.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/chatLanguageModels.json"
        },
        "agentPluginsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/agent-plugins",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/agent-plugins"
        },
        "cacheHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/CachedProfilesData/-54f7fec0",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/CachedProfilesData/-54f7fec0"
        },
        "isAgentsWindowProfile": false
      }
    ],
    "changes": [
      {
        "added": [
          {
            "id": "-54f7fec0",
            "isDefault": false,
            "name": "name",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/-54f7fec0",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/-54f7fec0"
            },
            "isAgentsWindowProfile": false
          }
        ],
        "removed": [],
        "updated": [],
        "all": [
          {
            "id": "__default__profile__",
            "isDefault": true,
            "name": "Default",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/__default__profile__",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/__default__profile__"
            },
            "isAgentsWindowProfile": false
          },
          {
            "id": "-54f7fec0",
            "isDefault": false,
            "name": "name",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/-54f7fec0",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/-54f7fec0"
            },
            "isAgentsWindowProfile": false
          }
        ]
      },
      {
        "added": [],
        "removed": [],
        "updated": [
          {
            "id": "-54f7fec0",
            "isDefault": false,
            "name": "name changed",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/-54f7fec0",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/-54f7fec0"
            },
            "isAgentsWindowProfile": false
          }
        ],
        "all": [
          {
            "id": "__default__profile__",
            "isDefault": true,
            "name": "Default",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/__default__profile__",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/__default__profile__"
            },
            "isAgentsWindowProfile": false
          },
          {
            "id": "-54f7fec0",
            "isDefault": false,
            "name": "name changed",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/-54f7fec0/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/-54f7fec0",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/-54f7fec0"
            },
            "isAgentsWindowProfile": false
          }
        ]
      }
    ]
  },
  "updatePersist": {
    "persisted": {
      "id": "-54f7fec0",
      "isDefault": false,
      "name": "saved",
      "location": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/-54f7fec0",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/-54f7fec0"
      },
      "globalStorageHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/-54f7fec0/globalStorage",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/globalStorage"
      },
      "settingsResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/-54f7fec0/settings.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/settings.json"
      },
      "keybindingsResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/-54f7fec0/keybindings.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/keybindings.json"
      },
      "tasksResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/-54f7fec0/tasks.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/tasks.json"
      },
      "snippetsHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/-54f7fec0/snippets",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/snippets"
      },
      "promptsHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/-54f7fec0/prompts",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/prompts"
      },
      "extensionsResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/-54f7fec0/extensions.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/extensions.json"
      },
      "mcpResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/-54f7fec0/mcp.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/mcp.json"
      },
      "languageModelsResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/-54f7fec0/chatLanguageModels.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/chatLanguageModels.json"
      },
      "agentPluginsHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/agent-plugins",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/agent-plugins"
      },
      "cacheHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/CachedProfilesData/-54f7fec0",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/CachedProfilesData/-54f7fec0"
      },
      "isAgentsWindowProfile": false
    },
    "profiles": [
      {
        "id": "__default__profile__",
        "isDefault": true,
        "name": "Default",
        "location": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User"
        },
        "globalStorageHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/globalStorage",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/globalStorage"
        },
        "settingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/settings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/settings.json"
        },
        "keybindingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/keybindings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/keybindings.json"
        },
        "tasksResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/tasks.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/tasks.json"
        },
        "snippetsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/snippets",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/snippets"
        },
        "promptsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/prompts",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/prompts"
        },
        "extensionsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/extensions.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/extensions.json"
        },
        "mcpResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/mcp.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/mcp.json"
        },
        "languageModelsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/chatLanguageModels.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/chatLanguageModels.json"
        },
        "agentPluginsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/agent-plugins",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/agent-plugins"
        },
        "cacheHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/CachedProfilesData/__default__profile__",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/CachedProfilesData/__default__profile__"
        },
        "isAgentsWindowProfile": false
      },
      {
        "id": "-54f7fec0",
        "isDefault": false,
        "name": "saved",
        "location": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0"
        },
        "globalStorageHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/globalStorage",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/globalStorage"
        },
        "settingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/settings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/settings.json"
        },
        "keybindingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/keybindings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/keybindings.json"
        },
        "tasksResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/tasks.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/tasks.json"
        },
        "snippetsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/snippets",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/snippets"
        },
        "promptsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/prompts",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/prompts"
        },
        "extensionsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/extensions.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/extensions.json"
        },
        "mcpResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/mcp.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/mcp.json"
        },
        "languageModelsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7fec0/chatLanguageModels.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/chatLanguageModels.json"
        },
        "agentPluginsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/agent-plugins",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/agent-plugins"
        },
        "cacheHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/CachedProfilesData/-54f7fec0",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/CachedProfilesData/-54f7fec0"
        },
        "isAgentsWindowProfile": false
      }
    ]
  },
  "updateWorkspaces": {
    "added": [
      {
        "scheme": "file",
        "authority": "",
        "path": "/workspace1",
        "query": "",
        "fragment": "",
        "toString": "file:///workspace1"
      }
    ],
    "replaced": [
      {
        "scheme": "file",
        "authority": "",
        "path": "/workspace2",
        "query": "",
        "fragment": "",
        "toString": "file:///workspace2"
      }
    ],
    "default": {
      "sameIdentity": true,
      "workspaces": [
        {
          "scheme": "file",
          "authority": "",
          "path": "/workspace1",
          "query": "",
          "fragment": "",
          "toString": "file:///workspace1"
        }
      ]
    }
  },
  "updateErrors": {
    "missing": {
      "ok": false,
      "error": {
        "message": "Profile 'gone' does not exist",
        "name": "Error"
      }
    },
    "default": {
      "ok": false,
      "error": {
        "message": "Cannot update default profile",
        "name": "Error"
      }
    }
  },
  "updateFlags": {
    "useDefaultFlags": {
      "keybindings": true
    },
    "keybindingsSameAsDefault": true
  },
  "workspaceAssociations": {
    "afterSet": [
      {
        "id": "__default__profile__"
      },
      {
        "id": "id"
      },
      {
        "id": "id1",
        "workspaces": [
          {
            "scheme": "file",
            "authority": "",
            "path": "/workspace1",
            "query": "",
            "fragment": "",
            "toString": "file:///workspace1"
          }
        ]
      }
    ],
    "changes": [
      {
        "added": [
          {
            "id": "id",
            "isDefault": false,
            "name": "name",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/id"
            },
            "isAgentsWindowProfile": false
          }
        ],
        "removed": [],
        "updated": [],
        "all": [
          {
            "id": "__default__profile__",
            "isDefault": true,
            "name": "Default",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/__default__profile__",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/__default__profile__"
            },
            "isAgentsWindowProfile": false
          },
          {
            "id": "id",
            "isDefault": false,
            "name": "name",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/id"
            },
            "isAgentsWindowProfile": false
          }
        ]
      },
      {
        "added": [],
        "removed": [],
        "updated": [
          {
            "id": "id",
            "isDefault": false,
            "name": "name",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/id"
            },
            "isAgentsWindowProfile": false,
            "workspaces": [
              {
                "scheme": "file",
                "authority": "",
                "path": "/workspace1",
                "query": "",
                "fragment": "",
                "toString": "file:///workspace1"
              }
            ]
          }
        ],
        "all": [
          {
            "id": "__default__profile__",
            "isDefault": true,
            "name": "Default",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/__default__profile__",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/__default__profile__"
            },
            "isAgentsWindowProfile": false
          },
          {
            "id": "id",
            "isDefault": false,
            "name": "name",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/id"
            },
            "isAgentsWindowProfile": false,
            "workspaces": [
              {
                "scheme": "file",
                "authority": "",
                "path": "/workspace1",
                "query": "",
                "fragment": "",
                "toString": "file:///workspace1"
              }
            ]
          }
        ]
      },
      {
        "added": [
          {
            "id": "id1",
            "isDefault": false,
            "name": "name1",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/id1",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/id1"
            },
            "isAgentsWindowProfile": false
          }
        ],
        "removed": [],
        "updated": [],
        "all": [
          {
            "id": "__default__profile__",
            "isDefault": true,
            "name": "Default",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/__default__profile__",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/__default__profile__"
            },
            "isAgentsWindowProfile": false
          },
          {
            "id": "id",
            "isDefault": false,
            "name": "name",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/id"
            },
            "isAgentsWindowProfile": false,
            "workspaces": [
              {
                "scheme": "file",
                "authority": "",
                "path": "/workspace1",
                "query": "",
                "fragment": "",
                "toString": "file:///workspace1"
              }
            ]
          },
          {
            "id": "id1",
            "isDefault": false,
            "name": "name1",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/id1",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/id1"
            },
            "isAgentsWindowProfile": false
          }
        ]
      },
      {
        "added": [],
        "removed": [],
        "updated": [
          {
            "id": "id",
            "isDefault": false,
            "name": "name",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/id"
            },
            "isAgentsWindowProfile": false
          },
          {
            "id": "id1",
            "isDefault": false,
            "name": "name1",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/id1",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/id1"
            },
            "isAgentsWindowProfile": false,
            "workspaces": [
              {
                "scheme": "file",
                "authority": "",
                "path": "/workspace1",
                "query": "",
                "fragment": "",
                "toString": "file:///workspace1"
              }
            ]
          }
        ],
        "all": [
          {
            "id": "__default__profile__",
            "isDefault": true,
            "name": "Default",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/__default__profile__",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/__default__profile__"
            },
            "isAgentsWindowProfile": false
          },
          {
            "id": "id",
            "isDefault": false,
            "name": "name",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/id"
            },
            "isAgentsWindowProfile": false
          },
          {
            "id": "id1",
            "isDefault": false,
            "name": "name1",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id1/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id1/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/id1",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/id1"
            },
            "isAgentsWindowProfile": false,
            "workspaces": [
              {
                "scheme": "file",
                "authority": "",
                "path": "/workspace1",
                "query": "",
                "fragment": "",
                "toString": "file:///workspace1"
              }
            ]
          }
        ]
      }
    ],
    "other": "id1",
    "afterUnset": [
      {
        "id": "__default__profile__"
      },
      {
        "id": "id"
      },
      {
        "id": "id1"
      }
    ]
  },
  "emptyWindow": {
    "associated": {
      "id": "id",
      "isDefault": false,
      "name": "name",
      "location": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/id",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/id"
      },
      "globalStorageHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/id/globalStorage",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/id/globalStorage"
      },
      "settingsResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/id/settings.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/id/settings.json"
      },
      "keybindingsResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/id/keybindings.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/id/keybindings.json"
      },
      "tasksResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/id/tasks.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/id/tasks.json"
      },
      "snippetsHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/id/snippets",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/id/snippets"
      },
      "promptsHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/id/prompts",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/id/prompts"
      },
      "extensionsResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/id/extensions.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/id/extensions.json"
      },
      "mcpResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/id/mcp.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/id/mcp.json"
      },
      "languageModelsResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/id/chatLanguageModels.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/id/chatLanguageModels.json"
      },
      "agentPluginsHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/agent-plugins",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/agent-plugins"
      },
      "cacheHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/CachedProfilesData/id",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/CachedProfilesData/id"
      },
      "isAgentsWindowProfile": false
    }
  },
  "agentsLookup": {
    "found": {
      "id": "agents",
      "isDefault": false,
      "name": "Agents",
      "location": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/builtin/agents",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/builtin/agents"
      },
      "globalStorageHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/builtin/agents/globalStorage",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/builtin/agents/globalStorage"
      },
      "settingsResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/settings.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/settings.json"
      },
      "keybindingsResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/keybindings.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/keybindings.json"
      },
      "tasksResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/tasks.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/tasks.json"
      },
      "snippetsHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/snippets",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/snippets"
      },
      "promptsHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/prompts",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/prompts"
      },
      "extensionsResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/extensions.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/extensions.json"
      },
      "mcpResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/mcp.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/mcp.json"
      },
      "languageModelsResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/chatLanguageModels.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/chatLanguageModels.json"
      },
      "agentPluginsHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/agent-plugins",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/agent-plugins"
      },
      "cacheHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/CachedProfilesData/agents",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/CachedProfilesData/agents"
      },
      "useDefaultFlags": {
        "settings": true,
        "keybindings": true,
        "prompts": true,
        "mcp": true,
        "languageModels": true,
        "snippets": true,
        "tasks": true,
        "extensions": true
      },
      "isInternal": true,
      "isAgentsWindowProfile": true
    },
    "agentsId": "agents"
  },
  "reset": {
    "profile": {
      "id": "id",
      "isDefault": false,
      "name": "name",
      "location": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/id",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/id"
      },
      "globalStorageHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/id/globalStorage",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/id/globalStorage"
      },
      "settingsResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/id/settings.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/id/settings.json"
      },
      "keybindingsResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/id/keybindings.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/id/keybindings.json"
      },
      "tasksResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/id/tasks.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/id/tasks.json"
      },
      "snippetsHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/id/snippets",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/id/snippets"
      },
      "promptsHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/id/prompts",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/id/prompts"
      },
      "extensionsResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/id/extensions.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/id/extensions.json"
      },
      "mcpResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/id/mcp.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/id/mcp.json"
      },
      "languageModelsResource": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/profiles/id/chatLanguageModels.json",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/profiles/id/chatLanguageModels.json"
      },
      "agentPluginsHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/agent-plugins",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/agent-plugins"
      },
      "cacheHome": {
        "scheme": "vscodeUserData",
        "authority": "",
        "path": "/root/User/CachedProfilesData/id",
        "query": "",
        "fragment": "",
        "toString": "vscodeUserData:/root/User/CachedProfilesData/id"
      },
      "isAgentsWindowProfile": false
    },
    "profiles": [
      {
        "id": "__default__profile__",
        "isDefault": true,
        "name": "Default",
        "location": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User"
        },
        "globalStorageHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/globalStorage",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/globalStorage"
        },
        "settingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/settings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/settings.json"
        },
        "keybindingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/keybindings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/keybindings.json"
        },
        "tasksResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/tasks.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/tasks.json"
        },
        "snippetsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/snippets",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/snippets"
        },
        "promptsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/prompts",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/prompts"
        },
        "extensionsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/extensions.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/extensions.json"
        },
        "mcpResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/mcp.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/mcp.json"
        },
        "languageModelsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/chatLanguageModels.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/chatLanguageModels.json"
        },
        "agentPluginsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/agent-plugins",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/agent-plugins"
        },
        "cacheHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/CachedProfilesData/__default__profile__",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/CachedProfilesData/__default__profile__"
        },
        "isAgentsWindowProfile": false
      },
      {
        "id": "id",
        "isDefault": false,
        "name": "name",
        "location": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id"
        },
        "globalStorageHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/globalStorage",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/globalStorage"
        },
        "settingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/settings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/settings.json"
        },
        "keybindingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/keybindings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/keybindings.json"
        },
        "tasksResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/tasks.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/tasks.json"
        },
        "snippetsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/snippets",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/snippets"
        },
        "promptsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/prompts",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/prompts"
        },
        "extensionsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/extensions.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/extensions.json"
        },
        "mcpResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/mcp.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/mcp.json"
        },
        "languageModelsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id/chatLanguageModels.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/id/chatLanguageModels.json"
        },
        "agentPluginsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/agent-plugins",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/agent-plugins"
        },
        "cacheHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/CachedProfilesData/id",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/CachedProfilesData/id"
        },
        "isAgentsWindowProfile": false
      }
    ],
    "resets": 1,
    "changes": [
      {
        "added": [
          {
            "id": "id",
            "isDefault": false,
            "name": "name",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/id"
            },
            "isAgentsWindowProfile": false,
            "workspaces": [
              {
                "scheme": "file",
                "authority": "",
                "path": "/w1",
                "query": "",
                "fragment": "",
                "toString": "file:///w1"
              }
            ]
          }
        ],
        "removed": [],
        "updated": [],
        "all": [
          {
            "id": "__default__profile__",
            "isDefault": true,
            "name": "Default",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/__default__profile__",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/__default__profile__"
            },
            "isAgentsWindowProfile": false
          },
          {
            "id": "id",
            "isDefault": false,
            "name": "name",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/id"
            },
            "isAgentsWindowProfile": false,
            "workspaces": [
              {
                "scheme": "file",
                "authority": "",
                "path": "/w1",
                "query": "",
                "fragment": "",
                "toString": "file:///w1"
              }
            ]
          }
        ]
      },
      {
        "added": [],
        "removed": [],
        "updated": [
          {
            "id": "__default__profile__",
            "isDefault": true,
            "name": "Default",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/__default__profile__",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/__default__profile__"
            },
            "isAgentsWindowProfile": false
          },
          {
            "id": "id",
            "isDefault": false,
            "name": "name",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/id"
            },
            "isAgentsWindowProfile": false
          }
        ],
        "all": [
          {
            "id": "__default__profile__",
            "isDefault": true,
            "name": "Default",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/__default__profile__",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/__default__profile__"
            },
            "isAgentsWindowProfile": false
          },
          {
            "id": "id",
            "isDefault": false,
            "name": "name",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/id"
            },
            "isAgentsWindowProfile": false
          }
        ]
      }
    ]
  },
  "remove": {
    "default": {
      "ok": false,
      "error": {
        "message": "Cannot remove default profile",
        "name": "Error"
      }
    },
    "missing": {
      "ok": false,
      "error": {
        "message": "Profile 'name' does not exist",
        "name": "Error"
      }
    },
    "removed": {
      "ok": true
    },
    "profiles": [
      {
        "id": "__default__profile__",
        "isDefault": true,
        "name": "Default",
        "location": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User"
        },
        "globalStorageHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/globalStorage",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/globalStorage"
        },
        "settingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/settings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/settings.json"
        },
        "keybindingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/keybindings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/keybindings.json"
        },
        "tasksResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/tasks.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/tasks.json"
        },
        "snippetsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/snippets",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/snippets"
        },
        "promptsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/prompts",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/prompts"
        },
        "extensionsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/extensions.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/extensions.json"
        },
        "mcpResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/mcp.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/mcp.json"
        },
        "languageModelsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/chatLanguageModels.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/chatLanguageModels.json"
        },
        "agentPluginsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/agent-plugins",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/agent-plugins"
        },
        "cacheHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/CachedProfilesData/__default__profile__",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/CachedProfilesData/__default__profile__"
        },
        "isAgentsWindowProfile": false
      }
    ],
    "ops": [
      [
        "createFolder",
        "vscodeUserData:/root/User/profiles/id"
      ],
      [
        "del",
        "vscodeUserData:/root/User/CachedProfilesData/id",
        {
          "recursive": true
        }
      ]
    ],
    "changes": [
      {
        "added": [
          {
            "id": "id",
            "isDefault": false,
            "name": "name",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/id"
            },
            "isAgentsWindowProfile": false
          }
        ],
        "removed": [],
        "updated": [],
        "all": [
          {
            "id": "__default__profile__",
            "isDefault": true,
            "name": "Default",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/__default__profile__",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/__default__profile__"
            },
            "isAgentsWindowProfile": false
          },
          {
            "id": "id",
            "isDefault": false,
            "name": "name",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/id"
            },
            "isAgentsWindowProfile": false
          }
        ]
      },
      {
        "added": [],
        "removed": [
          {
            "id": "id",
            "isDefault": false,
            "name": "name",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/profiles/id/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/profiles/id/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/id",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/id"
            },
            "isAgentsWindowProfile": false
          }
        ],
        "updated": [],
        "all": [
          {
            "id": "__default__profile__",
            "isDefault": true,
            "name": "Default",
            "location": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User"
            },
            "globalStorageHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/globalStorage",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/globalStorage"
            },
            "settingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/settings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/settings.json"
            },
            "keybindingsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/keybindings.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/keybindings.json"
            },
            "tasksResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/tasks.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/tasks.json"
            },
            "snippetsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/snippets",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/snippets"
            },
            "promptsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/prompts",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/prompts"
            },
            "extensionsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/extensions.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/extensions.json"
            },
            "mcpResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/mcp.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/mcp.json"
            },
            "languageModelsResource": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/chatLanguageModels.json",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/chatLanguageModels.json"
            },
            "agentPluginsHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/agent-plugins",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/agent-plugins"
            },
            "cacheHome": {
              "scheme": "vscodeUserData",
              "authority": "",
              "path": "/root/User/CachedProfilesData/__default__profile__",
              "query": "",
              "fragment": "",
              "toString": "vscodeUserData:/root/User/CachedProfilesData/__default__profile__"
            },
            "isAgentsWindowProfile": false
          }
        ]
      }
    ],
    "willRemoves": [
      {
        "profile": {
          "id": "id",
          "isDefault": false,
          "name": "name",
          "location": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/id",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/id"
          },
          "globalStorageHome": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/id/globalStorage",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/id/globalStorage"
          },
          "settingsResource": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/id/settings.json",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/id/settings.json"
          },
          "keybindingsResource": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/id/keybindings.json",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/id/keybindings.json"
          },
          "tasksResource": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/id/tasks.json",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/id/tasks.json"
          },
          "snippetsHome": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/id/snippets",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/id/snippets"
          },
          "promptsHome": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/id/prompts",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/id/prompts"
          },
          "extensionsResource": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/id/extensions.json",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/id/extensions.json"
          },
          "mcpResource": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/id/mcp.json",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/id/mcp.json"
          },
          "languageModelsResource": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/id/chatLanguageModels.json",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/id/chatLanguageModels.json"
          },
          "agentPluginsHome": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/agent-plugins",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/agent-plugins"
          },
          "cacheHome": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/CachedProfilesData/id",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/CachedProfilesData/id"
          },
          "isAgentsWindowProfile": false
        }
      }
    ]
  },
  "removeNotFound": {
    "logs": {
      "warn": [],
      "error": [],
      "info": [],
      "trace": []
    },
    "ops": [
      [
        "createFolder",
        "vscodeUserData:/root/User/profiles/id"
      ],
      [
        "del",
        "vscodeUserData:/root/User/CachedProfilesData/id",
        {
          "recursive": true
        }
      ]
    ]
  },
  "removeOtherError": {
    "logs": {
      "warn": [],
      "error": [
        [
          {
            "message": "denied",
            "name": "Error"
          }
        ]
      ],
      "info": [],
      "trace": []
    }
  },
  "cleanUp": {
    "before": [
      {
        "location": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id",
          "query": "",
          "fragment": ""
        },
        "name": "name"
      }
    ],
    "saved": [
      {
        "location": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/id",
          "query": "",
          "fragment": ""
        },
        "name": "name"
      }
    ],
    "savedAssoc": {
      "workspaces": {},
      "emptyWindows": {}
    },
    "logs": {
      "warn": [
        [
          "Skipping the invalid stored profile",
          {
            "scheme": "file",
            "authority": "",
            "path": "/root/User/profiles/invalid",
            "query": "",
            "fragment": ""
          }
        ]
      ],
      "error": [],
      "info": [],
      "trace": []
    },
    "ops": [
      [
        "createFolder",
        "vscodeUserData:/root/User/profiles/id"
      ],
      [
        "exists",
        "vscodeUserData:/root/User/profiles"
      ],
      [
        "resolve",
        "vscodeUserData:/root/User/profiles"
      ]
    ]
  },
  "cleanUpFolders": {
    "ops": [
      [
        "exists",
        "vscodeUserData:/root/User/profiles"
      ],
      [
        "resolve",
        "vscodeUserData:/root/User/profiles"
      ],
      [
        "del",
        "file:///root/User/profiles/orphan",
        {
          "recursive": true
        }
      ]
    ],
    "logs": {
      "warn": [],
      "error": [],
      "info": [],
      "trace": []
    }
  },
  "cleanUpTransient": {
    "profiles": [
      {
        "id": "__default__profile__",
        "isDefault": true,
        "name": "Default",
        "location": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User"
        },
        "globalStorageHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/globalStorage",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/globalStorage"
        },
        "settingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/settings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/settings.json"
        },
        "keybindingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/keybindings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/keybindings.json"
        },
        "tasksResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/tasks.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/tasks.json"
        },
        "snippetsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/snippets",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/snippets"
        },
        "promptsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/prompts",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/prompts"
        },
        "extensionsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/extensions.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/extensions.json"
        },
        "mcpResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/mcp.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/mcp.json"
        },
        "languageModelsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/chatLanguageModels.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/chatLanguageModels.json"
        },
        "agentPluginsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/agent-plugins",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/agent-plugins"
        },
        "cacheHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/CachedProfilesData/__default__profile__",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/CachedProfilesData/__default__profile__"
        },
        "isAgentsWindowProfile": false
      },
      {
        "id": "-54f7febf",
        "isDefault": false,
        "name": "Temp 2",
        "location": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febf",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febf"
        },
        "globalStorageHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febf/globalStorage",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febf/globalStorage"
        },
        "settingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febf/settings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febf/settings.json"
        },
        "keybindingsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febf/keybindings.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febf/keybindings.json"
        },
        "tasksResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febf/tasks.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febf/tasks.json"
        },
        "snippetsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febf/snippets",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febf/snippets"
        },
        "promptsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febf/prompts",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febf/prompts"
        },
        "extensionsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febf/extensions.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febf/extensions.json"
        },
        "mcpResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febf/mcp.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febf/mcp.json"
        },
        "languageModelsResource": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/profiles/-54f7febf/chatLanguageModels.json",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/profiles/-54f7febf/chatLanguageModels.json"
        },
        "agentPluginsHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/agent-plugins",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/agent-plugins"
        },
        "cacheHome": {
          "scheme": "vscodeUserData",
          "authority": "",
          "path": "/root/User/CachedProfilesData/-54f7febf",
          "query": "",
          "fragment": "",
          "toString": "vscodeUserData:/root/User/CachedProfilesData/-54f7febf"
        },
        "isInternal": true,
        "isTransient": true,
        "isAgentsWindowProfile": false,
        "workspaces": [
          {
            "scheme": "file",
            "authority": "",
            "path": "/w1",
            "query": "",
            "fragment": "",
            "toString": "file:///w1"
          }
        ]
      }
    ],
    "names": [
      "Default",
      "Temp 2"
    ]
  },
  "joiners": {
    "willCreates": [
      {
        "profile": {
          "id": "-54f7fec0",
          "isDefault": false,
          "name": "name",
          "location": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/-54f7fec0",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/-54f7fec0"
          },
          "globalStorageHome": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/-54f7fec0/globalStorage",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/globalStorage"
          },
          "settingsResource": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/-54f7fec0/settings.json",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/settings.json"
          },
          "keybindingsResource": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/-54f7fec0/keybindings.json",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/keybindings.json"
          },
          "tasksResource": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/-54f7fec0/tasks.json",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/tasks.json"
          },
          "snippetsHome": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/-54f7fec0/snippets",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/snippets"
          },
          "promptsHome": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/-54f7fec0/prompts",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/prompts"
          },
          "extensionsResource": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/-54f7fec0/extensions.json",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/extensions.json"
          },
          "mcpResource": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/-54f7fec0/mcp.json",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/mcp.json"
          },
          "languageModelsResource": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/profiles/-54f7fec0/chatLanguageModels.json",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/profiles/-54f7fec0/chatLanguageModels.json"
          },
          "agentPluginsHome": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/agent-plugins",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/agent-plugins"
          },
          "cacheHome": {
            "scheme": "vscodeUserData",
            "authority": "",
            "path": "/root/User/CachedProfilesData/-54f7fec0",
            "query": "",
            "fragment": "",
            "toString": "vscodeUserData:/root/User/CachedProfilesData/-54f7fec0"
          },
          "isAgentsWindowProfile": false
        }
      }
    ],
    "profile": "-54f7fec0"
  }
}
""") as Map<String, dynamic>;

Map<String, dynamic> _t(String key) => T[key] as Map<String, dynamic>;

final List<String> _uuids =
    List<String>.generate(64, (i) => 'fixed-uuid-$i');
int _uuidIndex = 0;
void _resetUuid() => _uuidIndex = 0;
void _setUpUuid() {
  udp.UserDataProfilesService.generateUuid =
      () => _uuids[_uuidIndex++ % _uuids.length];
  _resetUuid();
}

Map<String, Object?> _plainUri(uri.URI u) => <String, Object?>{
      'scheme': u.scheme,
      'authority': u.authority,
      'path': u.path,
      'query': u.query,
      'fragment': u.fragment,
      'toString': u.toString(),
    };

Map<String, Object?> _plainUriFields(uri.URI u) => <String, Object?>{
      'scheme': u.scheme,
      'authority': u.authority,
      'path': u.path,
      'query': u.query,
      'fragment': u.fragment,
    };

Object? _plainAny(Object? value) {
  if (value is uri.URI) return _plainUriFields(value);
  if (value is List) return value.map(_plainAny).toList();
  if (value is Map) {
    return value.map((k, v) =>
        MapEntry<String, Object?>(k.toString(), _plainAny(v)));
  }
  if (value is errors.BugIndicatingError) {
    return <String, Object?>{'message': value.message, 'name': 'Error'};
  }
  if (value is files.FileError) {
    return <String, Object?>{'message': value.message, 'name': 'Error'};
  }
  if (value is Exception || value is Error) {
    return <String, Object?>{'message': value.toString(), 'name': 'Error'};
  }
  return value;
}

Map<String, Object?> _plainProfile(udp.IUserDataProfile p) {
  final result = <String, Object?>{
    'id': p.id,
    'isDefault': p.isDefault,
    'name': p.name,
    'location': _plainUri(p.location),
    'globalStorageHome': _plainUri(p.globalStorageHome),
    'settingsResource': _plainUri(p.settingsResource),
    'keybindingsResource': _plainUri(p.keybindingsResource),
    'tasksResource': _plainUri(p.tasksResource),
    'snippetsHome': _plainUri(p.snippetsHome),
    'promptsHome': _plainUri(p.promptsHome),
    'extensionsResource': _plainUri(p.extensionsResource),
    'mcpResource': _plainUri(p.mcpResource),
    'languageModelsResource': _plainUri(p.languageModelsResource),
    'agentPluginsHome': _plainUri(p.agentPluginsHome),
    'cacheHome': _plainUri(p.cacheHome),
  };
  if (p.icon != null) result['icon'] = p.icon;
  if (p.useDefaultFlags != null) result['useDefaultFlags'] = p.useDefaultFlags;
  if (p.isInternal != null) result['isInternal'] = p.isInternal;
  if (p.isTransient != null) result['isTransient'] = p.isTransient;
  if (p.isAgentsWindowProfile != null) {
    result['isAgentsWindowProfile'] = p.isAgentsWindowProfile;
  }
  if (p.workspaces != null) {
    result['workspaces'] = p.workspaces!.map(_plainUri).toList();
  }
  return result;
}

List<Object?> _plainProfiles(Iterable<udp.IUserDataProfile> profiles) =>
    profiles.map(_plainProfile).toList();

Map<String, Object?> _outcome(Object? value, Object? error) => error == null
    ? <String, Object?>{
        'ok': true,
        if (value != null) 'value': value,
      }
    : <String, Object?>{
        'ok': false,
        'error': _plainAny(error),
      };

Future<Map<String, Object?>> _attempt(Future<Object?> Function() run) async {
  try {
    return _outcome(await run(), null);
  } catch (e) {
    return _outcome(null, e);
  }
}

class _Env implements environment.IEnvironmentServiceType {
  _Env([this._agent]);

  final uri.URI? _agent;

  @override
  uri.URI get userRoamingDataHome => uri.URI
      .file('/root/User')
      .withChanges(const uri.UriChange(scheme: 'vscodeUserData'));

  @override
  uri.URI get cacheHome => userRoamingDataHome;

  @override
  uri.URI get agentSessionsWorkspace => _agent ?? uri.URI.file('');

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FileService implements files.IFileServiceType {
  final List<Object?> ops = <Object?>[];
  Object? createFolderError;
  Object? delError;
  bool existsResult = true;
  List<Object?> children = <Object?>[];

  Future<void> createFolder(uri.URI resource) async {
    ops.add(<Object?>['createFolder', resource.toString()]);
    if (createFolderError != null) throw createFolderError!;
  }

  Future<void> del(uri.URI resource, Object? options) async {
    ops.add(<Object?>['del', resource.toString(), options]);
    if (delError != null) throw delError!;
  }

  Future<bool> exists(uri.URI resource) async {
    ops.add(<Object?>['exists', resource.toString()]);
    return existsResult;
  }

  Future<Object> resolve(uri.URI resource) async {
    ops.add(<Object?>['resolve', resource.toString()]);
    return _Stat(children);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Stat {
  _Stat(this.children);
  final List<Object?> children;
}

class _Child {
  _Child(this.name, this.path, this.isDirectory);
  final String name;
  final String path;
  final bool isDirectory;
  uri.URI get resource => uri.URI.file(path);
}

class _Log implements log.ILogServiceType {
  final Map<String, List<Object?>> calls = <String, List<Object?>>{
    'warn': <Object?>[],
    'error': <Object?>[],
    'info': <Object?>[],
    'trace': <Object?>[],
  };

  @override
  void warn(Object message, [List<Object?> args = const <Object?>[]]) {
    calls['warn']!.add(<Object?>[message, ...args.map(_plainAny)]);
  }

  @override
  void error(Object message, [List<Object?> args = const <Object?>[]]) {
    calls['error']!.add(<Object?>[_plainAny(message), ...args.map(_plainAny)]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _UriIdentity implements uriIdentity.IUriIdentityServiceType {
  @override
  final resources.IExtUri extUri = resources.ExtUri((_) => false);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Harness {
  _Harness({List<udp.StoredUserDataProfile>? stored,
      udp.StoredProfileAssociations? associations,
      this.delError,
      this.children = const <Object?>[],
      uri.URI? agentWorkspace})
      : environment = _Env(agentWorkspace) {
    if (stored != null) service.storedProfiles = stored;
    if (associations != null) service.storedProfileAssociations = associations;
    fileService.delError = delError;
    fileService.children = children;
    service.onDidChangeProfiles((e) => changes.add(<String, Object?>{
          'added': _plainProfiles(e.added),
          'removed': _plainProfiles(e.removed),
          'updated': _plainProfiles(e.updated),
          'all': _plainProfiles(e.all),
        }));
    service.onDidChangeProfiles((_) {});
    service.onWillCreateProfile((e) => willCreates
        .add(<String, Object?>{'profile': _plainProfile(e.profile)}));
    service.onWillRemoveProfile((e) => willRemoves
        .add(<String, Object?>{'profile': _plainProfile(e.profile)}));
    service.onDidResetWorkspaces((_) => resets.add(true));
  }

  final _Env environment;
  final _FileService fileService = _FileService();
  final _Log logService = _Log();
  final _UriIdentity uriIdentityService = _UriIdentity();
  final List<Object?> changes = <Object?>[];
  final List<Object?> willCreates = <Object?>[];
  final List<Object?> willRemoves = <Object?>[];
  final List<Object?> resets = <Object?>[];
  final Object? delError;
  final List<Object?> children;

  late final udp.InMemoryUserDataProfilesService service =
      udp.InMemoryUserDataProfilesService(
          environment, fileService, uriIdentityService, logService);

  Map<String, Object?> get logs => <String, Object?>{
        'warn': List<Object?>.from(logService.calls['warn']!),
        'error': List<Object?>.from(logService.calls['error']!),
        'info': List<Object?>.from(logService.calls['info']!),
        'trace': List<Object?>.from(logService.calls['trace']!),
      };
}

uri.URI _storedLocation(String path) => uri.URI.file(path);

udp.StoredUserDataProfile _stored(String path, Object name,
        [Object? extraIcon, Object? flags]) =>
    udp.StoredUserDataProfile(
      name: name as String,
      location: _storedLocation(path),
      icon: extraIcon as String?,
      useDefaultFlags: flags as udp.UseDefaultProfileFlags?,
    );

void main() {
  setUp(_setUpUuid);

  group('batch160 / userDataProfile.ts', () {
    test('constants, isUserDataProfile and pure profile builders', () {
      final constants = _t('constants');
      expect(udp.AGENTS_WINDOW_PROFILE_ID, constants['agentsWindowProfileId']);
      final types = (constants['profileResourceType'] as Map).cast<String, String>();
      expect(udp.ProfileResourceType.Settings, types['Settings']);
      expect(udp.ProfileResourceType.Keybindings, types['Keybindings']);
      expect(udp.ProfileResourceType.Snippets, types['Snippets']);
      expect(udp.ProfileResourceType.Prompts, types['Prompts']);
      expect(udp.ProfileResourceType.Tasks, types['Tasks']);
      expect(udp.ProfileResourceType.Extensions, types['Extensions']);
      expect(udp.ProfileResourceType.GlobalState, types['GlobalState']);
      expect(udp.ProfileResourceType.Mcp, types['Mcp']);
      expect(udp.ProfileResourceType.LanguageModels, types['LanguageModels']);

      final check = _t('isUserDataProfile');
      final base = udp.toUserDataProfile('id', 'name', uri.URI.file('/loc'),
          uri.URI.file('/cache'));
      expect(udp.isUserDataProfile(base), check['valid']);
      expect(udp.isUserDataProfile(null), check['null']);
      expect(udp.isUserDataProfile('x'), check['string']);

      final pure = _t('pureProfiles');
      final agents = udp.toUserDataProfile('agents', 'Agents',
          uri.URI.file('/agents'), uri.URI.file('/cache'), null, base);
      expect(_plainProfile(agents), pure['agents']);
      final flags = udp.toUserDataProfile(
        'id2',
        'name2',
        uri.URI.file('/loc2'),
        uri.URI.file('/cache'),
        udp.UserDataProfileOptions(
          icon: 'icon',
          useDefaultFlags: <String, Object?>{
            'settings': true,
            'keybindings': true,
            'globalState': true,
          },
          transient: true,
          workspaces: <uri.URI>[uri.URI.file('/w1')],
        ),
        base,
      );
      expect(_plainProfile(flags), pure['withFlags']);
    });

    test('default profile', () {
      final h = _Harness();
      final truth = _t('defaultProfile');
      expect(_plainProfile(h.service.defaultProfile), truth['profile']);
      expect(_plainProfiles(h.service.profiles), truth['profiles']);
      expect(h.service.profilesHome.toString(), truth['profilesHome']);
    });

    test('create profile, transient and error paths', () async {
      final h = _Harness();
      final truth = _t('create');
      final created = await _attempt(() async => h.service.createProfile('id', 'name'));
      expect(_normalizeOutcome(created), truth['profile']);
      final transient = await _attempt(
          () => h.service.createProfile('tid', 'tname',
              udp.UserDataProfileOptions(transient: true)));
      expect(_normalizeOutcome(transient), truth['transient']);
      final dup = await _attempt(() => h.service.createProfile('other', 'name'));
      expect(dup, truth['duplicate']);
      final missing =
          await _attempt(() => h.service.createProfile('x', ''));
      expect(missing, truth['missingName']);
      final nonString = await _attempt(
          () => h.service.createProfile('x', (1 as dynamic) as String));
      expect(nonString['ok'], truth['nonStringName']['ok']);
      expect(_plainProfiles(h.service.profiles), truth['profiles']);
      expect(h.fileService.ops, truth['ops']);
      expect(h.changes.length, (truth['changes'] as List).length);
      expect(h.willCreates, truth['willCreates']);
      expect(h.logs, truth['logs']);
    });

    test('transient naming and agents window profile', () async {
      _resetUuid();
      final h = _Harness();
      final truth = _t('transientNames');
      final p1 = await h.service.createTransientProfile();
      final p2 = await h.service.createTransientProfile();
      final p3 = await h.service.createTransientProfile();
      final p4 = await h.service.createProfile(
          'id', 'name', udp.UserDataProfileOptions(transient: true));
      expect(<Object?>[p1.name, p2.name, p3.name, p4.name], truth['names']);
      expect(<Object?>[p1.isTransient, p2.isTransient, p3.isTransient,
          p4.isTransient], truth['transients']);
      _resetUuid();
      final h2 = _Harness();
      await h2.service.createNamedProfile('Temp 1');
      final temp = await h2.service.createTransientProfile();
      expect(temp.name, _t('transientAfterTemp')['name']);

      _resetUuid();
      final h3 = _Harness();
      final agents = await h3.service.createProfile(
          udp.AGENTS_WINDOW_PROFILE_ID, 'Agents',
          udp.UserDataProfileOptions(transient: true));
      final aTruth = _t('agentsProfile');
      expect(agents.useDefaultFlags, aTruth['useDefaultFlags']);
      expect(agents.location.toString(), aTruth['location']);
      expect(agents.isAgentsWindowProfile, true);
    });

    test('stored profiles and associations', () {
      _resetUuid();
      final h = _Harness(
        stored: <udp.StoredUserDataProfile>[
          _stored('/root/User/profiles/p1', 'P1', 'i1',
              <String, Object?>{'settings': true}),
          _stored('/root/User/profiles/agents', 'Agents'),
          _stored('/root/User/profiles/invalid', ''),
          _stored('/root/User/profiles/invalid2', ''),
          _stored('', 'NoLocation'),
        ],
        associations: udp.StoredProfileAssociations(
          workspaces: <String, String>{
            'file:///workspace1': 'p1',
            'file:///missing': 'nope',
          },
          emptyWindows: <String, String>{'w1': 'p1', 'w2': 'nope'},
        ),
      );
      final truth = _t('stored');
      final names = h.service.profiles.map((p) => p.name).toList();
      expect(names, (truth['profiles'] as List).map((p) => p['name']).toList());
      expect(h.logs['warn'], truth['logs']['warn']);
      final found = h.service.getProfileForWorkspace(<String, Object?>{
        'id': 'file:///workspace1',
        'configPath': uri.URI.file('/workspace1'),
      });
      final emptyFound = h.service.getProfileForWorkspace(<String, Object?>{'id': 'w1'});
      expect(found?.name, 'P1');
      expect(emptyFound?.name, 'P1');
      expect(found?.workspaces?.map((w) => w.toString()).toList(),
          <Object?>['file:///workspace1']);
    });

    test('update profile: rename, persist, workspaces, flags and errors',
        () async {
      _resetUuid();
      final h = _Harness();
      var p = await h.service.createNamedProfile('name');
      final renamed = await _attempt(
          () => h.service.updateProfile(p,
              udp.UserDataProfileUpdateOptions(name: 'name changed')));
      expect(_normalizeOutcome(renamed), _t('updateRename')['renamed']);

      _resetUuid();
      final h2 = _Harness();
      final transient = await h2.service.createTransientProfile();
      final persisted = await h2.service.updateProfile(transient,
          udp.UserDataProfileUpdateOptions(name: 'saved', transient: false));
      expect(persisted.name, _t('updatePersist')['persisted']['name']);
      expect(persisted.isTransient, null);
      final cleared = await h2.service.updateProfile(
          persisted, udp.UserDataProfileUpdateOptions(icon: null));
      expect(cleared.icon, null);

      _resetUuid();
      final h3 = _Harness();
      var wp = await h3.service.createNamedProfile('name');
      wp = await h3.service.updateProfile(
          wp, udp.UserDataProfileUpdateOptions(
              workspaces: <uri.URI>[uri.URI.file('/workspace1')]));
      expect(wp.workspaces?.map((w) => w.toString()).toList(),
          <Object?>['file:///workspace1']);
      wp = await h3.service.updateProfile(
          wp, udp.UserDataProfileUpdateOptions(workspaces: <uri.URI>[]));
      expect(wp.workspaces, null);
      wp = await h3.service.updateProfile(
          wp, udp.UserDataProfileUpdateOptions(
              workspaces: <uri.URI>[uri.URI.file('/workspace2')]));
      expect(wp.workspaces?.map((w) => w.toString()).toList(),
          <Object?>['file:///workspace2']);
      final def = await h3.service.updateProfile(h3.service.defaultProfile,
          udp.UserDataProfileUpdateOptions(
              workspaces: <uri.URI>[uri.URI.file('/workspace1')]));
      expect(identical(def, h3.service.defaultProfile),
          _t('updateWorkspaces')['default']['sameIdentity']);

      _resetUuid();
      final h4 = _Harness();
      final p4 = await h4.service.createNamedProfile('name');
      final missing = await _attempt(() => h4.service.updateProfile(
          _copyWithId(p4, 'missing', 'gone')));
      expect(missing, _t('updateErrors')['missing']);
      final defaultErr = await _attempt(
          () => h4.service.updateProfile(h4.service.defaultProfile));
      expect(defaultErr, _t('updateErrors')['default']);

      _resetUuid();
      final h5 = _Harness();
      final p5 = await h5.service.createNamedProfile('name');
      final flagged = await h5.service.updateProfile(
          p5,
          udp.UserDataProfileUpdateOptions(
              useDefaultFlags: <String, Object?>{'keybindings': true}));
      expect(flagged.useDefaultFlags, _t('updateFlags')['useDefaultFlags']);
      expect(flagged.keybindingsResource.toString(),
          h5.service.defaultProfile.keybindingsResource.toString());
    });

    test('workspace association, empty window and agents lookup', () async {
      _resetUuid();
      final h = _Harness();
      final p = await h.service.createProfile('id', 'name');
      final ws = <String, Object?>{
        'id': '/workspace1',
        'uri': uri.URI.file('/workspace1'),
      };
      await h.service.setProfileForWorkspace(ws, p);
      await h.service.setProfileForWorkspace(ws, p);
      final other = await h.service.createProfile('id1', 'name1');
      await h.service.setProfileForWorkspace(ws, other);
      final afterSet = h.service.profiles
          .map((x) => <String, Object?>{
                'id': x.id,
                if (x.workspaces != null)
                  'workspaces': x.workspaces!.map(_plainUri).toList(),
              })
          .toList();
      expect(afterSet, _t('workspaceAssociations')['afterSet']);
      h.service.unsetWorkspace(ws);
      final afterUnset = h.service.profiles
          .map((x) => <String, Object?>{
                'id': x.id,
                if (x.workspaces != null)
                  'workspaces': x.workspaces!.map(_plainUri).toList(),
              })
          .toList();
      expect(afterUnset, _t('workspaceAssociations')['afterUnset']);

      _resetUuid();
      final h2 = _Harness();
      final p2 = await h2.service.createProfile('id', 'name');
      final empty = <String, Object?>{'id': 'empty-window-1'};
      await h2.service.setProfileForWorkspace(empty, p2);
      expect(h2.service.getProfileForWorkspace(empty)?.id, 'id');
      h2.service.unsetWorkspace(empty);
      expect(h2.service.getProfileForWorkspace(empty), isNull);

      _resetUuid();
      final agentUri = uri.URI.file('/agent-session');
      final h3 = _Harness(agentWorkspace: agentUri);
      await h3.service.createProfile(udp.AGENTS_WINDOW_PROFILE_ID, 'Agents');
      final found = h3.service.getProfileForWorkspace(<String, Object?>{
        'id': '/agent-session',
        'uri': agentUri,
      });
      expect(found?.name, _t('agentsLookup')['found']['name']);
    });

    test('reset and remove profiles', () async {
      _resetUuid();
      final h = _Harness();
      await h.service.createProfile('id', 'name',
          udp.UserDataProfileOptions(
              workspaces: <uri.URI>[uri.URI.file('/w1')]));
      var profile = h.service.profiles[1];
      await h.service.resetWorkspaces();
      expect(profile.workspaces, null);
      expect(h.resets.length, _t('reset')['resets']);

      _resetUuid();
      final h2 = _Harness();
      final p2 = await h2.service.createProfile('id', 'name');
      final defErr = await _attempt(
          () => h2.service.removeProfile(h2.service.defaultProfile));
      expect(defErr, _t('remove')['default']);
      final missingErr = await _attempt(
          () => h2.service.removeProfile(_copyWithId(p2, 'missing', p2.name)));
      expect(missingErr, _t('remove')['missing']);
      final removed = await _attempt(() => h2.service.removeProfile(p2));
      expect(removed, _t('remove')['removed']);
      expect(h2.service.profiles.length, 1);
      expect(h2.fileService.ops, _t('remove')['ops']);

      _resetUuid();
      final h3 = _Harness(delError: files.FileOperationError(
          'gone', files.FileOperationResult.FILE_NOT_FOUND));
      final p3 = await h3.service.createProfile('id', 'name');
      await h3.service.removeProfile(p3);
      expect(h3.logs['error'], _t('removeNotFound')['logs']['error']);

      _resetUuid();
      final h4 = _Harness(delError: files.FileError('denied'));
      final p4 = await h4.service.createProfile('id', 'name');
      await h4.service.removeProfile(p4);
      expect(h4.logs['error'], _t('removeOtherError')['logs']['error']);
    });

    test('cleanUp, cleanUpTransient and will-create events', () async {
      _resetUuid();
      final h = _Harness(
        stored: <udp.StoredUserDataProfile>[
          _stored('/root/User/profiles/invalid', ''),
        ],
        associations: udp.StoredProfileAssociations(),
      );
      await h.service.createProfile('id', 'name');
      await h.service.cleanUp();
      final truth = _t('cleanUp');
      expect(h.logs['warn'], truth['logs']['warn']);
      expect(h.service.storedProfiles.map((p) => p.name).toList(),
          (truth['saved'] as List).map((p) => p['name']).toList());

      _resetUuid();
      final h2 = _Harness(children: <Object?>[
        _Child('orphan', '/root/User/profiles/orphan', true),
        _Child('builtin', '/root/User/profiles/builtin', true),
        _Child('file', '/root/User/profiles/file', false),
      ]);
      await h2.service.cleanUp();
      expect(h2.fileService.ops, _t('cleanUpFolders')['ops']);

      _resetUuid();
      final h3 = _Harness();
      final t1 = await h3.service.createTransientProfile();
      final t2 = await h3.service.createTransientProfile();
      await h3.service.updateProfile(
          t2, udp.UserDataProfileUpdateOptions(
              workspaces: <uri.URI>[uri.URI.file('/w1')]));
      await h3.service.cleanUpTransientProfiles();
      expect(h3.service.profiles.map((p) => p.name).toList(),
          _t('cleanUpTransient')['names']);
      expect(t1.isTransient, true);
    });
  });
}

Map<String, Object?> _normalizeOutcome(Map<String, Object?> outcome) {
  if (outcome['ok'] == true) {
    final value = outcome['value'];
    if (value is udp.IUserDataProfile) {
      return <String, Object?>{'ok': true, 'value': _plainProfile(value)};
    }
  }
  return outcome;
}

udp.IUserDataProfile _copyWithId(
    udp.IUserDataProfile p, String id, String name) =>
    udp.UserDataProfileCarrier(
      id: id,
      isDefault: p.isDefault,
      name: name,
      icon: p.icon,
      location: p.location,
      globalStorageHome: p.globalStorageHome,
      settingsResource: p.settingsResource,
      keybindingsResource: p.keybindingsResource,
      tasksResource: p.tasksResource,
      snippetsHome: p.snippetsHome,
      promptsHome: p.promptsHome,
      extensionsResource: p.extensionsResource,
      mcpResource: p.mcpResource,
      languageModelsResource: p.languageModelsResource,
      agentPluginsHome: p.agentPluginsHome,
      cacheHome: p.cacheHome,
      useDefaultFlags: p.useDefaultFlags,
      isInternal: p.isInternal,
      isTransient: p.isTransient,
      isAgentsWindowProfile: p.isAgentsWindowProfile,
      workspaces: p.workspaces,
    );
