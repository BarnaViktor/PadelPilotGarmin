using Toybox.Graphics as Graphics;
using Toybox.WatchUi as WatchUi;

class MatchHistoryDetailView extends WatchUi.View {
    var _record;
    var _page;
    var _deleteConfirm;
    var _deleteDecisionIndex;

    function initialize(record) {
        View.initialize();
        _record = record;
        _page = 0;
        _deleteConfirm = false;
        _deleteDecisionIndex = 1;
    }

    function movePage(delta) {
        var pageCount = getPageCount();
        _page = (_page + delta + pageCount) % pageCount;
    }

    function getPageCount() {
        return _record[4].size() + 1
            + (MatchHistoryStore.isStopped(_record) ? 1 : 0);
    }

    function setDeleteConfirm(visible) {
        _deleteConfirm = visible;
        if (visible) {
            _deleteDecisionIndex = 1;
        }
    }

    function isDeleteConfirm() {
        return _deleteConfirm;
    }

    function moveDeleteSelection() {
        _deleteDecisionIndex = (_deleteDecisionIndex + 1) % 2;
    }

    function isDeleteYes() {
        return _deleteDecisionIndex == 0;
    }

    function onUpdate(dc) {
        PadelTheme.clear(dc);
        var centerX = dc.getWidth() / 2;
        if (_deleteConfirm) {
            drawDeleteConfirmation(dc, centerX);
            return;
        }

        var completedSetCount = _record[4].size();
        if (_page == 0) {
            drawMatchSummary(dc, centerX);
        } else if (_page <= completedSetCount) {
            drawSetSummary(dc, centerX, _page - 1);
        } else {
            drawStoppedSetSummary(dc, centerX);
        }
        drawDeleteHint(dc, centerX);
        PadelTheme.drawPageDots(dc, _page, getPageCount(), 376);
    }

    function drawMatchSummary(dc, centerX) {
        var stopped = MatchHistoryStore.isStopped(_record);
        PadelTheme.drawHeader(dc, stopped ? "MATCH STOPPED" : "MATCH OVER");
        dc.setColor(stopped ? PadelTheme.LIME
                : (_record[2] == 0 ? PadelTheme.CYAN : PadelTheme.RED),
            Graphics.COLOR_BLACK);
        dc.setPenWidth(4);
        dc.drawLine(centerX - 36, 104, centerX + 36, 104);
        dc.setPenWidth(1);

        var sets = _record[4];
        var firstX = centerX - ((sets.size() - 1) * 36);
        for (var index = 0; index < sets.size(); index += 1) {
            dc.setColor(sets[index][0] > sets[index][1]
                ? PadelTheme.CYAN : PadelTheme.RED, Graphics.COLOR_BLACK);
            dc.drawText(firstX + index * 72, 138, Graphics.FONT_XTINY,
                sets[index][0] + "–" + sets[index][1],
                Graphics.TEXT_JUSTIFY_CENTER);
        }

        if (stopped) {
            dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
            dc.drawText(centerX, 176, Graphics.FONT_XTINY,
                currentScoreLabel(), Graphics.TEXT_JUSTIFY_CENTER);
        }

        dc.setColor(PadelTheme.LINE, Graphics.COLOR_BLACK);
        dc.drawLine(82, 210, 334, 210);
        dc.setColor(PadelTheme.WHITE, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 237, Graphics.FONT_XTINY,
            durationLabel(_record[3]),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawStoppedSetSummary(dc, centerX) {
        var state = MatchHistoryStore.getCurrentState(_record);
        var setNumber = _record[0] + _record[1] + 1;
        var tieBreak = state[4];
        var decidingMatchTieBreak = state[5];

        PadelTheme.drawHeader(dc, decidingMatchTieBreak
            ? "MATCH TIE-BREAK" : "SET " + setNumber + " STOPPED");
        dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 94, Graphics.FONT_XTINY,
            tieBreak ? "TIE-BREAK POINTS" : "CURRENT GAMES",
            Graphics.TEXT_JUSTIFY_CENTER);

        if (tieBreak) {
            drawScore(dc, centerX, state[2], state[3]);
            if (!decidingMatchTieBreak) {
                dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
                dc.drawText(centerX, 218, Graphics.FONT_XTINY,
                    "GAMES " + state[0] + "–" + state[1],
                    Graphics.TEXT_JUSTIFY_CENTER);
            }
        } else {
            drawScore(dc, centerX, state[0], state[1]);
            dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
            dc.drawText(centerX, 218, Graphics.FONT_XTINY,
                "POINTS " + pointLabel(state[2], false) + "–"
                    + pointLabel(state[3], false),
                Graphics.TEXT_JUSTIFY_CENTER);
        }

        dc.setColor(PadelTheme.WHITE, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 266, Graphics.FONT_XTINY,
            stoppedSetDurationLabel(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawSetSummary(dc, centerX, setIndex) {
        var completedSet = _record[4][setIndex];
        PadelTheme.drawHeader(dc,
            completedSet[2] ? "MATCH TIE-BREAK" : "SET " + (setIndex + 1));
        dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 94, Graphics.FONT_XTINY, "SET RESULT",
            Graphics.TEXT_JUSTIFY_CENTER);

        drawScore(dc, centerX, completedSet[0], completedSet[1]);

        dc.setColor(PadelTheme.WHITE, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 237, Graphics.FONT_XTINY,
            setDurationLabel(setIndex),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawScore(dc, centerX, myScore, opponentScore) {
        dc.setColor(PadelTheme.CYAN, Graphics.COLOR_BLACK);
        dc.drawText(158, 166, Graphics.FONT_TINY, myScore,
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 166, Graphics.FONT_TINY, ":",
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(PadelTheme.RED, Graphics.COLOR_BLACK);
        dc.drawText(258, 166, Graphics.FONT_TINY, opponentScore,
            Graphics.TEXT_JUSTIFY_CENTER);
    }

    function currentScoreLabel() {
        var state = MatchHistoryStore.getCurrentState(_record);
        if (state[5]) {
            return "MTB " + state[2] + "–" + state[3];
        }
        if (state[4]) {
            return state[0] + "–" + state[1] + "  •  TB "
                + state[2] + "–" + state[3];
        }
        return state[0] + "–" + state[1] + " GAMES  •  "
            + pointLabel(state[2], false) + "–"
            + pointLabel(state[3], false);
    }

    function pointLabel(value, tieBreak) {
        if (tieBreak) {
            return value.toString();
        }
        var labels = ["0", "15", "30", "40", "AD"];
        return value >= 0 && value < labels.size()
            ? labels[value] : value.toString();
    }

    function setDurationLabel(setIndex) {
        if (_record.size() < 6) {
            return "--:--";
        }
        var previousEnd = setIndex == 0 ? 0 : _record[5][setIndex - 1];
        return durationLabel(_record[5][setIndex] - previousEnd);
    }

    function stoppedSetDurationLabel() {
        var completedSetCount = _record[4].size();
        var previousEnd = completedSetCount == 0
            ? 0 : _record[5][completedSetCount - 1];
        return durationLabel(_record[3] - previousEnd);
    }

    function drawDeleteHint(dc, centerX) {
        dc.setColor(PadelTheme.RED, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 326, Graphics.FONT_XTINY, "START: DELETE",
            Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawDeleteConfirmation(dc, centerX) {
        PadelTheme.drawHeader(dc, "DELETE MATCH?");
        drawDeleteButton(dc, 42, 174, "YES", _deleteDecisionIndex == 0,
            PadelTheme.RED);
        drawDeleteButton(dc, 218, 174, "NO", _deleteDecisionIndex == 1,
            PadelTheme.CYAN);
    }

    function drawDeleteButton(dc, x, y, label, selected, accent) {
        PadelTheme.drawCard(dc, x, y, 156, 68, selected, accent);
        dc.setColor(selected ? accent : PadelTheme.MUTED,
            Graphics.COLOR_BLACK);
        dc.drawText(x + 78, y + 34, Graphics.FONT_XTINY, label,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function durationLabel(totalSeconds) {
        var hours = (totalSeconds / 3600).toNumber();
        var minutes = ((totalSeconds % 3600) / 60).toNumber();
        var seconds = totalSeconds % 60;
        if (hours > 0) {
            return padTwo(hours) + ":" + padTwo(minutes) + ":" + padTwo(seconds);
        }
        return padTwo(minutes) + ":" + padTwo(seconds);
    }

    function padTwo(value) {
        return value < 10 ? "0" + value : value.toString();
    }
}
