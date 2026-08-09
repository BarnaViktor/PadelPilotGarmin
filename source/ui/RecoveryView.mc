using Toybox.Graphics as Graphics;
using Toybox.WatchUi as WatchUi;

class RecoveryView extends WatchUi.View {
    var _loadedMatch;
    var _confirmIcon;
    var _cancelIcon;

    function initialize(loadedMatch) {
        View.initialize();
        _loadedMatch = loadedMatch;
        _confirmIcon = WatchUi.loadResource(Rez.Drawables.ActionConfirm);
        _cancelIcon = WatchUi.loadResource(Rez.Drawables.ActionCancel);
    }

    function getLoadedMatch() {
        return _loadedMatch;
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var centerX = dc.getWidth() / 2;
        drawEdgeGlow(dc, centerX, true);
        drawEdgeGlow(dc, centerX, false);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 154, Graphics.FONT_SMALL,
            "CONTINUE MATCH?", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 205, Graphics.FONT_XTINY,
            scoreLabel(), Graphics.TEXT_JUSTIFY_CENTER);

        dc.drawBitmap(dc.getWidth() - 54, 91, _confirmIcon);
        dc.drawBitmap(14, 275, _cancelIcon);
    }

    function scoreLabel() {
        var engine = _loadedMatch[0];
        return engine.getSets()[1] + " : " + engine.getSets()[0] + " SETS";
    }

    function drawEdgeGlow(dc, centerX, isConfirm) {
        var centerY = dc.getHeight() / 2;
        var startAngle = isConfirm ? 18 : 198;
        var endAngle = isConfirm ? 44 : 224;
        var colors = isConfirm
            ? [0x020704, 0x030C05, 0x051408, 0x071E0C, 0x092B12,
                0x0C3B19, 0x104E21, 0x17682C, 0x20863A]
            : [0x090202, 0x100303, 0x1A0504, 0x280706, 0x390A08,
                0x4F0D0B, 0x68120F, 0x861915, 0xAA251E];

        for (var band = 0; band < colors.size(); band += 1) {
            dc.setColor(colors[band], Graphics.COLOR_BLACK);
            dc.setPenWidth(3);
            dc.drawArc(centerX, centerY, 180 + band * 3,
                Graphics.ARC_COUNTER_CLOCKWISE, startAngle, endAngle);
        }
        dc.setPenWidth(1);
    }
}
