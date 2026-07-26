using Toybox.WatchUi as WatchUi;
using Toybox.Attention as Attention;
using Toybox.System as System;

class ScoreInputDelegate extends WatchUi.BehaviorDelegate {
    var _view;
    var _engine;

    function initialize(view, engine) {
        BehaviorDelegate.initialize();
        _view = view;
        _engine = engine;
    }

    function onKey(event) {
        var key = event.getKey();

        if (key == WatchUi.KEY_UP) {
            awardPoint(0);
        } else if (key == WatchUi.KEY_DOWN) {
            awardPoint(1);
        } else if (key == WatchUi.KEY_ESC) {
            if (_engine.undoLastPoint()) {
                vibrate(25);
            }
        } else {
            return false;
        }

        WatchUi.requestUpdate();
        return true;
    }

    function onTap(clickEvent) {
        if (clickEvent.getCoordinates()[0] < System.getDeviceSettings().screenWidth / 2) {
            awardPoint(0);
        } else {
            awardPoint(1);
        }
        WatchUi.requestUpdate();
        return true;
    }

    function awardPoint(team) {
        var oldGames = _engine.getGames().slice(0, 2);
        var oldSets = _engine.getSets().slice(0, 2);
        var oldWinner = _engine.getMatchWinner();

        if (!_engine.awardPoint(team)) {
            return;
        }

        if (oldWinner == null && _engine.getMatchWinner() != null) {
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
}
