// 1:1 translation of
// vscode/src/vs/editor/contrib/inlineCompletions/browser/view/inlineEdits/utils/flexBoxLayout.ts

/// 1:1: `export interface IFlexBoxPartExtensionRule`
class IFlexBoxPartExtensionRule {
  final num? max;
  final num? priority;
  final num? share;

  const IFlexBoxPartExtensionRule({this.max, this.priority, this.share});
}

/// 1:1: `export interface IFlexBoxPartGrowthRule extends IFlexBoxPartExtensionRule`
class IFlexBoxPartGrowthRule extends IFlexBoxPartExtensionRule {
  final num? min;
  final List<IFlexBoxPartExtensionRule>? rules;

  const IFlexBoxPartGrowthRule({
    this.min,
    this.rules,
    super.max,
    super.priority,
    super.share,
  });
}

/// Source uses `Record<string, IFlexBoxPartGrowthRule | IFlexBoxPartGrowthRule[]>`.
/// In Dart a part is either a single [IFlexBoxPartGrowthRule] or a
/// `List<IFlexBoxPartExtensionRule>` (the source's array form).
typedef FlexBoxPart = Object;

/// Normalized part: `{ min: number; rules: IFlexBoxPartExtensionRule[] }`.
class _NormalizedPart {
  final num min;
  final List<IFlexBoxPartExtensionRule> rules;

  _NormalizedPart(this.min, this.rules);
}

class _CandidateRule {
  final String partKey;
  final int ruleIndex;
  final IFlexBoxPartExtensionRule rule;
  final num priority;
  final num share;

  _CandidateRule({
    required this.partKey,
    required this.ruleIndex,
    required this.rule,
    required this.priority,
    required this.share,
  });
}

class _Distribution {
  final String partKey;
  final int ruleIndex;
  final num amount;

  _Distribution({
    required this.partKey,
    required this.ruleIndex,
    required this.amount,
  });
}

/// Distributes a total size into parts that each have a list of growth rules.
/// Returns `null` if the layout is not possible.
///
/// First, each part gets its minimum size. Then, remaining space is distributed
/// to the rules with the highest priority, as long as the max constraint allows
/// it (considering share). This continues with next lower priority rules until
/// no space is left.
///
/// 1:1: `distributeFlexBoxLayout<T>(totalSize, parts): Record<keyof T, number> | null`
Map<String, num>? distributeFlexBoxLayout(
  num totalSize,
  Map<String, FlexBoxPart> parts,
) {
  // Normalize parts to always have array of rules
  final Map<String, _NormalizedPart> normalizedParts =
      <String, _NormalizedPart>{};
  for (final MapEntry<String, FlexBoxPart> entry in parts.entries) {
    final String key = entry.key;
    final FlexBoxPart part = entry.value;
    if (part is List) {
      normalizedParts[key] = _NormalizedPart(
        0,
        part.cast<IFlexBoxPartExtensionRule>(),
      );
    } else {
      final IFlexBoxPartGrowthRule gp = part as IFlexBoxPartGrowthRule;
      normalizedParts[key] = _NormalizedPart(
        gp.min ?? 0,
        gp.rules ?? <IFlexBoxPartExtensionRule>[
          IFlexBoxPartExtensionRule(
            max: gp.max,
            priority: gp.priority,
            share: gp.share,
          ),
        ],
      );
    }
  }

  // Initialize result with minimum sizes
  final Map<String, num> result = <String, num>{};
  num usedSize = 0;
  for (final MapEntry<String, _NormalizedPart> entry
      in normalizedParts.entries) {
    result[entry.key] = entry.value.min;
    usedSize += entry.value.min;
  }

  // Check if we can satisfy minimum constraints
  if (usedSize > totalSize) {
    return null;
  }

  num remainingSize = totalSize - usedSize;

  // Distribute remaining space by priority levels
  while (remainingSize > 0) {
    // Find all rules at current highest priority that can still grow
    final List<_CandidateRule> candidateRules = <_CandidateRule>[];

    for (final MapEntry<String, _NormalizedPart> entry
        in normalizedParts.entries) {
      final String key = entry.key;
      final _NormalizedPart part = entry.value;
      for (int i = 0; i < part.rules.length; i++) {
        final IFlexBoxPartExtensionRule rule = part.rules[i];
        final num currentUsage = result[key]!;
        final num maxSize = rule.max ?? double.infinity;

        if (currentUsage < maxSize) {
          candidateRules.add(_CandidateRule(
            partKey: key,
            ruleIndex: i,
            rule: rule,
            priority: rule.priority ?? 0,
            share: rule.share ?? 1,
          ));
        }
      }
    }

    if (candidateRules.isEmpty) {
      // No rules can grow anymore, but we have remaining space
      break;
    }

    // Find the highest priority among candidates
    num maxPriority = candidateRules.first.priority;
    for (final _CandidateRule c in candidateRules) {
      if (c.priority > maxPriority) {
        maxPriority = c.priority;
      }
    }
    final List<_CandidateRule> highestPriorityCandidates = candidateRules
        .where((_CandidateRule c) => c.priority == maxPriority)
        .toList();

    // Calculate total share
    num totalShare = 0;
    for (final _CandidateRule c in highestPriorityCandidates) {
      totalShare += c.share;
    }

    // Distribute space proportionally by share
    num distributedThisRound = 0;
    final List<_Distribution> distributions = <_Distribution>[];

    for (final _CandidateRule candidate in highestPriorityCandidates) {
      final IFlexBoxPartExtensionRule rule = candidate.rule;
      final num currentUsage = result[candidate.partKey]!;
      final num maxSize = rule.max ?? double.infinity;
      final num availableForThisRule = maxSize - currentUsage;

      // Calculate ideal share
      final num idealShare = (remainingSize * candidate.share) / totalShare;
      final num actualAmount =
          idealShare < availableForThisRule ? idealShare : availableForThisRule;

      distributions.add(_Distribution(
        partKey: candidate.partKey,
        ruleIndex: candidate.ruleIndex,
        amount: actualAmount,
      ));

      distributedThisRound += actualAmount;
    }

    if (distributedThisRound == 0) {
      // No progress can be made
      break;
    }

    // Apply distributions
    for (final _Distribution dist in distributions) {
      result[dist.partKey] = result[dist.partKey]! + dist.amount;
    }

    remainingSize -= distributedThisRound;

    // Break if remaining is negligible (floating point precision)
    if (remainingSize < 0.0001) {
      break;
    }
  }

  return result;
}
