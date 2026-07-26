using Toybox.Test as Test;

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
    Test.assertEqual("T2-1", engine.serverLabel());
    return true;
}

(:test)
function serverChangesAfterGame(logger) {
    var engine = createAdvantageMatch();

    Test.assertEqual(0, engine.getServerTeam());
    winGame(engine, 0);

    Test.assertEqual(1, engine.getServerTeam());
    Test.assertEqual("T2-1", engine.serverLabel());
    return true;
}

(:test)
function serverSlotChangesOnTeamNextServiceGame(logger) {
    var engine = createAdvantageMatch();

    winGame(engine, 0);
    winGame(engine, 1);

    Test.assertEqual(0, engine.getServerTeam());
    Test.assertEqual("T1-2", engine.serverLabel());
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
    Test.assertEqual(null, engine.getMatchWinner());
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
