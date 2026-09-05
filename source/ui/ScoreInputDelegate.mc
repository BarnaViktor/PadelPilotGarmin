using Toybox.WatchUi as WatchUi;
using Toybox.Attention as Attention;
using Toybox.System as System;

class ScoreInputDelegate extends WatchUi.BehaviorDelegate {
    var _view;
    var _engine;
    var _returnToFreshSetup;
    var _pointInputGuard;
    var _activitySaved;

    function initialize(view, engine, returnToFreshSetup) {
        BehaviorDelegate.initialize();
        _view = view;
        _engine = engine;
        _returnToFreshSetup = returnToFreshSetup;
        _pointInputGuard = new PointInputGuard(500);
        _activitySaved = false;
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
                _view.syncSetEndTimes();
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
        if (_view.isPauseDecision()) {
            if (key == WatchUi.KEY_DOWN || key == WatchUi.KEY_UP) {
                _view.moveDecisionSelection(1);
            } else if (key == WatchUi.KEY_ENTER) {
                if (_view.isDecisionYes()) {
                    if (_view.isSavePauseDecision()) {
                        saveStoppedMatch();
                    } else {
                        discardMatch();
                    }
                } else {
                    _view.clearPauseDecision();
                }
            } else if (key == WatchUi.KEY_ESC) {
                _view.clearPauseDecision();
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
                } else if (_view.getPauseSelection() == 1) {
                    _view.showSavePauseDecision();
                } else {
                    _view.showDiscardPauseDecision();
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
            if (key == WatchUi.KEY_DOWN || key == WatchUi.KEY_UP) {
                _view.moveDecisionSelection(1);
            } else if (key == WatchUi.KEY_ENTER) {
                if (_view.isDecisionYes()) {
                    saveCompletedMatch();
                } else {
                    discardMatch();
                }
            } else if (key == WatchUi.KEY_ESC) {
                _view.setFinishMenu(false);
                WatchUi.requestUpdate();
            } else {
                return false;
            }
            WatchUi.requestUpdate();
            ActiveMatchSession.persist();
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
        if (!_engine.awardPoint(team)) {
            return;
        }
        _view.syncSetEndTimes();
        PadelActivityRecorder.recordPoint(team, _engine);

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

    function saveCompletedMatch() {
        if (!saveActivity(false)) {
            return;
        }
        var historySaved = false;
        try {
            historySaved = MatchHistoryStore.saveCompleted(_engine,
                _view.getDurationSeconds(), _view.getSetEndTimes());
        } catch (error) {
        }
        if (!historySaved) {
            showSaveError("HISTORY SAVE FAILED");
            return;
        }
        exitMatch();
    }

    function saveStoppedMatch() {
        _view.syncSetEndTimes();
        if (!saveActivity(true)) {
            return;
        }
        var historySaved = false;
        try {
            historySaved = MatchHistoryStore.saveStopped(_engine,
                _view.getDurationSeconds(), _view.getSetEndTimes());
        } catch (error) {
        }
        if (!historySaved) {
            showSaveError("HISTORY SAVE FAILED");
            return;
        }
        exitMatch();
    }

    function saveActivity(stopped) {
        if (_activitySaved) {
            return true;
        }
        if (!PadelActivityRecorder.finish(_engine, true, stopped)) {
            showSaveError("ACTIVITY SAVE FAILED");
            return false;
        }
        _activitySaved = true;
        return true;
    }

    function showSaveError(message) {
        try {
            WatchUi.showToast(message + " - TRY AGAIN", null);
        } catch (error) {
        }
    }

    function discardMatch() {
        PadelActivityRecorder.finish(_engine, false, false);
        exitMatch();
    }

    function exitMatch() {
        ActiveMatchSession.clear();
        var homeView = new HomeView();
        WatchUi.switchToView(homeView, new HomeInputDelegate(homeView),
            WatchUi.SLIDE_IMMEDIATE);
    }
}
