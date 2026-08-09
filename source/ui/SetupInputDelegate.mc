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
            if (_setup.editing) {
                _setup.changeSelected(1);
            } else {
                _setup.moveSelection(-1);
            }
        } else if (key == WatchUi.KEY_DOWN) {
            if (_setup.editing) {
                _setup.changeSelected(-1);
            } else {
                _setup.moveSelection(1);
            }
        } else if (key == WatchUi.KEY_ESC) {
            if (!_setup.editing) {
                return false;
            }
            _setup.cancelEditing();
        } else if (key == WatchUi.KEY_ENTER) {
            if (_setup.editing) {
                _setup.saveEditing();
            } else if (_setup.isStartGameSelected()) {
                startMatch();
            } else if (_setup.isHistorySelected()) {
                openHistory();
            } else {
                _setup.beginEditing();
            }
        } else {
            return false;
        }

        WatchUi.requestUpdate();
        return true;
    }

    function onTap(clickEvent) {
        if (_setup.editing) {
            _setup.saveEditing();
        } else if (_setup.isStartGameSelected()) {
            startMatch();
        } else if (_setup.isHistorySelected()) {
            openHistory();
        } else {
            _setup.beginEditing();
        }
        WatchUi.requestUpdate();
        return true;
    }

    function onSwipe(swipeEvent) {
        var direction = swipeEvent.getDirection();
        if (direction == WatchUi.SWIPE_UP) {
            if (_setup.editing) {
                _setup.changeSelected(-1);
            } else {
                _setup.moveSelection(1);
            }
        } else if (direction == WatchUi.SWIPE_DOWN) {
            if (_setup.editing) {
                _setup.changeSelected(1);
            } else {
                _setup.moveSelection(-1);
            }
        } else if (direction == WatchUi.SWIPE_LEFT) {
            if (!_setup.editing) {
                return false;
            }
            _setup.saveEditing();
        } else if (direction == WatchUi.SWIPE_RIGHT) {
            if (!_setup.editing) {
                return false;
            }
            _setup.cancelEditing();
        } else {
            return false;
        }

        WatchUi.requestUpdate();
        return true;
    }

    function startMatch() {
        var engine = new ScoringEngine(_setup.toConfig());
        var view = new ScoreView(engine, 0);
        ActiveMatchSession.attach(engine, view);
        PadelActivityRecorder.start(engine);
        WatchUi.pushView(view, new ScoreInputDelegate(view, engine, false), WatchUi.SLIDE_IMMEDIATE);
    }

    function openHistory() {
        var view = new MatchHistoryView();
        WatchUi.pushView(view, new MatchHistoryInputDelegate(view), WatchUi.SLIDE_IMMEDIATE);
    }
}
