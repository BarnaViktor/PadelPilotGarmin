using Toybox.WatchUi as WatchUi;

class HomeInputDelegate extends WatchUi.BehaviorDelegate {
    var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onKey(event) {
        var key = event.getKey();
        if (key == WatchUi.KEY_UP || key == WatchUi.KEY_DOWN) {
            _view.moveSelection(1);
        } else if (key == WatchUi.KEY_ENTER) {
            openSelection();
        } else {
            return false;
        }
        WatchUi.requestUpdate();
        return true;
    }

    function onTap(event) {
        openSelection();
        return true;
    }

    function openSelection() {
        if (_view.getSelection() == 0) {
            var setup = new MatchSetupState();
            var setupView = new SetupView(setup);
            WatchUi.pushView(setupView, new SetupInputDelegate(setup),
                WatchUi.SLIDE_IMMEDIATE);
        } else {
            var historyView = new MatchHistoryView();
            WatchUi.pushView(historyView, new MatchHistoryInputDelegate(historyView),
                WatchUi.SLIDE_IMMEDIATE);
        }
    }
}
