using Toybox.Application as Application;
using Toybox.WatchUi as WatchUi;

class PadelApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        var setup = new MatchSetupState();
        var view = new SetupView(setup);

        return [view, new SetupInputDelegate(setup)];
    }
}
