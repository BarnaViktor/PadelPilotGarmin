using Toybox.Lang as Lang;
using Toybox.System as System;
using Toybox.Test as Test;
using Toybox.WatchUi as WatchUi;

(:debug)
function pointScore(engine, team) {
    var points = engine.getPoints() as Lang.Array<Lang.Number>;
    return points[team];
}

(:debug)
class SilentPointMatchDelegate extends PointMatchStartInputDelegate {
    function initialize(view) { PointMatchStartInputDelegate.initialize(view); }
    function vibrate(duration) {}
}

(:test)
function pointSessionCompletesEveryModeRuleAndStartingTeam(logger) {
    for (var mode = PointMatchMode.AMERICANO; mode <= PointMatchMode.MEXICANO; mode += 1) {
        for (var rule = PointMatchEndRule.TOTAL_POINTS; rule <= PointMatchEndRule.TEAM_TARGET; rule += 1) {
            for (var team = 0; team < 2; team += 1) {
                var engine = new PointMatchEngine(mode, rule, 3, team);
                var session = new PointMatchSession(engine, 0);
                Test.assert(session.awardPoint(1, 1000));
                Test.assert(session.awardPoint(0, 1500));
                Test.assert(session.awardPoint(1, 2000));
                if (rule == PointMatchEndRule.TEAM_TARGET) {
                    Test.assert(!engine.isComplete());
                    Test.assert(session.awardPoint(1, 2500));
                }
                Test.assert(engine.isComplete());
                Test.assertEqual(PointMatchResult.LOSS, engine.getResult());
                Test.assertEqual(2, session.getDurationSeconds(20000));
                Test.assert(!session.awardPoint(0, 30000));
                Test.assert(session.undoLastPoint(31000));
                Test.assert(!engine.isComplete());
                Test.assert(session.awardPoint(0, 31000));
                if (rule == PointMatchEndRule.TOTAL_POINTS) {
                    Test.assertEqual(PointMatchResult.WIN, engine.getResult());
                } else {
                    Test.assert(!engine.isComplete());
                    Test.assert(session.awardPoint(0, 31500));
                    Test.assertEqual(PointMatchResult.WIN, engine.getResult());
                }
                Test.assertEqual(team, engine.getStartingServerTeam());
            }
        }
    }
    return true;
}

(:test)
function pointSessionDebouncesAcrossTeamsAndAllowsCorrection(logger) {
    var engine = new PointMatchEngine(PointMatchMode.AMERICANO, PointMatchEndRule.TOTAL_POINTS, 24, 0);
    var session = new PointMatchSession(engine, 0);
    Test.assert(!session.undoLastPoint(0));
    Test.assert(!session.awardPoint(null, 999));
    Test.assert(!session.awardPoint(0.0, 999));
    Test.assert(session.awardPoint(0, 1000));
    Test.assert(!session.awardPoint(0, 1000));
    Test.assert(!session.awardPoint(1, 1499));
    Test.assert(session.awardPoint(1, 1500));
    Test.assert(session.undoLastPoint(1501));
    Test.assert(session.awardPoint(0, 1501));
    Test.assertEqual(2, pointScore(engine, 0));
    Test.assertEqual(0, pointScore(engine, 1));
    return true;
}

(:test)
function pointSessionPauseAndResultExcludeInactiveTime(logger) {
    var engine = new PointMatchEngine(PointMatchMode.MEXICANO, PointMatchEndRule.TOTAL_POINTS, 2, 1);
    var session = new PointMatchSession(engine, 100);
    Test.assert(session.awardPoint(0, 1100));
    session.setPaused(true, 1350);
    session.setPaused(true, 9000);
    Test.assert(!session.awardPoint(1, 20000));
    Test.assert(!session.undoLastPoint(20000));
    Test.assertEqual(1, session.getDurationSeconds(20000));
    session.setPaused(false, 21000);
    session.setPaused(false, 21100);
    Test.assertEqual(2, session.getDurationSeconds(21750));
    Test.assert(session.awardPoint(1, 21750));
    Test.assertEqual(PointMatchResult.DRAW, engine.getResult());
    session.setPaused(true, 25000);
    Test.assert(!session.isPaused());
    Test.assertEqual(2, session.getDurationSeconds(60000));
    Test.assert(session.undoLastPoint(60100));
    Test.assertEqual(2, session.getDurationSeconds(60100));
    session.setPaused(true, 60600);
    Test.assertEqual(2, session.getDurationSeconds(70000));
    session.setPaused(false, 80000);
    Test.assert(session.awardPoint(0, 80500));
    Test.assertEqual(PointMatchResult.WIN, engine.getResult());
    Test.assertEqual(3, session.getDurationSeconds(100000));
    return true;
}

(:test)
function pointSessionLimitsUndoDuringLongLiveMatch(logger) {
    var engine = new PointMatchEngine(PointMatchMode.MEXICANO, PointMatchEndRule.TEAM_TARGET, 999, 1);
    var session = new PointMatchSession(engine, 0);
    for (var i = 0; i < 1000; i += 1) {
        Test.assert(session.awardPoint(i % 2, i * 500));
    }
    Test.assertEqual(500, pointScore(engine, 0));
    Test.assertEqual(500, pointScore(engine, 1));
    for (var undo = 0; undo < 20; undo += 1) {
        Test.assert(session.undoLastPoint(500000));
    }
    Test.assert(!session.undoLastPoint(500000));
    Test.assertEqual(490, pointScore(engine, 0));
    Test.assertEqual(490, pointScore(engine, 1));
    Test.assertEqual(500, session.getDurationSeconds(500000));
    return true;
}

(:test)
function pointLiveButtonsPauseConfirmCancelAndUndoResult(logger) {
    var engine = new PointMatchEngine(PointMatchMode.AMERICANO, PointMatchEndRule.TOTAL_POINTS, 1, 1);
    var view = new PointMatchStartView(engine);
    var delegate = new SilentPointMatchDelegate(view);
    Test.assert(delegate.onKey(new SetupKeyEvent(WatchUi.KEY_ENTER)));
    Test.assert(view._session.isPaused());
    delegate.onKey(new SetupKeyEvent(WatchUi.KEY_DOWN));
    Test.assertEqual(0, pointScore(engine, 0));
    Test.assertEqual(1, view._pauseSelection);
    delegate.handleKey(WatchUi.KEY_ENTER);
    Test.assert(view._discardConfirm && !view._discardYes);
    delegate.handleKey(WatchUi.KEY_DOWN);
    Test.assert(view._discardYes);
    delegate.handleKey(WatchUi.KEY_ESC);
    Test.assert(!view._discardConfirm && view._session.isPaused());
    delegate.handleKey(WatchUi.KEY_ENTER);
    Test.assert(!view._discardYes);
    delegate.handleKey(WatchUi.KEY_ENTER);
    Test.assert(!view._discardConfirm && view._session.isPaused());
    delegate.handleKey(WatchUi.KEY_ESC);
    Test.assert(!view._session.isPaused());
    delegate.onKey(new SetupKeyEvent(WatchUi.KEY_UP));
    Test.assertEqual(PointMatchResult.LOSS, engine.getResult());
    delegate.handleKey(WatchUi.KEY_UP);
    delegate.handleKey(WatchUi.KEY_DOWN);
    Test.assertEqual(0, pointScore(engine, 0));
    Test.assertEqual(1, pointScore(engine, 1));
    delegate.handleKey(WatchUi.KEY_ENTER);
    Test.assert(view._discardConfirm && !view._discardYes);
    delegate.handleKey(WatchUi.KEY_ESC);
    Test.assert(engine.isComplete());
    delegate.onKey(new SetupKeyEvent(WatchUi.KEY_ESC));
    Test.assert(!engine.isComplete());
    delegate.onKey(new SetupKeyEvent(WatchUi.KEY_DOWN));
    Test.assertEqual(PointMatchResult.WIN, engine.getResult());
    Test.assert(delegate.onTap(null) && delegate.onSwipe(null));
    Test.assertEqual(1, pointScore(engine, 0));
    return true;
}

(:test)
function pointLiveTimerFollowsVisibilityPauseFinishAndUndo(logger) {
    var engine = new PointMatchEngine(PointMatchMode.MEXICANO, PointMatchEndRule.TOTAL_POINTS, 1, 0);
    var view = new PointMatchStartView(engine);
    var delegate = new SilentPointMatchDelegate(view);
    view.onShow();
    Test.assert(view._clockTimerRunning);
    view.setPaused(true);
    Test.assert(!view._clockTimerRunning);
    delegate.handleKey(WatchUi.KEY_ENTER);
    Test.assert(view._clockTimerRunning);
    delegate.handleKey(WatchUi.KEY_DOWN);
    Test.assert(!view._clockTimerRunning);
    delegate.handleKey(WatchUi.KEY_ESC);
    Test.assert(view._clockTimerRunning);
    view.onHide();
    Test.assert(!view._clockTimerRunning);
    return true;
}

(:debug)
function checkPointMatchLayouts(size) {
    for (var mode = PointMatchMode.AMERICANO; mode <= PointMatchMode.MEXICANO; mode += 1) {
        for (var rule = PointMatchEndRule.TOTAL_POINTS; rule <= PointMatchEndRule.TEAM_TARGET; rule += 1) {
            var engine = new PointMatchEngine(mode, rule, 999, 1);
            for (var point = 0; point < 998; point += 1) { engine.awardPoint(0); }
            for (var other = 0; other < (rule == PointMatchEndRule.TOTAL_POINTS ? 0 : 998); other += 1) {
                engine.awardPoint(1);
            }
            var view = new PointMatchStartView(engine);
            assertLayoutBounds(view, size);
            view.setPaused(true);
            assertLayoutBounds(view, size);
            view._pauseSelection = 1;
            assertLayoutBounds(view, size);
            view.showDiscardConfirm();
            assertLayoutBounds(view, size);
            view._discardYes = true;
            assertLayoutBounds(view, size);
            view.setPaused(false);
            view._session.awardPoint(0, System.getTimer());
            assertLayoutBounds(view, size);
            Test.assert(captureHistoryText(view).hasText("WIN"));
        }
        var drawEngine = new PointMatchEngine(mode, PointMatchEndRule.TOTAL_POINTS, 24, 0);
        for (var i = 0; i < 12; i += 1) {
            drawEngine.awardPoint(0); drawEngine.awardPoint(1);
        }
        var drawView = new PointMatchStartView(drawEngine);
        assertLayoutBounds(drawView, size);
        Test.assert(captureHistoryText(drawView).hasText("DRAW"));
        var lossEngine = new PointMatchEngine(mode, PointMatchEndRule.TEAM_TARGET, 1, 0);
        lossEngine.awardPoint(1);
        var lossView = new PointMatchStartView(lossEngine);
        assertLayoutBounds(lossView, size);
        Test.assert(captureHistoryText(lossView).hasText("LOSS"));
    }
}

(:test)
function pointLiveLayoutsAndResultsFitBothDisplays(logger) {
    checkPointMatchLayouts(280);
    checkPointMatchLayouts(416);
    return true;
}
