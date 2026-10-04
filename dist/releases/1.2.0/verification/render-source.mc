using Toybox.Application as Application;
using Toybox.WatchUi as WatchUi;
using Toybox.Timer as Timer;
using Toybox.System as System;
class PadelApp extends Application.AppBase {
    function initialize() { AppBase.initialize(); }
    function getInitialView() { return [new ReviewView(), new WatchUi.BehaviorDelegate()]; }
}
class ReviewView extends WatchUi.View {
    var _index;
    var _timer;
    function initialize() { View.initialize(); _index = 0; }
    function onShow() { _timer = new Timer.Timer(); _timer.start(method(:advance), 1200, true); }
    function onHide() { _timer.stop(); }
    function advance() as Void { _index = (_index + 1) % 16; WatchUi.requestUpdate(); }
    function onUpdate(dc) {
        var view;
        var setup = new MatchSetupState();
        var completed = [1, 0, 0, 120, [[6, 0, false]], [120], 3, 0,
            [0, 0, 0, 0, false, false], [24, 8]];
        var legacy = [0, 1, 1, 120, [[4, 6, false]]];
        if (_index == 0) { view = new HomeView(); }
        else if (_index <= 3) {
            if (_index == 2) { setup.beginEditing(); }
            if (_index == 3) {
                setup.matchMode = MatchMode.MEXICANO;
                setup.pointEndRule = PointMatchEndRule.TEAM_TARGET;
                setup.pointTarget = 999; setup.selectedField = 2; setup.beginEditing();
            }
            view = new SetupView(setup);
        } else if (_index <= 6) {
            var classic = new ScoringEngine(new MatchConfig(3, 0, 0, 0, 7, 10, true));
            classic.awardPoint(0); classic.awardPoint(1);
            view = new ScoreView(classic, 3600, []);
            if (_index >= 5) { view._paused = true; view._pausedAt = System.getTimer(); }
            if (_index == 6) { view._pauseServerPicker = true; }
        } else if (_index == 7) {
            view = new MatchHistoryView(); view._history = [completed, legacy];
        } else if (_index <= 10) {
            view = new MatchHistoryStatsView([completed, legacy]);
            view._page = _index == 8 ? 0 : (_index == 9 ? 1 : 3);
        } else if (_index == 11) {
            view = new MatchHistoryDetailView(completed);
            view._page = view.getScorePageCount() + 1;
        } else {
            var point = new PointMatchEngine(_index == 12 ? 0 : 1, 1, 999, 1);
            point.restoreState(_index == 13 ? [998, 999] : [998, 997]);
            if (_index == 15) { view = new RecoveryView([point, 360000123, []]); }
            else {
                view = new PointMatchStartView(point);
                view.restoreSavedTime(360000123);
                if (_index == 14) { view.setPaused(true); }
            }
        }
        view.onUpdate(dc);
        System.println("RELEASE_FRAME " + _index);
    }
}
