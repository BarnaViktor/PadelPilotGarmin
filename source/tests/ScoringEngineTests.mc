using Toybox.Test as Test;
using Toybox.Application.Storage as Storage;
using Toybox.Lang as Lang;

(:test)
function pointInputGuardRejectsRapidRepeatedInput(logger) {
    var guard = new PointInputGuard(500);

    Test.assert(guard.accept(1000));
    Test.assert(!guard.accept(1499));
    Test.assert(guard.accept(1500));
    return true;
}

(:test)
function pointInputGuardResetAllowsImmediateCorrection(logger) {
    var guard = new PointInputGuard(500);

    Test.assert(guard.accept(1000));
    guard.reset();
    Test.assert(guard.accept(1100));
    return true;
}

(:test)
function pointInputGuardRecoversAfterTimerWrap(logger) {
    var guard = new PointInputGuard(500);

    Test.assert(guard.accept(2147483600));
    Test.assert(guard.accept(-2147483600));
    return true;
}

(:test)
function undoHistoryRemainsBoundedDuringLongMatch(logger) {
    var engine = createAdvantageMatch();

    for (var point = 0; point < 1000; point += 1) {
        Test.assert(engine.awardPoint(point % 2));
    }

    Test.assert(engine.getMatchWinner() == null);
    for (var undo = 0; undo < 20; undo += 1) {
        Test.assert(engine.undoLastPoint());
    }
    Test.assert(!engine.undoLastPoint());
    return true;
}

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
    if (engine.isSideChangePending()) {
        engine.acknowledgeSideChange();
    }
}

function playPoint(engine, team) {
    var awarded = engine.awardPoint(team);
    if (engine.isSideChangePending()) {
        engine.acknowledgeSideChange();
    }
    return awarded;
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
        playPoint(engine, 0);
        playPoint(engine, 1);
    }
    playPoint(engine, 0);
    playPoint(engine, 0);

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
        playPoint(engine, 0);
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
        playPoint(engine, 0);
        playPoint(engine, 1);
    }
    playPoint(engine, 0);
    Test.assert(engine.getMatchWinner() == null);
    playPoint(engine, 0);
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
function noAdDecidingPointDoesNotInterruptPlay(logger) {
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

    Test.assert(!engine.isReceiverSideSelectionPending());
    Test.assert(engine.awardPoint(0));
    Test.assertEqual(1, engine.getGames()[0]);
    return true;
}

(:test)
function undoNoAdDecidingPointRestoresDeuce(logger) {
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
    engine.awardPoint(1);

    Test.assert(engine.undoLastPoint());
    Test.assert(!engine.isReceiverSideSelectionPending());
    Test.assertEqual("40", engine.pointLabel(0));
    Test.assertEqual("40", engine.pointLabel(1));
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
    Test.assert(!setup.isHistorySelected());
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
function pointInputContinuesAfterOddGame(logger) {
    var engine = createAdvantageMatch();

    for (var point = 0; point < 4; point += 1) {
        engine.awardPoint(0);
    }

    Test.assert(!engine.isSideChangePending());
    Test.assert(engine.awardPoint(1));
    return true;
}

(:test)
function sideChangeIsNotRequiredAfterEvenGame(logger) {
    var engine = createAdvantageMatch();

    winGame(engine, 0);
    for (var point = 0; point < 4; point += 1) {
        engine.awardPoint(1);
    }

    Test.assert(!engine.isSideChangePending());
    return true;
}

(:test)
function tieBreakContinuesAfterEverySixPoints(logger) {
    var engine = createAdvantageMatch();
    for (var game = 0; game < 6; game += 1) {
        winGame(engine, 0);
        winGame(engine, 1);
    }

    for (var point = 0; point < 5; point += 1) {
        engine.awardPoint(point % 2);
    }
    Test.assert(!engine.isSideChangePending());

    engine.awardPoint(1);
    Test.assert(!engine.isSideChangePending());
    Test.assert(engine.awardPoint(0));
    return true;
}

(:test)
function regularTieBreakSetEndDoesNotBlockNextSet(logger) {
    var engine = createAdvantageMatch();
    for (var game = 0; game < 6; game += 1) {
        winGame(engine, 0);
        winGame(engine, 1);
    }

    for (var point = 0; point < 5; point += 1) {
        playPoint(engine, 0);
        playPoint(engine, 1);
    }
    playPoint(engine, 0);
    engine.awardPoint(0);

    Test.assertEqual(1, engine.getSets()[0]);
    Test.assert(!engine.isSideChangePending());
    return true;
}

(:test)
function undoRestoresStateAfterGame(logger) {
    var engine = createAdvantageMatch();
    for (var point = 0; point < 3; point += 1) {
        engine.awardPoint(0);
    }

    engine.awardPoint(0);
    Test.assert(!engine.isSideChangePending());
    Test.assert(engine.undoLastPoint());
    Test.assert(!engine.isSideChangePending());
    Test.assertEqual("40", engine.pointLabel(0));
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
    MatchHistoryStore.save(engine, 123, [123]);

    var storedHistory = Storage.getValue(MatchHistoryStore.HISTORY_KEY);
    Test.assert(storedHistory instanceof Lang.Array);
    if (!(storedHistory instanceof Lang.Array)) {
        return false;
    }

    var history = storedHistory as Lang.Array<Storage.ValueType>;
    Test.assertEqual(1, history.size());
    var record = history[0] as Lang.Array<Storage.ValueType>;
    Test.assertEqual(9, record.size());
    var setEndTimes = record[5] as Lang.Array<Storage.ValueType>;
    Test.assertEqual(1, setEndTimes.size());
    Test.assertEqual(123, setEndTimes[0]);
    Test.assertEqual(MatchHistoryStore.RECORD_VERSION, record[6]);
    Test.assertEqual(MatchHistoryStore.STATUS_COMPLETE, record[7]);
    Storage.deleteValue(MatchHistoryStore.HISTORY_KEY);
    return true;
}

(:test)
function stoppedMatchKeepsCurrentGameAndPointScore(logger) {
    Storage.deleteValue(MatchHistoryStore.HISTORY_KEY);
    var engine = createAdvantageMatch();
    winGame(engine, 0);
    engine.awardPoint(0);
    engine.awardPoint(1);
    engine.awardPoint(0);

    Test.assert(MatchHistoryStore.saveStopped(engine, 87, []));
    var history = MatchHistoryStore.load();
    Test.assertEqual(1, history.size());
    var record = history[0];
    Test.assert(MatchHistoryStore.isStopped(record));
    Test.assertEqual(-1, record[2]);
    Test.assertEqual(MatchHistoryStore.STATUS_STOPPED, record[7]);

    var currentState = MatchHistoryStore.getCurrentState(record);
    Test.assertEqual(1, currentState[0]);
    Test.assertEqual(0, currentState[1]);
    Test.assertEqual(2, currentState[2]);
    Test.assertEqual(1, currentState[3]);
    Test.assert(!currentState[4]);
    Test.assert(!currentState[5]);
    Storage.deleteValue(MatchHistoryStore.HISTORY_KEY);
    return true;
}

(:test)
function stoppedMatchKeepsTieBreakState(logger) {
    Storage.deleteValue(MatchHistoryStore.HISTORY_KEY);
    var engine = createAdvantageMatch();
    for (var game = 0; game < 6; game += 1) {
        winGame(engine, 0);
        winGame(engine, 1);
    }
    engine.awardPoint(0);
    engine.awardPoint(1);
    engine.awardPoint(0);

    Test.assert(MatchHistoryStore.saveStopped(engine, 160, []));
    var record = MatchHistoryStore.load()[0];
    var currentState = MatchHistoryStore.getCurrentState(record);
    Test.assertEqual(6, currentState[0]);
    Test.assertEqual(6, currentState[1]);
    Test.assertEqual(2, currentState[2]);
    Test.assertEqual(1, currentState[3]);
    Test.assert(currentState[4]);
    Test.assert(!currentState[5]);
    Storage.deleteValue(MatchHistoryStore.HISTORY_KEY);
    return true;
}

(:test)
function legacyHistoryRecordsRemainReadable(logger) {
    Storage.setValue(MatchHistoryStore.HISTORY_KEY, [[
        1, 0, 0, 123, [[6, 4, false]], [123]
    ]]);

    var history = MatchHistoryStore.load();
    Test.assertEqual(1, history.size());
    Test.assert(!MatchHistoryStore.isStopped(history[0]));
    Test.assertEqual(6, history[0].size());
    Storage.deleteValue(MatchHistoryStore.HISTORY_KEY);
    return true;
}

(:test)
function historyDeletionUsesStorageIndexAndPreservesOrder(logger) {
    Storage.deleteValue(MatchHistoryStore.HISTORY_KEY);
    var engine = createAdvantageMatch();
    Test.assert(MatchHistoryStore.saveStopped(engine, 10, []));
    Test.assert(MatchHistoryStore.saveStopped(engine, 20, []));
    Test.assert(MatchHistoryStore.saveStopped(engine, 30, []));

    Test.assert(MatchHistoryStore.deleteAt(1));
    var history = MatchHistoryStore.load();
    Test.assertEqual(2, history.size());
    Test.assertEqual(10, history[0][3]);
    Test.assertEqual(30, history[1][3]);
    Test.assert(!MatchHistoryStore.deleteAt(-1));
    Test.assert(!MatchHistoryStore.deleteAt(2));
    Test.assertEqual(2, MatchHistoryStore.load().size());
    Storage.deleteValue(MatchHistoryStore.HISTORY_KEY);
    return true;
}

(:test)
function deletingOnlyHistoryRecordClearsStorage(logger) {
    Storage.deleteValue(MatchHistoryStore.HISTORY_KEY);
    var engine = createAdvantageMatch();
    Test.assert(MatchHistoryStore.saveStopped(engine, 10, []));

    Test.assert(MatchHistoryStore.deleteAt(0));
    Test.assertEqual(0, MatchHistoryStore.load().size());
    Test.assert(Storage.getValue(MatchHistoryStore.HISTORY_KEY) == null);
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

    ActiveMatchStore.save(engine, 87, []);
    var loaded = ActiveMatchStore.load();
    Test.assert(loaded != null);
    if (loaded == null) {
        return false;
    }

    var restored = loaded[0];
    Test.assertEqual(87, loaded[1]);
    Test.assertEqual(0, loaded[2].size());
    Test.assertEqual(engine.getPoints()[0], restored.getPoints()[0]);
    Test.assertEqual(engine.getPoints()[1], restored.getPoints()[1]);
    Test.assertEqual(1, restored.getServerTeam());
    Test.assertEqual(0, restored.getServeSide());
    ActiveMatchStore.clear();
    return true;
}

(:test)
function activeMatchRoundTripDoesNotRestoreSideChangeBlock(logger) {
    ActiveMatchStore.clear();
    var engine = createAdvantageMatch();
    for (var point = 0; point < 4; point += 1) {
        engine.awardPoint(0);
    }
    Test.assert(!engine.isSideChangePending());

    ActiveMatchStore.save(engine, 42, []);
    var loaded = ActiveMatchStore.load();
    Test.assert(loaded != null);
    if (loaded == null) {
        return false;
    }

    Test.assert(!loaded[0].isSideChangePending());
    Test.assert(loaded[0].awardPoint(1));
    ActiveMatchStore.clear();
    return true;
}

(:test)
function activeMatchRoundTripKeepsNoAdPlayContinuous(logger) {
    ActiveMatchStore.clear();
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
    ActiveMatchStore.save(engine, 43, []);
    var loaded = ActiveMatchStore.load();
    Test.assert(loaded != null);
    if (loaded == null) {
        return false;
    }

    Test.assert(loaded[0].getReceiverSide() == null);
    Test.assert(!loaded[0].isReceiverSideSelectionPending());
    Test.assert(loaded[0].awardPoint(0));
    ActiveMatchStore.clear();
    return true;
}

(:test)
function restoredNoAdDeuceDoesNotRequireReceiverChoice(logger) {
    ActiveMatchStore.clear();
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
    Test.assert(!engine.isReceiverSideSelectionPending());

    ActiveMatchStore.save(engine, 44, []);
    var loaded = ActiveMatchStore.load();
    Test.assert(loaded != null);
    if (loaded == null) {
        return false;
    }

    Test.assert(!loaded[0].isReceiverSideSelectionPending());
    Test.assert(loaded[0].awardPoint(0));
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
function fitStoppedScoreContainsCurrentGameAndPoints(logger) {
    var engine = createAdvantageMatch();
    winGame(engine, 0);
    engine.awardPoint(0);
    engine.awardPoint(1);
    engine.awardPoint(0);

    Test.assertEqual("1-0 30-15 STOP",
        PadelActivityRecorder.buildIncompleteSetScores(engine, "Stopped"));
    return true;
}

(:test)
function fitStoppedScoreIdentifiesTieBreak(logger) {
    var engine = createAdvantageMatch();
    for (var game = 0; game < 6; game += 1) {
        winGame(engine, 0);
        winGame(engine, 1);
    }
    engine.awardPoint(0);
    engine.awardPoint(1);
    engine.awardPoint(0);

    Test.assertEqual("6-6 TB 2-1 STOP",
        PadelActivityRecorder.buildIncompleteSetScores(engine, "Stopped"));
    return true;
}

(:test)
function fitLapIsFlushedOnSetWinningPoint(logger) {
    var engine = createAdvantageMatch();
    Test.assert(PadelActivityRecorder.start(engine));

    for (var game = 0; game < 6; game += 1) {
        for (var point = 0; point < 4; point += 1) {
            engine.awardPoint(0);
            PadelActivityRecorder.recordPoint(0, engine);
        }
    }

    Test.assertEqual(1, engine.getCompletedSets().size());
    Test.assertEqual(1, PadelActivityRecorder.getRecordedSetCount());
    engine.awardPoint(1);
    PadelActivityRecorder.recordPoint(1, engine);
    Test.assertEqual(1, PadelActivityRecorder.getRecordedSetCount());
    Test.assert(PadelActivityRecorder.finish(engine, false, false));
    return true;
}

(:test)
function fitSetFeedbackCanFireAgainAfterWinningPointUndo(logger) {
    var engine = createAdvantageMatch();
    Test.assert(PadelActivityRecorder.start(engine));

    for (var game = 0; game < 6; game += 1) {
        for (var point = 0; point < 4; point += 1) {
            engine.awardPoint(0);
            PadelActivityRecorder.recordPoint(0, engine);
        }
    }
    Test.assertEqual(1, PadelActivityRecorder.getRecordedSetCount());

    Test.assert(engine.undoLastPoint());
    PadelActivityRecorder.recordUndo(engine);
    Test.assertEqual(0, PadelActivityRecorder.getRecordedSetCount());

    engine.awardPoint(0);
    PadelActivityRecorder.recordPoint(0, engine);
    Test.assertEqual(1, PadelActivityRecorder.getRecordedSetCount());
    Test.assert(PadelActivityRecorder.finish(engine, false, false));
    return true;
}

(:test)
function recoveredFitSegmentDoesNotRepeatCompletedSetOnNextPoint(logger) {
    var engine = createAdvantageMatch();
    winSet(engine, 0);
    Test.assertEqual(1, engine.getCompletedSets().size());

    Test.assert(PadelActivityRecorder.start(engine));
    Test.assertEqual(1, PadelActivityRecorder.getRecordedSetCount());
    engine.awardPoint(1);
    PadelActivityRecorder.recordPoint(1, engine);
    Test.assertEqual(1, PadelActivityRecorder.getRecordedSetCount());
    Test.assert(PadelActivityRecorder.finish(engine, false, false));
    return true;
}

(:test)
function fitSessionStartsRecordsAndDiscards(logger) {
    var engine = createAdvantageMatch();

    Test.assert(PadelActivityRecorder.start(engine));
    engine.awardPoint(0);
    PadelActivityRecorder.recordPoint(0, engine);
    Test.assert(PadelActivityRecorder.finish(engine, false, false));
    return true;
}
