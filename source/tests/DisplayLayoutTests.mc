using Toybox.Test as Test;

// Checks drawing geometry without allocating a full-screen bitmap on the
// 128 KiB Enduro. Native font metrics, contrast and the circular mask still
// need visual verification in the simulator and on a watch.
(:debug)
class LayoutBoundsDc {
    var _size;
    var drawCount;

    function initialize(size) {
        _size = size;
        drawCount = 0;
    }

    function getWidth() { return _size; }
    function getHeight() { return _size; }
    function clear() {}
    function setColor(foreground, background) {}
    function setPenWidth(width) { Test.assert(width >= 1); }

    function point(x, y) {
        Test.assert(x >= 0 && x <= _size && y >= 0 && y <= _size);
        drawCount += 1;
    }

    function rectangle(x, y, width, height) {
        Test.assert(width > 0 && height > 0);
        point(x, y);
        point(x + width, y + height);
    }

    function drawText(x, y, font, text, justification) { point(x, y); }
    function drawLine(x1, y1, x2, y2) { point(x1, y1); point(x2, y2); }
    function drawCircle(x, y, radius) {
        Test.assert(radius > 0);
        point(x - radius, y - radius);
        point(x + radius, y + radius);
    }
    function fillCircle(x, y, radius) { drawCircle(x, y, radius); }
    function drawArc(x, y, radius, direction, start, end) { drawCircle(x, y, radius); }
    function fillRectangle(x, y, width, height) { rectangle(x, y, width, height); }
    function drawRoundedRectangle(x, y, width, height, radius) {
        rectangle(x, y, width, height);
    }
    function fillRoundedRectangle(x, y, width, height, radius) {
        rectangle(x, y, width, height);
    }
}

(:debug)
function assertLayoutBounds(view, size) {
    var dc = new LayoutBoundsDc(size);
    view.onUpdate(dc);
    Test.assert(dc.drawCount > 0);
}

(:debug)
function checkSetupLayouts(size) {
    assertLayoutBounds(new HomeView(), size);
    var setup = new MatchSetupState();
    var view = new SetupView(setup);
    for (var field = 0; field < setup.itemCount(); field += 1) {
        setup.selectedField = field;
        assertLayoutBounds(view, size);
        if (setup.beginEditing()) {
            assertLayoutBounds(view, size);
            setup.changeSelected(1);
            assertLayoutBounds(view, size);
            setup.cancelEditing();
        }
    }
}

(:debug)
function checkMatchLayouts(size) {
    var engine = new ScoringEngine(new MatchConfig(
        1, ScoringMode.ADVANTAGE, DecidingSetMode.FULL_SET, 0, 7, 10, true));
    engine.awardPoint(0);
    engine.awardPoint(1);
    var view = new ScoreView(engine, 30, []);
    assertLayoutBounds(view, size);
    view.setPaused(true);
    assertLayoutBounds(view, size);
    view.setPauseServerPicker(true);
    for (var quadrant = 0; quadrant < 4; quadrant += 1) {
        assertLayoutBounds(view, size);
        view.moveServerPickerSelection(1);
    }
    view.setPauseServerPicker(false);
    view.showSavePauseDecision();
    assertLayoutBounds(view, size);
    view.showDiscardPauseDecision();
    assertLayoutBounds(view, size);
    view.clearPauseDecision();
    assertLayoutBounds(new RecoveryView([engine, 30, []]), size);
    // The opponent already has one point, so finish the current game first.
    for (var point = 0; point < 23; point += 1) {
        engine.awardPoint(0);
    }
    Test.assert(engine.getMatchWinner() == 0);
    view.completeMatch();
    assertLayoutBounds(view, size);
    view.changeSummaryPage(1);
    assertLayoutBounds(view, size);
    view.setFinishMenu(true);
    assertLayoutBounds(view, size);
}

(:debug)
function checkHistoryLayouts(size) {
    var completed = [1, 0, 0, 120, [[6, 0, false]], [120], 2, 0,
        [0, 0, 0, 0, false, false]];
    var stopped = [0, 0, -1, 30, [], [], 2, 1,
        [2, 1, 3, 2, false, false]];
    var history = new MatchHistoryView();
    history._history = [];
    assertLayoutBounds(history, size);
    history._history = [completed, stopped];
    assertLayoutBounds(history, size);
    var stats = new MatchHistoryStatsView(history._history);
    for (var statsPage = 0; statsPage < stats.getPageCount();
            statsPage += 1) {
        assertLayoutBounds(stats, size);
        stats.movePage(1);
    }
    for (var index = 0; index < 2; index += 1) {
        var detail = new MatchHistoryDetailView(history._history[index]);
        for (var page = 0; page < detail.getPageCount(); page += 1) {
            assertLayoutBounds(detail, size);
            detail.movePage(1);
        }
        detail.setDeleteConfirm(true);
        assertLayoutBounds(detail, size);
        detail.moveDeleteSelection();
        assertLayoutBounds(detail, size);
    }
}

(:test)
function enduroSetupLayoutsStayWithinDisplay(logger) {
    checkSetupLayouts(280);
    return true;
}

(:test)
function enduroMatchLayoutsStayWithinDisplay(logger) {
    checkMatchLayouts(280);
    return true;
}

(:test)
function enduroHistoryLayoutsStayWithinDisplay(logger) {
    checkHistoryLayouts(280);
    return true;
}

(:test)
function amoledLayoutsStayWithinDisplay(logger) {
    checkSetupLayouts(416);
    checkMatchLayouts(416);
    checkHistoryLayouts(416);
    return true;
}
