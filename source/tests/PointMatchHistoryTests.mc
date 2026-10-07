using Toybox.Application.Storage as Storage;
using Toybox.Lang as Lang;
using Toybox.Test as Test;
using Toybox.WatchUi as WatchUi;

(:debug)
class HistoryTestPointDelegate extends RecoveryTestPointDelegate {
    var failure;
    function initialize(view) {
        RecoveryTestPointDelegate.initialize(view);
        failure = 0;
    }
    function writeHistory() {
        if (failure == 1) { return false; }
        if (failure == 2) { throw new Lang.InvalidValueException("Storage unavailable"); }
        return PointMatchStartInputDelegate.writeHistory();
    }
    // History tests inject history failures; AM-7 covers the FIT transaction.
    function saveActivity() { return true; }
}

(:test)
function pointHistoryPreservesEveryModeRuleTeamAndResult(logger) {
    Storage.deleteValue(MatchHistoryStore.HISTORY_KEY);
    for (var mode = 0; mode < 2; mode += 1) {
        for (var rule = 0; rule < 2; rule += 1) {
            for (var team = 0; team < 2; team += 1) {
                var engine = new PointMatchEngine(mode, rule, 4, team);
                Test.assert(!MatchHistoryStore.savePointCompleted(engine, 87));
                Test.assert(!MatchHistoryStore.savePointStopped(engine, -1));
                Test.assert(!MatchHistoryStore.savePointStopped(engine, 1.0));
                Test.assert(engine.restoreState([1, 1]));
                Test.assert(MatchHistoryStore.savePointStopped(engine, 87));
                var states = rule == 0 ? [[3, 1], [1, 3]] : [[4, 3], [3, 4]];
                for (var result = 0; result < states.size(); result += 1) {
                    Test.assert(engine.restoreState(states[result]));
                    Test.assert(!MatchHistoryStore.savePointStopped(engine, 123));
                    Test.assert(MatchHistoryStore.savePointCompleted(engine, 123));
                    var history = MatchHistoryStore.load();
                    var record = history[history.size() - 1];
                    Test.assert(MatchHistoryStore.isValidRecord(record));
                    Test.assert(MatchHistoryStore.isPointRecord(record));
                    Test.assertEqual(mode, record[1]);
                    Test.assertEqual(rule, record[2]);
                    Test.assertEqual(4, record[3]);
                    Test.assertEqual(team, record[4]);
                    Test.assertEqual(states[result][0], MatchHistoryStore.getPointTotals(record)[0]);
                    Test.assertEqual(states[result][1], MatchHistoryStore.getPointTotals(record)[1]);
                    Test.assertEqual(123, MatchHistoryStore.getDurationSeconds(record));
                    Test.assertEqual(result == 0 ? PointMatchResult.WIN : PointMatchResult.LOSS,
                        MatchHistoryStore.getResult(record));
                    Test.assert(!MatchHistoryStore.isStopped(record));
                }
                if (rule == 0) {
                    engine.restoreState([2, 2]);
                    Test.assert(MatchHistoryStore.savePointCompleted(engine, 99));
                    var history = MatchHistoryStore.load();
                    var draw = history[history.size() - 1];
                    Test.assertEqual(PointMatchResult.DRAW, MatchHistoryStore.getResult(draw));
                    Test.assert(!MatchHistoryStore.isStopped(draw));
                }
            }
        }
    }
    Storage.deleteValue(MatchHistoryStore.HISTORY_KEY);
    return true;
}

(:test)
function pointHistoryRejectsCorruptionAndImpossibleResults(logger) {
    var valid = [4, 0, 0, 24, 1, [12, 12], 87, PointMatchResult.DRAW];
    Test.assert(MatchHistoryStore.isValidRecord(valid));
    var invalidFields = [
        [5, 4.0, null], [2, -1, "0", 0.0], [2, -1, true, 1.0],
        [0, -1, 24.0, "24"], [2, -1, null],
        [null, [], [12], [12, 12, 0], [12.0, 12], [-1, 12], [13, 12], [25, 0]],
        [-1, 87.0, null], [PointMatchResult.ACTIVE, PointMatchResult.WIN, PointMatchResult.LOSS, 99]
    ];
    for (var field = 0; field < valid.size(); field += 1) {
        for (var value = 0; value < invalidFields[field].size(); value += 1) {
            var corrupt = valid.slice(0, null);
            corrupt[field] = invalidFields[field][value];
            Test.assert(!MatchHistoryStore.isValidRecord(corrupt));
        }
    }
    Test.assert(!MatchHistoryStore.isValidRecord(valid.slice(0, 7)));
    Test.assert(!MatchHistoryStore.isValidRecord([4, 1, 1, 24, 0, [24, 24], 5, PointMatchResult.DRAW]));
    Test.assert(!MatchHistoryStore.isValidRecord([4, 1, 1, 24, 0, [23, 23], 5, PointMatchResult.DRAW]));
    Test.assert(MatchHistoryStore.isValidRecord([4, 1, 1, 24, 0, [23, 23], 5, PointMatchResult.ACTIVE]));
    Test.assert(MatchHistoryStore.isValidRecord([4, 1, 0, 2147483647, 0,
        [2147483646, 1], 5, PointMatchResult.WIN]));
    Test.assert(!MatchHistoryStore.isValidRecord([4, 1, 0, 2147483647, 0,
        [2147483647, 2147483647], 5, PointMatchResult.DRAW]));
    return true;
}

(:test)
function pointHistoryReadsAllClassicVersionsAndKeepsActiveMatch(logger) {
    ActiveMatchSession.clear();
    var engine = new PointMatchEngine(0, 0, 24, 1);
    ActiveMatchStore.savePointMatch(engine, 12345);
    var legacy = [1, 0, 0, 60, [[6, 0, false]]];
    var withTimes = [0, 1, 1, 120, [[0, 6, false]], [120]];
    var v2 = [0, 0, -1, 30, [], [], 2, 1, [2, 1, 3, 2, false, false]];
    var v3 = [1, 0, 0, 60, [[6, 0, false]], [60], 3, 0,
        [0, 0, 0, 0, false, false], [24, 8]];
    var point = [4, 1, 0, 24, 1, [12, 12], 90, PointMatchResult.DRAW];
    Storage.setValue(MatchHistoryStore.HISTORY_KEY,
        [legacy, withTimes, v2, v3, [4, 0, 0, 24, 0, [13, 12], 1, PointMatchResult.DRAW], point]);
    var history = MatchHistoryStore.load();
    Test.assertEqual(5, history.size());
    Test.assertEqual(5, Storage.getValue(MatchHistoryStore.HISTORY_KEY).size());
    Test.assertEqual(12345, ActiveMatchStore.load()[1]);
    Test.assert(!MatchHistoryStore.hasPointTotals(history[0]));
    Test.assert(!MatchHistoryStore.hasPointTotals(history[1]));
    Test.assert(!MatchHistoryStore.hasPointTotals(history[2]));
    Test.assert(MatchHistoryStore.hasPointTotals(history[3]));
    Test.assert(MatchHistoryStore.hasPointTotals(history[4]));
    ActiveMatchSession.clear();
    Storage.deleteValue(MatchHistoryStore.HISTORY_KEY);
    return true;
}

(:test)
function pointHistorySharesTwentyRecordLimitAndDeletionWithClassic(logger) {
    Storage.deleteValue(MatchHistoryStore.HISTORY_KEY);
    var point = new PointMatchEngine(1, 1, 999, 1);
    point.restoreState([998, 997]);
    var classic = createAdvantageMatch();
    for (var i = 0; i < 25; i += 1) {
        Test.assert(i % 2 == 0 ? MatchHistoryStore.savePointStopped(point, i)
            : MatchHistoryStore.saveStopped(classic, i, []));
    }
    var history = MatchHistoryStore.load();
    Test.assertEqual(20, history.size());
    Test.assertEqual(5, MatchHistoryStore.getDurationSeconds(history[0]));
    Test.assertEqual(24, MatchHistoryStore.getDurationSeconds(history[19]));
    point.awardPoint(0);
    Test.assertEqual(998, MatchHistoryStore.getPointTotals(history[19])[0]);
    var view = new MatchHistoryView();
    Test.assert(MatchHistoryStore.isPointRecord(view.getSelectedRecord()));
    view.moveSelection(1);
    Test.assertEqual(23, MatchHistoryStore.getDurationSeconds(view.getSelectedRecord()));
    Test.assert(view.deleteSelected());
    Test.assertEqual(19, view.getHistory().size());
    Test.assertEqual(22, MatchHistoryStore.getDurationSeconds(view.getSelectedRecord()));
    Test.assertEqual(24, MatchHistoryStore.getDurationSeconds(view.getHistory()[18]));
    var summary = MatchHistoryStatistics.summarize(view.getHistory());
    Test.assertEqual(19, summary[MatchHistoryStatistics.TOTAL_MATCHES]);
    Test.assertEqual(19, summary[MatchHistoryStatistics.POINT_DATA_MATCHES]);
    Test.assertEqual(9980, summary[MatchHistoryStatistics.POINTS_WON]);
    // Delete newest until the shared key itself disappears.
    view._selected = 0;
    while (view.getHistory().size() > 0) { Test.assert(view.deleteSelected()); }
    Test.assert(Storage.getValue(MatchHistoryStore.HISTORY_KEY) == null);
    return true;
}

(:test)
function pointHistoryStatisticsCountDrawsPointsTimeAndOnlyRealSets(logger) {
    var history = [
        [1, 0, 0, 60, [[6, 0, false]]],
        [0, 1, 1, 120, [[0, 6, false]], [120]],
        [0, 0, -1, 30, [], [], 2, 1, [2, 1, 3, 2, false, false]],
        [1, 0, 0, 60, [[6, 0, false]], [60], 3, 0,
            [0, 0, 0, 0, false, false], [24, 8]],
        [4, 0, 0, 24, 1, [12, 12], 90, PointMatchResult.DRAW],
        [4, 1, 1, 24, 0, [24, 23], 120, PointMatchResult.WIN],
        [4, 0, 1, 24, 1, [23, 24], 120, PointMatchResult.LOSS],
        [4, 1, 0, 24, 0, [7, 5], 30, PointMatchResult.ACTIVE]
    ];
    var summary = MatchHistoryStatistics.summarize(history);
    Test.assertEqual(8, summary[MatchHistoryStatistics.TOTAL_MATCHES]);
    Test.assertEqual(6, summary[MatchHistoryStatistics.COMPLETED_MATCHES]);
    Test.assertEqual(2, summary[MatchHistoryStatistics.STOPPED_MATCHES]);
    Test.assertEqual(3, summary[MatchHistoryStatistics.MATCH_WINS]);
    Test.assertEqual(2, summary[MatchHistoryStatistics.MATCH_LOSSES]);
    Test.assertEqual(1, summary[MatchHistoryStatistics.MATCH_DRAWS]);
    Test.assertEqual(2, summary[MatchHistoryStatistics.SETS_WON]);
    Test.assertEqual(1, summary[MatchHistoryStatistics.SETS_LOST]);
    Test.assertEqual(5, summary[MatchHistoryStatistics.POINT_DATA_MATCHES]);
    Test.assertEqual(90, summary[MatchHistoryStatistics.POINTS_WON]);
    Test.assertEqual(72, summary[MatchHistoryStatistics.POINTS_LOST]);
    Test.assertEqual(630, summary[MatchHistoryStatistics.TOTAL_SECONDS]);
    Test.assertEqual(78, MatchHistoryStatistics.averageDuration(summary));
    var stats = new MatchHistoryStatsView(history);
    stats.movePage(1);
    var dc = captureHistoryText(stats);
    Test.assert(dc.hasText("DRAWS") && dc.hasText("50%"));
    var draws = new MatchHistoryStatsView([history[4]]);
    draws.movePage(1);
    dc = captureHistoryText(draws);
    Test.assert(dc.hasText("DRAWS") && dc.hasText("0%"));
    var stopped = new MatchHistoryStatsView([history[7]]);
    stopped.movePage(1);
    Test.assert(captureHistoryText(stopped).hasText("--"));
    return true;
}

(:test)
function pointHistoryButtonsConfirmStoppedAndAllCompletedResults(logger) {
    Storage.deleteValue(MatchHistoryStore.HISTORY_KEY);
    ActiveMatchSession.clear();
    var states = [[1, 1], [3, 1], [1, 3], [2, 2]];
    for (var i = 0; i < states.size(); i += 1) {
        var engine = new PointMatchEngine(i % 2, 0, 4, i % 2);
        engine.restoreState(states[i]);
        var view = new PointMatchStartView(engine);
        view.restoreSavedTime(12345);
        ActiveMatchSession.attach(engine, view);
        var delegate = new HistoryTestPointDelegate(view);
        if (i == 0) { delegate.handleKey(WatchUi.KEY_DOWN); }
        else { delegate.handleKey(WatchUi.KEY_ENTER); }
        delegate.onKey(new SetupKeyEvent(WatchUi.KEY_ENTER));
        Test.assert(view._saveConfirm && !view._saveYes);
        delegate.handleKey(WatchUi.KEY_ENTER);
        Test.assert(!view._saveConfirm && !delegate.left);
        Test.assertEqual(i, MatchHistoryStore.load().size());
        delegate.handleKey(WatchUi.KEY_ENTER);
        delegate.handleKey(WatchUi.KEY_UP);
        delegate.handleKey(WatchUi.KEY_ESC);
        Test.assert(!view._saveConfirm && !delegate.left);
        Test.assert(ActiveMatchStore.load() != null);
        delegate.handleKey(WatchUi.KEY_ENTER);
        Test.assert(!view._saveYes);
        delegate.handleKey(WatchUi.KEY_DOWN);
        delegate.handleKey(WatchUi.KEY_ENTER);
        Test.assert(delegate.left);
        Test.assert(ActiveMatchStore.load() == null);
        view.onHide();
        new PadelApp().onStop(null);
        Test.assert(ActiveMatchStore.load() == null);
        delegate.handleKey(WatchUi.KEY_ENTER);
        Test.assert(!delegate.saveMatch());
        var history = MatchHistoryStore.load();
        Test.assertEqual(i + 1, history.size());
        Test.assertEqual(12, MatchHistoryStore.getDurationSeconds(history[i]));
        Test.assertEqual(i == 0, MatchHistoryStore.isStopped(history[i]));
        Test.assertEqual(states[i][0], MatchHistoryStore.getPointTotals(history[i])[0]);
        Test.assertEqual(states[i][1], MatchHistoryStore.getPointTotals(history[i])[1]);
    }
    Storage.deleteValue(MatchHistoryStore.HISTORY_KEY);
    return true;
}

(:test)
function pointHistorySaveFailureRetainsRecoveryAndAllowsRetry(logger) {
    Storage.deleteValue(MatchHistoryStore.HISTORY_KEY);
    for (var completed = 0; completed < 2; completed += 1) {
        var engine = new PointMatchEngine(0, 0, 2, 1);
        engine.restoreState(completed == 0 ? [1, 0] : [1, 1]);
        var view = new PointMatchStartView(engine);
        view.restoreSavedTime(9876);
        ActiveMatchSession.attach(engine, view);
        var delegate = new HistoryTestPointDelegate(view);
        if (completed == 0) { delegate.handleKey(WatchUi.KEY_DOWN); }
        else { delegate.handleKey(WatchUi.KEY_ENTER); }
        delegate.handleKey(WatchUi.KEY_ENTER);
        delegate.handleKey(WatchUi.KEY_UP);
        for (var failure = 1; failure <= 2; failure += 1) {
            delegate.failure = failure;
            delegate.handleKey(WatchUi.KEY_ENTER);
            Test.assert(!delegate.left && !delegate._ended);
            Test.assert(view._saveConfirm && view._saveYes && view._saveError);
            Test.assert(captureHistoryText(view).hasText("HISTORY SAVE FAILED"));
            Test.assertEqual(completed, MatchHistoryStore.load().size());
            Test.assertEqual(9876, ActiveMatchStore.load()[1]);
            Test.assertEqual(1, pointScore(ActiveMatchStore.load()[0], 0));
        }
        delegate.failure = 0;
        delegate.handleKey(WatchUi.KEY_ENTER);
        Test.assert(delegate.left && ActiveMatchStore.load() == null);
        Test.assertEqual(completed + 1, MatchHistoryStore.load().size());
    }
    Storage.deleteValue(MatchHistoryStore.HISTORY_KEY);
    return true;
}

(:test)
function pointHistoryDiscardDoesNotAppendOrDeleteOlderMatches(logger) {
    Storage.deleteValue(MatchHistoryStore.HISTORY_KEY);
    var previous = new PointMatchEngine(0, 0, 2, 0);
    previous.restoreState([1, 1]);
    MatchHistoryStore.savePointCompleted(previous, 90);
    for (var completed = 0; completed < 2; completed += 1) {
        var engine = new PointMatchEngine(1, 1, 2, 1);
        engine.restoreState(completed == 0 ? [1, 0] : [2, 1]);
        var view = new PointMatchStartView(engine);
        view.restoreSavedTime(3000);
        ActiveMatchSession.attach(engine, view);
        var delegate = new HistoryTestPointDelegate(view);
        if (completed == 1) { delegate.handleKey(WatchUi.KEY_ENTER); }
        delegate.handleKey(WatchUi.KEY_UP);
        Test.assertEqual(completed == 0 ? 2 : 1, view._pauseSelection);
        delegate.handleKey(WatchUi.KEY_ENTER);
        Test.assert(view._discardConfirm && !view._discardYes);
        delegate.handleKey(WatchUi.KEY_DOWN);
        delegate.handleKey(WatchUi.KEY_ENTER);
        Test.assert(delegate.left && ActiveMatchStore.load() == null);
        Test.assertEqual(1, MatchHistoryStore.load().size());
        Test.assertEqual(PointMatchResult.DRAW, MatchHistoryStore.getResult(MatchHistoryStore.load()[0]));
    }
    Storage.deleteValue(MatchHistoryStore.HISTORY_KEY);
    return true;
}

(:test)
function pointHistoryDetailsShowPointsRulesTimeAndNoSetPages(logger) {
    var records = [
        [4, 0, 0, 24, 1, [12, 12], 90, PointMatchResult.DRAW],
        [4, 1, 1, 999, 0, [998, 999], 360000, PointMatchResult.LOSS],
        [4, 0, 1, 999, 1, [999, 998], 12, PointMatchResult.WIN],
        [4, 1, 0, 24, 0, [0, 0], 0, PointMatchResult.ACTIVE]
    ];
    for (var size = 280; size <= 416; size += 136) {
        var history = new MatchHistoryView();
        history._history = records;
        assertLayoutBounds(history, size);
        for (var i = 0; i < records.size(); i += 1) {
            var view = new MatchHistoryDetailView(records[i]);
            Test.assertEqual(2, view.getPageCount());
            assertLayoutBounds(view, size);
            var dc = captureHistoryText(view);
            Test.assert(dc.hasText(MatchHistoryStore.modeLabel(records[i])));
            Test.assert(dc.hasText(MatchHistoryStore.resultLabel(records[i])));
            Test.assert(dc.hasText(i == 1 || i == 2 ? "TEAM TARGET: 999" : "TOTAL POINTS: 24"));
            Test.assert(dc.hasText(i == 1 || i == 2 ? "998" : (i == 0 ? "12" : "0")));
            Test.assert(!dc.hasText("CURRENT GAMES"));
            view.movePage(-1);
            assertLayoutBounds(view, size);
            dc = captureHistoryText(view);
            Test.assert(dc.hasText("MATCH POINTS") && dc.hasText("MATCH TIME"));
            Test.assert(!dc.hasText("MATCH SET STATS") && !dc.hasText("NO POINT DATA"));
            Test.assert(dc.hasText(i == 3 ? "--" : (i == 0 ? "50%" : (i == 1 ? "49%" : "50%"))));
            view.movePage(1);
            Test.assertEqual(0, view._page);
            view.setDeleteConfirm(true);
            assertLayoutBounds(view, size);
            Test.assert(!view.isDeleteYes());
            view.moveDeleteSelection();
            assertLayoutBounds(view, size);
            Test.assert(view.isDeleteYes());
        }
        var stats = new MatchHistoryStatsView(records);
        for (var page = 0; page < stats.getPageCount(); page += 1) {
            assertLayoutBounds(stats, size);
            stats.movePage(1);
        }
        var fullHistory = [];
        for (var i = 0; i < 20; i += 1) {
            fullHistory.add([4, i % 2, 1, 999, i % 2,
                [998, 998], 60, PointMatchResult.ACTIVE]);
        }
        stats = new MatchHistoryStatsView(fullHistory);
        stats.movePage(-1);
        assertLayoutBounds(stats, size);
        var dc = captureHistoryText(stats);
        Test.assert(dc.hasText("19960") && dc.hasText("50%") && dc.hasText("20"));
    }
    return true;
}
