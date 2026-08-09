using Toybox.Test as Test;
using Toybox.Application.Storage as Storage;
using Toybox.Lang as Lang;

function createAdvantageMatch() {
    return new ScoringEngine(new MatchConfig(
        3,
        ScoringMode.ADVANTAGE,
        DecidingSetMode.FULL_SET,
        0,
        7,
        10,
        true
    ));
}

function winGame(engine, team) {
    for (var point = 0; point < 4; point += 1) {
        engine.awardPoint(team);
    }
}

function winSet(engine, team) {
    for (var game = 0; game < 6; game += 1) {
        winGame(engine, team);
    }
}

(:test)
function advantageReturnsToDeuce(logger) {
    var engine = createAdvantageMatch();

    for (var point = 0; point < 3; point += 1) {
        engine.awardPoint(0);
        engine.awardPoint(1);
    }

    engine.awardPoint(0);
    Test.assertEqual("AD", engine.pointLabel(0));
    engine.awardPoint(1);

    Test.assertEqual("40", engine.pointLabel(0));
    Test.assertEqual("40", engine.pointLabel(1));
    return true;
}

(:test)
function noAdDecidingPointCompletesGame(logger) {
    var engine = new ScoringEngine(new MatchConfig(
        3,
        ScoringMode.NO_AD,
        DecidingSetMode.FULL_SET,
        0,
        7,
        10,
        true
    ));

    for (var point = 0; point < 3; point += 1) {
        engine.awardPoint(0);
        engine.awardPoint(1);
    }
    engine.awardPoint(1);

    Test.assertEqual(1, engine.getGames()[1]);
    Test.assertEqual(0, engine.getPoints()[0]);
    Test.assertEqual(0, engine.getPoints()[1]);
    return true;
}

(:test)
function setEndsAtSixFour(logger) {
    var engine = createAdvantageMatch();

    for (var game = 0; game < 4; game += 1) {
        winGame(engine, 0);
        winGame(engine, 1);
    }
    winGame(engine, 0);
    winGame(engine, 0);

    Test.assertEqual(1, engine.getSets()[0]);
    Test.assertEqual(0, engine.getGames()[0]);
    Test.assertEqual(0, engine.getGames()[1]);
    return true;
}

(:test)
function regularTieBreakEndsSet(logger) {
    var engine = createAdvantageMatch();

    for (var game = 0; game < 6; game += 1) {
        winGame(engine, 0);
        winGame(engine, 1);
    }

    Test.assert(engine.isTieBreak());
    for (var point = 0; point < 5; point += 1) {
        engine.awardPoint(0);
        engine.awardPoint(1);
    }
    engine.awardPoint(0);
    engine.awardPoint(0);

    Test.assertEqual(1, engine.getSets()[0]);
    Test.assert(!engine.isTieBreak());
    return true;
}

(:test)
function decidingMatchTieBreakStartsAtOneSetAll(logger) {
    var engine = new ScoringEngine(new MatchConfig(
        3,
        ScoringMode.ADVANTAGE,
        DecidingSetMode.MATCH_TIEBREAK,
        0,
        7,
        10,
        true
    ));

    winSet(engine, 0);
    winSet(engine, 1);

    Test.assert(engine.isTieBreak());
    Test.assert(engine.isDecidingMatchTieBreak());

    for (var point = 0; point < 10; point += 1) {
        engine.awardPoint(0);
    }

    Test.assertEqual(0, engine.getMatchWinner());
    return true;
}

(:test)
function startingServerIsApplied(logger) {
    var engine = new ScoringEngine(new MatchConfig(
        3,
        ScoringMode.ADVANTAGE,
        DecidingSetMode.FULL_SET,
        1,
        7,
        10,
        true
    ));

    Test.assertEqual(1, engine.getServerTeam());
    Test.assertEqual("OPP-1", engine.serverLabel());
    return true;
}

(:test)
function serverChangesAfterGame(logger) {
    var engine = createAdvantageMatch();

    Test.assertEqual(0, engine.getServerTeam());
    winGame(engine, 0);

    Test.assertEqual(1, engine.getServerTeam());
    Test.assertEqual("OPP-1", engine.serverLabel());
    return true;
}

(:test)
function serverSlotChangesOnTeamNextServiceGame(logger) {
    var engine = createAdvantageMatch();

    winGame(engine, 0);
    winGame(engine, 1);

    Test.assertEqual(0, engine.getServerTeam());
    Test.assertEqual("MY-2", engine.serverLabel());
    return true;
}

(:test)
function tieBreakServeOrderUsesOneThenTwoPoints(logger) {
    var engine = createAdvantageMatch();

    for (var game = 0; game < 6; game += 1) {
        winGame(engine, 0);
        winGame(engine, 1);
    }

    Test.assert(engine.isTieBreak());
    Test.assertEqual(0, engine.getServerTeam());

    engine.awardPoint(0);
    Test.assertEqual(1, engine.getServerTeam());
    engine.awardPoint(0);
    Test.assertEqual(1, engine.getServerTeam());
    engine.awardPoint(0);
    Test.assertEqual(0, engine.getServerTeam());
    return true;
}

(:test)
function nextSetStartsWithNextServerAfterSixFour(logger) {
    var engine = createAdvantageMatch();

    for (var game = 0; game < 4; game += 1) {
        winGame(engine, 0);
        winGame(engine, 1);
    }
    winGame(engine, 0);
    winGame(engine, 0);

    Test.assertEqual(1, engine.getSets()[0]);
    Test.assertEqual(0, engine.getGames()[0]);
    Test.assertEqual(0, engine.getGames()[1]);
    Test.assertEqual(0, engine.getServerTeam());
    return true;
}

(:test)
function decidingMatchTieBreakHonorsTwoPointMargin(logger) {
    var engine = new ScoringEngine(new MatchConfig(
        3,
        ScoringMode.ADVANTAGE,
        DecidingSetMode.MATCH_TIEBREAK,
        0,
        7,
        10,
        true
    ));

    winSet(engine, 0);
    winSet(engine, 1);

    for (var point = 0; point < 9; point += 1) {
        engine.awardPoint(0);
        engine.awardPoint(1);
    }
    engine.awardPoint(0);
    Test.assert(engine.getMatchWinner() == null);
    engine.awardPoint(0);
    Test.assertEqual(0, engine.getMatchWinner());
    return true;
}

(:test)
function noAdDecidingPointCanBeWonByEitherTeam(logger) {
    var engine = new ScoringEngine(new MatchConfig(
        1,
        ScoringMode.NO_AD,
        DecidingSetMode.FULL_SET,
        0,
        7,
        10,
        true
    ));

    for (var point = 0; point < 3; point += 1) {
        engine.awardPoint(0);
        engine.awardPoint(1);
    }
    engine.awardPoint(0);

    Test.assertEqual(1, engine.getGames()[0]);
    Test.assertEqual(0, engine.getGames()[1]);
    return true;
}

(:test)
function undoRestoresCompleteStateAfterSet(logger) {
    var engine = createAdvantageMatch();

    for (var game = 0; game < 5; game += 1) {
        winGame(engine, 0);
    }
    for (var point = 0; point < 3; point += 1) {
        engine.awardPoint(0);
    }
    var serverBeforeSetPoint = engine.getServerTeam();
    var labelBeforeSetPoint = engine.serverLabel();

    engine.awardPoint(0);
    Test.assertEqual(1, engine.getSets()[0]);

    Test.assert(engine.undoLastPoint());
    Test.assertEqual(0, engine.getSets()[0]);
    Test.assertEqual(5, engine.getGames()[0]);
    Test.assertEqual("40", engine.pointLabel(0));
    Test.assertEqual(serverBeforeSetPoint, engine.getServerTeam());
    Test.assertEqual(labelBeforeSetPoint, engine.serverLabel());
    return true;
}

(:test)
function undoRestoresPreviousState(logger) {
    var engine = createAdvantageMatch();

    engine.awardPoint(0);
    engine.awardPoint(0);
    Test.assertEqual("30", engine.pointLabel(0));

    Test.assert(engine.undoLastPoint());
    Test.assertEqual("15", engine.pointLabel(0));
    return true;
}

(:test)
function serverTeamCanBeChangedWhilePaused(logger) {
    var engine = createAdvantageMatch();

    Test.assert(engine.setServerTeam(1));
    Test.assertEqual(1, engine.getServerTeam());
    Test.assertEqual("OPP-1", engine.serverLabel());

    winGame(engine, 0);
    Test.assertEqual(0, engine.getServerTeam());
    return true;
}

(:test)
function manualTieBreakServerChangeKeepsRotation(logger) {
    var engine = createAdvantageMatch();

    for (var game = 0; game < 6; game += 1) {
        winGame(engine, 0);
        winGame(engine, 1);
    }

    engine.awardPoint(0);
    Test.assertEqual(1, engine.getServerTeam());

    Test.assert(engine.setServerTeam(0));
    engine.awardPoint(0);
    Test.assertEqual(0, engine.getServerTeam());
    engine.awardPoint(0);
    Test.assertEqual(1, engine.getServerTeam());
    return true;
}

(:test)
function setupEditorSavesAndCancelsValues(logger) {
    var setup = new MatchSetupState();

    Test.assert(setup.beginEditing());
    setup.changeSelected(1);
    setup.saveEditing();
    Test.assertEqual(5, setup.bestOfSets);

    Test.assert(setup.beginEditing());
    setup.changeSelected(1);
    setup.cancelEditing();
    Test.assertEqual(5, setup.bestOfSets);
    return true;
}

(:test)
function startGameItemCannotBeEdited(logger) {
    var setup = new MatchSetupState();

    setup.selectedField = setup.itemCount() - 1;
    Test.assert(setup.isStartGameSelected());
    Test.assert(!setup.beginEditing());

    setup.selectedField = setup.fieldCount();
    Test.assert(setup.isHistorySelected());
    Test.assert(!setup.beginEditing());
    return true;
}

(:test)
function serveSideAlternatesEveryPointAndResetsWithGame(logger) {
    var engine = createAdvantageMatch();

    Test.assertEqual(0, engine.getServeSide());
    engine.awardPoint(0);
    Test.assertEqual(1, engine.getServeSide());
    engine.awardPoint(0);
    Test.assertEqual(0, engine.getServeSide());
    engine.awardPoint(0);
    Test.assertEqual(1, engine.getServeSide());
    engine.awardPoint(0);

    Test.assertEqual(0, engine.getServeSide());
    Test.assertEqual(1, engine.getServerTeam());
    return true;
}

(:test)
function serveSideCanBeSelectedAndKeepsAlternating(logger) {
    var engine = createAdvantageMatch();

    engine.awardPoint(0);
    Test.assertEqual(1, engine.getServeSide());
    Test.assert(engine.setServeSide(0));
    Test.assertEqual(0, engine.getServeSide());

    engine.awardPoint(0);
    Test.assertEqual(1, engine.getServeSide());
    Test.assert(engine.undoLastPoint());
    Test.assertEqual(0, engine.getServeSide());
    return true;
}

(:test)
function completedSetScoreIsStoredAndUndoRestoresIt(logger) {
    var engine = createAdvantageMatch();

    for (var game = 0; game < 5; game += 1) {
        winGame(engine, 0);
    }
    for (var point = 0; point < 3; point += 1) {
        engine.awardPoint(0);
    }
    engine.awardPoint(0);

    Test.assertEqual(1, engine.getCompletedSets().size());
    Test.assertEqual(6, engine.getCompletedSets()[0][0]);
    Test.assertEqual(0, engine.getCompletedSets()[0][1]);
    Test.assert(!engine.getCompletedSets()[0][2]);

    Test.assert(engine.undoLastPoint());
    Test.assertEqual(0, engine.getCompletedSets().size());
    return true;
}

(:test)
function completedMatchCanBeSavedLocally(logger) {
    Storage.deleteValue(MatchHistoryStore.HISTORY_KEY);
    var engine = new ScoringEngine(new MatchConfig(
        1,
        ScoringMode.ADVANTAGE,
        DecidingSetMode.FULL_SET,
        0,
        7,
        10,
        true
    ));

    winSet(engine, 0);
    MatchHistoryStore.save(engine, 123);

    var storedHistory = Storage.getValue(MatchHistoryStore.HISTORY_KEY);
    Test.assert(storedHistory instanceof Lang.Array);
    if (!(storedHistory instanceof Lang.Array)) {
        return false;
    }

    var history = storedHistory as Lang.Array<Storage.ValueType>;
    Test.assertEqual(1, history.size());
    Storage.deleteValue(MatchHistoryStore.HISTORY_KEY);
    return true;
}

(:test)
function activeMatchRoundTripRestoresScoreServeAndTime(logger) {
    ActiveMatchStore.clear();
    var engine = createAdvantageMatch();
    engine.awardPoint(0);
    engine.awardPoint(1);
    engine.awardPoint(0);
    engine.setServerTeam(1);
    engine.setServeSide(0);

    ActiveMatchStore.save(engine, 87);
    var loaded = ActiveMatchStore.load();
    Test.assert(loaded != null);
    if (loaded == null) {
        return false;
    }

    var restored = loaded[0];
    Test.assertEqual(87, loaded[1]);
    Test.assertEqual(engine.getPoints()[0], restored.getPoints()[0]);
    Test.assertEqual(engine.getPoints()[1], restored.getPoints()[1]);
    Test.assertEqual(1, restored.getServerTeam());
    Test.assertEqual(0, restored.getServeSide());
    ActiveMatchStore.clear();
    return true;
}

(:test)
function corruptActiveMatchIsDiscardedSafely(logger) {
    Storage.setValue(ActiveMatchStore.ACTIVE_KEY, [999, "broken"]);

    Test.assert(ActiveMatchStore.load() == null);
    Test.assert(Storage.getValue(ActiveMatchStore.ACTIVE_KEY) == null);
    return true;
}

(:test)
function corruptHistoryRecordsAreFiltered(logger) {
    Storage.setValue(MatchHistoryStore.HISTORY_KEY, [["broken"]]);

    var history = MatchHistoryStore.load();
    Test.assertEqual(0, history.size());
    Storage.deleteValue(MatchHistoryStore.HISTORY_KEY);
    return true;
}

(:test)
function fitSetScoreLabelContainsEveryCompletedSet(logger) {
    var engine = createAdvantageMatch();
    winSet(engine, 0);

    Test.assertEqual("6-0", PadelActivityRecorder.buildSetScores(engine));
    return true;
}

(:test)
function fitSessionStartsRecordsAndDiscards(logger) {
    var engine = createAdvantageMatch();

    Test.assert(PadelActivityRecorder.start(engine));
    var completedSetsBeforePoint = engine.getCompletedSets().size();
    engine.awardPoint(0);
    PadelActivityRecorder.recordPoint(0, engine, completedSetsBeforePoint);
    Test.assert(PadelActivityRecorder.finish(engine, false));
    return true;
}
