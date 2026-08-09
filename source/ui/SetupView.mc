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
        if (_setup.editing) {
            drawEditor(dc, centerX);
            return;
        }

        dc.drawText(
            centerX,
            42,
            Graphics.FONT_TINY,
            "MATCH SETUP",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        var firstField = _setup.selectedField - 2;
        if (firstField < 0) {
            firstField = 0;
        }
        if (firstField > _setup.itemCount() - 5) {
            firstField = _setup.itemCount() - 5;
        }

        for (var row = 0; row < 5; row += 1) {
            var index = firstField + row;
            var y = 84 + row * 42;
            var selected = index == _setup.selectedField;
            var isHistory = index == _setup.fieldCount();

            dc.setColor(selected ? Graphics.COLOR_BLACK
                    : (index == _setup.itemCount() - 1 ? Graphics.COLOR_GREEN
                    : (isHistory ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_WHITE)),
                selected ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK);
            if (selected) {
                dc.fillRectangle(46, y - 4, dc.getWidth() - 92, 32);
            }
            dc.drawText(
                centerX,
                y,
                Graphics.FONT_TINY,
                _setup.labelFor(index),
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }

    }

    function drawEditor(dc, centerX) {
        dc.drawText(
            centerX,
            58,
            Graphics.FONT_TINY,
            _setup.titleFor(_setup.selectedField),
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawText(
            centerX,
            138,
            Graphics.FONT_MEDIUM,
            _setup.valueLabelFor(_setup.selectedField),
            Graphics.TEXT_JUSTIFY_CENTER
        );

    }
}
