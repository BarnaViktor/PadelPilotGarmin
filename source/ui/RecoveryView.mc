using Toybox.Graphics as Graphics;
using Toybox.Lang as Lang;
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
        dc = PadelTheme.canvas(dc);
        PadelTheme.clear(dc);
        var centerX = dc.getWidth() / 2;
        var engine = _loadedMatch[0];
        var isPointMatch = engine instanceof PointMatchEngine;
        var score = (isPointMatch ? engine.getPoints() : engine.getSets())
            as Lang.Array<Lang.Number>;
        PadelTheme.drawHeader(dc, "SAVED MATCH");

        PadelTheme.drawCard(dc, 50, 116, 316, isPointMatch ? 156 : 142,
            true, PadelTheme.CYAN);
        dc.setColor(PadelTheme.WHITE, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 153, Graphics.FONT_XTINY,
            isPointMatch ? (engine.getMode() == PointMatchMode.AMERICANO
                ? "AMERICANO" : "MEXICANO") : "CONTINUE MATCH?",
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(PadelTheme.CYAN, Graphics.COLOR_BLACK);
        var scoreY = isPointMatch ? 190 : 205;
        dc.drawText(160, scoreY, Graphics.FONT_TINY,
            score[0], Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
        dc.drawText(centerX, scoreY, Graphics.FONT_TINY, "–",
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(PadelTheme.RED, Graphics.COLOR_BLACK);
        dc.drawText(256, scoreY, Graphics.FONT_TINY,
            score[1], Graphics.TEXT_JUSTIFY_CENTER);

        if (isPointMatch) {
            dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
            dc.drawText(centerX, 252, Graphics.FONT_XTINY,
                (engine.getEndRule() == PointMatchEndRule.TOTAL_POINTS
                    ? "TOTAL X: " : "TEAM X: ") + engine.getTarget(),
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        PadelTheme.drawActionButton(dc, 88, 282, 240, 48, true,
            "CONTINUE");
        PadelTheme.drawCard(dc, 108, 344, 200, 42, false, PadelTheme.RED);
        dc.setColor(PadelTheme.RED, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 365, Graphics.FONT_XTINY, "DISCARD",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}
