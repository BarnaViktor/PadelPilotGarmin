using Toybox.Lang as Lang;

class ScoringEngine {
    var _config;
    var _points;
    var _games;
    var _sets;
    var _isTieBreak;
    var _isDecidingMatchTieBreak;
    var _matchWinner;
    var _history;
    var _serverTeam;
    var _nextGameServerTeam;
    var _tieBreakFirstServerTeam;
    var _teamServerSlots;
    var _completedSets;
    var _serveSideOffset;

    function initialize(config) {
        _config = config;
        _points = [0, 0];
        _games = [0, 0];
        _sets = [0, 0];
        _isTieBreak = false;
        _isDecidingMatchTieBreak = false;
        _matchWinner = null;
        _history = [];
        _serverTeam = config.startingServerTeam;
        _nextGameServerTeam = config.startingServerTeam;
        _tieBreakFirstServerTeam = null;
        _teamServerSlots = [0, 0];
        _completedSets = [];
        _serveSideOffset = 0;
    }

    function awardPoint(team) {
        if (_matchWinner != null || (team != 0 && team != 1)) {
            return false;
        }

        _history.add(new MatchSnapshot(self));

        if (_isTieBreak) {
            awardTieBreakPoint(team);
        } else {
            awardGamePoint(team);
        }

        return true;
    }

    function undoLastPoint() {
        if (_history.size() == 0) {
            return false;
        }

        var snapshot = _history[_history.size() - 1];
        _history.remove(snapshot);
        _points = snapshot.points;
        _games = snapshot.games;
        _sets = snapshot.sets;
        _isTieBreak = snapshot.tieBreak;
        _isDecidingMatchTieBreak = snapshot.decidingMatchTieBreak;
        _matchWinner = snapshot.matchWinner;
        _serverTeam = snapshot.serverTeam;
        _nextGameServerTeam = snapshot.nextGameServerTeam;
        _tieBreakFirstServerTeam = snapshot.tieBreakFirstServerTeam;
        _teamServerSlots = snapshot.teamServerSlots;
        _completedSets = snapshot.completedSets;
        _serveSideOffset = snapshot.serveSideOffset;

        return true;
    }

    function awardGamePoint(team) {
        var opponent = 1 - team;

        if (_config.scoringMode == ScoringMode.NO_AD) {
            if (_points[team] >= 3) {
                completeGame(team);
            } else {
                _points[team] += 1;
            }
            return;
        }

        if (_points[team] <= 2) {
            _points[team] += 1;
            if (_points[team] == 4 && _points[opponent] <= 2) {
                completeGame(team);
            }
            return;
        }

        if (_points[team] == 3 && _points[opponent] <= 2) {
            completeGame(team);
        } else if (_points[team] == 3 && _points[opponent] == 3) {
            _points[team] = 4;
        } else if (_points[team] == 3 && _points[opponent] == 4) {
            _points[opponent] = 3;
        } else if (_points[team] == 4) {
            completeGame(team);
        }
    }

    function completeGame(team) {
        _games[team] += 1;
        _points = [0, 0];
        _serveSideOffset = 0;
        advanceGameServer();

        var opponent = 1 - team;
        if (_games[team] >= 6 && (_games[team] - _games[opponent]) >= 2) {
            completeSet(team);
        } else if (_games[0] == 6 && _games[1] == 6) {
            _isTieBreak = true;
            _tieBreakFirstServerTeam = _nextGameServerTeam;
            updateTieBreakServer();
        }
    }

    function awardTieBreakPoint(team) {
        _points[team] += 1;
        var opponent = 1 - team;
        var target = _isDecidingMatchTieBreak
            ? _config.decidingTieBreakTarget
            : _config.regularTieBreakTarget;

        var hasMargin = !_config.requireTwoPointTieBreakMargin
            || (_points[team] - _points[opponent]) >= 2;

        if (_points[team] >= target && hasMargin) {
            if (!_isDecidingMatchTieBreak) {
                _games[team] += 1;
            }
            completeSet(team);
        } else {
            updateTieBreakServer();
        }
    }

    function completeSet(team) {
        var completedTieBreak = _isTieBreak;
        var completedTieBreakFirstServerTeam = _tieBreakFirstServerTeam;

        if (_isDecidingMatchTieBreak) {
            _completedSets.add([_points[0], _points[1], true]);
        } else {
            _completedSets.add([_games[0], _games[1], false]);
        }

        _sets[team] += 1;
        _games = [0, 0];
        _points = [0, 0];
        _isTieBreak = false;
        _isDecidingMatchTieBreak = false;
        _tieBreakFirstServerTeam = null;
        _serveSideOffset = 0;

        if (completedTieBreak && completedTieBreakFirstServerTeam != null) {
            _serverTeam = 1 - completedTieBreakFirstServerTeam;
            _nextGameServerTeam = _serverTeam;
        }

        if (_sets[team] >= _config.setsToWin()) {
            _matchWinner = team;
            return;
        }

        if (shouldStartDecidingMatchTieBreak()) {
            _isTieBreak = true;
            _isDecidingMatchTieBreak = true;
            _tieBreakFirstServerTeam = _nextGameServerTeam;
            updateTieBreakServer();
        }
    }

    function advanceGameServer() {
        _teamServerSlots[_serverTeam] = 1 - _teamServerSlots[_serverTeam];
        _nextGameServerTeam = 1 - _serverTeam;
        _serverTeam = _nextGameServerTeam;
    }

    function updateTieBreakServer() {
        var servedPoints = _points[0] + _points[1];
        if (servedPoints == 0) {
            _serverTeam = _tieBreakFirstServerTeam;
        } else {
            var blocksAfterFirst = ((servedPoints + 1) / 2).toNumber();
            _serverTeam = (blocksAfterFirst % 2 == 0)
                ? _tieBreakFirstServerTeam
                : 1 - _tieBreakFirstServerTeam;
        }
    }

    function shouldStartDecidingMatchTieBreak() {
        if (_config.decidingSetMode != DecidingSetMode.MATCH_TIEBREAK) {
            return false;
        }

        var oneSetBeforeWin = _config.setsToWin() - 1;
        return _sets[0] == oneSetBeforeWin && _sets[1] == oneSetBeforeWin;
    }

    function pointLabel(team) {
        if (_isTieBreak) {
            return _points[team].toString();
        }

        var labels = ["0", "15", "30", "40", "AD"];
        return labels[_points[team]];
    }

    function getPoints() {
        return _points;
    }

    function getConfig() {
        return _config;
    }

    function getGames() {
        return _games;
    }

    function getSets() {
        return _sets;
    }

    function isTieBreak() {
        return _isTieBreak;
    }

    function isDecidingMatchTieBreak() {
        return _isDecidingMatchTieBreak;
    }

    function getMatchWinner() {
        return _matchWinner;
    }

    function getServerTeam() {
        return _serverTeam;
    }

    function getNextGameServerTeam() {
        return _nextGameServerTeam;
    }

    function getTieBreakFirstServerTeam() {
        return _tieBreakFirstServerTeam;
    }

    function getTeamServerSlots() {
        return _teamServerSlots;
    }

    function getCompletedSets() {
        return _completedSets;
    }

    function getServeSide() {
        var playedPoints = _points[0] + _points[1];
        return (playedPoints + _serveSideOffset) % 2;
    }

    function getServeSideOffset() {
        return _serveSideOffset;
    }

    function setServeSide(side) {
        if (side != 0 && side != 1) {
            return false;
        }

        var playedPoints = _points[0] + _points[1];
        _serveSideOffset = (side - (playedPoints % 2) + 2) % 2;
        return true;
    }

    function setServerTeam(team) {
        if (team != 0 && team != 1) {
            return false;
        }

        _serverTeam = team;
        _nextGameServerTeam = team;

        if (_isTieBreak) {
            var servedPoints = _points[0] + _points[1];
            if (servedPoints == 0) {
                _tieBreakFirstServerTeam = team;
            } else {
                var blocksAfterFirst = ((servedPoints + 1) / 2).toNumber();
                _tieBreakFirstServerTeam = (blocksAfterFirst % 2 == 0)
                    ? team
                    : 1 - team;
            }
        }

        return true;
    }

    function serverLabel() {
        var teamName = _serverTeam == 0 ? "MY" : "OPP";
        return teamName + "-" + (_teamServerSlots[_serverTeam] + 1);
    }

    function exportState() {
        var completedSets = [];
        for (var index = 0; index < _completedSets.size(); index += 1) {
            completedSets.add(_completedSets[index].slice(0, 3));
        }

        return [
            _points.slice(0, 2),
            _games.slice(0, 2),
            _sets.slice(0, 2),
            _isTieBreak,
            _isDecidingMatchTieBreak,
            _matchWinner == null ? -1 : _matchWinner,
            _serverTeam,
            _nextGameServerTeam,
            _tieBreakFirstServerTeam == null ? -1 : _tieBreakFirstServerTeam,
            _teamServerSlots.slice(0, 2),
            completedSets,
            _serveSideOffset
        ];
    }

    function restoreState(state) {
        if (!(state instanceof Lang.Array) || state.size() != 12
                || !isScorePair(state[0]) || !isScorePair(state[1])
                || !isScorePair(state[2]) || !isScorePair(state[9])
                || !(state[3] instanceof Lang.Boolean)
                || !(state[4] instanceof Lang.Boolean)
                || !isTeamOrNone(state[5]) || !isTeam(state[6])
                || !isTeam(state[7]) || !isTeamOrNone(state[8])
                || !(state[10] instanceof Lang.Array)
                || !isTeam(state[11])) {
            return false;
        }

        var restoredSets = [];
        for (var index = 0; index < state[10].size(); index += 1) {
            var completedSet = state[10][index];
            if (!(completedSet instanceof Lang.Array) || completedSet.size() != 3
                    || !(completedSet[0] instanceof Lang.Number)
                    || !(completedSet[1] instanceof Lang.Number)
                    || !(completedSet[2] instanceof Lang.Boolean)
                    || completedSet[0] < 0 || completedSet[1] < 0) {
                return false;
            }
            restoredSets.add(completedSet.slice(0, 3));
        }

        _points = state[0].slice(0, 2);
        _games = state[1].slice(0, 2);
        _sets = state[2].slice(0, 2);
        _isTieBreak = state[3];
        _isDecidingMatchTieBreak = state[4];
        _matchWinner = state[5] == -1 ? null : state[5];
        _serverTeam = state[6];
        _nextGameServerTeam = state[7];
        _tieBreakFirstServerTeam = state[8] == -1 ? null : state[8];
        _teamServerSlots = state[9].slice(0, 2);
        _completedSets = restoredSets;
        _serveSideOffset = state[11];
        _history = [];
        return true;
    }

    function isScorePair(value) {
        return value instanceof Lang.Array && value.size() == 2
            && value[0] instanceof Lang.Number && value[1] instanceof Lang.Number
            && value[0] >= 0 && value[1] >= 0;
    }

    function isTeam(value) {
        return value instanceof Lang.Number && (value == 0 || value == 1);
    }

    function isTeamOrNone(value) {
        return value instanceof Lang.Number && (value == -1 || value == 0 || value == 1);
    }
}
