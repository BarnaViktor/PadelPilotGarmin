using Toybox.Attention as Attention;
using Toybox.System as System;
using Toybox.WatchUi as WatchUi;

class PointMatchStartInputDelegate extends WatchUi.BehaviorDelegate {
    var _view as PointMatchStartView;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onKey(event) {
        return handleKey(event.getKey());
    }

    // Separate the physical event wrapper from routing for deterministic tests.
    function handleKey(key) {
        if (_view._discardConfirm) {
            if (key == WatchUi.KEY_UP || key == WatchUi.KEY_DOWN) {
                _view._discardYes = !_view._discardYes;
            } else if (key == WatchUi.KEY_ESC) {
                _view._discardConfirm = false;
            } else if (key == WatchUi.KEY_ENTER) {
                if (_view._discardYes) {
                    discardMatch();
                    return true;
                }
                _view._discardConfirm = false;
            } else {
                return false;
            }
        } else if (_view._session.isPaused()) {
            if (key == WatchUi.KEY_UP || key == WatchUi.KEY_DOWN) {
                _view._pauseSelection = 1 - _view._pauseSelection;
            } else if (key == WatchUi.KEY_ESC) {
                _view.setPaused(false);
            } else if (key == WatchUi.KEY_ENTER) {
                if (_view._pauseSelection == 0) {
                    _view.setPaused(false);
                } else {
                    _view.showDiscardConfirm();
                }
            } else {
                return false;
            }
        } else if (_view._engine.isComplete()) {
            if (key == WatchUi.KEY_ESC) {
                undoPoint();
            } else if (key == WatchUi.KEY_ENTER) {
                _view.showDiscardConfirm();
            } else if (key != WatchUi.KEY_UP && key != WatchUi.KEY_DOWN) {
                return false;
            }
        } else if (key == WatchUi.KEY_DOWN) {
            awardPoint(0);
        } else if (key == WatchUi.KEY_UP) {
            awardPoint(1);
        } else if (key == WatchUi.KEY_ESC) {
            undoPoint();
        } else if (key == WatchUi.KEY_ENTER) {
            _view.setPaused(true);
        } else {
            return false;
        }
        _view.syncClockTimer();
        WatchUi.requestUpdate();
        return true;
    }

    function awardPoint(team) {
        if (_view._session.awardPoint(team, System.getTimer())) {
            _view.persist();
            vibrate(_view._engine.isComplete() ? 180 : 35);
        }
    }

    function undoPoint() {
        if (_view._session.undoLastPoint(System.getTimer())) {
            _view.persist();
            vibrate(25);
        }
    }

    function onTap(clickEvent) { return true; }
    function onSwipe(swipeEvent) { return true; }

    function discardMatch() {
        ActiveMatchSession.clear();
        leaveMatch();
    }

    function leaveMatch() {
        if (_view._recovered) {
            var homeView = new HomeView();
            WatchUi.switchToView(homeView, new HomeInputDelegate(homeView),
                WatchUi.SLIDE_IMMEDIATE);
        } else {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }

    function vibrate(duration) {
        Attention.vibrate([new Attention.VibeProfile(50, duration)]);
    }
}
