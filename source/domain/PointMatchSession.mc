using Toybox.Lang as Lang;

// Live input and active time for one point match. Callers supply monotonic
// milliseconds so pause/finish/undo timing is testable without a UI timer.
class PointMatchSession {
    var _engine as PointMatchEngine;
    private var _paused;
    private var _elapsedMs;
    private var _runningSince;
    private var _pointInputGuard;

    function initialize(engine, now) {
        _engine = engine;
        _paused = false;
        _elapsedMs = 0;
        _runningSince = engine.isComplete() ? null : now;
        _pointInputGuard = new PointInputGuard(500);
    }

    function awardPoint(team, now) {
        if (_paused || _engine.isComplete() || !(team instanceof Lang.Number)
                || (team != 0 && team != 1) || !_pointInputGuard.accept(now)) {
            return false;
        }
        if (!_engine.awardPoint(team)) {
            return false;
        }
        if (_engine.isComplete()) {
            stopTime(now);
        }
        return true;
    }

    function undoLastPoint(now) {
        if (_paused || !_engine.undoLastPoint()) {
            return false;
        }
        _pointInputGuard.reset();
        // Time spent viewing the result is excluded when reopening a match.
        if (_runningSince == null) {
            _runningSince = now;
        }
        return true;
    }

    function setPaused(paused, now) {
        if (_engine.isComplete() || paused == _paused) {
            return;
        }
        if (paused) {
            stopTime(now);
        } else {
            _runningSince = now;
        }
        _paused = paused;
    }

    function isPaused() { return _paused; }
    function getEngine() { return _engine; }

    function getDurationSeconds(now) {
        return (getElapsedMilliseconds(now) / 1000).toNumber();
    }

    function getElapsedMilliseconds(now) {
        var elapsed = _elapsedMs;
        if (_runningSince != null && now >= _runningSince) {
            elapsed += now - _runningSince;
        }
        return elapsed;
    }

    function restoreElapsedMilliseconds(elapsedMs) {
        if (!(elapsedMs instanceof Lang.Number) || elapsedMs < 0) {
            return false;
        }
        _elapsedMs = elapsedMs;
        _runningSince = null;
        _paused = !_engine.isComplete();
        _pointInputGuard.reset();
        return true;
    }

    private function stopTime(now) {
        if (_runningSince != null && now >= _runningSince) {
            _elapsedMs += now - _runningSince;
        }
        _runningSince = null;
    }
}
