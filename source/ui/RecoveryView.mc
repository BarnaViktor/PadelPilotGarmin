using Toybox.Graphics as Graphics;
using Toybox.WatchUi as WatchUi;

class RecoveryView extends WatchUi.View {
    var _loadedMatch;

    function initialize(loadedMatch) {
        View.initialize();
        _loadedMatch = loadedMatch;
    }

    function getLoadedMatch() {
        return _loadedMatch;
    }

    function onUpdate(dc) {
        PadelTheme.clear(dc);
        var centerX = dc.getWidth() / 2;
        PadelTheme.drawHeader(dc, "SAVED MATCH");

        PadelTheme.drawCard(dc, 50, 116, 316, 142, true, PadelTheme.CYAN);
        dc.setColor(PadelTheme.WHITE, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 153, Graphics.FONT_XTINY, "CONTINUE MATCH?",
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(PadelTheme.CYAN, Graphics.COLOR_BLACK);
        dc.drawText(160, 205, Graphics.FONT_TINY,
            _loadedMatch[0].getSets()[0], Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 205, Graphics.FONT_TINY, "–",
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(PadelTheme.RED, Graphics.COLOR_BLACK);
        dc.drawText(256, 205, Graphics.FONT_TINY,
            _loadedMatch[0].getSets()[1], Graphics.TEXT_JUSTIFY_CENTER);

        PadelTheme.drawActionButton(dc, 88, 282, 240, 48, true,
            "CONTINUE");
        PadelTheme.drawCard(dc, 108, 344, 200, 42, false, PadelTheme.RED);
        dc.setColor(PadelTheme.RED, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 365, Graphics.FONT_XTINY, "DISCARD",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}
