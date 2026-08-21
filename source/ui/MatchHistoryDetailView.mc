using Toybox.Graphics as Graphics;
using Toybox.WatchUi as WatchUi;

class MatchHistoryDetailView extends WatchUi.View {
    var _record;
    var _page;

    function initialize(record) {
        View.initialize();
        _record = record;
        _page = 0;
    }

    function movePage(delta) {
        var pageCount = _record[4].size() + 1;
        _page = (_page + delta + pageCount) % pageCount;
    }

    function onUpdate(dc) {
        PadelTheme.clear(dc);
        var centerX = dc.getWidth() / 2;
        if (_page == 0) {
            drawMatchSummary(dc, centerX);
        } else {
            drawSetSummary(dc, centerX, _page - 1);
        }
        PadelTheme.drawPageDots(dc, _page, _record[4].size() + 1, 376);
    }

    function drawMatchSummary(dc, centerX) {
        PadelTheme.drawHeader(dc, "MATCH OVER");
        dc.setColor(_record[2] == 0 ? PadelTheme.CYAN : PadelTheme.RED,
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

        dc.setColor(PadelTheme.LINE, Graphics.COLOR_BLACK);
        dc.drawLine(82, 210, 334, 210);
        dc.setColor(PadelTheme.WHITE, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 237, Graphics.FONT_XTINY,
            durationLabel(_record[3]),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawSetSummary(dc, centerX, setIndex) {
        var completedSet = _record[4][setIndex];
        PadelTheme.drawHeader(dc,
            completedSet[2] ? "MATCH TIE-BREAK" : "SET " + (setIndex + 1));
        dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 94, Graphics.FONT_XTINY, "SET RESULT",
            Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(PadelTheme.CYAN, Graphics.COLOR_BLACK);
        dc.drawText(158, 166, Graphics.FONT_TINY, completedSet[0],
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 166, Graphics.FONT_TINY, ":",
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(PadelTheme.RED, Graphics.COLOR_BLACK);
        dc.drawText(258, 166, Graphics.FONT_TINY, completedSet[1],
            Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(PadelTheme.WHITE, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 237, Graphics.FONT_XTINY,
            setDurationLabel(setIndex),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function setDurationLabel(setIndex) {
        if (_record.size() < 6) {
            return "--:--";
        }
        var previousEnd = setIndex == 0 ? 0 : _record[5][setIndex - 1];
        return durationLabel(_record[5][setIndex] - previousEnd);
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
