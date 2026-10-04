using Toybox.Graphics as Graphics;
using Toybox.WatchUi as WatchUi;

class SetupView extends WatchUi.View {
    var _setup;

    function initialize(setup) {
        View.initialize();
        _setup = setup;
    }

    function onUpdate(dc) {
        dc = PadelTheme.canvas(dc);
        PadelTheme.clear(dc);
        var centerX = dc.getWidth() / 2;
        PadelTheme.drawHeader(dc, _setup.editing
            ? _setup.titleFor(_setup.selectedField) : "MATCH SETUP");

        if (_setup.editing) {
            drawEditor(dc, centerX);
            dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
            dc.drawText(centerX, 328, Graphics.FONT_XTINY, "START: SAVE",
                Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(centerX, 362, Graphics.FONT_XTINY, "BACK: CANCEL",
                Graphics.TEXT_JUSTIFY_CENTER);
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
            var y = 98 + row * 62;
            var selected = index == _setup.selectedField;
            if (index == _setup.fieldCount()) {
                PadelTheme.drawActionButton(dc, 72, y, 272, 48, selected,
                    "START");
            } else if (_setup.fieldFor(index) == MatchSetupField.MODE) {
                PadelTheme.drawActionButton(dc, 49, y, 318, 48, selected,
                    "MODE: " + _setup.modeLabel());
            } else {
                PadelTheme.drawSplitCard(dc, 49, y, 318, 48, selected,
                    shortTitle(index), shortValue(index));
            }
        }

        PadelTheme.drawPageDots(dc, _setup.selectedField, _setup.itemCount(), 370);
    }

    function drawEditor(dc, centerX) {
        var index = _setup.selectedField;
        var field = _setup.fieldFor(index);
        if (field == MatchSetupField.MODE) {
            var modes = [MatchMode.CLASSIC, MatchMode.AMERICANO, MatchMode.MEXICANO];
            var labels = ["CLASSIC", "AMERICANO", "MEXICANO"];
            for (var row = 0; row < 3; row += 1) {
                PadelTheme.drawActionButton(dc, 58, 108 + row * 72, 300, 56,
                    _setup.matchMode == modes[row], labels[row]);
            }
            return;
        }
        if (field == MatchSetupField.END_RULE) {
            drawChoiceEditor(dc,
                _setup.pointEndRule == PointMatchEndRule.TOTAL_POINTS,
                "A + B = X", "A = X OR B = X");
            return;
        }
        if (field == MatchSetupField.FIRST_SERVE) {
            drawTeamEditor(dc, centerX);
            return;
        }

        if (field == MatchSetupField.SCORING) {
            drawChoiceEditor(dc,
                _setup.scoringMode == ScoringMode.ADVANTAGE,
                "ADVANTAGE", "NO-AD");
            return;
        } else if (field == MatchSetupField.DECIDER) {
            drawChoiceEditor(dc,
                _setup.decidingSetMode == DecidingSetMode.FULL_SET,
                "FULL SET", "MATCH TIE-BREAK");
            return;
        } else if (field == MatchSetupField.MARGIN) {
            drawChoiceEditor(dc, _setup.requireTwoPointTieBreakMargin,
                "ON", "OFF");
            return;
        }

        PadelTheme.drawCard(dc, 48, 139, 320, 92, true, PadelTheme.CYAN);
        var centerY = 185;
        dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
        dc.drawText(84, centerY, Graphics.FONT_TINY, "-",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(332, centerY, Graphics.FONT_TINY, "+",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(PadelTheme.LINE, Graphics.COLOR_BLACK);
        dc.drawLine(127, 149, 127, 221);
        dc.drawLine(289, 149, 289, 221);
        dc.setColor(PadelTheme.WHITE, Graphics.COLOR_BLACK);
        dc.drawText(centerX, centerY, Graphics.FONT_XTINY, shortValue(index),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    }

    function drawChoiceEditor(dc, firstSelected, firstLabel, secondLabel) {
        PadelTheme.drawActionButton(dc, 58, 124, 300, 56, firstSelected,
            firstLabel);
        PadelTheme.drawActionButton(dc, 58, 202, 300, 56, !firstSelected,
            secondLabel);
    }

    function drawTeamEditor(dc, centerX) {
        var mine = _setup.startingServerTeam == 0;
        PadelTheme.drawCard(dc, 38, 124, 340, 150, true,
            mine ? PadelTheme.CYAN : PadelTheme.RED);
        dc.setColor(PadelTheme.LINE, Graphics.COLOR_BLACK);
        dc.drawLine(centerX, 128, centerX, 270);

        dc.setColor(mine ? PadelTheme.CYAN : PadelTheme.MUTED,
            Graphics.COLOR_BLACK);
        dc.drawText(124, 181, Graphics.FONT_TINY, "A",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(124, 217, Graphics.FONT_XTINY, "MY TEAM",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(!mine ? PadelTheme.RED : PadelTheme.MUTED,
            Graphics.COLOR_BLACK);
        dc.drawText(292, 181, Graphics.FONT_TINY, "B",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(292, 217, Graphics.FONT_XTINY, "OPPONENT",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    }

    function shortTitle(index) {
        var titles = ["MODE", "SETS", "SCORING", "1ST SERVE", "FINAL SET",
            "TIE-BREAK", "MATCH TB", "WIN BY TWO", "END AT", "POINTS X"];
        return titles[_setup.fieldFor(index)];
    }

    function shortValue(index) {
        var field = _setup.fieldFor(index);
        if (field == MatchSetupField.MODE) { return _setup.modeLabel(); }
        if (field == MatchSetupField.END_RULE) {
            return _setup.pointEndRule == PointMatchEndRule.TOTAL_POINTS
                ? "TOTAL X" : "TEAM X";
        }
        if (field == MatchSetupField.POINT_TARGET) { return _setup.pointTarget.toString(); }
        if (field == MatchSetupField.SETS) { return _setup.bestOfSets + " SETS"; }
        if (field == MatchSetupField.SCORING) {
            return _setup.scoringMode == ScoringMode.ADVANTAGE ? "ADV" : "NO-AD";
        }
        if (field == MatchSetupField.FIRST_SERVE) {
            return _setup.startingServerTeam == 0 ? "A TEAM" : "B TEAM";
        }
        if (field == MatchSetupField.DECIDER) {
            return _setup.decidingSetMode == DecidingSetMode.FULL_SET ? "FS" : "MTB";
        }
        if (field == MatchSetupField.TIE_BREAK) { return _setup.regularTieBreakTarget.toString(); }
        if (field == MatchSetupField.MATCH_TB) { return _setup.decidingTieBreakTarget.toString(); }
        return _setup.requireTwoPointTieBreakMargin ? "ON" : "OFF";
    }
}
