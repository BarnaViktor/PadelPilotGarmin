using Toybox.Test as Test;
using Toybox.Lang as Lang;

(:test)
function pointMatchTotalBoundaryAndRejectedPoints(logger) {
    for (var mode = 0; mode < 2; mode += 1) {
        for (var server = 0; server < 2; server += 1) {
            var engine = new PointMatchEngine(mode, PointMatchEndRule.TOTAL_POINTS, 24, server);
            awardPointMatchPoints(engine, 0, 14);
            awardPointMatchPoints(engine, 1, 9);
            assertPointMatchState(engine, 14, 9, PointMatchResult.ACTIVE);
            Test.assert(engine.awardPoint(1));
            assertPointMatchState(engine, 14, 10, PointMatchResult.WIN);
            Test.assert(!engine.awardPoint(0));
            Test.assert(!engine.awardPoint(1));
            assertPointMatchState(engine, 14, 10, PointMatchResult.WIN);
            Test.assert(engine.undoLastPoint());
            assertPointMatchState(engine, 14, 9, PointMatchResult.ACTIVE);
            Test.assertEqual(server, engine.getStartingServerTeam());
        }
    }
    return true;
}

(:test)
function pointMatchDrawUndoAndAlternateWinner(logger) {
    for (var mode = 0; mode < 2; mode += 1) {
        for (var server = 0; server < 2; server += 1) {
            var engine = new PointMatchEngine(mode, PointMatchEndRule.TOTAL_POINTS, 24, server);
            awardPointMatchPoints(engine, 0, 12);
            awardPointMatchPoints(engine, 1, 11);
            assertPointMatchState(engine, 12, 11, PointMatchResult.ACTIVE);
            Test.assert(engine.awardPoint(1));
            assertPointMatchState(engine, 12, 12, PointMatchResult.DRAW);
            Test.assert(!engine.awardPoint(0));
            Test.assert(engine.undoLastPoint());
            assertPointMatchState(engine, 12, 11, PointMatchResult.ACTIVE);
            Test.assert(engine.awardPoint(0));
            assertPointMatchState(engine, 13, 11, PointMatchResult.WIN);

            var loss = new PointMatchEngine(mode, PointMatchEndRule.TOTAL_POINTS, 24, server);
            awardPointMatchPoints(loss, 0, 10);
            awardPointMatchPoints(loss, 1, 14);
            assertPointMatchState(loss, 10, 14, PointMatchResult.LOSS);
        }
    }
    return true;
}

(:test)
function pointMatchTeamTargetNeedsNoTwoPointMargin(logger) {
    for (var mode = 0; mode < 2; mode += 1) {
        for (var server = 0; server < 2; server += 1) {
            var engine = new PointMatchEngine(mode, PointMatchEndRule.TEAM_TARGET, 24, server);
            awardPointMatchPoints(engine, 0, 23);
            awardPointMatchPoints(engine, 1, 23);
            assertPointMatchState(engine, 23, 23, PointMatchResult.ACTIVE);
            Test.assert(engine.awardPoint(0));
            assertPointMatchState(engine, 24, 23, PointMatchResult.WIN);
            Test.assert(!engine.awardPoint(0));
            Test.assert(!engine.awardPoint(1));
            Test.assert(engine.undoLastPoint());
            assertPointMatchState(engine, 23, 23, PointMatchResult.ACTIVE);
            Test.assert(engine.awardPoint(1));
            assertPointMatchState(engine, 23, 24, PointMatchResult.LOSS);
        }
    }
    return true;
}

(:test)
function pointMatchSameScoreHasDifferentCompletion(logger) {
    for (var mode = 0; mode < 2; mode += 1) {
        for (var server = 0; server < 2; server += 1) {
            var total = new PointMatchEngine(mode, PointMatchEndRule.TOTAL_POINTS, 24, server);
            var target = new PointMatchEngine(mode, PointMatchEndRule.TEAM_TARGET, 24, server);
            awardPointMatchPoints(total, 0, 14);
            awardPointMatchPoints(total, 1, 10);
            awardPointMatchPoints(target, 0, 14);
            awardPointMatchPoints(target, 1, 10);
            assertPointMatchState(total, 14, 10, PointMatchResult.WIN);
            assertPointMatchState(target, 14, 10, PointMatchResult.ACTIVE);
            for (var winner = 0; winner < 2; winner += 1) {
                var shutout = new PointMatchEngine(mode, PointMatchEndRule.TEAM_TARGET, 7, server);
                awardPointMatchPoints(shutout, winner, 6);
                Test.assert(!shutout.isComplete());
                Test.assert(shutout.awardPoint(winner));
                assertPointMatchState(shutout, winner == 0 ? 7 : 0, winner == 1 ? 7 : 0,
                    winner == 0 ? PointMatchResult.WIN : PointMatchResult.LOSS);
            }
        }
    }
    return true;
}

(:test)
function pointMatchCustomOddAndEvenTargets(logger) {
    for (var mode = 0; mode < 2; mode += 1) {
        for (var server = 0; server < 2; server += 1) {
            var odd = new PointMatchEngine(mode, PointMatchEndRule.TOTAL_POINTS, 17, server);
            awardPointMatchPoints(odd, 0, 9);
            awardPointMatchPoints(odd, 1, 7);
            assertPointMatchState(odd, 9, 7, PointMatchResult.ACTIVE);
            Test.assert(odd.awardPoint(1));
            assertPointMatchState(odd, 9, 8, PointMatchResult.WIN);
            var even = new PointMatchEngine(mode, PointMatchEndRule.TOTAL_POINTS, 18, server);
            awardPointMatchPoints(even, 0, 9);
            awardPointMatchPoints(even, 1, 9);
            assertPointMatchState(even, 9, 9, PointMatchResult.DRAW);
            var target = new PointMatchEngine(mode, PointMatchEndRule.TEAM_TARGET, 18, server);
            awardPointMatchPoints(target, 0, 9);
            awardPointMatchPoints(target, 1, 9);
            assertPointMatchState(target, 9, 9, PointMatchResult.ACTIVE);
            awardPointMatchPoints(target, 0, 8);
            awardPointMatchPoints(target, 1, 8);
            Test.assert(target.awardPoint(0));
            assertPointMatchState(target, 18, 17, PointMatchResult.WIN);
        }
    }
    return true;
}

(:test)
function pointMatchNewMatchAndSinglePointTarget(logger) {
    for (var mode = 0; mode < 2; mode += 1) {
        for (var rule = 0; rule < 2; rule += 1) {
            for (var server = 0; server < 2; server += 1) {
                for (var winner = 0; winner < 2; winner += 1) {
                    var engine = new PointMatchEngine(mode, rule, 1, server);
                    assertPointMatchState(engine, 0, 0, PointMatchResult.ACTIVE);
                    assertPointMatchSettings(engine, mode, rule, 1, server);
                    Test.assert(!engine.undoLastPoint());
                    Test.assert(engine.awardPoint(winner));
                    assertPointMatchState(engine, winner == 0 ? 1 : 0, winner == 1 ? 1 : 0,
                        winner == 0 ? PointMatchResult.WIN : PointMatchResult.LOSS);
                    Test.assert(engine.undoLastPoint());
                    assertPointMatchState(engine, 0, 0, PointMatchResult.ACTIVE);
                    assertPointMatchSettings(engine, mode, rule, 1, server);
                }
            }
        }
    }
    return true;
}

(:test)
function pointMatchUndoFollowsLastPointAndBranch(logger) {
    for (var mode = 0; mode < 2; mode += 1) {
        for (var rule = 0; rule < 2; rule += 1) {
            for (var server = 0; server < 2; server += 1) {
                var engine = new PointMatchEngine(mode, rule, 50, server);
                Test.assert(!engine.undoLastPoint());
                Test.assert(engine.awardPoint(0));
                Test.assert(engine.awardPoint(1));
                Test.assert(engine.awardPoint(1));
                Test.assert(engine.undoLastPoint());
                Test.assert(engine.awardPoint(0));
                assertPointMatchState(engine, 2, 1, PointMatchResult.ACTIVE);
                // Duplicate team entries must still be popped in temporal order.
                Test.assert(engine.undoLastPoint());
                assertPointMatchState(engine, 1, 1, PointMatchResult.ACTIVE);
                Test.assert(engine.undoLastPoint());
                assertPointMatchState(engine, 1, 0, PointMatchResult.ACTIVE);
                Test.assert(engine.undoLastPoint());
                Test.assert(!engine.undoLastPoint());
                assertPointMatchState(engine, 0, 0, PointMatchResult.ACTIVE);
                assertPointMatchSettings(engine, mode, rule, 50, server);
            }
        }
    }
    return true;
}

(:test)
function pointMatchUndoKeepsOnlyLastTwentyPoints(logger) {
    for (var mode = 0; mode < 2; mode += 1) {
        for (var rule = 0; rule < 2; rule += 1) {
            for (var server = 0; server < 2; server += 1) {
                var engine = new PointMatchEngine(mode, rule, 2001, server);
                for (var point = 0; point < 1001; point += 1) {
                    Test.assert(engine.awardPoint(point % 2));
                }
                assertPointMatchState(engine, 501, 500, PointMatchResult.ACTIVE);
                for (var undo = 0; undo < 20; undo += 1) {
                    Test.assert(engine.undoLastPoint());
                    assertPointMatchState(engine, 501 - (undo / 2).toNumber() - 1,
                        500 - ((undo + 1) / 2).toNumber(), PointMatchResult.ACTIVE);
                }
                Test.assert(!engine.undoLastPoint());
                assertPointMatchState(engine, 491, 490, PointMatchResult.ACTIVE);
                Test.assert(engine.awardPoint(1));
                Test.assert(engine.undoLastPoint());
                Test.assert(!engine.undoLastPoint());
                assertPointMatchSettings(engine, mode, rule, 2001, server);
            }
        }
    }
    return true;
}

(:test)
function pointMatchRejectsInvalidSettings(logger) {
    var invalidTargets = [null, 0, -1, 1.5, 24.0, "24", true, [], {}];
    var invalidSelectors = [null, -1, 2, 0.0, 0.5, "0", true, [], {}];
    for (var mode = 0; mode < 2; mode += 1) {
        for (var rule = 0; rule < 2; rule += 1) {
            for (var server = 0; server < 2; server += 1) {
                for (var index = 0; index < invalidTargets.size(); index += 1) {
                    var target = invalidTargets[index];
                    assertPointMatchSettingsRejected(mode, rule, target, server);
                }
            }
            for (var index = 0; index < invalidSelectors.size(); index += 1) {
                var selector = invalidSelectors[index];
                assertPointMatchSettingsRejected(mode, rule, 24, selector);
            }
        }
        for (var index = 0; index < invalidSelectors.size(); index += 1) {
            var selector = invalidSelectors[index];
            assertPointMatchSettingsRejected(mode, selector, 24, 0);
            assertPointMatchSettingsRejected(selector, mode, 24, 0);
        }
    }
    return true;
}

(:test)
function pointMatchInvalidPointPreservesScoreResultAndUndo(logger) {
    var invalidTeams = [null, -1, 2, 0.0, 1.0, 0.5, "0", true, [], {}];
    for (var mode = 0; mode < 2; mode += 1) {
        for (var rule = 0; rule < 2; rule += 1) {
            for (var server = 0; server < 2; server += 1) {
                var engine = new PointMatchEngine(mode, rule, 2, server);
                for (var index = 0; index < invalidTeams.size(); index += 1) {
                    var team = invalidTeams[index];
                    Test.assert(!engine.awardPoint(team));
                }
                Test.assert(!engine.undoLastPoint());
                Test.assert(engine.awardPoint(0));
                for (var index = 0; index < invalidTeams.size(); index += 1) {
                    var team = invalidTeams[index];
                    Test.assert(!engine.awardPoint(team));
                    assertPointMatchState(engine, 1, 0, PointMatchResult.ACTIVE);
                }
                Test.assert(engine.undoLastPoint());
                Test.assert(!engine.undoLastPoint());
                awardPointMatchPoints(engine, 0, 2);
                for (var index = 0; index < invalidTeams.size(); index += 1) {
                    var team = invalidTeams[index];
                    Test.assert(!engine.awardPoint(team));
                    assertPointMatchState(engine, 2, 0, PointMatchResult.WIN);
                }
                Test.assert(engine.undoLastPoint());
                assertPointMatchState(engine, 1, 0, PointMatchResult.ACTIVE);
                Test.assert(engine.undoLastPoint());
                Test.assert(!engine.undoLastPoint());
            }
        }
    }
    return true;
}

(:test)
function pointMatchStateIsIndependentAndScoresAreDefensiveCopies(logger) {
    var first = new PointMatchEngine(PointMatchMode.AMERICANO, PointMatchEndRule.TOTAL_POINTS, 1, 1);
    Test.assert(first.awardPoint(1));
    var second = new PointMatchEngine(PointMatchMode.MEXICANO, PointMatchEndRule.TEAM_TARGET, 2147483647, 0);
    var exposed = second.getPoints();
    exposed[0] = 2147483647;
    exposed[1] = -1;
    assertPointMatchState(second, 0, 0, PointMatchResult.ACTIVE);
    Test.assert(second.awardPoint(0));
    assertPointMatchState(second, 1, 0, PointMatchResult.ACTIVE);
    assertPointMatchState(first, 0, 1, PointMatchResult.LOSS);
    Test.assert(!second.awardPoint(null));
    Test.assert(second.undoLastPoint());
    Test.assert(!second.undoLastPoint());
    assertPointMatchState(second, 0, 0, PointMatchResult.ACTIVE);
    var total = new PointMatchEngine(PointMatchMode.AMERICANO, PointMatchEndRule.TOTAL_POINTS, 2147483647, 1);
    Test.assert(total.awardPoint(1));
    assertPointMatchState(total, 0, 1, PointMatchResult.ACTIVE);
    return true;
}

function awardPointMatchPoints(engine, team, count) {
    for (var point = 0; point < count; point += 1) {
        Test.assert(engine.awardPoint(team));
    }
}

function assertPointMatchState(engine, a, b, result) {
    var points = engine.getPoints();
    Test.assertEqual(a, points[0]);
    Test.assertEqual(b, points[1]);
    Test.assertEqual(result, engine.getResult());
    Test.assertEqual(result != PointMatchResult.ACTIVE, engine.isComplete());
}

function assertPointMatchSettings(engine, mode, rule, target, server) {
    Test.assertEqual(mode, engine.getMode());
    Test.assertEqual(rule, engine.getEndRule());
    Test.assertEqual(target, engine.getTarget());
    Test.assertEqual(server, engine.getStartingServerTeam());
}

function assertPointMatchSettingsRejected(mode, rule, target, server) {
    var rejected = false;
    try {
        new PointMatchEngine(mode, rule, target, server);
    } catch (error instanceof Lang.InvalidValueException) {
        rejected = true;
    }
    Test.assert(rejected);
}
