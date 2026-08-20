using Toybox.WatchUi as WatchUi;
using Toybox.Attention as Attention;
using Toybox.System as System;

class ScoreInputDelegate extends WatchUi.BehaviorDelegate {
    var _view;
    var _engine;
    var _returnToFreshSetup;
    var _pointInputGuard;

    function initialize(view, engine, returnToFreshSetup) {
        BehaviorDelegate.initialize();
        _view = view;
        _engine = engine;
        _returnToFreshSetup = returnToFreshSetup;
        _pointInputGuard = new PointInputGuard(500);
    }

    function onKey(event) {
        var key = event.getKey();

        if (_engine.getMatchWinner() != null) {
            return handleSummaryKey(key);
        }

        if (_view.isPaused()) {
            return handlePausedKey(key);
        }

        if (key == WatchUi.KEY_UP) {
            awardPoint(1);
        } else if (key == WatchUi.KEY_DOWN) {
            awardPoint(0);
        } else if (key == WatchUi.KEY_ESC) {
            if (_engine.undoLastPoint()) {
                _pointInputGuard.reset();
                PadelActivityRecorder.recordUndo(_engine);
                vibrate(25);
            }
        } else if (key == WatchUi.KEY_ENTER) {
            _view.setPaused(true);
            PadelActivityRecorder.pause();
        } else {
            return false;
        }

        WatchUi.requestUpdate();
        ActiveMatchSession.persist();
        return true;
    }

    function handlePausedKey(key) {
        if (_view.isPauseStopConfirm()) {
            if (key == WatchUi.KEY_ENTER) {
                PadelActivityRecorder.finish(_engine, false);
                exitMatch();
            } else if (key == WatchUi.KEY_DOWN || key == WatchUi.KEY_ESC) {
                _view.setPauseStopConfirm(false);
            } else {
                return false;
            }
        } else if (_view.isPauseServerPicker()) {
            if (key == WatchUi.KEY_DOWN) {
                _view.moveServerPickerSelection(1);
            } else if (key == WatchUi.KEY_UP) {
                _view.moveServerPickerSelection(-1);
            } else if (key == WatchUi.KEY_ENTER) {
                selectServer(
                    _view.getSelectedServerTeam(),
                    _view.getSelectedServeSide()
                );
            } else if (key == WatchUi.KEY_ESC) {
                _view.setPauseServerPicker(false);
            } else {
                return false;
            }
        } else {
            if (key == WatchUi.KEY_DOWN) {
                _view.movePauseSelection(1);
            } else if (key == WatchUi.KEY_UP) {
                _view.movePauseSelection(-1);
            } else if (key == WatchUi.KEY_ENTER) {
                if (_view.getPauseSelection() == 0) {
                    _view.setPauseServerPicker(true);
                } else {
                    _view.setPauseStopConfirm(true);
                }
            } else if (key == WatchUi.KEY_ESC) {
                _view.setPaused(false);
                PadelActivityRecorder.resume();
            } else {
                return false;
            }
        }

        WatchUi.requestUpdate();
        ActiveMatchSession.persist();
        return true;
    }

    function handleSummaryKey(key) {
        if (_view.isFinishMenu()) {
            if (key == WatchUi.KEY_ENTER) {
                PadelActivityRecorder.finish(_engine, true);
                MatchHistoryStore.save(_engine, _view.getDurationSeconds());
                exitMatch();
            } else if (key == WatchUi.KEY_DOWN) {
                PadelActivityRecorder.finish(_engine, false);
                exitMatch();
            } else if (key == WatchUi.KEY_ESC) {
                _view.setFinishMenu(false);
                WatchUi.requestUpdate();
            } else {
                return false;
            }
            return true;
        }

        if (key == WatchUi.KEY_DOWN) {
            _view.changeSummaryPage(1);
        } else if (key == WatchUi.KEY_UP) {
            _view.changeSummaryPage(-1);
        } else if (key == WatchUi.KEY_ENTER) {
            _view.setFinishMenu(true);
        } else if (key == WatchUi.KEY_ESC) {
            if (_engine.undoLastPoint()) {
                _pointInputGuard.reset();
                _view.resumeMatchAfterUndo();
                PadelActivityRecorder.resume();
                PadelActivityRecorder.recordUndo(_engine);
                vibrate(25);
            }
        } else {
            return false;
        }

        WatchUi.requestUpdate();
        ActiveMatchSession.persist();
        return true;
    }

    function onTap(clickEvent) {
        // Live match input is intentionally button-only. Consuming touches keeps
        // sweat, sleeves and accidental taps from changing match state.
        return true;
    }

    function selectServer(team, side) {
        _engine.setServerTeam(team);
        _engine.setServeSide(side);
        _view.setPaused(false);
        PadelActivityRecorder.resume();
        vibrate(55);
        ActiveMatchSession.persist();
    }

    function awardPoint(team) {
        if (!_pointInputGuard.accept(System.getTimer())) {
            return;
        }

        var oldGames = _engine.getGames().slice(0, 2);
        var oldSets = _engine.getSets().slice(0, 2);
        var oldWinner = _engine.getMatchWinner();
        var completedSetsBeforePoint = _engine.getCompletedSets().size();

        if (!_engine.awardPoint(team)) {
            return;
        }
        PadelActivityRecorder.recordPoint(team, _engine, completedSetsBeforePoint);

        if (oldWinner == null && _engine.getMatchWinner() != null) {
            _view.completeMatch();
            vibrate(180);
        } else if (oldSets[0] != _engine.getSets()[0] || oldSets[1] != _engine.getSets()[1]) {
            vibrate(120);
        } else if (oldGames[0] != _engine.getGames()[0] || oldGames[1] != _engine.getGames()[1]) {
            vibrate(80);
        } else {
            vibrate(35);
        }
    }

    function vibrate(duration) {
        Attention.vibrate([new Attention.VibeProfile(50, duration)]);
    }

    function exitMatch() {
        ActiveMatchSession.clear();
        if (_returnToFreshSetup) {
            var homeView = new HomeView();
            WatchUi.switchToView(homeView, new HomeInputDelegate(homeView), WatchUi.SLIDE_IMMEDIATE);
        } else {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }
}
