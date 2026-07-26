class MatchSetupState {
    var bestOfSets;
    var scoringMode;
    var startingServerTeam;
    var decidingSetMode;
    var regularTieBreakTarget;
    var decidingTieBreakTarget;
    var requireTwoPointTieBreakMargin;
    var selectedField;

    function initialize() {
        bestOfSets = 3;
        scoringMode = ScoringMode.ADVANTAGE;
        startingServerTeam = 0;
        decidingSetMode = DecidingSetMode.MATCH_TIEBREAK;
        regularTieBreakTarget = 7;
        decidingTieBreakTarget = 10;
        requireTwoPointTieBreakMargin = true;
        selectedField = 0;
    }

    function fieldCount() {
        return 7;
    }

    function moveSelection(delta) {
        selectedField = (selectedField + delta + fieldCount()) % fieldCount();
    }

    function changeSelected(delta) {
        if (selectedField == 0) {
            var values = [1, 3, 5];
            bestOfSets = cycleValue(values, bestOfSets, delta);
        } else if (selectedField == 1) {
            scoringMode = scoringMode == ScoringMode.ADVANTAGE
                ? ScoringMode.NO_AD
                : ScoringMode.ADVANTAGE;
        } else if (selectedField == 2) {
            startingServerTeam = 1 - startingServerTeam;
        } else if (selectedField == 3) {
            decidingSetMode = decidingSetMode == DecidingSetMode.FULL_SET
                ? DecidingSetMode.MATCH_TIEBREAK
                : DecidingSetMode.FULL_SET;
        } else if (selectedField == 4) {
            regularTieBreakTarget = clamp(regularTieBreakTarget + delta, 5, 21);
        } else if (selectedField == 5) {
            decidingTieBreakTarget = clamp(decidingTieBreakTarget + delta, 7, 21);
        } else if (selectedField == 6) {
            requireTwoPointTieBreakMargin = !requireTwoPointTieBreakMargin;
        }
    }

    function toConfig() {
        return new MatchConfig(
            bestOfSets,
            scoringMode,
            decidingSetMode,
            startingServerTeam,
            regularTieBreakTarget,
            decidingTieBreakTarget,
            requireTwoPointTieBreakMargin
        );
    }

    function labelFor(index) {
        if (index == 0) {
            return "Sets: best of " + bestOfSets;
        } else if (index == 1) {
            return "Scoring: " + (scoringMode == ScoringMode.ADVANTAGE ? "Adv" : "No-ad");
        } else if (index == 2) {
            return "First serve: Team " + (startingServerTeam + 1);
        } else if (index == 3) {
            return "Decider: " + (decidingSetMode == DecidingSetMode.FULL_SET ? "Full" : "MTB");
        } else if (index == 4) {
            return "TB target: " + regularTieBreakTarget;
        } else if (index == 5) {
            return "MTB target: " + decidingTieBreakTarget;
        }

        return "Win by 2: " + (requireTwoPointTieBreakMargin ? "On" : "Off");
    }

    function cycleValue(values, current, delta) {
        var index = 0;
        for (var i = 0; i < values.size(); i += 1) {
            if (values[i] == current) {
                index = i;
            }
        }

        return values[(index + delta + values.size()) % values.size()];
    }

    function clamp(value, minValue, maxValue) {
        if (value < minValue) {
            return minValue;
        }
        if (value > maxValue) {
            return maxValue;
        }
        return value;
    }
}
