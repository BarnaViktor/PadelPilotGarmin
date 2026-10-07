using Toybox.Application.Storage as Storage;
using Toybox.Lang as Lang;
using Toybox.System as System;
using Toybox.Test as Test;
using Toybox.WatchUi as WatchUi;

(:debug)
class RecoveryTestPointDelegate extends SilentPointMatchDelegate {
    var left;
    function initialize(view) {
        SilentPointMatchDelegate.initialize(view);
        left = false;
    }
    function leaveMatch() { left = true; }
}

(:test)
function pointStateRestoreValidatesBeforeChangingScoreOrUndo(logger) {
    var engine = new PointMatchEngine(PointMatchMode.AMERICANO,
        PointMatchEndRule.TOTAL_POINTS, 24, 1);
    engine.awardPoint(0);
    var invalid = [null, [], [1], [1, 2, 3], [-1, 0], [0, -1],
        [1.0, 0], [true, 0], ["1", 0], [null, 0], [25, 0], [0, 25],
        [13, 12], [2147483647, 2147483647]];
    for (var i = 0; i < invalid.size(); i += 1) {
        Test.assert(!engine.restoreState(invalid[i]));
        Test.assertEqual(1, pointScore(engine, 0));
        Test.assertEqual(0, pointScore(engine, 1));
    }
    Test.assert(engine.undoLastPoint());
    var state = [12, 11];
    Test.assert(engine.restoreState(state));
    state[0] = 0;
    var exported = engine.exportState();
    exported[1] = 0;
    Test.assertEqual(12, pointScore(engine, 0));
    Test.assertEqual(11, pointScore(engine, 1));
    Test.assert(!engine.undoLastPoint());
    Test.assert(engine.awardPoint(1));
    Test.assertEqual(PointMatchResult.DRAW, engine.getResult());
    Test.assert(engine.undoLastPoint());
    Test.assert(!engine.isComplete());
    return true;
}

(:test)
function pointStateRestoreChecksTeamTargetAndMaximumNumber(logger) {
    var engine = new PointMatchEngine(PointMatchMode.MEXICANO,
        PointMatchEndRule.TEAM_TARGET, 7, 0);
    Test.assert(!engine.restoreState([7, 7]));
    Test.assert(!engine.restoreState([8, 0]));
    Test.assert(engine.restoreState([7, 6]));
    Test.assertEqual(PointMatchResult.WIN, engine.getResult());
    Test.assert(engine.restoreState([0, 7]));
    Test.assertEqual(PointMatchResult.LOSS, engine.getResult());
    Test.assert(!engine.awardPoint(0));
    var maxEngine = new PointMatchEngine(PointMatchMode.AMERICANO,
        PointMatchEndRule.TOTAL_POINTS, 2147483647, 0);
    Test.assert(!maxEngine.restoreState([2147483647, 1]));
    Test.assert(maxEngine.restoreState([2147483646, 1]));
    Test.assert(maxEngine.isComplete());
    return true;
}

(:test)
function pointActiveRoundTripRecoversEveryModeRuleAndStartingTeam(logger) {
    ActiveMatchSession.clear();
    for (var mode = 0; mode < 2; mode += 1) {
        for (var rule = 0; rule < 2; rule += 1) {
            for (var team = 0; team < 2; team += 1) {
                var engine = new PointMatchEngine(mode, rule, 17, team);
                Test.assert(engine.restoreState([9, 7]));
                ActiveMatchStore.savePointMatch(engine, 12345);
                var initial = new PadelApp().getInitialView() as Lang.Array<Lang.Object>;
                Test.assert(initial[0] instanceof RecoveryView);
                var recovery = initial[0] as RecoveryView;
                var loaded = recovery.getLoadedMatch();
                Test.assertEqual(12345, loaded[1]);
                Test.assertEqual(mode, loaded[0].getMode());
                Test.assertEqual(rule, loaded[0].getEndRule());
                Test.assertEqual(17, loaded[0].getTarget());
                Test.assertEqual(team, loaded[0].getStartingServerTeam());
                var input = initial[1] as RecoveryInputDelegate;
                var view = input.createResumedView() as PointMatchStartView;
                Test.assert(view instanceof PointMatchStartView);
                Test.assert(view._recovered && view._session.isPaused());
                Test.assertEqual(9, pointScore(view._engine, 0));
                Test.assertEqual(7, pointScore(view._engine, 1));
                Test.assertEqual(12345, view._session.getElapsedMilliseconds(1000000));
                Test.assert(!view._session.awardPoint(0, 1000000));
                view.onShow();
                Test.assert(!view._clockTimerRunning);
                view.onHide();
                view._session.setPaused(false, 2000000);
                Test.assert(!view._session.undoLastPoint(2000000));
                Test.assert(view._session.awardPoint(0, 2000500));
                Test.assert(view._session.undoLastPoint(2001000));
                Test.assertEqual(9, pointScore(view._engine, 0));
                Test.assertEqual(7, pointScore(view._engine, 1));
            }
        }
    }
    ActiveMatchSession.clear();
    return true;
}

(:test)
function pointRecoveryPreservesFractionsAndExcludesRestartAndPauseTime(logger) {
    ActiveMatchSession.clear();
    var engine = new PointMatchEngine(PointMatchMode.MEXICANO,
        PointMatchEndRule.TEAM_TARGET, 24, 1);
    var session = new PointMatchSession(engine, 100);
    session.awardPoint(0, 1000);
    session.setPaused(true, 1350);
    ActiveMatchStore.savePointMatch(engine, session.getElapsedMilliseconds(100000));
    var loaded = ActiveMatchStore.load();
    var restored = new PointMatchSession(loaded[0], 200000);
    Test.assert(restored.restoreElapsedMilliseconds(loaded[1]));
    Test.assert(restored.isPaused());
    Test.assertEqual(1250, restored.getElapsedMilliseconds(300000));
    restored.setPaused(false, 300000);
    restored.setPaused(true, 300750);
    Test.assertEqual(2, restored.getDurationSeconds(400000));
    ActiveMatchStore.savePointMatch(loaded[0], restored.getElapsedMilliseconds(400000));
    var again = ActiveMatchStore.load();
    Test.assertEqual(2000, again[1]);
    Test.assertEqual(1, pointScore(again[0], 0));
    Test.assert(!restored.restoreElapsedMilliseconds(-1));
    Test.assert(!restored.restoreElapsedMilliseconds(1.0));
    Test.assert(!restored.restoreElapsedMilliseconds(null));
    Test.assertEqual(2000, restored.getElapsedMilliseconds(400000));
    ActiveMatchSession.clear();
    return true;
}

(:test)
function pointRecoveryRetainsWinLossDrawAndFrozenResultTime(logger) {
    ActiveMatchSession.clear();
    var states = [[2, 0], [0, 2], [1, 1]];
    for (var mode = 0; mode < 2; mode += 1) {
        for (var result = 0; result < 3; result += 1) {
            var engine = new PointMatchEngine(mode, PointMatchEndRule.TOTAL_POINTS, 2, 1);
            Test.assert(engine.restoreState(states[result]));
            ActiveMatchStore.savePointMatch(engine, 5678);
            var loaded = ActiveMatchStore.load();
            var view = new RecoveryInputDelegate(new RecoveryView(loaded)).createResumedView();
            Test.assert(view._engine.isComplete());
            Test.assertEqual(result + 1, view._engine.getResult());
            Test.assertEqual(5678, view._session.getElapsedMilliseconds(100000));
            Test.assert(!view._session.awardPoint(0, 100000));
            Test.assert(!view._session.undoLastPoint(100000));
            view.onShow();
            Test.assert(!view._clockTimerRunning);
            view.onHide();
        }
    }
    ActiveMatchSession.clear();
    return true;
}

(:test)
function corruptPointSavesClearOnlyActiveStorage(logger) {
    ActiveMatchSession.clear();
    Storage.setValue(MatchHistoryStore.HISTORY_KEY, [[1, 0, 0, 60, [[6, 0, false]]]]);
    var config = [PointMatchMode.AMERICANO, PointMatchEndRule.TOTAL_POINTS, 24, 0];
    var corrupt = [[], "broken", [4], [4, 0, config], [4, 0, config, [0, 0], []],
        [4.0, 0, config, [0, 0]], [99, 0, config, [0, 0]],
        [4, -1, config, [0, 0]], [4, 1.0, config, [0, 0]],
        [4, null, config, [0, 0]], [4, 0, null, [0, 0]],
        [4, 0, [0, 0, 24], [0, 0]], [4, 0, [0, 0, 24, 0, 1], [0, 0]],
        [4, 0, [2, 0, 24, 0], [0, 0]], [4, 0, [0, 2, 24, 0], [0, 0]],
        [4, 0, [0, 0, 0, 0], [0, 0]], [4, 0, [0, 0, -1, 0], [0, 0]],
        [4, 0, [0, 0, 24.0, 0], [0, 0]], [4, 0, [0, 0, "24", 0], [0, 0]],
        [4, 0, [0, 0, 24, 2], [0, 0]], [4, 0, [0, 0, 24, null], [0, 0]],
        [4, 0, config, null], [4, 0, config, [13, 12]],
        [4, 0, [1, 1, 7, 1], [7, 7]],
        [4, 0, [3, 0, 0, 0, 7, 10, true], [0, 0]],
        [3, 0, config, [0, 0], []]];
    for (var i = 0; i < corrupt.size(); i += 1) {
        Storage.setValue(ActiveMatchStore.ACTIVE_KEY, corrupt[i]);
        Test.assert(ActiveMatchStore.load() == null);
        Test.assert(Storage.getValue(ActiveMatchStore.ACTIVE_KEY) == null);
        var history = Storage.getValue(MatchHistoryStore.HISTORY_KEY);
        Test.assertEqual(1, history.size());
        Test.assertEqual(60, history[0][3]);
        Test.assertEqual(6, history[0][4][0][0]);
    }
    Storage.deleteValue(MatchHistoryStore.HISTORY_KEY);
    return true;
}

(:test)
function classicActiveVersionsRemainReadableBesidePointSchema(logger) {
    ActiveMatchSession.clear();
    var engine = createAdvantageMatch();
    engine.awardPoint(0);
    var config = [3, ScoringMode.ADVANTAGE, DecidingSetMode.FULL_SET, 0, 7, 10, true];
    for (var version = 1; version <= 3; version += 1) {
        var state = engine.exportState();
        if (version < 3) { state = state.slice(0, version == 1 ? 12 : 15); }
        var stored = [version, 87, config, state];
        if (version > 1) { stored.add([]); }
        Storage.setValue(ActiveMatchStore.ACTIVE_KEY, stored);
        var loaded = ActiveMatchStore.load();
        Test.assert(loaded != null && loaded[0] instanceof ScoringEngine);
        Test.assertEqual(87, loaded[1]);
        Test.assertEqual(1, loaded[0].getPoints()[0]);
        Test.assertEqual(version == 3, loaded[0].hasCompletePointTotals());
        var view = new RecoveryInputDelegate(new RecoveryView(loaded)).createResumedView();
        Test.assert(view instanceof ScoreView);
        ActiveMatchSession.attach(loaded[0], view);
        Test.assertEqual(3, Storage.getValue(ActiveMatchStore.ACTIVE_KEY)[0]);
        Test.assertEqual(87, ActiveMatchStore.load()[1]);
    }
    ActiveMatchSession.clear();
    return true;
}

(:test)
function pointLivePersistenceFollowsPointsUndoPauseStopAndDiscard(logger) {
    ActiveMatchSession.clear();
    var engine = new PointMatchEngine(0, 0, 1, 1);
    var view = new PointMatchStartView(engine);
    view.restoreSavedTime(12345);
    ActiveMatchSession.attach(engine, view);
    var delegate = new RecoveryTestPointDelegate(view);
    Test.assertEqual(4, Storage.getValue(ActiveMatchStore.ACTIVE_KEY)[0]);
    delegate.handleKey(WatchUi.KEY_DOWN);
    Test.assertEqual(0, pointScore(ActiveMatchStore.load()[0], 0));
    delegate.handleKey(WatchUi.KEY_ESC);
    delegate.handleKey(WatchUi.KEY_UP);
    Test.assertEqual(PointMatchResult.LOSS, ActiveMatchStore.load()[0].getResult());
    delegate.handleKey(WatchUi.KEY_ESC);
    Test.assert(!ActiveMatchStore.load()[0].isComplete());
    delegate.handleKey(WatchUi.KEY_DOWN);
    Test.assertEqual(PointMatchResult.WIN, ActiveMatchStore.load()[0].getResult());
    delegate.handleKey(WatchUi.KEY_ESC);
    view.setPaused(true);
    var time = view.getElapsedMilliseconds();
    Test.assertEqual(time, ActiveMatchStore.load()[1]);
    new PadelApp().onStop(null);
    Test.assertEqual(time, ActiveMatchStore.load()[1]);
    delegate.handleKey(WatchUi.KEY_DOWN);
    delegate.handleKey(WatchUi.KEY_DOWN);
    delegate.handleKey(WatchUi.KEY_ENTER);
    delegate.handleKey(WatchUi.KEY_ENTER);
    Test.assert(ActiveMatchStore.load() != null && !delegate.left);
    delegate.handleKey(WatchUi.KEY_ENTER);
    delegate.handleKey(WatchUi.KEY_DOWN);
    delegate.handleKey(WatchUi.KEY_ENTER);
    Test.assert(delegate.left);
    Test.assert(Storage.getValue(ActiveMatchStore.ACTIVE_KEY) == null);
    view.onHide();
    new PadelApp().onStop(null);
    Test.assert(Storage.getValue(ActiveMatchStore.ACTIVE_KEY) == null);
    return true;
}

(:test)
function pointRecoveryLabelsAndLargeScoresFitBothDisplays(logger) {
    for (var mode = 0; mode < 2; mode += 1) {
        for (var rule = 0; rule < 2; rule += 1) {
            var engine = new PointMatchEngine(mode, rule, 999, 1);
            Test.assert(engine.restoreState(rule == 0 ? [998, 1] : [998, 999]));
            var view = new RecoveryView([engine, 360000001, []]);
            assertLayoutBounds(view, 280);
            assertLayoutBounds(view, 416);
            var text = captureHistoryText(view);
            Test.assert(text.hasText(mode == 0 ? "AMERICANO" : "MEXICANO"));
            Test.assert(text.hasText(rule == 0 ? "TOTAL X: 999" : "TEAM X: 999"));
            Test.assert(text.hasText("998"));
            var resumed = new RecoveryInputDelegate(view).createResumedView();
            assertLayoutBounds(resumed, 280);
            assertLayoutBounds(resumed, 416);
            Test.assertEqual(360000, resumed.getDurationSeconds());
        }
    }
    return true;
}
