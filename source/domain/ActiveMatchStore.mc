using Toybox.Application.Storage as Storage;
using Toybox.Lang as Lang;

module ActiveMatchStore {
    const ACTIVE_KEY = "activeMatch";
    const SCHEMA_VERSION = 3;
    const POINT_SCHEMA_VERSION = 4;
    const FINALIZING_POINT_SCHEMA_VERSION = 5;

    function save(engine, elapsedSeconds, setEndTimes) {
        var config = engine.getConfig();
        Storage.setValue(ACTIVE_KEY, [
            SCHEMA_VERSION,
            elapsedSeconds.toNumber(),
            [
                config.bestOfSets,
                config.scoringMode,
                config.decidingSetMode,
                config.startingServerTeam,
                config.regularTieBreakTarget,
                config.decidingTieBreakTarget,
                config.requireTwoPointTieBreakMargin
            ],
            engine.exportState(),
            setEndTimes
        ]);
    }

    // Point matches use milliseconds and direct points, never classic sets.
    function savePointMatch(engine, elapsedMs) {
        Storage.setValue(ACTIVE_KEY, [
            POINT_SCHEMA_VERSION,
            elapsedMs.toNumber(),
            [engine.getMode(), engine.getEndRule(), engine.getTarget(),
                engine.getStartingServerTeam()],
            engine.exportState()
        ]);
    }

    function loadPointMatch(stored) {
        var finalizing = stored[0] == FINALIZING_POINT_SCHEMA_VERSION;
        if ((!finalizing && stored.size() != 4)
                || (finalizing && (stored.size() != 5
                    || !(stored[4] instanceof Lang.Boolean) || !stored[4]))
                || !(stored[1] instanceof Lang.Number)
                || stored[1] < 0 || !(stored[2] instanceof Lang.Array)
                || stored[2].size() != 4) {
            clear();
            return null;
        }
        var values = stored[2];
        // The constructor checks all four settings, including their types.
        var engine = new PointMatchEngine(values[0], values[1], values[2], values[3]);
        if (!engine.restoreState(stored[3])) {
            clear();
            return null;
        }
        var loaded = [engine, stored[1], []];
        if (finalizing) { loaded.add(true); }
        return loaded;
    }

    // FIT is already saved: restart must retry only the local history write.
    function saveFinalizingPointMatch(engine, elapsedMs) {
        Storage.setValue(ACTIVE_KEY, [FINALIZING_POINT_SCHEMA_VERSION,
            elapsedMs.toNumber(), [engine.getMode(), engine.getEndRule(),
                engine.getTarget(), engine.getStartingServerTeam()],
            engine.exportState(), true]);
    }

    function load() {
        var stored = Storage.getValue(ACTIVE_KEY);
        if (stored == null) {
            return null;
        }

        try {
            if (!(stored instanceof Lang.Array)
                    || stored.size() == 0 || !(stored[0] instanceof Lang.Number)) {
                clear();
                return null;
            }
            if (stored[0] == POINT_SCHEMA_VERSION || stored[0] == FINALIZING_POINT_SCHEMA_VERSION) {
                return loadPointMatch(stored);
            }
            if ((stored[0] == 1 && stored.size() != 4)
                    || ((stored[0] == 2 || stored[0] == SCHEMA_VERSION)
                        && stored.size() != 5)
                    || (stored[0] != 1 && stored[0] != 2
                        && stored[0] != SCHEMA_VERSION)
                    || !(stored[1] instanceof Lang.Number) || stored[1] < 0
                    || !isValidConfig(stored[2])) {
                clear();
                return null;
            }

            var values = stored[2];
            var config = new MatchConfig(
                values[0], values[1], values[2], values[3],
                values[4], values[5], values[6]
            );
            var engine = new ScoringEngine(config);
            if (!engine.restoreState(stored[3])) {
                clear();
                return null;
            }
            var setEndTimes = [];
            if (stored[0] == 2 || stored[0] == SCHEMA_VERSION) {
                if (!isValidSetEndTimes(stored[4], stored[1],
                        engine.getCompletedSets().size())) {
                    clear();
                    return null;
                }
                setEndTimes = stored[4].slice(0, stored[4].size());
            }
            return [engine, stored[1], setEndTimes];
        } catch (error) {
            clear();
            return null;
        }
    }

    function clear() {
        Storage.deleteValue(ACTIVE_KEY);
    }

    function isValidConfig(value) {
        if (!(value instanceof Lang.Array) || value.size() != 7) {
            return false;
        }
        for (var index = 0; index < 6; index += 1) {
            if (!(value[index] instanceof Lang.Number)) {
                return false;
            }
        }
        return value[6] instanceof Lang.Boolean
            && (value[0] == 1 || value[0] == 3 || value[0] == 5)
            && (value[1] == ScoringMode.ADVANTAGE || value[1] == ScoringMode.NO_AD)
            && (value[2] == DecidingSetMode.FULL_SET || value[2] == DecidingSetMode.MATCH_TIEBREAK)
            && (value[3] == 0 || value[3] == 1)
            && value[4] >= 5 && value[4] <= 21
            && value[5] >= 7 && value[5] <= 21;
    }

    function isValidSetEndTimes(value, elapsedSeconds, completedSetCount) {
        if (!(value instanceof Lang.Array)
                || value.size() != completedSetCount) {
            return false;
        }
        var previous = 0;
        for (var index = 0; index < value.size(); index += 1) {
            if (!(value[index] instanceof Lang.Number)
                    || value[index] < previous
                    || value[index] > elapsedSeconds) {
                return false;
            }
            previous = value[index];
        }
        return true;
    }
}

module ActiveMatchSession {
    var _engine = null;
    var _view = null;

    function attach(engine, view) {
        _engine = engine;
        _view = view;
        persist();
    }

    function persist() {
        if (_engine != null && _view != null) {
            if (_engine instanceof PointMatchEngine) {
                if (_view._activitySaved) {
                    ActiveMatchStore.saveFinalizingPointMatch(_engine, _view.getElapsedMilliseconds());
                } else {
                    ActiveMatchStore.savePointMatch(_engine, _view.getElapsedMilliseconds());
                }
            } else {
                ActiveMatchStore.save(_engine, _view.getDurationSeconds(),
                    _view.getSetEndTimes());
            }
        }
    }

    function persistIfAttached(view) {
        if (_view == view) {
            persist();
        }
    }

    function clear() {
        _engine = null;
        _view = null;
        ActiveMatchStore.clear();
    }
}
