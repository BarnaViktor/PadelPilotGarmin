using Toybox.Test as Test;
using Toybox.WatchUi as WatchUi;

(:debug)
class SetupKeyEvent {
    var _key;
    function initialize(key) { _key = key; }
    function getKey() { return _key; }
}

(:debug)
function editSetupField(setup, index, delta, save) {
    setup.selectedField = index;
    Test.assert(setup.beginEditing());
    setup.changeSelected(delta);
    if (save) { setup.saveEditing(); }
    else { setup.cancelEditing(); }
}

(:test)
function setupModesCancelAndKeepHiddenSettings(logger) {
    var setup = new MatchSetupState();
    Test.assertEqual(MatchMode.CLASSIC, setup.matchMode);
    Test.assertEqual(9, setup.itemCount());
    editSetupField(setup, 1, 1, true);
    editSetupField(setup, 2, 1, true);
    editSetupField(setup, 0, 1, false);
    Test.assertEqual(MatchMode.CLASSIC, setup.matchMode);
    Test.assertEqual(9, setup.itemCount());
    editSetupField(setup, 0, 1, true);
    Test.assertEqual(MatchMode.AMERICANO, setup.matchMode);
    Test.assertEqual(5, setup.itemCount());
    editSetupField(setup, 1, 1, true);
    editSetupField(setup, 2, -1, true);
    editSetupField(setup, 3, 1, true);
    editSetupField(setup, 0, 1, false);
    Test.assertEqual(MatchMode.AMERICANO, setup.matchMode);
    editSetupField(setup, 0, 1, true);
    Test.assertEqual(MatchMode.MEXICANO, setup.matchMode);
    editSetupField(setup, 0, 1, true);
    Test.assertEqual(MatchMode.CLASSIC, setup.matchMode);
    Test.assertEqual(5, setup.bestOfSets);
    Test.assertEqual(ScoringMode.NO_AD, setup.scoringMode);
    Test.assertEqual(1, setup.startingServerTeam);
    editSetupField(setup, 0, -1, true);
    Test.assertEqual(MatchMode.MEXICANO, setup.matchMode);
    Test.assertEqual(PointMatchEndRule.TEAM_TARGET, setup.pointEndRule);
    Test.assertEqual(23, setup.pointTarget);
    // Navigation cannot change the field being edited, even across modes.
    setup.selectedField = 0;
    setup.beginEditing();
    setup.changeSelected(1);
    setup.moveSelection(1);
    Test.assertEqual(0, setup.selectedField);
    setup.cancelEditing();
    Test.assertEqual(MatchMode.MEXICANO, setup.matchMode);
    return true;
}

(:test)
function setupPointFieldsCancelAndTargetUsesSingleSteps(logger) {
    var setup = new MatchSetupState();
    setup.matchMode = MatchMode.AMERICANO;
    for (var field = 1; field < setup.fieldCount(); field += 1) {
        var original = setup.valueFor(field);
        editSetupField(setup, field, 1, false);
        Test.assertEqual(original, setup.valueFor(field));
    }
    setup.pointTarget = 17;
    editSetupField(setup, 2, 1, true);
    Test.assertEqual(18, setup.pointTarget);
    editSetupField(setup, 2, -1, true);
    Test.assertEqual(17, setup.pointTarget);
    setup.pointTarget = 1;
    editSetupField(setup, 2, -1, true);
    Test.assertEqual(1, setup.pointTarget);
    setup.pointTarget = MatchSetupField.MAX_POINT_TARGET;
    editSetupField(setup, 2, 1, true);
    Test.assertEqual(MatchSetupField.MAX_POINT_TARGET, setup.pointTarget);
    setup.selectedField = setup.fieldCount();
    Test.assert(!setup.beginEditing());
    setup.moveSelection(1);
    Test.assertEqual(0, setup.selectedField);
    setup.moveSelection(-1);
    Test.assert(setup.isStartGameSelected());
    return true;
}

(:test)
function setupStartsFreshEngineWithEveryPointCombination(logger) {
    var setup = new MatchSetupState();
    for (var mode = MatchMode.AMERICANO; mode <= MatchMode.MEXICANO; mode += 1) {
        for (var rule = PointMatchEndRule.TOTAL_POINTS;
                rule <= PointMatchEndRule.TEAM_TARGET; rule += 1) {
            for (var team = 0; team < 2; team += 1) {
                setup.matchMode = mode;
                setup.pointEndRule = rule;
                setup.pointTarget = 17;
                setup.startingServerTeam = team;
                var engine = setup.createEngine();
                Test.assert(engine instanceof PointMatchEngine);
                Test.assertEqual(mode == MatchMode.AMERICANO
                    ? PointMatchMode.AMERICANO : PointMatchMode.MEXICANO, engine.getMode());
                Test.assertEqual(rule, engine.getEndRule());
                Test.assertEqual(17, engine.getTarget());
                Test.assertEqual(team, engine.getStartingServerTeam());
                Test.assertEqual(0, engine.getPoints()[0]);
                Test.assertEqual(0, engine.getPoints()[1]);
                engine.awardPoint(0);
                var next = setup.createEngine();
                Test.assertEqual(0, next.getPoints()[0]);
                setup.pointTarget = 18;
                Test.assertEqual(17, engine.getTarget());
                Test.assertEqual(17, next.getTarget());
            }
        }
    }
    setup.matchMode = MatchMode.CLASSIC;
    setup.bestOfSets = 5;
    setup.scoringMode = ScoringMode.NO_AD;
    setup.decidingSetMode = DecidingSetMode.FULL_SET;
    setup.regularTieBreakTarget = 9;
    setup.decidingTieBreakTarget = 13;
    setup.requireTwoPointTieBreakMargin = false;
    var classic = setup.createEngine();
    Test.assert(classic instanceof ScoringEngine);
    Test.assertEqual(5, classic.getConfig().bestOfSets);
    Test.assertEqual(ScoringMode.NO_AD, classic.getConfig().scoringMode);
    Test.assertEqual(DecidingSetMode.FULL_SET, classic.getConfig().decidingSetMode);
    Test.assertEqual(1, classic.getConfig().startingServerTeam);
    Test.assertEqual(9, classic.getConfig().regularTieBreakTarget);
    Test.assertEqual(13, classic.getConfig().decidingTieBreakTarget);
    Test.assert(!classic.getConfig().requireTwoPointTieBreakMargin);
    return true;
}

(:test)
function setupPhysicalButtonsSaveAndCancelAcrossModes(logger) {
    var setup = new MatchSetupState();
    var delegate = new SetupInputDelegate(setup);
    Test.assert(delegate.onKey(new SetupKeyEvent(WatchUi.KEY_ENTER)));
    // Follow the displayed CLASSIC / AMERICANO / MEXICANO row order,
    // including wrapping at both ends while the visible setup fields change.
    var downwardModes = [MatchMode.AMERICANO, MatchMode.MEXICANO, MatchMode.CLASSIC];
    var upwardModes = [MatchMode.MEXICANO, MatchMode.AMERICANO, MatchMode.CLASSIC];
    for (var i = 0; i < downwardModes.size(); i += 1) {
        Test.assert(delegate.onKey(new SetupKeyEvent(WatchUi.KEY_DOWN)));
        Test.assertEqual(downwardModes[i], setup.matchMode);
        Test.assertEqual(0, setup.selectedField);
        Test.assert(setup.editing);
    }
    for (var i = 0; i < upwardModes.size(); i += 1) {
        Test.assert(delegate.onKey(new SetupKeyEvent(WatchUi.KEY_UP)));
        Test.assertEqual(upwardModes[i], setup.matchMode);
        Test.assertEqual(0, setup.selectedField);
        Test.assert(setup.editing);
    }
    Test.assert(delegate.onKey(new SetupKeyEvent(WatchUi.KEY_UP)));
    Test.assertEqual(MatchMode.MEXICANO, setup.matchMode);
    Test.assert(delegate.onKey(new SetupKeyEvent(WatchUi.KEY_ESC)));
    Test.assertEqual(MatchMode.CLASSIC, setup.matchMode);
    delegate.onKey(new SetupKeyEvent(WatchUi.KEY_ENTER));
    delegate.onKey(new SetupKeyEvent(WatchUi.KEY_DOWN));
    delegate.onKey(new SetupKeyEvent(WatchUi.KEY_ENTER));
    Test.assertEqual(MatchMode.AMERICANO, setup.matchMode);
    // Rule, target and team: modify, cancel, modify again, then save.
    for (var field = 1; field < setup.fieldCount(); field += 1) {
        delegate.onKey(new SetupKeyEvent(WatchUi.KEY_DOWN));
        var original = setup.valueFor(field);
        delegate.onKey(new SetupKeyEvent(WatchUi.KEY_ENTER));
        delegate.onKey(new SetupKeyEvent(WatchUi.KEY_UP));
        delegate.onKey(new SetupKeyEvent(WatchUi.KEY_ESC));
        Test.assertEqual(original, setup.valueFor(field));
        delegate.onKey(new SetupKeyEvent(WatchUi.KEY_ENTER));
        delegate.onKey(new SetupKeyEvent(WatchUi.KEY_UP));
        delegate.onKey(new SetupKeyEvent(WatchUi.KEY_ENTER));
        Test.assert(setup.valueFor(field) != original);
        if (setup.fieldFor(field) == MatchSetupField.POINT_TARGET) {
            Test.assertEqual(original + 1, setup.pointTarget);
            delegate.onKey(new SetupKeyEvent(WatchUi.KEY_ENTER));
            delegate.onKey(new SetupKeyEvent(WatchUi.KEY_DOWN));
            delegate.onKey(new SetupKeyEvent(WatchUi.KEY_ENTER));
            Test.assertEqual(original, setup.pointTarget);
        }
    }
    Test.assert(!delegate.onKey(new SetupKeyEvent(WatchUi.KEY_ESC)));
    return true;
}

(:test)
function setupLabelsShowModesRulesAndFrozenStartSettings(logger) {
    var setup = new MatchSetupState();
    for (var mode = MatchMode.AMERICANO; mode <= MatchMode.MEXICANO; mode += 1) {
        setup.matchMode = mode;
        var dc = captureHistoryText(new SetupView(setup));
        Test.assert(dc.hasText("MODE: " + setup.modeLabel()));
        Test.assert(dc.hasText("TOTAL X") && dc.hasText("24"));
        setup.selectedField = 1;
        setup.beginEditing();
        dc = captureHistoryText(new SetupView(setup));
        Test.assert(dc.hasText("A + B = X") && dc.hasText("A = X OR B = X"));
        setup.cancelEditing();
        setup.pointEndRule = PointMatchEndRule.TEAM_TARGET;
        setup.pointTarget = 999;
        setup.startingServerTeam = 1;
        dc = captureHistoryText(new PointMatchStartView(setup.createEngine()));
        Test.assert(dc.hasText(setup.modeLabel()) && dc.hasText("TEAM TARGET: 999"));
        Test.assert(dc.hasText("1ST SERVE: B") && dc.hasText("0"));
        setup = new MatchSetupState();
    }
    return true;
}
