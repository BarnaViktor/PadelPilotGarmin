using Toybox.Graphics as Graphics;
using Toybox.Lang as Lang;
using Toybox.System as System;
using Toybox.Timer as Timer;
using Toybox.WatchUi as WatchUi;

// Live point match with active recovery. History/FIT belong to later units.
class PointMatchStartView extends WatchUi.View {
    var _engine as PointMatchEngine;
    var _session as PointMatchSession;
    var _pauseSelection;
    var _discardConfirm;
    var _discardYes;
    var _clockTimer;
    var _visible;
    var _clockTimerRunning;
    var _recovered;

    function initialize(engine) {
        View.initialize();
        _engine = engine;
        _session = new PointMatchSession(engine, System.getTimer());
        _pauseSelection = 0;
        _discardConfirm = false;
        _discardYes = false;
        _clockTimer = new Timer.Timer();
        _visible = false;
        _clockTimerRunning = false;
        _recovered = false;
    }

    function restoreSavedTime(elapsedMs) {
        if (!_session.restoreElapsedMilliseconds(elapsedMs)) {
            return false;
        }
        _recovered = true;
        syncClockTimer();
        return true;
    }

    function onShow() {
        _visible = true;
        syncClockTimer();
    }

    function onHide() {
        persist();
        _visible = false;
        syncClockTimer();
    }

    function syncClockTimer() {
        var shouldRun = _visible && !_session.isPaused() && !_engine.isComplete();
        if (shouldRun && !_clockTimerRunning) {
            _clockTimer.start(method(:onClockTimer), 1000, true);
            _clockTimerRunning = true;
        } else if (!shouldRun && _clockTimerRunning) {
            _clockTimer.stop();
            _clockTimerRunning = false;
        }
    }

    function onClockTimer() {
        if (!_session.isPaused() && !_engine.isComplete()) {
            WatchUi.requestUpdate();
        }
    }

    function setPaused(paused) {
        _session.setPaused(paused, System.getTimer());
        _pauseSelection = 0;
        _discardConfirm = false;
        syncClockTimer();
        persist();
    }

    function showDiscardConfirm() {
        _discardConfirm = true;
        _discardYes = false;
    }

    function onUpdate(dc) {
        dc = PadelTheme.canvas(dc);
        PadelTheme.clear(dc);
        if (_discardConfirm) {
            drawDiscardConfirm(dc);
        } else if (_engine.isComplete()) {
            drawMatch(dc, true);
        } else if (_session.isPaused()) {
            drawPause(dc);
        } else {
            drawMatch(dc, false);
        }
    }

    function drawMatch(dc, completed) {
        var clock = System.getClockTime();
        dc.setColor(PadelTheme.WHITE, Graphics.COLOR_BLACK);
        dc.drawText(208, 8, Graphics.FONT_XTINY,
            padTwo(clock.hour) + ":" + padTwo(clock.min), Graphics.TEXT_JUSTIFY_CENTER);
        PadelTheme.drawHeader(dc, _engine.getMode() == PointMatchMode.AMERICANO
            ? "AMERICANO" : "MEXICANO");
        var rule = _engine.getEndRule() == PointMatchEndRule.TOTAL_POINTS
            ? "TOTAL POINTS: " : "TEAM TARGET: ";
        dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
        dc.drawText(208, 112, Graphics.FONT_XTINY, rule + _engine.getTarget(),
            Graphics.TEXT_JUSTIFY_CENTER);
        if (completed) {
            var result = _engine.getResult();
            dc.setColor(result == PointMatchResult.WIN ? PadelTheme.CYAN
                : (result == PointMatchResult.LOSS ? PadelTheme.RED : PadelTheme.LIME),
                Graphics.COLOR_BLACK);
            dc.drawText(208, 150, Graphics.FONT_XTINY,
                result == PointMatchResult.WIN ? "WIN"
                    : (result == PointMatchResult.LOSS ? "LOSS" : "DRAW"),
                Graphics.TEXT_JUSTIFY_CENTER);
        }
        dc.setColor(PadelTheme.CYAN, Graphics.COLOR_BLACK);
        dc.drawText(116, 188, Graphics.FONT_XTINY, "MY TEAM",
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(PadelTheme.RED, Graphics.COLOR_BLACK);
        dc.drawText(300, 188, Graphics.FONT_XTINY, "OPPONENT",
            Graphics.TEXT_JUSTIFY_CENTER);
        var points = _engine.getPoints() as Lang.Array<Lang.Number>;
        dc.setColor(PadelTheme.CYAN, Graphics.COLOR_BLACK);
        dc.drawText(116, 220, Graphics.FONT_MEDIUM, points[0].toString(),
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(PadelTheme.RED, Graphics.COLOR_BLACK);
        dc.drawText(300, 220, Graphics.FONT_MEDIUM, points[1].toString(),
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
        dc.drawText(208, 278, Graphics.FONT_XTINY,
            "1ST SERVE: " + (_engine.getStartingServerTeam() == 0 ? "A" : "B"),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(PadelTheme.WHITE, Graphics.COLOR_BLACK);
        dc.drawText(208, 310, Graphics.FONT_XTINY, durationLabel(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        drawHelp(dc, completed ? "START: DISCARD" : "START: PAUSE", "BACK: UNDO");
    }

    function drawPause(dc) {
        PadelTheme.drawHeader(dc, "PAUSED");
        PadelTheme.drawActionButton(dc, 63, 118, 290, 56, _pauseSelection == 0,
            "RESUME");
        PadelTheme.drawActionButton(dc, 63, 190, 290, 56, _pauseSelection == 1,
            "DISCARD MATCH");
        dc.setColor(PadelTheme.WHITE, Graphics.COLOR_BLACK);
        dc.drawText(208, 284, Graphics.FONT_XTINY, durationLabel(),
            Graphics.TEXT_JUSTIFY_CENTER);
        drawHelp(dc, "START: SELECT", "BACK: RESUME");
    }

    function drawDiscardConfirm(dc) {
        PadelTheme.drawHeader(dc, "DISCARD MATCH?");
        PadelTheme.drawActionButton(dc, 42, 174, 156, 68, _discardYes, "YES");
        PadelTheme.drawActionButton(dc, 218, 174, 156, 68, !_discardYes, "NO");
        drawHelp(dc, "START: SELECT", "BACK: CANCEL");
    }

    function drawHelp(dc, first, second) {
        dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
        dc.drawText(208, 338, Graphics.FONT_XTINY, first,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(208, 366, Graphics.FONT_XTINY, second,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function getDurationSeconds() {
        return _session.getDurationSeconds(System.getTimer());
    }

    function getElapsedMilliseconds() {
        return _session.getElapsedMilliseconds(System.getTimer());
    }

    function persist() {
        ActiveMatchSession.persistIfAttached(self);
    }

    function durationLabel() {
        var seconds = getDurationSeconds();
        return padTwo((seconds / 3600).toNumber()) + ":"
            + padTwo(((seconds % 3600) / 60).toNumber()) + ":" + padTwo(seconds % 60);
    }

    function padTwo(value) {
        return value < 10 ? "0" + value : value.toString();
    }
}
