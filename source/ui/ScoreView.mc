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
    var _confirmIcon;
    var _cancelIcon;
    var _trophyMyTeam;
    var _trophyOpponent;

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
        _confirmIcon = WatchUi.loadResource(Rez.Drawables.ActionConfirm);
        _cancelIcon = WatchUi.loadResource(Rez.Drawables.ActionCancel);
        _trophyMyTeam = WatchUi.loadResource(Rez.Drawables.TrophyMyTeam);
        _trophyOpponent = WatchUi.loadResource(Rez.Drawables.TrophyOpponent);
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

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

        drawServerBorder(dc, centerX);
        drawScoreTable(dc, centerX);
    }

    function drawScoreTable(dc, centerX) {
        var columnX = [128, 208, 288];
        var headers = ["S", "G", "P"];

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        for (var column = 0; column < 3; column += 1) {
            dc.drawText(columnX[column], 58, Graphics.FONT_XTINY, headers[column], Graphics.TEXT_JUSTIFY_CENTER);
        }

        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
        drawScoreRow(dc, columnX, 105, 1);

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawLine(82, 188, 334, 188);

        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
        drawScoreRow(dc, columnX, 220, 0);
    }

    function drawScoreRow(dc, columnX, y, team) {
        dc.drawText(columnX[0], y, Graphics.FONT_MEDIUM, _engine.getSets()[team], Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(columnX[1], y, Graphics.FONT_MEDIUM, _engine.getGames()[team], Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(columnX[2], y, Graphics.FONT_MEDIUM, _engine.pointLabel(team), Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawServerBorder(dc, centerX) {
        var serverTeam = _engine.getServerTeam();
        var serveSide = _engine.getServeSide();
        var startAngle;
        var endAngle;

        if (serverTeam == 1) {
            startAngle = serveSide == 0 ? 90 : 0;
            endAngle = serveSide == 0 ? 180 : 90;
        } else {
            startAngle = serveSide == 0 ? 270 : 180;
            endAngle = serveSide == 0 ? 360 : 270;
        }

        dc.setColor(serverTeam == 0 ? Graphics.COLOR_GREEN : Graphics.COLOR_RED, Graphics.COLOR_BLACK);
        dc.setPenWidth(10);
        dc.drawArc(centerX, dc.getHeight() / 2, (dc.getWidth() / 2) - 9,
            Graphics.ARC_COUNTER_CLOCKWISE, startAngle, endAngle);
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
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 58, Graphics.FONT_XTINY, "SETS", Graphics.TEXT_JUSTIFY_CENTER);

        drawSummaryScore(dc, centerX, _engine.getSets()[1], _engine.getSets()[0],
            _engine.getMatchWinner() == 1);

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 238, Graphics.FONT_XTINY, "DURATION", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 270, Graphics.FONT_MEDIUM, durationLabel(), Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawSetSummary(dc, centerX, setIndex) {
        var completedSet = _engine.getCompletedSets()[setIndex];
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(
            centerX,
            58,
            Graphics.FONT_XTINY,
            completedSet[2] ? "MATCH TIE-BREAK" : "SET " + (setIndex + 1),
            Graphics.TEXT_JUSTIFY_CENTER
        );

        drawSummaryScore(dc, centerX, completedSet[1], completedSet[0], completedSet[1] > completedSet[0]);
    }

    function drawSummaryScore(dc, centerX, opponentScore, myScore, opponentWon) {
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
        dc.drawText(158, 120, Graphics.FONT_LARGE, opponentScore, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 120, Graphics.FONT_LARGE, ":", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
        dc.drawText(258, 120, Graphics.FONT_LARGE, myScore, Graphics.TEXT_JUSTIFY_CENTER);

        if (opponentWon) {
            dc.drawBitmap(103, 134, _trophyOpponent);
        } else {
            dc.drawBitmap(280, 134, _trophyMyTeam);
        }
    }

    function drawPageDots(dc, centerX) {
        var pageCount = _engine.getCompletedSets().size() + 1;
        var firstX = centerX - ((pageCount - 1) * 10);
        for (var page = 0; page < pageCount; page += 1) {
            dc.setColor(page == _summaryPage ? Graphics.COLOR_WHITE : Graphics.COLOR_DK_GRAY,
                Graphics.COLOR_BLACK);
            if (page == _summaryPage) {
                dc.fillCircle(firstX + page * 20, 340, 4);
            } else {
                dc.drawCircle(firstX + page * 20, 340, 4);
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
    }

    function isPauseServerPicker() {
        return _pauseServerPicker;
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

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(
            centerX,
            68,
            Graphics.FONT_XTINY,
            "PAUSED",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        drawPauseMenuRow(dc, centerX, 128, 0, "CHANGE SERVER");
        drawPauseMenuRow(dc, centerX, 224, 1, "END MATCH");
    }

    function drawFinishMenu(dc, centerX) {
        drawDecision(dc, centerX, "SAVE MATCH?", null);
    }

    function drawPauseMenuRow(dc, centerX, y, index, label) {
        var selected = _pauseMenuIndex == index;
        var selectedColor = index == 1 ? Graphics.COLOR_RED : Graphics.COLOR_WHITE;
        dc.setColor(selected ? selectedColor : Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(centerX, y, Graphics.FONT_SMALL, label, Graphics.TEXT_JUSTIFY_CENTER);
        if (selected) {
            dc.setPenWidth(3);
            dc.drawLine(centerX - 24, y + 46, centerX + 24, y + 46);
            dc.setPenWidth(1);
        }
    }

    function drawServerPicker(dc, centerX) {
        var centerY = dc.getHeight() / 2;

        dc.setColor(0x160505, Graphics.COLOR_BLACK);
        dc.fillRectangle(0, 0, dc.getWidth(), centerY);
        dc.setColor(0x041506, Graphics.COLOR_BLACK);
        dc.fillRectangle(0, centerY, dc.getWidth(), centerY);

        dc.setColor(0x3A3A3A, Graphics.COLOR_BLACK);
        dc.drawLine(centerX, 34, centerX, dc.getHeight() - 34);
        dc.drawLine(34, centerY, dc.getWidth() - 34, centerY);

        drawServerBorder(dc, centerX);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRoundedRectangle(centerX - 96, centerY - 24, 192, 48, 14);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(centerX, centerY - 12, Graphics.FONT_XTINY,
            "WHO SERVES FIRST?", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawDecision(dc, centerX, question, explanation) {
        drawEdgeGlow(dc, true);
        drawEdgeGlow(dc, false);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 160, Graphics.FONT_SMALL, question, Graphics.TEXT_JUSTIFY_CENTER);
        if (explanation != null) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
            dc.drawText(centerX, 202, Graphics.FONT_XTINY, explanation, Graphics.TEXT_JUSTIFY_CENTER);
        }

        dc.drawBitmap(dc.getWidth() - 54, 91, _confirmIcon);
        dc.drawBitmap(14, 275, _cancelIcon);
    }

    function drawEdgeGlow(dc, isConfirm) {
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        var startAngle = isConfirm ? 18 : 198;
        var endAngle = isConfirm ? 44 : 224;
        var colors;

        if (isConfirm) {
            colors = [0x020704, 0x030C05, 0x051408, 0x071E0C, 0x092B12,
                0x0C3B19, 0x104E21, 0x17682C, 0x20863A];
        } else {
            colors = [0x090202, 0x100303, 0x1A0504, 0x280706, 0x390A08,
                0x4F0D0B, 0x68120F, 0x861915, 0xAA251E];
        }

        for (var band = 0; band < colors.size(); band += 1) {
            dc.setColor(colors[band], Graphics.COLOR_BLACK);
            dc.setPenWidth(3);
            dc.drawArc(centerX, centerY, 180 + band * 3,
                Graphics.ARC_COUNTER_CLOCKWISE, startAngle, endAngle);
        }
        dc.setPenWidth(1);
    }
}
