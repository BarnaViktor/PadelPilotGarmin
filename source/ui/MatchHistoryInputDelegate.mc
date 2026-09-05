using Toybox.WatchUi as WatchUi;

class MatchHistoryInputDelegate extends WatchUi.BehaviorDelegate {
    var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onKey(event) {
        var key = event.getKey();
        if (key == WatchUi.KEY_UP) {
            _view.moveSelection(-1);
        } else if (key == WatchUi.KEY_DOWN) {
            _view.moveSelection(1);
        } else if (key == WatchUi.KEY_ESC) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            return true;
        } else if (key == WatchUi.KEY_ENTER) {
            var record = _view.getSelectedRecord();
            if (record == null) {
                return false;
            }
            var detailView = new MatchHistoryDetailView(record);
            WatchUi.pushView(detailView,
                new MatchHistoryDetailInputDelegate(detailView, _view),
                WatchUi.SLIDE_IMMEDIATE);
            return true;
        } else {
            return false;
        }
        WatchUi.requestUpdate();
        return true;
    }
}
