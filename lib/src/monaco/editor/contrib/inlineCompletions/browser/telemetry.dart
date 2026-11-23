// 1:1 port of vs/editor/contrib/inlineCompletions/browser/telemetry.ts
// The two type aliases in the TS source are type-only (erased at runtime); they
// are represented here as classes carrying the same fields / metadata.

import '../../../../platform/dataChannel/browser/forwardingTelemetryService.dart'
    show DataChannelForwardingTelemetryService;

/// 1:1: `export function sendInlineCompletionsEndOfLifeTelemetry(...)`
///
/// Forwards the summary unchanged to `publicLog2` under the fixed event name.
void sendInlineCompletionsEndOfLifeTelemetry(
  DataChannelForwardingTelemetryService dataChannel,
  InlineCompletionEndOfLifeEvent endOfLifeSummary,
) {
  dataChannel.publicLog2(
      'inlineCompletion.endOfLife', endOfLifeSummary);
}

/// 1:1: `export type InlineCompletionEndOfLifeEvent = { ... }`
class InlineCompletionEndOfLifeEvent {
  // request
  final String opportunityId;
  final String requestReason;
  final String editorType;
  final String languageId;
  final num typingInterval;
  final num typingIntervalCharacterCount;
  final bool selectedSuggestionInfo;
  final String availableProviders;
  final String? skuPlan;
  final String? skuType;
  // response
  final String? correlationId;
  final String extensionId;
  final String extensionVersion;
  final String? groupId;
  // behavior
  final bool shown;
  final num? shownDuration;
  final num? shownDurationUncollapsed;
  final num? timeUntilShown;
  final num? timeUntilProviderRequest;
  final num? timeUntilProviderResponse;
  /// TS union `'accepted' | 'rejected' | 'ignored' | undefined`.
  final String? reason;
  final bool? acceptedAlternativeAction;
  final num? partiallyAccepted;
  final num? partiallyAcceptedCountSinceOriginal;
  final num? partiallyAcceptedRatioSinceOriginal;
  final num? partiallyAcceptedCharactersSinceOriginal;
  final bool? preceeded;
  final bool? superseded;
  final String? notShownReason;
  final bool? renameCreated;
  final num? renameDuration;
  final bool? renameTimedOut;
  final num? renameDroppedOtherEdits;
  final num? renameDroppedRenameEdits;
  final String? performanceMarkers;
  // rendering
  final String? viewKind;
  final num? cursorColumnDistance;
  final num? cursorLineDistance;
  final num? lineCountOriginal;
  final num? lineCountModified;
  final num? characterCountOriginal;
  final num? characterCountModified;
  final num? disjointReplacements;
  final bool? sameShapeReplacements;
  final bool? longDistanceHintVisible;
  final num? longDistanceHintDistance;
  final bool? isForAnotherDocument;
  // empty
  final String? noSuggestionReason;
  // shape
  final String? editKind;

  InlineCompletionEndOfLifeEvent({
    this.opportunityId = '',
    this.requestReason = '',
    this.editorType = '',
    this.languageId = '',
    this.typingInterval = 0,
    this.typingIntervalCharacterCount = 0,
    this.selectedSuggestionInfo = false,
    this.availableProviders = '',
    this.skuPlan,
    this.skuType,
    this.correlationId,
    this.extensionId = '',
    this.extensionVersion = '',
    this.groupId,
    this.shown = false,
    this.shownDuration,
    this.shownDurationUncollapsed,
    this.timeUntilShown,
    this.timeUntilProviderRequest,
    this.timeUntilProviderResponse,
    this.reason,
    this.acceptedAlternativeAction,
    this.partiallyAccepted,
    this.partiallyAcceptedCountSinceOriginal,
    this.partiallyAcceptedRatioSinceOriginal,
    this.partiallyAcceptedCharactersSinceOriginal,
    this.preceeded,
    this.superseded,
    this.notShownReason,
    this.renameCreated,
    this.renameDuration,
    this.renameTimedOut,
    this.renameDroppedOtherEdits,
    this.renameDroppedRenameEdits,
    this.performanceMarkers,
    this.viewKind,
    this.cursorColumnDistance,
    this.cursorLineDistance,
    this.lineCountOriginal,
    this.lineCountModified,
    this.characterCountOriginal,
    this.characterCountModified,
    this.disjointReplacements,
    this.sameShapeReplacements,
    this.longDistanceHintVisible,
    this.longDistanceHintDistance,
    this.isForAnotherDocument,
    this.noSuggestionReason,
    this.editKind,
  });
}

/// 1:1: `type InlineCompletionsEndOfLifeClassification = { ... }`
///
/// Type-only in TS (GDPR annotation). Carried here as metadata for fidelity.
class InlineCompletionsEndOfLifeClassification {
  static const String owner = 'benibenj';
  static const String comment =
      'Inline completions ended. @sentToGitHub';

  /// Each entry mirrors `{ classification, purpose, comment, [isMeasurement] }`.
  static const Map<String, Map<String, Object?>> fields =
      <String, Map<String, Object?>>{
    'opportunityId': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'Unique identifier for an opportunity to show an inline completion or NES',
    },
    'correlationId': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The correlation identifier for the inline completion',
    },
    'extensionId': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The identifier for the extension that contributed the inline completion',
    },
    'extensionVersion': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The version of the extension that contributed the inline completion',
    },
    'groupId': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The group ID of the extension that contributed the inline completion',
    },
    'availableProviders': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The list of available inline completion providers at the time of the request',
    },
    'skuPlan': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The the plan the user is subscribed to',
    },
    'skuType': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The sku type of the user',
    },
    'shown': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'Whether the inline completion was shown to the user',
    },
    'shownDuration': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The duration for which the inline completion was shown',
    },
    'shownDurationUncollapsed': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The duration for which the inline completion was shown without collapsing',
    },
    'timeUntilShown': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The time it took for the inline completion to be shown after the request',
    },
    'timeUntilProviderRequest': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The time it took for the inline completion to be requested from the provider',
    },
    'timeUntilProviderResponse': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The time it took for the inline completion to be shown after the request',
    },
    'reason': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The reason for the inline completion ending',
    },
    'acceptedAlternativeAction': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'Whether the user performed an alternative action when accepting the inline completion',
    },
    'selectedSuggestionInfo': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'Whether the inline completion was requested with a selected suggestion',
    },
    'partiallyAccepted': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'How often the inline completion was partially accepted by the user',
    },
    'partiallyAcceptedCountSinceOriginal': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'How often the inline completion was partially accepted since the original request',
    },
    'partiallyAcceptedRatioSinceOriginal': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The percentage of characters accepted since the original request',
    },
    'partiallyAcceptedCharactersSinceOriginal': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The character count accepted since the original request',
    },
    'preceeded': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'Whether the inline completion was preceeded by another one',
    },
    'languageId': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The language ID of the document where the inline completion was shown',
    },
    'requestReason': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The reason for the inline completion request',
    },
    'typingInterval': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The average typing interval of the user at the moment the inline completion was requested',
    },
    'typingIntervalCharacterCount': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The character count involved in the typing interval calculation',
    },
    'renameCreated': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'Whether a rename operation was created',
    },
    'renameDuration': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The duration of the rename processor',
    },
    'renameTimedOut': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'Whether the rename prepare operation timed out',
    },
    'renameDroppedOtherEdits': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The number of non-rename edits dropped due to rename processing',
    },
    'renameDroppedRenameEdits': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The number of rename edits dropped due to rename processing',
    },
    'superseded': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'Whether the inline completion was superseded by another one',
    },
    'editorType': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The type of the editor where the inline completion was shown',
    },
    'viewKind': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The kind of the view where the inline completion was shown',
    },
    'cursorColumnDistance': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The distance in columns from the cursor to the inline suggestion',
    },
    'cursorLineDistance': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The distance in lines from the cursor to the inline suggestion',
    },
    'lineCountOriginal': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The number of lines in the original text',
    },
    'lineCountModified': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The number of lines in the modified text',
    },
    'characterCountOriginal': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The number of characters in the original text',
    },
    'characterCountModified': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The number of characters in the modified text',
    },
    'disjointReplacements': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The number of inner replacements made by the inline completion',
    },
    'sameShapeReplacements': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'Whether all inner replacements are the same shape',
    },
    'longDistanceHintVisible': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'Whether a long distance hint was rendered',
    },
    'longDistanceHintDistance': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'isMeasurement': true,
      'comment': 'The distance in lines between the long distance hint and the inline edit',
    },
    'isForAnotherDocument': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'Whether the inline edit targets a different document than the one currently being edited',
    },
    'noSuggestionReason': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The reason why no inline completion was provided',
    },
    'notShownReason': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The reason why the inline completion was not shown',
    },
    'performanceMarkers': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'Performance markers for the inline completion lifecycle',
    },
    'editKind': <String, Object?>{
      'classification': 'SystemMetaData',
      'purpose': 'FeatureInsight',
      'comment': 'The kind of edit made by the inline completion',
    },
  };
}
