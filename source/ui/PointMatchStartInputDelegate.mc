using Toybox.Attention as Attention;
using Toybox.System as System;
using Toybox.WatchUi as WatchUi;

class PointMatchStartInputDelegate extends WatchUi.BehaviorDelegate {
    var _view as PointMatchStartView;
    var _ended;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
        _ended = false;
    }

    function onKey(event) {
        return handleKey(event.getKey());
    }

    // Separate the physical event wrapper from routing for deterministic tests.
    function handleKey(key) {
        if (_ended) { return true; }
        if (_view._activitySaved) {
            // An immutable FIT file exists. Finish history before allowing
            // score changes, cancellation or another recording segment.
            if (key == WatchUi.KEY_ENTER) {
                if (saveMatch()) { return true; }
            }
        } else if (_view._saveConfirm) {
            if (key == WatchUi.KEY_UP || key == WatchUi.KEY_DOWN) {
                _view._saveYes = !_view._saveYes;
            } else if (key == WatchUi.KEY_ESC) {
                _view._saveConfirm = false;
            } else if (key == WatchUi.KEY_ENTER) {
                if (_view._saveYes) {
                    if (saveMatch()) { return true; }
                } else {
                    _view._saveConfirm = false;
                }
            } else {
                return false;
            }
        } else if (_view._discardConfirm) {
            if (key == WatchUi.KEY_UP || key == WatchUi.KEY_DOWN) {
                _view._discardYes = !_view._discardYes;
            } else if (key == WatchUi.KEY_ESC) {
                _view._discardConfirm = false;
            } else if (key == WatchUi.KEY_ENTER) {
                if (_view._discardYes) {
                    if (discardMatch()) { return true; }
                } else {
                    _view._discardConfirm = false;
                }
            } else {
                return false;
            }
        } else if (_view._activityStartFailed) {
            if (key == WatchUi.KEY_ENTER) {
                _view.startActivity();
            } else if (key == WatchUi.KEY_ESC) {
                _view.showDiscardConfirm();
            }
        } else if (_view._finishMenu || _view._session.isPaused()) {
            var itemCount = _view._finishMenu ? 2 : 3;
            if (key == WatchUi.KEY_UP) {
                _view._pauseSelection = (_view._pauseSelection + itemCount - 1) % itemCount;
            } else if (key == WatchUi.KEY_DOWN) {
                _view._pauseSelection = (_view._pauseSelection + 1) % itemCount;
            } else if (key == WatchUi.KEY_ESC) {
                if (_view._finishMenu) { _view._finishMenu = false; }
                else { resumeMatch(); }
            } else if (key == WatchUi.KEY_ENTER) {
                if (!_view._finishMenu && _view._pauseSelection == 0) {
                    resumeMatch();
                } else if (_view._pauseSelection == (_view._finishMenu ? 0 : 1)) {
                    _view.showSaveConfirm();
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
                _view._finishMenu = true;
                _view._pauseSelection = 0;
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
            if (!pauseActivity()) { _view._activityStartFailed = true; }
        } else {
            return false;
        }
        _view.syncClockTimer();
        WatchUi.requestUpdate();
        return true;
    }

    function awardPoint(team) {
        if (_view._session.awardPoint(team, System.getTimer())) {
            PadelActivityRecorder.recordPoint(team, _view._engine);
            _view.persist();
            vibrate(_view._engine.isComplete() ? 180 : 35);
        }
    }

    function undoPoint() {
        var wasComplete = _view._engine.isComplete();
        if (_view._session.undoLastPoint(System.getTimer())) {
            PadelActivityRecorder.recordUndo(_view._engine);
            if (wasComplete && !resumeActivity()) {
                _view.setPaused(true);
                _view._activityStartFailed = true;
            }
            _view.persist();
            vibrate(25);
        }
    }

    function onTap(clickEvent) { return true; }
    function onSwipe(swipeEvent) { return true; }

    function discardMatch() {
        if (_ended || _view._activitySaved) { return false; }
        if (PadelActivityRecorder._session != null
                && !PadelActivityRecorder.finish(_view._engine, false, false)) {
            _view._discardError = true;
            return false;
        }
        _ended = true;
        ActiveMatchSession.clear();
        leaveMatch();
        return true;
    }

    function saveMatch() {
        if (_ended || (!_view._engine.isComplete() && !_view._session.isPaused())) {
            return false;
        }
        if (!saveActivity()) { return false; }
        var saved = false;
        try {
            // The v5 checkpoint prevents a second FIT after a history-write
            // failure followed by app shutdown and cold restart.
            if (_view._activitySaved) { _view.persist(); }
            saved = writeHistory();
        } catch (error) {
        }
        if (!saved) {
            _view._saveError = true;
            _view._saveErrorMessage = "HISTORY SAVE FAILED";
            return false;
        }
        _ended = true;
        ActiveMatchSession.clear();
        leaveMatch();
        return true;
    }

    function saveActivity() {
        if (_view._activitySaved) { return true; }
        if (!_view.startActivity()
                || !PadelActivityRecorder.finish(_view._engine, true, !_view._engine.isComplete())) {
            _view._saveError = true;
            _view._saveErrorMessage = "ACTIVITY SAVE FAILED";
            return false;
        }
        _view._activitySaved = true;
        return true;
    }

    function pauseActivity() {
        return !PadelActivityRecorder.isAttached(_view._engine) || PadelActivityRecorder.pause();
    }

    function resumeActivity() {
        return _view.startActivity() && PadelActivityRecorder.resume();
    }

    function resumeMatch() {
        if (resumeActivity()) { _view.setPaused(false); }
        else { _view._activityStartFailed = true; }
    }

    function writeHistory() {
        return _view._engine.isComplete()
            ? MatchHistoryStore.savePointCompleted(_view._engine, _view.getDurationSeconds())
            : MatchHistoryStore.savePointStopped(_view._engine, _view.getDurationSeconds());
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
