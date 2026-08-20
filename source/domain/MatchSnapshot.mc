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
    var completedSets;
    var serveSideOffset;
    var sideChangePending;
    var receiverSideSelectionPending;
    var receiverSide;

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
        completedSets = engine.getCompletedSets().slice(0, engine.getCompletedSets().size());
        serveSideOffset = engine.getServeSideOffset();
        sideChangePending = false;
        receiverSideSelectionPending = false;
        receiverSide = null;
    }
}
