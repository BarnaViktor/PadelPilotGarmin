using Toybox.Application.Storage as Storage;
using Toybox.Lang as Lang;

module MatchHistoryStore {
    const HISTORY_KEY = "matchHistory";
    const MAX_HISTORY_SIZE = 20;

    function save(engine, durationSeconds, setEndTimes) {
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

        history.add([
            engine.getSets()[0].toNumber(),
            engine.getSets()[1].toNumber(),
            engine.getMatchWinner().toNumber(),
            durationSeconds.toNumber(),
            completedSets,
            storedSetEndTimes
        ] as Lang.Array<Storage.ValueType>);

        if (history.size() > MAX_HISTORY_SIZE) {
            history = history.slice(history.size() - MAX_HISTORY_SIZE, history.size());
        }

        Storage.setValue(HISTORY_KEY, history);
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

    function isValidRecord(record) {
        if (!(record instanceof Lang.Array)
                || (record.size() != 5 && record.size() != 6)) {
            return false;
        }
        for (var index = 0; index < 4; index += 1) {
            if (!(record[index] instanceof Lang.Number)) {
                return false;
            }
        }
        if (record[0] < 0 || record[1] < 0 || record[2] < 0
                || record[2] > 1 || record[3] < 0
                || !(record[4] instanceof Lang.Array)) {
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
        if (record.size() == 6) {
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
}
