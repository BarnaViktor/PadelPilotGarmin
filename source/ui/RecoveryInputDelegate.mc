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
        var loaded = _view.getLoadedMatch();
        var engine = loaded[0];
        var scoreView = new ScoreView(engine, loaded[1]);
        if (engine.getMatchWinner() == null) {
            scoreView.setPaused(true);
        } else {
            scoreView.completeMatch();
        }
        ActiveMatchSession.attach(engine, scoreView);
        PadelActivityRecorder.start(engine);
        PadelActivityRecorder.pause();
        WatchUi.switchToView(scoreView,
            new ScoreInputDelegate(scoreView, engine, true), WatchUi.SLIDE_IMMEDIATE);
    }

    function discardMatch() {
        ActiveMatchSession.clear();
        var setup = new MatchSetupState();
        var setupView = new SetupView(setup);
        WatchUi.switchToView(setupView,
            new SetupInputDelegate(setup), WatchUi.SLIDE_IMMEDIATE);
    }
}
