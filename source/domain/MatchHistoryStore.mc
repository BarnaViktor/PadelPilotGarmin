using Toybox.Application.Storage as Storage;
using Toybox.Lang as Lang;

module MatchHistoryStore {
    const HISTORY_KEY = "matchHistory";
    const MAX_HISTORY_SIZE = 20;
    const RECORD_VERSION = 2;
    const STATUS_COMPLETE = 0;
    const STATUS_STOPPED = 1;

    function save(engine, durationSeconds, setEndTimes) {
        return saveCompleted(engine, durationSeconds, setEndTimes);
    }

    function saveCompleted(engine, durationSeconds, setEndTimes) {
        if (engine.getMatchWinner() == null) {
            return false;
        }
        return saveRecord(engine, durationSeconds, setEndTimes,
            STATUS_COMPLETE);
    }

    function saveStopped(engine, durationSeconds, setEndTimes) {
        if (engine.getMatchWinner() != null) {
            return false;
        }
        return saveRecord(engine, durationSeconds, setEndTimes,
            STATUS_STOPPED);
    }

    function saveRecord(engine, durationSeconds, setEndTimes, status) {
        var history = load();

        var completedSets = [] as Lang.Array<Storage.ValueType>;
        for (var index = 0; index < engine.getCompletedSets().size(); index += 1) {
            var completedSet = engine.getCompletedSets()[index];
            completedSets.add([
                completedSet[0].toNumber(),
                completedSet[1].toNumber(),
                completedSet[2] ? true : false
            ] as Lang.Array<Storage.ValueType>);
        }

        var storedSetEndTimes = [] as Lang.Array<Storage.ValueType>;
        for (var timeIndex = 0; timeIndex < setEndTimes.size(); timeIndex += 1) {
            storedSetEndTimes.add(setEndTimes[timeIndex].toNumber());
        }

        var winner = engine.getMatchWinner();
        history.add([
            engine.getSets()[0].toNumber(),
            engine.getSets()[1].toNumber(),
            winner == null ? -1 : winner.toNumber(),
            durationSeconds.toNumber(),
            completedSets,
            storedSetEndTimes,
            RECORD_VERSION,
            status,
            [
                engine.getGames()[0].toNumber(),
                engine.getGames()[1].toNumber(),
                engine.getPoints()[0].toNumber(),
                engine.getPoints()[1].toNumber(),
                engine.isTieBreak(),
                engine.isDecidingMatchTieBreak()
            ] as Lang.Array<Storage.ValueType>
        ] as Lang.Array<Storage.ValueType>);

        if (history.size() > MAX_HISTORY_SIZE) {
            history = history.slice(history.size() - MAX_HISTORY_SIZE, history.size());
        }

        Storage.setValue(HISTORY_KEY, history);
        return true;
    }

    function load() {
        var history = [] as Lang.Array<Storage.ValueType>;
        var storedHistory = Storage.getValue(HISTORY_KEY);
        if (!(storedHistory instanceof Lang.Array)) {
            if (storedHistory != null) {
                Storage.deleteValue(HISTORY_KEY);
            }
            return history;
        }

        for (var index = 0; index < storedHistory.size(); index += 1) {
            if (isValidRecord(storedHistory[index])) {
                history.add(storedHistory[index]);
            }
        }

        if (history.size() != storedHistory.size()) {
            Storage.setValue(HISTORY_KEY, history);
        }
        return history;
    }

    function deleteAt(storageIndex) {
        var history = load();
        if (!(storageIndex instanceof Lang.Number)
                || storageIndex < 0 || storageIndex >= history.size()) {
            return false;
        }

        var remaining = [] as Lang.Array<Storage.ValueType>;
        for (var index = 0; index < history.size(); index += 1) {
            if (index != storageIndex) {
                remaining.add(history[index]);
            }
        }

        if (remaining.size() == 0) {
            Storage.deleteValue(HISTORY_KEY);
        } else {
            Storage.setValue(HISTORY_KEY, remaining);
        }
        return true;
    }

    function isStopped(record) {
        return record instanceof Lang.Array && record.size() == 9
            && record[6] == RECORD_VERSION && record[7] == STATUS_STOPPED;
    }

    function getCurrentState(record) {
        if (record instanceof Lang.Array && record.size() == 9
                && record[6] == RECORD_VERSION) {
            return record[8];
        }
        return [0, 0, 0, 0, false, false];
    }

    function isValidRecord(record) {
        if (!(record instanceof Lang.Array)
                || (record.size() != 5 && record.size() != 6
                    && record.size() != 9)) {
            return false;
        }
        for (var index = 0; index < 4; index += 1) {
            if (!(record[index] instanceof Lang.Number)) {
                return false;
            }
        }
        if (record[0] < 0 || record[1] < 0 || record[3] < 0
                || !(record[4] instanceof Lang.Array)) {
            return false;
        }

        if (record.size() == 9) {
            if (!(record[6] instanceof Lang.Number)
                    || record[6] != RECORD_VERSION
                    || !(record[7] instanceof Lang.Number)
                    || (record[7] != STATUS_COMPLETE
                        && record[7] != STATUS_STOPPED)
                    || (record[7] == STATUS_COMPLETE
                        && (record[2] < 0 || record[2] > 1))
                    || (record[7] == STATUS_STOPPED && record[2] != -1)
                    || !isValidCurrentState(record[8])) {
                return false;
            }
        } else if (record[2] < 0 || record[2] > 1) {
            return false;
        }

        for (var setIndex = 0; setIndex < record[4].size(); setIndex += 1) {
            var completedSet = record[4][setIndex];
            if (!(completedSet instanceof Lang.Array) || completedSet.size() != 3
                    || !(completedSet[0] instanceof Lang.Number)
                    || !(completedSet[1] instanceof Lang.Number)
                    || !(completedSet[2] instanceof Lang.Boolean)
                    || completedSet[0] < 0 || completedSet[1] < 0) {
                return false;
            }
        }
        if (record.size() == 6 || record.size() == 9) {
            if (!(record[5] instanceof Lang.Array)
                    || record[5].size() != record[4].size()) {
                return false;
            }
            var previousEnd = 0;
            for (var timeIndex = 0; timeIndex < record[5].size(); timeIndex += 1) {
                if (!(record[5][timeIndex] instanceof Lang.Number)
                        || record[5][timeIndex] < previousEnd
                        || record[5][timeIndex] > record[3]) {
                    return false;
                }
                previousEnd = record[5][timeIndex];
            }
        }
        return true;
    }

    function isValidCurrentState(state) {
        if (!(state instanceof Lang.Array) || state.size() != 6) {
            return false;
        }
        for (var index = 0; index < 4; index += 1) {
            if (!(state[index] instanceof Lang.Number) || state[index] < 0) {
                return false;
            }
        }
        return state[4] instanceof Lang.Boolean
            && state[5] instanceof Lang.Boolean
            && (!state[5] || state[4]);
    }
}
