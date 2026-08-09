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
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        var centerX = dc.getWidth() / 2;

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 50, Graphics.FONT_TINY,
            "MATCH HISTORY", Graphics.TEXT_JUSTIFY_CENTER);

        if (_history.size() == 0) {
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
            dc.drawText(centerX, 180, Graphics.FONT_SMALL,
                "NO MATCHES YET", Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        var first = _selected - 2;
        if (first < 0) {
            first = 0;
        }
        if (first > _history.size() - 4) {
            first = _history.size() - 4;
        }
        if (first < 0) {
            first = 0;
        }

        for (var row = 0; row < 4 && first + row < _history.size(); row += 1) {
            drawRecord(dc, first + row, 105 + row * 58);
        }
    }

    function drawRecord(dc, displayIndex, y) {
        var record = _history[_history.size() - 1 - displayIndex];
        var selected = displayIndex == _selected;

        if (selected) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.fillCircle(76, y + 14, 4);
        }

        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
        dc.drawText(145, y, Graphics.FONT_SMALL, record[1], Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(selected ? Graphics.COLOR_WHITE : Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(190, y, Graphics.FONT_SMALL, ":", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
        dc.drawText(235, y, Graphics.FONT_SMALL, record[0], Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(306, y + 7, Graphics.FONT_XTINY,
            durationLabel(record[3]), Graphics.TEXT_JUSTIFY_CENTER);
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
