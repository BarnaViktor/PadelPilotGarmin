using Toybox.Lang as Lang;

module PointMatchMode {
    enum { AMERICANO, MEXICANO }
}

module PointMatchEndRule {
    enum { TOTAL_POINTS, TEAM_TARGET }
}

// Results are relative to MY TEAM (team 0). A draw is a completed match.
module PointMatchResult {
    enum { ACTIVE, WIN, LOSS, DRAW }
}

// One independent match. UI, timekeeping, storage and FIT belong to callers.
class PointMatchEngine {
    const MAX_UNDO_HISTORY = 20;

    private var _mode;
    private var _endRule;
    private var _target;
    private var _startingServerTeam;
    private var _points as Lang.Array<Lang.Number>;
    private var _history as Lang.Array<Lang.Number>;

    function initialize(mode, endRule, target, startingServerTeam) {
        if (!(mode instanceof Lang.Number)
                || (mode != PointMatchMode.AMERICANO && mode != PointMatchMode.MEXICANO)
                || !(endRule instanceof Lang.Number)
                || (endRule != PointMatchEndRule.TOTAL_POINTS && endRule != PointMatchEndRule.TEAM_TARGET)
                || !(target instanceof Lang.Number) || target <= 0
                || !isTeam(startingServerTeam)) {
            throw new Lang.InvalidValueException("Invalid point match settings");
        }

        _mode = mode;
        _endRule = endRule;
        _target = target;
        _startingServerTeam = startingServerTeam;
        _points = [0, 0];
        _history = [];
    }

    function awardPoint(team) {
        if (!isTeam(team) || isComplete()) {
            return false;
        }

        // Only the scoring team is needed to reverse a direct point.
        _history.add(team);
        if (_history.size() > MAX_UNDO_HISTORY) {
            _history = _history.slice(1, null);
        }
        _points[team] += 1;
        return true;
    }

    function undoLastPoint() {
        if (_history.size() == 0) {
            return false;
        }
        var lastIndex = _history.size() - 1;
        var team = _history[lastIndex];
        _history = _history.slice(0, lastIndex);
        _points[team] -= 1;
        return true;
    }

    function isComplete() {
        if (_endRule == PointMatchEndRule.TOTAL_POINTS) {
            // Subtraction also works at the maximum signed Number target.
            return _points[0] == _target - _points[1];
        }
        return _points[0] == _target || _points[1] == _target;
    }

    function getResult() {
        if (!isComplete()) {
            return PointMatchResult.ACTIVE;
        }
        if (_points[0] == _points[1]) {
            return PointMatchResult.DRAW;
        }
        return _points[0] > _points[1] ? PointMatchResult.WIN : PointMatchResult.LOSS;
    }

    function getPoints() {
        return _points.slice(0, 2);
    }

    function getMode() { return _mode; }
    function getEndRule() { return _endRule; }
    function getTarget() { return _target; }
    function getStartingServerTeam() { return _startingServerTeam; }

    function exportState() {
        return getPoints();
    }

    // Undo is session-local, just as it is for restored classic matches.
    // Validate before mutating; impossible scores never enter the engine.
    function restoreState(state) {
        if (!(state instanceof Lang.Array) || state.size() != 2
                || !(state[0] instanceof Lang.Number)
                || !(state[1] instanceof Lang.Number)
                || state[0] < 0 || state[1] < 0
                || state[0] > _target || state[1] > _target) {
            return false;
        }
        if (_endRule == PointMatchEndRule.TOTAL_POINTS) {
            if (state[0] > _target - state[1]) {
                return false;
            }
        } else if (state[0] == _target && state[1] == _target) {
            return false;
        }
        _points = state.slice(0, 2) as Lang.Array<Lang.Number>;
        _history = [];
        return true;
    }

    private function isTeam(value) {
        return value instanceof Lang.Number && (value == 0 || value == 1);
    }
}
