using Toybox.Graphics as Graphics;
using Toybox.System as System;
using Toybox.WatchUi as WatchUi;

class ScoreView extends WatchUi.View {
    var _engine;
    var _paused;
    var _startedAt;
    var _finishedAt;
    var _summaryPage;
    var _finishMenu;
    var _pauseMenuIndex;
    var _pauseStopConfirm;
    var _pauseServerPicker;
    var _serverPickerIndex;

    function initialize(engine, elapsedSeconds) {
        View.initialize();
        _engine = engine;
        _paused = false;
        _startedAt = System.getTimer() - (elapsedSeconds * 1000);
        _finishedAt = null;
        _summaryPage = 0;
        _finishMenu = false;
        _pauseMenuIndex = 0;
        _pauseStopConfirm = false;
        _pauseServerPicker = false;
        _serverPickerIndex = 0;
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
        drawSetStrip(dc, centerX);

        dc.setColor(PadelTheme.LINE, Graphics.COLOR_BLACK);
        dc.setPenWidth(2);
        dc.drawLine(centerX, 48, centerX, 256);
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

    function drawSetStrip(dc, centerX) {
        var sets = _engine.getCompletedSets();
        var startX = centerX - ((sets.size() - 1) * 26);
        if (sets.size() == 0) {
            dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
            dc.drawText(centerX, 45, Graphics.FONT_XTINY, "MATCH IN PROGRESS",
                Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }
        for (var i = 0; i < sets.size(); i += 1) {
            dc.setColor(PadelTheme.CYAN, Graphics.COLOR_BLACK);
            dc.drawText(startX + i * 52 - 10, 45, Graphics.FONT_XTINY,
                sets[i][0], Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
            dc.drawText(startX + i * 52, 45, Graphics.FONT_XTINY, "–",
                Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(PadelTheme.RED, Graphics.COLOR_BLACK);
            dc.drawText(startX + i * 52 + 10, 45, Graphics.FONT_XTINY,
                sets[i][1], Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    function drawTeamLabel(dc, x, y, team, label) {
        var color = team == 0 ? PadelTheme.CYAN : PadelTheme.RED;
        if (_engine.getServerTeam() == team) {
            dc.setColor(PadelTheme.LIME, Graphics.COLOR_BLACK);
            dc.fillCircle(x - 44, y + 10, 10);
            dc.setColor(Graphics.COLOR_BLACK, PadelTheme.LIME);
            dc.setPenWidth(2);
            dc.drawArc(x - 44, y + 10, 7, Graphics.ARC_COUNTER_CLOCKWISE, 30, 210);
            dc.setPenWidth(1);
        }
        dc.setColor(color, Graphics.COLOR_BLACK);
        dc.drawText(x, y + 5, Graphics.FONT_XTINY, label, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawServeIndicator(dc, centerX, y) {
        var team = _engine.getServerTeam();
        var side = _engine.getServeSide();
        var player = _engine.getTeamServerSlots()[team] + 1;
        var left = centerX - 80;
        var top = y + 28;

        dc.setColor(team == 0 ? PadelTheme.CYAN : PadelTheme.RED,
            Graphics.COLOR_BLACK);
        dc.drawText(centerX, y, Graphics.FONT_XTINY,
            (team == 0 ? "A" : "B") + player,
            Graphics.TEXT_JUSTIFY_CENTER);

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
        var markerY = side == 0 ? top + 13 : top + 39;
        dc.setColor(PadelTheme.LIME, Graphics.COLOR_BLACK);
        dc.fillCircle(markerX, markerY, 8);
        dc.setColor(Graphics.COLOR_BLACK, PadelTheme.LIME);
        dc.setPenWidth(2);
        dc.drawArc(markerX, markerY, 6, Graphics.ARC_COUNTER_CLOCKWISE, 25, 205);
        dc.setPenWidth(1);
    }

    function completeMatch() {
        if (_finishedAt == null) {
            _finishedAt = System.getTimer();
        }
        _summaryPage = 0;
        _finishMenu = false;
    }

    function resumeMatchAfterUndo() {
        _finishedAt = null;
        _summaryPage = 0;
        _finishMenu = false;
    }

    function changeSummaryPage(delta) {
        var pageCount = _engine.getCompletedSets().size() + 1;
        _summaryPage = (_summaryPage + delta + pageCount) % pageCount;
    }

    function setFinishMenu(visible) {
        _finishMenu = visible;
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
            Graphics.TEXT_JUSTIFY_CENTER);
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
        var endTime = _finishedAt == null ? System.getTimer() : _finishedAt;
        var totalSeconds = ((endTime - _startedAt) / 1000).toNumber();
        var hours = (totalSeconds / 3600).toNumber();
        var minutes = ((totalSeconds % 3600) / 60).toNumber();
        var seconds = totalSeconds % 60;

        if (hours > 0) {
            return padTwo(hours) + ":" + padTwo(minutes) + ":" + padTwo(seconds);
        }
        return padTwo(minutes) + ":" + padTwo(seconds);
    }

    function getDurationSeconds() {
        var endTime = _finishedAt == null ? System.getTimer() : _finishedAt;
        return ((endTime - _startedAt) / 1000).toNumber();
    }

    function padTwo(value) {
        return value < 10 ? "0" + value : value.toString();
    }

    function setPaused(paused) {
        _paused = paused;
        if (paused) {
            _pauseMenuIndex = 0;
            _pauseStopConfirm = false;
            _pauseServerPicker = false;
        }
    }

    function isPaused() {
        return _paused;
    }

    function movePauseSelection(delta) {
        _pauseMenuIndex = (_pauseMenuIndex + delta + 2) % 2;
    }

    function getPauseSelection() {
        return _pauseMenuIndex;
    }

    function setPauseStopConfirm(visible) {
        _pauseStopConfirm = visible;
    }

    function isPauseStopConfirm() {
        return _pauseStopConfirm;
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

    function serverPickerIndex(team, side) {
        if (team == 1) {
            return side == 0 ? 0 : 1;
        }
        return side == 0 ? 2 : 3;
    }

    function drawPause(dc, centerX) {
        if (_pauseStopConfirm) {
            drawDecision(dc, centerX, "END MATCH?", null);
            return;
        }
        if (_pauseServerPicker) {
            drawServerPicker(dc, centerX);
            return;
        }

        PadelTheme.drawHeader(dc, "PAUSED");
        drawPauseMenuRow(dc, centerX, 128, 0, "CHANGE SERVER");
        drawPauseMenuRow(dc, centerX, 214, 1, "END MATCH");
    }

    function drawFinishMenu(dc, centerX) {
        drawDecision(dc, centerX, "SAVE MATCH?", null);
    }

    function drawPauseMenuRow(dc, centerX, y, index, label) {
        var selected = _pauseMenuIndex == index;
        var selectedColor = index == 1 ? PadelTheme.RED : PadelTheme.CYAN;
        PadelTheme.drawCard(dc, 63, y, 290, 65, selected, selectedColor);
        dc.setColor(selected ? selectedColor : PadelTheme.MUTED,
            Graphics.COLOR_BLACK);
        dc.drawText(centerX, y + 24, Graphics.FONT_XTINY, label,
            Graphics.TEXT_JUSTIFY_CENTER);
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

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRoundedRectangle(centerX - 112, centerY - 31, 224, 62, 14);
        dc.setColor(PadelTheme.WHITE, Graphics.COLOR_BLACK);
        dc.drawText(centerX, centerY - 23, Graphics.FONT_XTINY,
            (getSelectedServerTeam() == 0 ? "A" : "B")
                + (_engine.getTeamServerSlots()[getSelectedServerTeam()] + 1),
            Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawDecision(dc, centerX, question, explanation) {
        PadelTheme.drawCard(dc, 56, 108, 304, 200, true, PadelTheme.LINE);
        dc.setColor(PadelTheme.RED, Graphics.COLOR_BLACK);
        dc.setPenWidth(4);
        dc.drawArc(centerX, 147, 20, Graphics.ARC_COUNTER_CLOCKWISE, 300, 90);
        dc.setPenWidth(1);

        dc.setColor(PadelTheme.WHITE, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 188, Graphics.FONT_XTINY, question, Graphics.TEXT_JUSTIFY_CENTER);
        if (explanation != null) {
            dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
            dc.drawText(centerX, 216, Graphics.FONT_XTINY, explanation, Graphics.TEXT_JUSTIFY_CENTER);
        }
        dc.setColor(PadelTheme.LINE, Graphics.COLOR_BLACK);
        dc.drawLine(76, 255, 340, 255);
        dc.drawLine(centerX, 255, centerX, 300);
        dc.setColor(PadelTheme.LIME, Graphics.COLOR_BLACK);
        dc.drawText(132, 268, Graphics.FONT_XTINY, "YES",
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(PadelTheme.WHITE, Graphics.COLOR_BLACK);
        dc.drawText(284, 268, Graphics.FONT_XTINY, "NO",
            Graphics.TEXT_JUSTIFY_CENTER);
    }

}
