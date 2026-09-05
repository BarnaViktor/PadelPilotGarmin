using Toybox.WatchUi as WatchUi;

class MatchHistoryDetailInputDelegate extends WatchUi.BehaviorDelegate {
    var _view;
    var _historyView;

    function initialize(view, historyView) {
        BehaviorDelegate.initialize();
        _view = view;
        _historyView = historyView;
    }

    function onKey(event) {
        var key = event.getKey();

        if (_view.isDeleteConfirm()) {
            if (key == WatchUi.KEY_UP || key == WatchUi.KEY_DOWN) {
                _view.moveDeleteSelection();
            } else if (key == WatchUi.KEY_ENTER) {
                if (_view.isDeleteYes()) {
                    if (_historyView.deleteSelected()) {
                        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                        return true;
                    }
                } else {
                    _view.setDeleteConfirm(false);
                }
            } else if (key == WatchUi.KEY_ESC) {
                _view.setDeleteConfirm(false);
            } else {
                return false;
            }
            WatchUi.requestUpdate();
            return true;
        }

        if (key == WatchUi.KEY_UP) {
            _view.movePage(-1);
        } else if (key == WatchUi.KEY_DOWN) {
            _view.movePage(1);
        } else if (key == WatchUi.KEY_ENTER) {
            _view.setDeleteConfirm(true);
        } else if (key == WatchUi.KEY_ESC) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            return true;
        } else {
            return false;
        }
        WatchUi.requestUpdate();
        return true;
    }
}
