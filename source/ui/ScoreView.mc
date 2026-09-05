using Toybox.Graphics as Graphics;
using Toybox.System as System;
using Toybox.Timer as Timer;
using Toybox.WatchUi as WatchUi;

class ScoreView extends WatchUi.View {
    const PAUSE_ACTION_NONE = 0;
    const PAUSE_ACTION_SAVE = 1;
    const PAUSE_ACTION_DISCARD = 2;

    var _engine;
    var _paused;
    var _pausedAt;
    var _startedAt;
    var _finishedAt;
    var _summaryPage;
    var _finishMenu;
    var _pauseMenuIndex;
    var _pauseDecisionAction;
    var _pauseServerPicker;
    var _serverPickerIndex;
    var _decisionIndex;
    var _setEndTimes;
    var _clockTimer;
    var _lastClockMinute;
    var _visible;
    var _clockTimerRunning;

    function initialize(engine, elapsedSeconds, setEndTimes) {
        View.initialize();
        _engine = engine;
        _paused = false;
        _pausedAt = null;
        _startedAt = System.getTimer() - (elapsedSeconds * 1000);
        _finishedAt = null;
        _summaryPage = 0;
        _finishMenu = false;
        _pauseMenuIndex = 0;
        _pauseDecisionAction = PAUSE_ACTION_NONE;
        _pauseServerPicker = false;
        _serverPickerIndex = 0;
        _decisionIndex = 0;
        _setEndTimes = setEndTimes.slice(0, setEndTimes.size());
        _clockTimer = new Timer.Timer();
        _lastClockMinute = -1;
        _visible = false;
        _clockTimerRunning = false;
    }

    function onShow() {
        _visible = true;
        syncClockTimer();
    }

    function onHide() {
        _visible = false;
        syncClockTimer();
    }

    function syncClockTimer() {
        var shouldRun = _visible && !_paused
            && _engine.getMatchWinner() == null;
        if (shouldRun && !_clockTimerRunning) {
            _clockTimer.start(method(:onClockTimer), 1000, true);
            _clockTimerRunning = true;
        } else if (!shouldRun && _clockTimerRunning) {
            _clockTimer.stop();
            _clockTimerRunning = false;
        }
    }

    function onClockTimer() {
        if (_paused || _engine.getMatchWinner() != null) {
            return;
        }

        var clock = System.getClockTime();
        var minute = clock.hour * 60 + clock.min;
        if (minute != _lastClockMinute) {
            _lastClockMinute = minute;
            WatchUi.requestUpdate();
        }
    }

    function onUpdate(dc) {
        PadelTheme.clear(dc);

        var centerX = dc.getWidth() / 2;
        if (_engine.getMatchWinner() != null) {
            if (_finishedAt == null) {
                _finishedAt = System.getTimer();
            }
            if (_finishMenu) {
                drawFinishMenu(dc, centerX);
            } else {
                drawSummary(dc, centerX);
            }
            return;
        }
        if (_paused) {
            drawPause(dc, centerX);
            return;
        }

        drawScoreTable(dc, centerX);
    }

    function drawScoreTable(dc, centerX) {
        drawClock(dc, centerX);
        drawSetStrip(dc, centerX);

        dc.setColor(PadelTheme.LINE, Graphics.COLOR_BLACK);
        dc.setPenWidth(2);
        dc.drawLine(centerX, 82, centerX, 256);
        dc.setPenWidth(1);
        dc.fillCircle(centerX, 183, 5);

        dc.setColor(PadelTheme.CYAN, Graphics.COLOR_BLACK);
        dc.drawText(112, 118, Graphics.FONT_SMALL, _engine.pointLabel(0),
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(PadelTheme.RED, Graphics.COLOR_BLACK);
        dc.drawText(304, 118, Graphics.FONT_SMALL, _engine.pointLabel(1),
            Graphics.TEXT_JUSTIFY_CENTER);

        drawTeamLabel(dc, 112, 211, 0, "A");
        drawTeamLabel(dc, 304, 211, 1, "B");

        dc.setColor(PadelTheme.WHITE, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 266, Graphics.FONT_XTINY,
            "SET " + (_engine.getSets()[0] + _engine.getSets()[1] + 1)
            + "  •  " + _engine.getGames()[0] + "–" + _engine.getGames()[1] + " GAMES",
            Graphics.TEXT_JUSTIFY_CENTER);
        drawServeIndicator(dc, centerX, 308);
    }

    function drawClock(dc, centerX) {
        var clock = System.getClockTime();
        _lastClockMinute = clock.hour * 60 + clock.min;
        dc.setColor(PadelTheme.WHITE, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 8, Graphics.FONT_XTINY,
            padTwo(clock.hour) + ":" + padTwo(clock.min),
            Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawSetStrip(dc, centerX) {
        var sets = _engine.getCompletedSets();
        var startX = centerX - ((sets.size() - 1) * 34);
        if (sets.size() == 0) {
            return;
        }
        for (var i = 0; i < sets.size(); i += 1) {
            dc.setColor(PadelTheme.CYAN, Graphics.COLOR_BLACK);
            dc.drawText(startX + i * 68 - 24, 45, Graphics.FONT_XTINY,
                sets[i][0], Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
            dc.drawText(startX + i * 68, 45, Graphics.FONT_XTINY, "–",
                Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(PadelTheme.RED, Graphics.COLOR_BLACK);
            dc.drawText(startX + i * 68 + 24, 45, Graphics.FONT_XTINY,
                sets[i][1], Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    function drawTeamLabel(dc, x, y, team, label) {
        var color = team == 0 ? PadelTheme.CYAN : PadelTheme.RED;
        if (_engine.getServerTeam() == team) {
            PadelTheme.drawTennisBall(dc, x - 44, y + 10, 10);
        }
        dc.setColor(color, Graphics.COLOR_BLACK);
        dc.drawText(x, y + 10, Graphics.FONT_XTINY, label,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawServeIndicator(dc, centerX, y) {
        var team = _engine.getServerTeam();
        var side = _engine.getServeSide();
        var left = centerX - 80;
        var top = y + 12;

        dc.setColor(PadelTheme.CYAN, Graphics.COLOR_BLACK);
        dc.setPenWidth(2);
        dc.drawLine(left, top, centerX, top);
        dc.drawLine(left, top, left, top + 52);
        dc.drawLine(left, top + 52, centerX, top + 52);
        dc.setColor(PadelTheme.RED, Graphics.COLOR_BLACK);
        dc.drawLine(centerX, top, centerX + 80, top);
        dc.drawLine(centerX + 80, top, centerX + 80, top + 52);
        dc.drawLine(centerX, top + 52, centerX + 80, top + 52);
        dc.setColor(PadelTheme.LINE, Graphics.COLOR_BLACK);
        dc.drawLine(centerX, top, centerX, top + 52);
        dc.drawLine(left, top + 26, centerX + 80, top + 26);
        dc.setPenWidth(1);

        var markerX = team == 0 ? centerX - 40 : centerX + 40;
        var markerIsLower = (team == 0 && side == 0)
            || (team == 1 && side == 1);
        var markerY = markerIsLower ? top + 39 : top + 13;
        PadelTheme.drawTennisBall(dc, markerX, markerY, 8);
    }

    function completeMatch() {
        syncSetEndTimes();
        if (_finishedAt == null) {
            _finishedAt = System.getTimer();
        }
        _summaryPage = 0;
        _finishMenu = false;
        syncClockTimer();
    }

    function resumeMatchAfterUndo() {
        syncSetEndTimes();
        _finishedAt = null;
        _summaryPage = 0;
        _finishMenu = false;
        syncClockTimer();
    }

    function changeSummaryPage(delta) {
        var pageCount = _engine.getCompletedSets().size() + 1;
        _summaryPage = (_summaryPage + delta + pageCount) % pageCount;
    }

    function setFinishMenu(visible) {
        _finishMenu = visible;
        if (visible) {
            _decisionIndex = 0;
        }
    }

    function isFinishMenu() {
        return _finishMenu;
    }

    function drawSummary(dc, centerX) {
        if (_summaryPage == 0) {
            drawMatchSummary(dc, centerX);
        } else {
            drawSetSummary(dc, centerX, _summaryPage - 1);
        }
        drawPageDots(dc, centerX);
    }

    function drawMatchSummary(dc, centerX) {
        var winner = _engine.getMatchWinner();
        var winnerColor = winner == 0 ? PadelTheme.CYAN : PadelTheme.RED;
        PadelTheme.drawHeader(dc, "MATCH OVER");
        dc.setColor(winnerColor, Graphics.COLOR_BLACK);
        dc.setPenWidth(4);
        dc.drawLine(centerX - 36, 104, centerX + 36, 104);
        dc.setPenWidth(1);
        drawCompletedSetScores(dc, centerX, 138);
        dc.setColor(PadelTheme.LINE, Graphics.COLOR_BLACK);
        dc.drawLine(82, 210, 334, 210);
        dc.setColor(PadelTheme.WHITE, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 237, Graphics.FONT_XTINY, durationLabel(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        PadelTheme.drawActionButton(dc, 106, 294, 204, 50, true, "SAVE");
    }

    function drawSetSummary(dc, centerX, setIndex) {
        var completedSet = _engine.getCompletedSets()[setIndex];
        PadelTheme.drawHeader(dc, completedSet[2] ? "MATCH TIE-BREAK" : "SET " + (setIndex + 1));
        dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
        dc.drawText(
            centerX,
            94,
            Graphics.FONT_XTINY,
            "SET RESULT",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        drawSummaryScore(dc, centerX, completedSet[1], completedSet[0]);
        dc.setColor(PadelTheme.WHITE, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 237, Graphics.FONT_XTINY,
            setDurationLabel(setIndex),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawSummaryScore(dc, centerX, opponentScore, myScore) {
        dc.setColor(PadelTheme.RED, Graphics.COLOR_BLACK);
        dc.drawText(258, 166, Graphics.FONT_TINY, opponentScore, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 166, Graphics.FONT_TINY, ":", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(PadelTheme.CYAN, Graphics.COLOR_BLACK);
        dc.drawText(158, 166, Graphics.FONT_TINY, myScore, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawCompletedSetScores(dc, centerX, y) {
        var sets = _engine.getCompletedSets();
        var firstX = centerX - ((sets.size() - 1) * 36);
        for (var i = 0; i < sets.size(); i += 1) {
            dc.setColor(sets[i][0] > sets[i][1]
                ? PadelTheme.CYAN : PadelTheme.RED, Graphics.COLOR_BLACK);
            dc.drawText(firstX + i * 72, y, Graphics.FONT_XTINY,
                sets[i][0] + "–" + sets[i][1], Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    function drawPageDots(dc, centerX) {
        var pageCount = _engine.getCompletedSets().size() + 1;
        var firstX = centerX - ((pageCount - 1) * 10);
        for (var page = 0; page < pageCount; page += 1) {
            dc.setColor(page == _summaryPage ? Graphics.COLOR_WHITE : Graphics.COLOR_DK_GRAY,
                Graphics.COLOR_BLACK);
            if (page == _summaryPage) {
                dc.fillCircle(firstX + page * 20, 402, 4);
            } else {
                dc.drawCircle(firstX + page * 20, 402, 4);
            }
        }
    }

    function durationLabel() {
        var endTime = currentEndTime();
        var totalSeconds = ((endTime - _startedAt) / 1000).toNumber();
        return formatDuration(totalSeconds);
    }

    function setDurationLabel(setIndex) {
        return formatDuration(getSetDurationSeconds(setIndex));
    }

    function formatDuration(totalSeconds) {
        var hours = (totalSeconds / 3600).toNumber();
        var minutes = ((totalSeconds % 3600) / 60).toNumber();
        var seconds = totalSeconds % 60;

        if (hours > 0) {
            return padTwo(hours) + ":" + padTwo(minutes) + ":" + padTwo(seconds);
        }
        return padTwo(minutes) + ":" + padTwo(seconds);
    }

    function getDurationSeconds() {
        var endTime = currentEndTime();
        return ((endTime - _startedAt) / 1000).toNumber();
    }

    function currentEndTime() {
        if (_finishedAt != null) {
            return _finishedAt;
        }
        return _pausedAt == null ? System.getTimer() : _pausedAt;
    }

    function syncSetEndTimes() {
        var completedCount = _engine.getCompletedSets().size();
        if (_setEndTimes.size() > completedCount) {
            _setEndTimes = _setEndTimes.slice(0, completedCount);
        }
        while (_setEndTimes.size() < completedCount) {
            _setEndTimes.add(getDurationSeconds());
        }
    }

    function getSetEndTimes() {
        return _setEndTimes.slice(0, _setEndTimes.size());
    }

    function getSetDurationSeconds(setIndex) {
        if (setIndex < 0 || setIndex >= _setEndTimes.size()) {
            return 0;
        }
        var previousEnd = setIndex == 0 ? 0 : _setEndTimes[setIndex - 1];
        return _setEndTimes[setIndex] - previousEnd;
    }

    function padTwo(value) {
        return value < 10 ? "0" + value : value.toString();
    }

    function setPaused(paused) {
        if (paused) {
            if (!_paused) {
                _pausedAt = System.getTimer();
            }
            _paused = true;
            _pauseMenuIndex = 0;
            _pauseDecisionAction = PAUSE_ACTION_NONE;
            _pauseServerPicker = false;
        } else {
            if (_paused && _pausedAt != null) {
                _startedAt += System.getTimer() - _pausedAt;
            }
            _pausedAt = null;
            _paused = false;
        }
        syncClockTimer();
    }

    function isPaused() {
        return _paused;
    }

    function movePauseSelection(delta) {
        _pauseMenuIndex = (_pauseMenuIndex + delta + 3) % 3;
    }

    function getPauseSelection() {
        return _pauseMenuIndex;
    }

    function setPauseDecision(action) {
        _pauseDecisionAction = action;
        _decisionIndex = action == PAUSE_ACTION_DISCARD ? 1 : 0;
    }

    function showSavePauseDecision() {
        setPauseDecision(PAUSE_ACTION_SAVE);
    }

    function showDiscardPauseDecision() {
        setPauseDecision(PAUSE_ACTION_DISCARD);
    }

    function clearPauseDecision() {
        setPauseDecision(PAUSE_ACTION_NONE);
    }

    function isPauseDecision() {
        return _pauseDecisionAction != PAUSE_ACTION_NONE;
    }

    function isSavePauseDecision() {
        return _pauseDecisionAction == PAUSE_ACTION_SAVE;
    }

    function setPauseServerPicker(visible) {
        _pauseServerPicker = visible;
        if (visible) {
            _serverPickerIndex = serverPickerIndex(
                _engine.getServerTeam(),
                _engine.getServeSide()
            );
        }
    }

    function isPauseServerPicker() {
        return _pauseServerPicker;
    }

    function moveServerPickerSelection(delta) {
        _serverPickerIndex = (_serverPickerIndex + delta + 4) % 4;
    }

    function getSelectedServerTeam() {
        return _serverPickerIndex < 2 ? 1 : 0;
    }

    function getSelectedServeSide() {
        if (_serverPickerIndex == 0 || _serverPickerIndex == 2) {
            return 0;
        }
        return 1;
    }

    function moveDecisionSelection(delta) {
        _decisionIndex = (_decisionIndex + delta + 2) % 2;
    }

    function isDecisionYes() {
        return _decisionIndex == 0;
    }

    function serverPickerIndex(team, side) {
        if (team == 1) {
            return side == 0 ? 0 : 1;
        }
        return side == 0 ? 2 : 3;
    }

    function drawPause(dc, centerX) {
        if (isPauseDecision()) {
            drawDecision(dc, centerX,
                isSavePauseDecision() ? "SAVE & END?" : "DISCARD MATCH?",
                isSavePauseDecision() ? PadelTheme.LIME : PadelTheme.RED);
            return;
        }
        if (_pauseServerPicker) {
            drawServerPicker(dc, centerX);
            return;
        }

        PadelTheme.drawHeader(dc, "PAUSED");
        drawPauseMenuRow(dc, centerX, 108, 0, "CHANGE SERVER");
        drawPauseMenuRow(dc, centerX, 180, 1, "SAVE & END");
        drawPauseMenuRow(dc, centerX, 252, 2, "DISCARD MATCH");
    }

    function drawFinishMenu(dc, centerX) {
        drawDecision(dc, centerX, "SAVE MATCH?", PadelTheme.LIME);
    }

    function drawPauseMenuRow(dc, centerX, y, index, label) {
        var selected = _pauseMenuIndex == index;
        var selectedColor = index == 0 ? PadelTheme.CYAN
            : (index == 1 ? PadelTheme.LIME : PadelTheme.RED);
        PadelTheme.drawCard(dc, 63, y, 290, 56, selected, selectedColor);
        dc.setColor(selected ? selectedColor : PadelTheme.MUTED,
            Graphics.COLOR_BLACK);
        dc.drawText(centerX, y + 28, Graphics.FONT_XTINY, label,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawServerPicker(dc, centerX) {
        var centerY = dc.getHeight() / 2;

        dc.setColor(PadelTheme.RED_DARK, Graphics.COLOR_BLACK);
        dc.fillRectangle(0, 0, dc.getWidth(), centerY);
        dc.setColor(PadelTheme.CYAN_DARK, Graphics.COLOR_BLACK);
        dc.fillRectangle(0, centerY, dc.getWidth(), centerY);

        dc.setColor(PadelTheme.LINE, Graphics.COLOR_BLACK);
        dc.drawLine(centerX, 34, centerX, dc.getHeight() - 34);
        dc.drawLine(34, centerY, dc.getWidth() - 34, centerY);

        var selectorX = (_serverPickerIndex == 0 || _serverPickerIndex == 3)
            ? centerX - 92 : centerX + 92;
        var selectorY = _serverPickerIndex < 2 ? centerY - 92 : centerY + 92;
        dc.setColor(getSelectedServerTeam() == 0 ? PadelTheme.CYAN : PadelTheme.RED,
            Graphics.COLOR_BLACK);
        dc.setPenWidth(6);
        dc.drawCircle(selectorX, selectorY, 54);
        dc.setPenWidth(1);

    }

    function drawDecision(dc, centerX, question, yesAccent) {
        PadelTheme.drawHeader(dc, question);
        drawDecisionButton(dc, 42, 174, 156, 68, "YES",
            _decisionIndex == 0, yesAccent);
        drawDecisionButton(dc, 218, 174, 156, 68, "NO",
            _decisionIndex == 1, PadelTheme.CYAN);
    }

    function drawDecisionButton(dc, x, y, width, height, label, selected,
            accent) {
        PadelTheme.drawCard(dc, x, y, width, height, selected, accent);
        dc.setColor(selected ? accent : PadelTheme.MUTED,
            Graphics.COLOR_BLACK);
        dc.drawText(x + width / 2, y + height / 2, Graphics.FONT_XTINY,
            label, Graphics.TEXT_JUSTIFY_CENTER
                | Graphics.TEXT_JUSTIFY_VCENTER);
    }

}
