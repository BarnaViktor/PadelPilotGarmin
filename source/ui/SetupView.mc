using Toybox.Graphics as Graphics;
using Toybox.WatchUi as WatchUi;

class SetupView extends WatchUi.View {
    var _setup;

    function initialize(setup) {
        View.initialize();
        _setup = setup;
    }

    function onUpdate(dc) {
        PadelTheme.clear(dc);
        var centerX = dc.getWidth() / 2;
        PadelTheme.drawHeader(dc, "MATCH SETUP");

        if (_setup.editing) {
            drawEditor(dc, centerX);
        } else {
            drawSettings(dc, centerX);
        }
    }

    function drawSettings(dc, centerX) {
        var first = _setup.selectedField - 1;
        if (first < 0) {
            first = 0;
        }
        if (first > _setup.itemCount() - 4) {
            first = _setup.itemCount() - 4;
        }

        for (var row = 0; row < 4; row += 1) {
            var index = first + row;
            var y = 94 + row * 58;
            var selected = index == _setup.selectedField;
            if (index == _setup.fieldCount()) {
                PadelTheme.drawActionButton(dc, 72, y, 272, 49, selected,
                    "START");
            } else {
                PadelTheme.drawSplitCard(dc, 49, y, 318, 49, selected,
                    shortTitle(index), shortValue(index));
            }
        }

        PadelTheme.drawPageDots(dc, _setup.selectedField, _setup.itemCount(), 370);
    }

    function drawEditor(dc, centerX) {
        var index = _setup.selectedField;
        if (index == 2) {
            drawTeamEditor(dc, centerX);
            return;
        }

        PadelTheme.drawCard(dc, 48, 139, 320, 92, true, PadelTheme.CYAN);
        dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
        dc.drawText(84, 177, Graphics.FONT_TINY, "−",
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(332, 177, Graphics.FONT_TINY, "+",
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(PadelTheme.LINE, Graphics.COLOR_BLACK);
        dc.drawLine(127, 149, 127, 221);
        dc.drawLine(289, 149, 289, 221);
        dc.setColor(PadelTheme.WHITE, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 177, Graphics.FONT_XTINY, shortValue(index),
            Graphics.TEXT_JUSTIFY_CENTER);

    }

    function drawTeamEditor(dc, centerX) {
        var mine = _setup.startingServerTeam == 0;
        PadelTheme.drawCard(dc, 38, 124, 340, 150, true,
            mine ? PadelTheme.CYAN : PadelTheme.RED);
        dc.setColor(PadelTheme.LINE, Graphics.COLOR_BLACK);
        dc.drawLine(centerX, 128, centerX, 270);

        dc.setColor(mine ? PadelTheme.CYAN : PadelTheme.MUTED,
            Graphics.COLOR_BLACK);
        dc.drawText(124, 188, Graphics.FONT_TINY, "A",
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(124, 224, Graphics.FONT_XTINY, "MY TEAM",
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(!mine ? PadelTheme.RED : PadelTheme.MUTED,
            Graphics.COLOR_BLACK);
        dc.drawText(292, 188, Graphics.FONT_TINY, "B",
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(292, 224, Graphics.FONT_XTINY, "OPPONENT",
            Graphics.TEXT_JUSTIFY_CENTER);

    }

    function shortTitle(index) {
        var titles = ["SETS", "SCORING", "FIRST SERVE", "DECIDING SET",
            "TIE-BREAK", "MATCH TB", "WIN BY TWO"];
        return titles[index];
    }

    function shortValue(index) {
        if (index == 0) {
            return _setup.bestOfSets + " SETS";
        } else if (index == 1) {
            return _setup.scoringMode == ScoringMode.ADVANTAGE ? "ADV" : "NO-AD";
        } else if (index == 2) {
            return _setup.startingServerTeam == 0 ? "A TEAM" : "B TEAM";
        } else if (index == 3) {
            return _setup.decidingSetMode == DecidingSetMode.FULL_SET
                ? "FULL SET" : "MATCH TB";
        } else if (index == 4) {
            return _setup.regularTieBreakTarget.toString();
        } else if (index == 5) {
            return _setup.decidingTieBreakTarget.toString();
        }
        return _setup.requireTwoPointTieBreakMargin ? "ON" : "OFF";
    }
}
