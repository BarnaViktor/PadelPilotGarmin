using Toybox.Graphics as Graphics;
using Toybox.WatchUi as WatchUi;

class MatchHistoryView extends WatchUi.View {
    var _history;
    var _selected;

    function initialize() {
        View.initialize();
        _history = MatchHistoryStore.load();
        _selected = 0;
    }

    function moveSelection(delta) {
        if (_history.size() > 0) {
            _selected = (_selected + delta + _history.size()) % _history.size();
        }
    }

    function onUpdate(dc) {
        PadelTheme.clear(dc);
        var centerX = dc.getWidth() / 2;
        PadelTheme.drawHeader(dc, "MATCH HISTORY");

        if (_history.size() == 0) {
            dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
            dc.drawText(centerX, 196, Graphics.FONT_XTINY, "NO MATCHES YET",
                Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        var first = _selected - 1;
        if (first < 0) {
            first = 0;
        }
        if (first > _history.size() - 3) {
            first = _history.size() - 3;
        }
        if (first < 0) {
            first = 0;
        }

        for (var row = 0; row < 3 && first + row < _history.size(); row += 1) {
            drawRecord(dc, first + row, 103 + row * 78);
        }
        PadelTheme.drawPageDots(dc, _selected, _history.size(), 376);
    }

    function drawRecord(dc, displayIndex, y) {
        var record = _history[_history.size() - 1 - displayIndex];
        var selected = displayIndex == _selected;
        PadelTheme.drawCard(dc, 52, y, 312, 64, selected, PadelTheme.CYAN);

        dc.setColor(PadelTheme.CYAN, Graphics.COLOR_BLACK);
        dc.drawText(126, y + 20, Graphics.FONT_XTINY, record[0],
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
        dc.drawText(172, y + 20, Graphics.FONT_XTINY, "–",
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(PadelTheme.RED, Graphics.COLOR_BLACK);
        dc.drawText(218, y + 20, Graphics.FONT_XTINY, record[1],
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
        dc.drawText(312, y + 19, Graphics.FONT_XTINY, durationLabel(record[3]),
            Graphics.TEXT_JUSTIFY_CENTER);
    }

    function durationLabel(totalSeconds) {
        var hours = (totalSeconds / 3600).toNumber();
        var minutes = ((totalSeconds % 3600) / 60).toNumber();
        var seconds = totalSeconds % 60;
        if (hours > 0) {
            return padTwo(hours) + ":" + padTwo(minutes);
        }
        return padTwo(minutes) + ":" + padTwo(seconds);
    }

    function padTwo(value) {
        return value < 10 ? "0" + value : value.toString();
    }
}
