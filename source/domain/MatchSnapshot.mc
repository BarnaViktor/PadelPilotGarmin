class MatchSnapshot {
    var points;
    var games;
    var sets;
    var tieBreak;
    var decidingMatchTieBreak;
    var matchWinner;
    var serverTeam;
    var nextGameServerTeam;
    var tieBreakFirstServerTeam;
    var teamServerSlots;

    function initialize(engine) {
        points = engine.getPoints().slice(0, 2);
        games = engine.getGames().slice(0, 2);
        sets = engine.getSets().slice(0, 2);
        tieBreak = engine.isTieBreak();
        decidingMatchTieBreak = engine.isDecidingMatchTieBreak();
        matchWinner = engine.getMatchWinner();
        serverTeam = engine.getServerTeam();
        nextGameServerTeam = engine.getNextGameServerTeam();
        tieBreakFirstServerTeam = engine.getTieBreakFirstServerTeam();
        teamServerSlots = engine.getTeamServerSlots().slice(0, 2);
    }
}
