module MatchMode {
    enum { CLASSIC, AMERICANO, MEXICANO }
}

module MatchSetupField {
    const MODE = 0;
    const SETS = 1;
    const SCORING = 2;
    const FIRST_SERVE = 3;
    const DECIDER = 4;
    const TIE_BREAK = 5;
    const MATCH_TB = 6;
    const MARGIN = 7;
    const END_RULE = 8;
    const POINT_TARGET = 9;
    const MAX_POINT_TARGET = 999;
}

class MatchSetupState {
    var matchMode;
    var pointEndRule;
    var pointTarget;
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
    var _originalField;

    function initialize() {
        matchMode = MatchMode.CLASSIC;
        pointEndRule = PointMatchEndRule.TOTAL_POINTS;
        pointTarget = 24;
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
        _originalField = null;
    }

    function fieldCount() {
        return isPointMatch() ? 4 : 8;
    }

    function isPointMatch() {
        return matchMode != MatchMode.CLASSIC;
    }

    function fieldFor(index) {
        if (isPointMatch()) {
            var fields = [MatchSetupField.MODE, MatchSetupField.END_RULE,
                MatchSetupField.POINT_TARGET, MatchSetupField.FIRST_SERVE];
            return fields[index];
        }
        return index;
    }

    function itemCount() {
        return fieldCount() + 1;
    }

    function moveSelection(delta) {
        if (editing) { return; }
        selectedField = (selectedField + delta + itemCount()) % itemCount();
    }

    function isStartGameSelected() {
        return selectedField == fieldCount();
    }

    function isHistorySelected() {
        return false;
    }

    function beginEditing() {
        if (editing || isStartGameSelected() || isHistorySelected()) {
            return false;
        }

        _originalField = fieldFor(selectedField);
        _originalValue = valueFor(selectedField);
        editing = true;
        return true;
    }

    function saveEditing() {
        editing = false;
        _originalValue = null;
        _originalField = null;
    }

    function cancelEditing() {
        if (!editing) {
            return;
        }

        setFieldValue(_originalField, _originalValue);
        editing = false;
        _originalValue = null;
        _originalField = null;
    }

    function changeSelected(delta) {
        if (!editing) { return; }
        var field = fieldFor(selectedField);
        if (field == MatchSetupField.MODE) {
            matchMode = cycleValue([MatchMode.CLASSIC, MatchMode.AMERICANO,
                MatchMode.MEXICANO], matchMode, delta);
        } else if (field == MatchSetupField.END_RULE) {
            pointEndRule = pointEndRule == PointMatchEndRule.TOTAL_POINTS
                ? PointMatchEndRule.TEAM_TARGET : PointMatchEndRule.TOTAL_POINTS;
        } else if (field == MatchSetupField.POINT_TARGET) {
            pointTarget = clamp(pointTarget + delta, 1, MatchSetupField.MAX_POINT_TARGET);
        } else if (field == MatchSetupField.SETS) {
            bestOfSets = cycleValue([1, 3, 5], bestOfSets, delta);
        } else if (field == MatchSetupField.SCORING) {
            scoringMode = scoringMode == ScoringMode.ADVANTAGE
                ? ScoringMode.NO_AD : ScoringMode.ADVANTAGE;
        } else if (field == MatchSetupField.FIRST_SERVE) {
            startingServerTeam = 1 - startingServerTeam;
        } else if (field == MatchSetupField.DECIDER) {
            decidingSetMode = decidingSetMode == DecidingSetMode.FULL_SET
                ? DecidingSetMode.MATCH_TIEBREAK : DecidingSetMode.FULL_SET;
        } else if (field == MatchSetupField.TIE_BREAK) {
            regularTieBreakTarget = clamp(regularTieBreakTarget + delta, 5, 21);
        } else if (field == MatchSetupField.MATCH_TB) {
            decidingTieBreakTarget = clamp(decidingTieBreakTarget + delta, 7, 21);
        } else if (field == MatchSetupField.MARGIN) {
            requireTwoPointTieBreakMargin = !requireTwoPointTieBreakMargin;
        }
    }

    // Each start captures accepted settings in a fresh, independent engine.
    function createEngine() {
        if (!isPointMatch()) {
            return new ScoringEngine(toConfig());
        }
        return new PointMatchEngine(
            matchMode == MatchMode.AMERICANO
                ? PointMatchMode.AMERICANO : PointMatchMode.MEXICANO,
            pointEndRule, pointTarget, startingServerTeam);
    }

    function modeLabel() {
        if (matchMode == MatchMode.AMERICANO) { return "AMERICANO"; }
        if (matchMode == MatchMode.MEXICANO) { return "MEXICANO"; }
        return "CLASSIC";
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
        if (index == fieldCount()) { return "START GAME"; }
        return titleFor(index) + ": " + valueLabelFor(index);
    }

    function titleFor(index) {
        var titles = ["MATCH MODE", "MATCH LENGTH", "SCORING", "FIRST SERVE",
            "DECIDING SET", "TIE-BREAK TARGET", "MATCH TB TARGET",
            "TIE-BREAK MARGIN", "END RULE", "POINT TARGET"];
        return titles[fieldFor(index)];
    }

    function valueLabelFor(index) {
        var field = fieldFor(index);
        if (field == MatchSetupField.MODE) { return modeLabel(); }
        if (field == MatchSetupField.END_RULE) {
            return pointEndRule == PointMatchEndRule.TOTAL_POINTS
                ? "A + B = X" : "A = X OR B = X";
        }
        if (field == MatchSetupField.POINT_TARGET) { return pointTarget.toString(); }
        if (field == MatchSetupField.SETS) { return "Best of " + bestOfSets; }
        if (field == MatchSetupField.SCORING) {
            return scoringMode == ScoringMode.ADVANTAGE ? "Advantage" : "No-ad";
        }
        if (field == MatchSetupField.FIRST_SERVE) {
            return startingServerTeam == 0 ? "My team" : "Opponent";
        }
        if (field == MatchSetupField.DECIDER) {
            return decidingSetMode == DecidingSetMode.FULL_SET
                ? "Full set" : "Match tie-break";
        }
        if (field == MatchSetupField.TIE_BREAK) { return regularTieBreakTarget.toString(); }
        if (field == MatchSetupField.MATCH_TB) { return decidingTieBreakTarget.toString(); }
        return requireTwoPointTieBreakMargin ? "On" : "Off";
    }

    function valueFor(index) {
        var field = fieldFor(index);
        if (field == MatchSetupField.MODE) { return matchMode; }
        if (field == MatchSetupField.END_RULE) { return pointEndRule; }
        if (field == MatchSetupField.POINT_TARGET) { return pointTarget; }
        if (field == MatchSetupField.SETS) { return bestOfSets; }
        if (field == MatchSetupField.SCORING) { return scoringMode; }
        if (field == MatchSetupField.FIRST_SERVE) { return startingServerTeam; }
        if (field == MatchSetupField.DECIDER) { return decidingSetMode; }
        if (field == MatchSetupField.TIE_BREAK) { return regularTieBreakTarget; }
        if (field == MatchSetupField.MATCH_TB) { return decidingTieBreakTarget; }
        return requireTwoPointTieBreakMargin;
    }

    function setValueFor(index, value) {
        setFieldValue(fieldFor(index), value);
    }

    function setFieldValue(field, value) {
        if (field == MatchSetupField.MODE) { matchMode = value; }
        else if (field == MatchSetupField.END_RULE) { pointEndRule = value; }
        else if (field == MatchSetupField.POINT_TARGET) { pointTarget = value; }
        else if (field == MatchSetupField.SETS) { bestOfSets = value; }
        else if (field == MatchSetupField.SCORING) { scoringMode = value; }
        else if (field == MatchSetupField.FIRST_SERVE) { startingServerTeam = value; }
        else if (field == MatchSetupField.DECIDER) { decidingSetMode = value; }
        else if (field == MatchSetupField.TIE_BREAK) { regularTieBreakTarget = value; }
        else if (field == MatchSetupField.MATCH_TB) { decidingTieBreakTarget = value; }
        else if (field == MatchSetupField.MARGIN) { requireTwoPointTieBreakMargin = value; }
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
