class MatchSetupState {
    var bestOfSets;
    var scoringMode;
    var startingServerTeam;
    var decidingSetMode;
    var regularTieBreakTarget;
    var decidingTieBreakTarget;
    var requireTwoPointTieBreakMargin;
    var selectedField;
    var editing;
    var _originalValue;

    function initialize() {
        bestOfSets = 3;
        scoringMode = ScoringMode.ADVANTAGE;
        startingServerTeam = 0;
        decidingSetMode = DecidingSetMode.MATCH_TIEBREAK;
        regularTieBreakTarget = 7;
        decidingTieBreakTarget = 10;
        requireTwoPointTieBreakMargin = true;
        selectedField = 0;
        editing = false;
        _originalValue = null;
    }

    function fieldCount() {
        return 7;
    }

    function itemCount() {
        return fieldCount() + 1;
    }

    function moveSelection(delta) {
        selectedField = (selectedField + delta + itemCount()) % itemCount();
    }

    function isStartGameSelected() {
        return selectedField == fieldCount();
    }

    function isHistorySelected() {
        return false;
    }

    function beginEditing() {
        if (isStartGameSelected() || isHistorySelected()) {
            return false;
        }

        _originalValue = valueFor(selectedField);
        editing = true;
        return true;
    }

    function saveEditing() {
        editing = false;
        _originalValue = null;
    }

    function cancelEditing() {
        if (!editing) {
            return;
        }

        setValueFor(selectedField, _originalValue);
        editing = false;
        _originalValue = null;
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
            return "Best of " + bestOfSets;
        } else if (index == 1) {
            return "Scoring: " + (scoringMode == ScoringMode.ADVANTAGE ? "Adv" : "No-ad");
        } else if (index == 2) {
            return "First serve: " + (startingServerTeam == 0 ? "Me" : "Opponent");
        } else if (index == 3) {
            return "Decider: " + (decidingSetMode == DecidingSetMode.FULL_SET ? "Full" : "MTB");
        } else if (index == 4) {
            return "Tie-break to " + regularTieBreakTarget;
        } else if (index == 5) {
            return "Match TB to " + decidingTieBreakTarget;
        }

        if (index == 6) {
            return "Win by 2: " + (requireTwoPointTieBreakMargin ? "On" : "Off");
        }

        return "START GAME";
    }

    function titleFor(index) {
        var titles = [
            "MATCH LENGTH",
            "SCORING",
            "FIRST SERVE",
            "DECIDING SET",
            "TIE-BREAK TARGET",
            "MATCH TB TARGET",
            "TIE-BREAK MARGIN"
        ];
        return titles[index];
    }

    function valueLabelFor(index) {
        if (index == 0) {
            return "Best of " + bestOfSets;
        } else if (index == 1) {
            return scoringMode == ScoringMode.ADVANTAGE ? "Advantage" : "No-ad";
        } else if (index == 2) {
            return startingServerTeam == 0 ? "My team" : "Opponent";
        } else if (index == 3) {
            return decidingSetMode == DecidingSetMode.FULL_SET ? "Full set" : "Match tie-break";
        } else if (index == 4) {
            return regularTieBreakTarget.toString();
        } else if (index == 5) {
            return decidingTieBreakTarget.toString();
        }

        return requireTwoPointTieBreakMargin ? "On" : "Off";
    }

    function valueFor(index) {
        if (index == 0) {
            return bestOfSets;
        } else if (index == 1) {
            return scoringMode;
        } else if (index == 2) {
            return startingServerTeam;
        } else if (index == 3) {
            return decidingSetMode;
        } else if (index == 4) {
            return regularTieBreakTarget;
        } else if (index == 5) {
            return decidingTieBreakTarget;
        }

        return requireTwoPointTieBreakMargin;
    }

    function setValueFor(index, value) {
        if (index == 0) {
            bestOfSets = value;
        } else if (index == 1) {
            scoringMode = value;
        } else if (index == 2) {
            startingServerTeam = value;
        } else if (index == 3) {
            decidingSetMode = value;
        } else if (index == 4) {
            regularTieBreakTarget = value;
        } else if (index == 5) {
            decidingTieBreakTarget = value;
        } else if (index == 6) {
            requireTwoPointTieBreakMargin = value;
        }
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
