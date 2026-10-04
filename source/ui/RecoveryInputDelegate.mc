using Toybox.WatchUi as WatchUi;

class RecoveryInputDelegate extends WatchUi.BehaviorDelegate {
    var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onKey(event) {
        var key = event.getKey();
        if (key == WatchUi.KEY_ENTER) {
            resumeMatch();
        } else if (key == WatchUi.KEY_DOWN) {
            discardMatch();
        } else {
            return false;
        }
        return true;
    }

    function resumeMatch() {
        var scoreView = createResumedView();
        var engine = _view.getLoadedMatch()[0];
        ActiveMatchSession.attach(engine, scoreView);
        if (engine instanceof PointMatchEngine) {
            WatchUi.switchToView(scoreView, new PointMatchStartInputDelegate(scoreView),
                WatchUi.SLIDE_IMMEDIATE);
            return;
        }
        PadelActivityRecorder.start(engine);
        PadelActivityRecorder.pause();
        WatchUi.switchToView(scoreView,
            new ScoreInputDelegate(scoreView, engine, true), WatchUi.SLIDE_IMMEDIATE);
    }

    function createResumedView() {
        var loaded = _view.getLoadedMatch();
        var engine = loaded[0];
        if (engine instanceof PointMatchEngine) {
            var pointView = new PointMatchStartView(engine);
            pointView.restoreSavedTime(loaded[1]);
            return pointView;
        }
        var scoreView = new ScoreView(engine, loaded[1], loaded[2]);
        if (engine.getMatchWinner() == null) {
            scoreView.setPaused(true);
        } else {
            scoreView.completeMatch();
        }
        return scoreView;
    }

    function discardMatch() {
        ActiveMatchSession.clear();
        var homeView = new HomeView();
        WatchUi.switchToView(homeView,
            new HomeInputDelegate(homeView), WatchUi.SLIDE_IMMEDIATE);
    }
}
