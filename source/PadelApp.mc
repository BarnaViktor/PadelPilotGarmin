using Toybox.Application as Application;
using Toybox.WatchUi as WatchUi;

class PadelApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        var loadedMatch = ActiveMatchStore.load();
        if (loadedMatch != null) {
            var recoveryView = new RecoveryView(loadedMatch);
            return [recoveryView, new RecoveryInputDelegate(recoveryView)];
        }

        var setup = new MatchSetupState();
        var view = new SetupView(setup);

        return [view, new SetupInputDelegate(setup)];
    }

    function onStop(state) {
        ActiveMatchSession.persist();
        PadelActivityRecorder.handleAppStop();
    }
}
