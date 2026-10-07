using Toybox.Application.Storage as Storage;
using Toybox.FitContributor as FitContributor;
using Toybox.Lang as Lang;
using Toybox.Test as Test;
using Toybox.WatchUi as WatchUi;

(:debug)
class FitTestField {
    var id;
    var type;
    var options;
    var value;
    function initialize(fieldId, fieldType, fieldOptions) {
        id = fieldId; type = fieldType; options = fieldOptions; value = null;
    }
    function setData(data) { value = data; }
}

// An ActivityRecording-shaped double with injected API failures. Native tests
// separately verify actual saved FIT files, metadata and timer events.
(:debug)
class FitTestSession {
    var fields;
    var recording;
    var starts;
    var stops;
    var saves;
    var discards;
    var laps;
    var startFailure;
    var stopFailure;
    var saveFailure;
    var discardFailure;
    var fieldFailure;
    function initialize() {
        fields = []; recording = false;
        starts = 0; stops = 0; saves = 0; discards = 0; laps = 0;
        startFailure = 0; stopFailure = 0; saveFailure = 0; discardFailure = 0;
        fieldFailure = false;
    }
    function createField(name, id, type, options) {
        if (fieldFailure) { throw new Lang.InvalidValueException("Cannot create FIT field"); }
        var field = new FitTestField(id, type, options);
        fields.add(field);
        return field;
    }
    function field(id) {
        for (var i = 0; i < fields.size(); i += 1) {
            if (fields[i].id == id) { return fields[i]; }
        }
        return null;
    }
    function start() {
        starts += 1;
        if (startFailure == 2) { throw new Lang.InvalidValueException("Cannot start FIT"); }
        if (startFailure == 1) { return false; }
        recording = true;
        return true;
    }
    function stop() {
        stops += 1;
        if (stopFailure == 2) { throw new Lang.InvalidValueException("Cannot stop FIT"); }
        if (stopFailure == 1) { return false; }
        recording = false;
        return true;
    }
    function isRecording() { return recording; }
    function save() {
        Test.assert(!recording);
        saves += 1;
        if (saveFailure == 2) { throw new Lang.InvalidValueException("Cannot save FIT"); }
        return saveFailure == 0;
    }
    function discard() {
        discards += 1;
        if (discardFailure == 2) { throw new Lang.InvalidValueException("Cannot discard FIT"); }
        return discardFailure == 0;
    }
    function addLap() { laps += 1; return true; }
}

(:debug)
class FitTestPointDelegate extends PointMatchStartInputDelegate {
    var left;
    var historyFailure;
    function initialize(view) {
        PointMatchStartInputDelegate.initialize(view);
        left = false; historyFailure = 0;
    }
    function vibrate(duration) {}
    function leaveMatch() { left = true; }
    function writeHistory() {
        if (historyFailure == 1) { return false; }
        if (historyFailure == 2) { throw new Lang.InvalidValueException("Cannot save history"); }
        return PointMatchStartInputDelegate.writeHistory();
    }
}

(:test)
function pointFitFieldsPreserveAllSettingsAndLargePointsWithoutSets(logger) {
    for (var mode = 0; mode < 2; mode += 1) {
        for (var rule = 0; rule < 2; rule += 1) {
            for (var team = 0; team < 2; team += 1) {
                var engine = new PointMatchEngine(mode, rule, 999, team);
                engine.restoreState(rule == 0 ? [998, 1] : [998, 999]);
                var session = new FitTestSession();
                Test.assert(PadelActivityRecorder.startWithSession(engine, session));
                Test.assertEqual(11, session.fields.size());
                Test.assertEqual(mode == 0 ? "AMERICANO" : "MEXICANO", session.field(7).value);
                Test.assertEqual(rule == 0 ? "TOTAL_POINTS" : "TEAM_TARGET", session.field(8).value);
                Test.assertEqual(999, session.field(9).value);
                Test.assertEqual(team, session.field(10).value);
                Test.assertEqual(998, session.field(11).value);
                Test.assertEqual(rule == 0 ? 1 : 999, session.field(12).value);
                Test.assertEqual(998, session.field(13).value);
                Test.assertEqual(rule == 0 ? 1 : 999, session.field(14).value);
                Test.assertEqual(FitContributor.DATA_TYPE_UINT32, session.field(13).type);
                Test.assertEqual(FitContributor.MESG_TYPE_RECORD, session.field(11).options[:mesgType]);
                Test.assertEqual(FitContributor.MESG_TYPE_SESSION, session.field(13).options[:mesgType]);
                Test.assertEqual(0, session.field(0).value);
                Test.assertEqual(0, session.field(15).value);
                for (var id = 1; id <= 6; id += 1) {
                    if (id != 5) { Test.assert(session.field(id) == null); }
                }
                Test.assert(!session.recording);
                Test.assert(PadelActivityRecorder.finish(engine, true, false));
                Test.assertEqual(0, session.laps);
                Test.assertEqual(1, session.saves);
                Test.assert(PadelActivityRecorder._session == null);
            }
        }
    }
    return true;
}

(:test)
function pointFitWinningPointUndoAndDrawUpdateResultAndTimer(logger) {
    var engine = new PointMatchEngine(0, 0, 2, 1);
    var session = new FitTestSession();
    Test.assert(PadelActivityRecorder.startWithSession(engine, session));
    engine.awardPoint(0); PadelActivityRecorder.recordPoint(0, engine);
    engine.awardPoint(1); PadelActivityRecorder.recordPoint(1, engine);
    Test.assertEqual("Draw", session.field(5).value);
    Test.assert(!session.recording);
    Test.assertEqual(2, session.field(15).value);
    engine.undoLastPoint(); PadelActivityRecorder.recordUndo(engine);
    Test.assert(PadelActivityRecorder.resume());
    Test.assertEqual("-", session.field(5).value);
    Test.assertEqual(0, session.field(14).value);
    Test.assertEqual(PadelActivityRecorder.EVENT_UNDO, session.field(0).value);
    Test.assertEqual(3, session.field(15).value);
    engine.awardPoint(0); PadelActivityRecorder.recordPoint(0, engine);
    Test.assertEqual("My team", session.field(5).value);
    Test.assertEqual(2, session.field(13).value);
    Test.assertEqual(4, session.field(15).value);
    Test.assert(!session.recording);
    Test.assert(PadelActivityRecorder.finish(engine, true, false));
    Test.assertEqual(0, session.laps);
    return true;
}

(:test)
function pointFitLiveButtonsRejectDuplicatePointsAndPauseScoring(logger) {
    var engine = new PointMatchEngine(1, 1, 24, 0);
    var view = new PointMatchStartView(engine);
    var session = new FitTestSession();
    PadelActivityRecorder.startWithSession(engine, session);
    var delegate = new FitTestPointDelegate(view);
    delegate.handleKey(WatchUi.KEY_DOWN);
    delegate.handleKey(WatchUi.KEY_UP);
    Test.assertEqual(1, session.field(15).value);
    Test.assertEqual(1, session.field(13).value);
    Test.assertEqual(0, session.field(14).value);
    delegate.handleKey(WatchUi.KEY_ESC);
    Test.assertEqual(2, session.field(15).value);
    delegate.handleKey(WatchUi.KEY_UP);
    Test.assertEqual(3, session.field(15).value);
    delegate.handleKey(WatchUi.KEY_ENTER);
    Test.assert(view._session.isPaused() && !session.recording);
    delegate.handleKey(WatchUi.KEY_DOWN);
    delegate.handleKey(WatchUi.KEY_UP);
    Test.assertEqual(3, session.field(15).value);
    delegate.handleKey(WatchUi.KEY_ESC);
    Test.assert(!view._session.isPaused() && session.recording);
    Test.assert(delegate.onTap(null) && delegate.onSwipe(null));
    Test.assertEqual(3, session.field(15).value);
    Test.assert(PadelActivityRecorder.finish(engine, false, false));
    return true;
}

(:test)
function pointFitSaveFailuresKeepActiveHistoryAndSessionRetryable(logger) {
    Storage.deleteValue(MatchHistoryStore.HISTORY_KEY);
    for (var complete = 0; complete < 2; complete += 1) {
        var engine = new PointMatchEngine(complete, 0, 2, 1);
        engine.restoreState(complete == 0 ? [1, 0] : [1, 1]);
        var view = new PointMatchStartView(engine);
        view.restoreSavedTime(12345);
        ActiveMatchSession.attach(engine, view);
        var session = new FitTestSession();
        PadelActivityRecorder.startWithSession(engine, session);
        PadelActivityRecorder.pause();
        var delegate = new FitTestPointDelegate(view);
        view.showSaveConfirm(); view._saveYes = true;
        for (var failure = 1; failure <= 2; failure += 1) {
            session.saveFailure = failure;
            delegate.handleKey(WatchUi.KEY_ENTER);
            Test.assert(!delegate.left && !view._activitySaved);
            Test.assert(view._saveConfirm && view._saveYes && view._saveError);
            Test.assert(captureHistoryText(view).hasText("ACTIVITY SAVE FAILED"));
            Test.assertEqual(complete, MatchHistoryStore.load().size());
            Test.assertEqual(12345, ActiveMatchStore.load()[1]);
            Test.assert(PadelActivityRecorder.isAttached(engine));
            Test.assert(!session.recording);
        }
        session.saveFailure = 0;
        delegate.handleKey(WatchUi.KEY_ENTER);
        Test.assert(delegate.left && view._activitySaved);
        Test.assert(PadelActivityRecorder._session == null && ActiveMatchStore.load() == null);
        Test.assertEqual(3, session.saves);
        Test.assertEqual(complete == 0 ? "Stopped" : "Draw", session.field(5).value);
        Test.assertEqual(complete + 1, MatchHistoryStore.load().size());
        delegate.handleKey(WatchUi.KEY_ENTER);
        Test.assertEqual(3, session.saves);
    }
    Storage.deleteValue(MatchHistoryStore.HISTORY_KEY);
    return true;
}

(:test)
function pointFitHistoryFailureSurvivesRestartWithoutSavingAnotherFit(logger) {
    Storage.deleteValue(MatchHistoryStore.HISTORY_KEY);
    for (var complete = 0; complete < 2; complete += 1) {
        var engine = new PointMatchEngine(complete, 0, 2, 1);
        engine.restoreState(complete == 0 ? [1, 0] : [1, 1]);
        var view = new PointMatchStartView(engine);
        view.restoreSavedTime(9876);
        ActiveMatchSession.attach(engine, view);
        var session = new FitTestSession();
        PadelActivityRecorder.startWithSession(engine, session);
        var delegate = new FitTestPointDelegate(view);
        view.showSaveConfirm(); view._saveYes = true;
        delegate.historyFailure = 1;
        delegate.handleKey(WatchUi.KEY_ENTER);
        Test.assertEqual(1, session.saves);
        Test.assert(view._activitySaved && !delegate.left);
        Test.assertEqual(5, Storage.getValue(ActiveMatchStore.ACTIVE_KEY)[0]);
        delegate.handleKey(WatchUi.KEY_UP);
        delegate.handleKey(WatchUi.KEY_DOWN);
        delegate.handleKey(WatchUi.KEY_ESC);
        Test.assert(view._saveConfirm && view._saveYes);
        Test.assertEqual(1, pointScore(engine, 0));
        Test.assert(!delegate.discardMatch());
        delegate.historyFailure = 2;
        delegate.handleKey(WatchUi.KEY_ENTER);
        Test.assertEqual(1, session.saves);
        Test.assertEqual(complete, MatchHistoryStore.load().size());
        new PadelApp().onStop(null);
        Test.assertEqual(1, session.saves);
        var initial = new PadelApp().getInitialView();
        var pending = initial[0] as PointMatchStartView;
        Test.assert(pending._recovered && pending._activitySaved && pending._saveConfirm);
        Test.assertEqual(9876, pending.getElapsedMilliseconds());
        Test.assert(PadelActivityRecorder._session == null);
        Test.assert(captureHistoryText(pending).hasText("FINISH SAVE"));
        var retry = new FitTestPointDelegate(pending);
        retry.handleKey(WatchUi.KEY_ENTER);
        Test.assert(retry.left && ActiveMatchStore.load() == null);
        Test.assertEqual(1, session.saves);
        Test.assertEqual(complete + 1, MatchHistoryStore.load().size());
        Test.assertEqual(9, MatchHistoryStore.getDurationSeconds(MatchHistoryStore.load()[complete]));
    }
    Storage.deleteValue(MatchHistoryStore.HISTORY_KEY);
    return true;
}

(:test)
function pointFitDiscardFailuresPreserveActiveAndRetryWithoutHistory(logger) {
    Storage.deleteValue(MatchHistoryStore.HISTORY_KEY);
    var engine = new PointMatchEngine(1, 1, 999, 0);
    engine.restoreState([998, 997]);
    var view = new PointMatchStartView(engine);
    view.restoreSavedTime(12345);
    ActiveMatchSession.attach(engine, view);
    var session = new FitTestSession();
    PadelActivityRecorder.startWithSession(engine, session);
    var delegate = new FitTestPointDelegate(view);
    view.showDiscardConfirm(); view._discardYes = true;
    for (var failure = 1; failure <= 2; failure += 1) {
        session.discardFailure = failure;
        delegate.handleKey(WatchUi.KEY_ENTER);
        Test.assert(!delegate.left && view._discardConfirm && view._discardError);
        Test.assert(PadelActivityRecorder.isAttached(engine));
        Test.assert(ActiveMatchStore.load() != null);
        Test.assert(captureHistoryText(view).hasText("DISCARD FAILED"));
    }
    session.discardFailure = 0;
    delegate.handleKey(WatchUi.KEY_ENTER);
    Test.assert(delegate.left && ActiveMatchStore.load() == null);
    Test.assert(PadelActivityRecorder._session == null);
    Test.assertEqual(3, session.discards);
    Test.assertEqual(0, session.saves);
    Test.assertEqual(0, MatchHistoryStore.load().size());
    view.onHide(); new PadelApp().onStop(null);
    Test.assert(ActiveMatchStore.load() == null);
    return true;
}

(:test)
function pointFitAppStopAndNewSegmentPreserveScoreWithoutReplay(logger) {
    Storage.deleteValue(MatchHistoryStore.HISTORY_KEY);
    for (var mode = 0; mode < 2; mode += 1) {
        for (var rule = 0; rule < 2; rule += 1) {
            for (var team = 0; team < 2; team += 1) {
                var engine = new PointMatchEngine(mode, rule, 999, team);
                engine.restoreState([9, 7]);
                var view = new PointMatchStartView(engine);
                view.restoreSavedTime(12345);
                ActiveMatchSession.attach(engine, view);
                var first = new FitTestSession();
                PadelActivityRecorder.startWithSession(engine, first);
                new PadelApp().onStop(null);
                Test.assertEqual(1, first.saves);
                Test.assertEqual("Interrupted", first.field(5).value);
                Test.assertEqual(0, MatchHistoryStore.load().size());
                Test.assert(PadelActivityRecorder._session == null);
                var loaded = ActiveMatchStore.load();
                Test.assertEqual(12345, loaded[1]);
                var resumed = new RecoveryInputDelegate(new RecoveryView(loaded)).createResumedView();
                ActiveMatchSession.attach(loaded[0], resumed);
                var second = new FitTestSession();
                PadelActivityRecorder.startWithSession(loaded[0], second);
                Test.assert(resumed.startActivity());
                Test.assert(!second.recording && resumed._session.isPaused());
                Test.assertEqual(9, second.field(13).value);
                Test.assertEqual(7, second.field(14).value);
                Test.assertEqual(0, second.field(0).value);
                Test.assertEqual(0, second.field(15).value);
                var delegate = new FitTestPointDelegate(resumed);
                delegate.handleKey(WatchUi.KEY_DOWN);
                delegate.handleKey(WatchUi.KEY_UP);
                Test.assertEqual(0, second.field(15).value);
                delegate.handleKey(WatchUi.KEY_ESC);
                Test.assert(second.recording);
                delegate.handleKey(WatchUi.KEY_DOWN);
                Test.assertEqual(10, second.field(13).value);
                Test.assertEqual(1, second.field(15).value);
                Test.assert(PadelActivityRecorder.finish(loaded[0], false, false));
                Test.assertEqual(0, second.laps);
                ActiveMatchSession.clear();
            }
        }
    }
    return true;
}

(:test)
function pointFitCompletedAppStopKeepsDrawAndPausedTime(logger) {
    var engine = new PointMatchEngine(0, 0, 24, 1);
    engine.restoreState([12, 12]);
    var view = new PointMatchStartView(engine);
    view.restoreSavedTime(12345);
    ActiveMatchSession.attach(engine, view);
    var session = new FitTestSession();
    PadelActivityRecorder.startWithSession(engine, session);
    Test.assert(!session.recording);
    new PadelApp().onStop(null);
    Test.assertEqual(1, session.saves);
    Test.assertEqual("Draw", session.field(5).value);
    Test.assertEqual(PointMatchResult.DRAW, ActiveMatchStore.load()[0].getResult());
    Test.assertEqual(12345, ActiveMatchStore.load()[1]);
    ActiveMatchSession.clear();
    return true;
}

(:test)
function pointFitAppStopSavesEvenWhenClosingTimerCannotRestart(logger) {
    var engine = new PointMatchEngine(0, 0, 24, 1);
    engine.restoreState([9, 7]);
    var session = new FitTestSession();
    Test.assert(PadelActivityRecorder.startWithSession(engine, session));
    Test.assert(PadelActivityRecorder.pause());
    session.startFailure = 1;
    PadelActivityRecorder.handleAppStop();
    Test.assertEqual(1, session.saves);
    Test.assertEqual("Interrupted", session.field(5).value);
    Test.assert(PadelActivityRecorder._session == null);
    return true;
}

(:test)
function pointFitStartAndPauseFailuresRemainRetryable(logger) {
    for (var failure = 1; failure <= 3; failure += 1) {
        var engine = new PointMatchEngine(0, 1, 24, 0);
        var failed = new FitTestSession();
        failed.startFailure = failure < 3 ? failure : 0;
        failed.fieldFailure = failure == 3;
        Test.assert(!PadelActivityRecorder.startWithSession(engine, failed));
        if (failure == 1) {
            Test.assert(PadelActivityRecorder.isAttached(engine));
            Test.assertEqual(0, failed.discards);
            failed.startFailure = 0;
            Test.assert(PadelActivityRecorder.start(engine));
            Test.assertEqual(2, failed.starts);
            Test.assert(PadelActivityRecorder.finish(engine, false, false));
        } else {
            Test.assert(PadelActivityRecorder._session == null);
            Test.assertEqual(1, failed.discards);
        }
    }
    var engine = new PointMatchEngine(1, 1, 24, 0);
    var view = new PointMatchStartView(engine);
    view.restoreSavedTime(1000);
    var session = new FitTestSession();
    PadelActivityRecorder.startWithSession(engine, session);
    PadelActivityRecorder.pause();
    var delegate = new FitTestPointDelegate(view);
    session.startFailure = 1;
    delegate.handleKey(WatchUi.KEY_ENTER);
    Test.assert(view._session.isPaused() && view._activityStartFailed && !session.recording);
    session.startFailure = 0;
    delegate.handleKey(WatchUi.KEY_ENTER);
    Test.assert(!view._activityStartFailed && view._session.isPaused());
    delegate.handleKey(WatchUi.KEY_ENTER);
    Test.assert(!view._session.isPaused() && session.recording);
    session.stopFailure = 1;
    delegate.handleKey(WatchUi.KEY_ENTER);
    Test.assert(view._session.isPaused() && view._activityStartFailed);
    session.stopFailure = 0;
    delegate.handleKey(WatchUi.KEY_ENTER);
    Test.assert(!view._activityStartFailed && !session.recording);
    Test.assert(PadelActivityRecorder.finish(engine, false, false));
    return true;
}

(:test)
function pointFitRecorderRejectsDifferentMatchOwnership(logger) {
    var engine = new PointMatchEngine(0, 1, 999, 0);
    var other = new PointMatchEngine(1, 0, 24, 1);
    var session = new FitTestSession();
    Test.assert(PadelActivityRecorder.startWithSession(engine, session));
    Test.assert(PadelActivityRecorder.start(engine));
    Test.assertEqual(1, session.starts);
    Test.assert(!PadelActivityRecorder.start(other));
    other.awardPoint(0);
    PadelActivityRecorder.recordPoint(0, other);
    PadelActivityRecorder.recordUndo(other);
    Test.assert(!PadelActivityRecorder.finish(other, true, true));
    Test.assertEqual(0, session.field(15).value);
    Test.assertEqual(0, session.saves);
    Test.assert(PadelActivityRecorder.finish(engine, false, false));
    return true;
}

(:test)
function pointFitFinalizingSchemaValidatesAndKeepsOldActiveVersions(logger) {
    var config = [0, 0, 24, 1];
    var invalid = [[5], [5, 0, config, [1, 1]], [5, 0, config, [1, 1], false],
        [5, 0, config, [1, 1], 1], [5, 0, config, [1, 1], "true"],
        [5, 0, config, [13, 12], true], [5, -1, config, [1, 1], true],
        [5, 0, config, [1, 1], true, true]];
    for (var i = 0; i < invalid.size(); i += 1) {
        Storage.setValue(ActiveMatchStore.ACTIVE_KEY, invalid[i]);
        Test.assert(ActiveMatchStore.load() == null);
    }
    Storage.setValue(ActiveMatchStore.ACTIVE_KEY, [4, 12345, config, [1, 1]]);
    var old = ActiveMatchStore.load();
    Test.assertEqual(3, old.size());
    Test.assertEqual(12345, old[1]);
    Storage.setValue(ActiveMatchStore.ACTIVE_KEY, [5, 12345, config, [1, 1], true]);
    var pending = ActiveMatchStore.load();
    Test.assertEqual(4, pending.size());
    Test.assert(pending[3]);
    Test.assertEqual(1, pointScore(pending[0], 0));
    ActiveMatchSession.clear();
    return true;
}

(:test)
function pointFitErrorAndFinalizingLayoutsFitBothDisplays(logger) {
    var engine = new PointMatchEngine(1, 1, 999, 1);
    var view = new PointMatchStartView(engine);
    view.restoreSavedTime(360000123);
    for (var size = 280; size <= 416; size += 136) {
        view._saveConfirm = false;
        view._discardConfirm = false;
        view._activityStartFailed = true;
        assertLayoutBounds(view, size);
        Test.assert(captureHistoryText(view).hasText("ACTIVITY ERROR"));
        view._activityStartFailed = false;
        view.showDiscardConfirm(); view._discardError = true;
        assertLayoutBounds(view, size);
        view.showSaveConfirm(); view._saveYes = true;
        view._saveError = true; view._saveErrorMessage = "ACTIVITY SAVE FAILED";
        assertLayoutBounds(view, size);
        view._activitySaved = true;
        view._saveErrorMessage = "HISTORY SAVE FAILED";
        assertLayoutBounds(view, size);
        var dc = captureHistoryText(view);
        Test.assert(dc.hasText("FINISH SAVE") && dc.hasText("RETRY SAVE"));
        Test.assert(!dc.hasText("BACK: CANCEL"));
        view._activitySaved = false;
    }
    return true;
}
