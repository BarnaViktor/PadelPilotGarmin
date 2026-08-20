using Toybox.Graphics as Graphics;
using Toybox.WatchUi as WatchUi;

class HomeView extends WatchUi.View {
    var _selected;

    function initialize() {
        View.initialize();
        _selected = 0;
    }

    function moveSelection(delta) {
        _selected = (_selected + delta + 2) % 2;
    }

    function getSelection() {
        return _selected;
    }

    function onUpdate(dc) {
        PadelTheme.clear(dc);
        var centerX = dc.getWidth() / 2;

        dc.setColor(PadelTheme.WHITE, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 62, Graphics.FONT_XTINY, "PADEL PILOT",
            Graphics.TEXT_JUSTIFY_CENTER);
        drawCourt(dc, centerX, 112);

        PadelTheme.drawActionButton(dc, 68, 228, 280, 58, _selected == 0,
            "NEW MATCH");
        PadelTheme.drawActionButton(dc, 88, 306, 240, 49, _selected == 1,
            "HISTORY");
        PadelTheme.drawPageDots(dc, _selected, 2, 378);
    }

    function drawCourt(dc, centerX, y) {
        dc.setPenWidth(3);
        dc.setColor(PadelTheme.CYAN, Graphics.COLOR_BLACK);
        dc.drawLine(centerX - 76, y, centerX - 18, y);
        dc.drawLine(centerX - 76, y, centerX - 88, y + 66);
        dc.drawLine(centerX - 88, y + 66, centerX - 18, y + 66);
        dc.drawLine(centerX - 61, y, centerX - 69, y + 66);
        dc.drawLine(centerX - 82, y + 33, centerX - 24, y + 33);

        dc.setColor(PadelTheme.RED, Graphics.COLOR_BLACK);
        dc.drawLine(centerX + 18, y, centerX + 76, y);
        dc.drawLine(centerX + 76, y, centerX + 88, y + 66);
        dc.drawLine(centerX + 88, y + 66, centerX + 18, y + 66);
        dc.drawLine(centerX + 61, y, centerX + 69, y + 66);
        dc.drawLine(centerX + 24, y + 33, centerX + 82, y + 33);

        dc.setColor(PadelTheme.WHITE, Graphics.COLOR_BLACK);
        dc.drawLine(centerX, y - 6, centerX, y + 72);
        dc.setPenWidth(1);
    }
}
