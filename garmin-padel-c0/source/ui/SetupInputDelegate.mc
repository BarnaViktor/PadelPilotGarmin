using Toybox.WatchUi as WatchUi;

class SetupInputDelegate extends WatchUi.BehaviorDelegate {
    var _setup;

    function initialize(setup) {
        BehaviorDelegate.initialize();
        _setup = setup;
    }

    function onKey(event) {
        var key = event.getKey();

        if (key == WatchUi.KEY_UP) {
            _setup.moveSelection(-1);
        } else if (key == WatchUi.KEY_DOWN) {
            _setup.moveSelection(1);
        } else if (key == WatchUi.KEY_ESC) {
            _setup.changeSelected(-1);
        } else if (key == WatchUi.KEY_MENU) {
            _setup.changeSelected(1);
        } else if (key == WatchUi.KEY_ENTER) {
            startMatch();
        } else {
            return false;
        }

        WatchUi.requestUpdate();
        return true;
    }

    function onTap(clickEvent) {
        _setup.moveSelection(1);
        WatchUi.requestUpdate();
        return true;
    }

    function onSwipe(swipeEvent) {
        var direction = swipeEvent.getDirection();
        if (direction == WatchUi.SWIPE_UP) {
            _setup.moveSelection(1);
        } else if (direction == WatchUi.SWIPE_DOWN) {
            _setup.moveSelection(-1);
        } else if (direction == WatchUi.SWIPE_LEFT) {
            _setup.changeSelected(1);
        } else if (direction == WatchUi.SWIPE_RIGHT) {
            _setup.changeSelected(-1);
        } else {
            return false;
        }

        WatchUi.requestUpdate();
        return true;
    }

    function startMatch() {
        var engine = new ScoringEngine(_setup.toConfig());
        var view = new ScoreView(engine);
        WatchUi.pushView(view, new ScoreInputDelegate(view, engine), WatchUi.SLIDE_IMMEDIATE);
    }
}
