using Toybox.Graphics as Graphics;
using Toybox.WatchUi as WatchUi;

class ScoreView extends WatchUi.View {
    var _engine;

    function initialize(engine) {
        View.initialize();
        _engine = engine;
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var centerX = dc.getWidth() / 2;
        var winner = _engine.getMatchWinner();

        dc.drawText(
            centerX,
            25,
            Graphics.FONT_SMALL,
            _engine.isDecidingMatchTieBreak() ? "MATCH TIE-BREAK" : "PADEL",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawText(
            centerX,
            80,
            Graphics.FONT_NUMBER_MILD,
            _engine.pointLabel(0) + "  :  " + _engine.pointLabel(1),
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawText(
            centerX,
            145,
            Graphics.FONT_MEDIUM,
            _engine.getGames()[0] + "-" + _engine.getGames()[1]
                + "  (" + _engine.getSets()[0] + "-" + _engine.getSets()[1] + ")",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawText(
            centerX,
            188,
            Graphics.FONT_SMALL,
            "SERVE " + _engine.serverLabel(),
            Graphics.TEXT_JUSTIFY_CENTER
        );

        if (winner != null) {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
            dc.drawText(
                centerX,
                232,
                Graphics.FONT_MEDIUM,
                "TEAM " + (winner + 1) + " WINS",
                Graphics.TEXT_JUSTIFY_CENTER
            );
        } else {
            dc.drawText(
                centerX,
                dc.getHeight() - 45,
                Graphics.FONT_TINY,
                "UP T1   DOWN T2   BACK UNDO",
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }
    }
}
