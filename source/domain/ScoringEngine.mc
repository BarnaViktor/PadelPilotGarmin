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

        _sets[team] += 1;
        _games = [0, 0];
        _points = [0, 0];
        _isTieBreak = false;
        _isDecidingMatchTieBreak = false;
        _tieBreakFirstServerTeam = null;

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

    function serverLabel() {
        return "T" + (_serverTeam + 1) + "-" + (_teamServerSlots[_serverTeam] + 1);
    }
}
