enum ScoringMode {
    ADVANTAGE,
    NO_AD
}

enum DecidingSetMode {
    FULL_SET,
    MATCH_TIEBREAK
}

class MatchConfig {
    var bestOfSets;
    var scoringMode;
    var decidingSetMode;
    var startingServerTeam;
    var regularTieBreakTarget;
    var decidingTieBreakTarget;
    var requireTwoPointTieBreakMargin;

    function initialize(
        selectedBestOfSets,
        selectedScoringMode,
        selectedDecidingSetMode,
        selectedStartingServerTeam,
        selectedRegularTieBreakTarget,
        selectedDecidingTieBreakTarget,
        selectedRequireTwoPointTieBreakMargin
    ) {
        bestOfSets = selectedBestOfSets;
        scoringMode = selectedScoringMode;
        decidingSetMode = selectedDecidingSetMode;
        startingServerTeam = selectedStartingServerTeam;
        regularTieBreakTarget = selectedRegularTieBreakTarget;
        decidingTieBreakTarget = selectedDecidingTieBreakTarget;
        requireTwoPointTieBreakMargin = selectedRequireTwoPointTieBreakMargin;
    }

    function setsToWin() {
        return (bestOfSets / 2).toNumber() + 1;
    }
}
