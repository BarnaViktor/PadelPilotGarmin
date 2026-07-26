using Toybox.Graphics as Graphics;
using Toybox.WatchUi as WatchUi;

class SetupView extends WatchUi.View {
    var _setup;

    function initialize(setup) {
        View.initialize();
        _setup = setup;
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var centerX = dc.getWidth() / 2;
        dc.drawText(
            centerX,
            24,
            Graphics.FONT_SMALL,
            "MATCH SETUP",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        var firstField = _setup.selectedField - 2;
        if (firstField < 0) {
            firstField = 0;
        }
        if (firstField > _setup.fieldCount() - 5) {
            firstField = _setup.fieldCount() - 5;
        }

        for (var row = 0; row < 5; row += 1) {
            var index = firstField + row;
            var y = 72 + row * 42;
            var selected = index == _setup.selectedField;

            dc.setColor(selected ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE,
                selected ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK);
            if (selected) {
                dc.fillRectangle(34, y - 5, dc.getWidth() - 68, 34);
            }
            dc.drawText(
                centerX,
                y,
                Graphics.FONT_TINY,
                _setup.labelFor(index),
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(
            centerX,
            dc.getHeight() - 46,
            Graphics.FONT_TINY,
            "UP/DOWN field  START edit/start",
            Graphics.TEXT_JUSTIFY_CENTER
        );
        dc.drawText(
            centerX,
            dc.getHeight() - 24,
            Graphics.FONT_TINY,
            "MENU/BACK value",
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }
}
