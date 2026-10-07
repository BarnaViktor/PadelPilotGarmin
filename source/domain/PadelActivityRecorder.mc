using Toybox.Activity as Activity;
using Toybox.ActivityRecording as ActivityRecording;
using Toybox.FitContributor as FitContributor;
using Toybox.Position as Position;
using Toybox.Sensor as Sensor;

class PadelPositioningListener {
    function initialize() {
    }

    function onPosition(info as Position.Info) as Void {
        // ActivityRecording consumes the enabled location stream and writes the
        // native FIT position, distance and speed fields.
    }
}

module PadelActivityRecorder {
    const FIELD_POINT_EVENT = 0;
    const FIELD_MY_SET_SCORE = 1;
    const FIELD_OPPONENT_SET_SCORE = 2;
    const FIELD_MY_SETS = 3;
    const FIELD_OPPONENT_SETS = 4;
    const FIELD_WINNER = 5;
    const FIELD_SET_SCORES = 6;
    // Keep the classic 0..6 field identifiers stable in existing FIT files.
    const FIELD_MATCH_MODE = 7;
    const FIELD_END_RULE = 8;
    const FIELD_POINT_TARGET = 9;
    const FIELD_FIRST_SERVER = 10;
    const FIELD_MY_POINTS = 11;
    const FIELD_OPPONENT_POINTS = 12;
    const FIELD_MY_MATCH_POINTS = 13;
    const FIELD_OPPONENT_MATCH_POINTS = 14;
    const FIELD_POINT_SEQUENCE = 15;

    const EVENT_MY_POINT = 1;
    const EVENT_OPPONENT_POINT = 2;
    const EVENT_UNDO = 3;

    var _session = null;
    var _engine = null;
    var _pointEventField = null;
    var _mySetScoreField = null;
    var _opponentSetScoreField = null;
    var _mySetsField = null;
    var _opponentSetsField = null;
    var _winnerField = null;
    var _setScoresField = null;
    var _pointFields = null;
    var _pointSequence = 0;
    var _recordedSetCount = 0;
    var _positioningEnabled = false;
    var _positionListener = null;

    function start(engine) {
        if (_session != null) {
            return _engine == engine && resume();
        }

        try {
            Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
            enablePositioning();

            var session = ActivityRecording.createSession({
                :name => "Padel",
                :sport => Activity.SPORT_RACKET,
                :subSport => Activity.SUB_SPORT_PADEL
            });
            return startWithSession(engine, session);
        } catch (error) {
            abortStart();
            return false;
        }
    }

    function isAttached(engine) {
        return _session != null && _engine == engine;
    }

    // The API-shaped session parameter also lets tests exercise failed saves.
    function startWithSession(engine, session) {
        if (_session != null) { return _engine == engine; }
        try {
            _session = session;
            _engine = engine;
            _pointSequence = 0;
            // Recovered classic sets belong to the previous FIT segment.
            _recordedSetCount = engine instanceof PointMatchEngine
                ? 0 : engine.getCompletedSets().size();
            createFields();
            updateSummary(engine, null);
            // A false start is retryable on the same initialized session.
            // Discarding it and immediately creating another session can race
            // native cleanup and lose the later recording in the simulator.
            if (!_session.start()) {
                if (!(engine instanceof PointMatchEngine)) { abortStart(); }
                return false;
            }
            if (engine instanceof PointMatchEngine && engine.isComplete() && !pause()) {
                abortStart(); return false;
            }
            return true;
        } catch (error) {
            abortStart();
            return false;
        }
    }

    function abortStart() {
        try { if (_session != null) { _session.discard(); } }
        catch (error) {}
        reset();
    }

    function createFields() {
        _pointEventField = _session.createField("point_event", FIELD_POINT_EVENT,
            FitContributor.DATA_TYPE_UINT8,
            {:mesgType => FitContributor.MESG_TYPE_RECORD, :units => "code"});
        _pointEventField.setData(0);
        _winnerField = _session.createField("winner", FIELD_WINNER,
            FitContributor.DATA_TYPE_STRING,
            {:count => 16, :mesgType => FitContributor.MESG_TYPE_SESSION, :units => ""});
        if (_engine instanceof PointMatchEngine) {
            createPointFields();
            return;
        }
        _mySetScoreField = _session.createField("my_set_games", FIELD_MY_SET_SCORE,
            FitContributor.DATA_TYPE_UINT8,
            {:mesgType => FitContributor.MESG_TYPE_LAP, :units => "games"});
        _opponentSetScoreField = _session.createField("opponent_set_games", FIELD_OPPONENT_SET_SCORE,
            FitContributor.DATA_TYPE_UINT8,
            {:mesgType => FitContributor.MESG_TYPE_LAP, :units => "games"});
        _mySetsField = _session.createField("my_sets", FIELD_MY_SETS,
            FitContributor.DATA_TYPE_UINT8,
            {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => "sets"});
        _opponentSetsField = _session.createField("opponent_sets", FIELD_OPPONENT_SETS,
            FitContributor.DATA_TYPE_UINT8,
            {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => "sets"});
        _setScoresField = _session.createField("set_scores", FIELD_SET_SCORES,
            FitContributor.DATA_TYPE_STRING,
            {:count => 64, :mesgType => FitContributor.MESG_TYPE_SESSION, :units => ""});
    }

    function createPointFields() {
        // Point matches create no set/game fields and never add fictitious laps.
        _pointFields = [
            _session.createField("match_mode", FIELD_MATCH_MODE, FitContributor.DATA_TYPE_STRING,
                {:count => 16, :mesgType => FitContributor.MESG_TYPE_SESSION, :units => ""}),
            _session.createField("end_rule", FIELD_END_RULE, FitContributor.DATA_TYPE_STRING,
                {:count => 16, :mesgType => FitContributor.MESG_TYPE_SESSION, :units => ""}),
            _session.createField("point_target", FIELD_POINT_TARGET, FitContributor.DATA_TYPE_UINT32,
                {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => "points"}),
            _session.createField("first_server", FIELD_FIRST_SERVER, FitContributor.DATA_TYPE_UINT8,
                {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => "team"}),
            _session.createField("my_points", FIELD_MY_POINTS, FitContributor.DATA_TYPE_UINT32,
                {:mesgType => FitContributor.MESG_TYPE_RECORD, :units => "points"}),
            _session.createField("opponent_points", FIELD_OPPONENT_POINTS, FitContributor.DATA_TYPE_UINT32,
                {:mesgType => FitContributor.MESG_TYPE_RECORD, :units => "points"}),
            _session.createField("my_match_points", FIELD_MY_MATCH_POINTS, FitContributor.DATA_TYPE_UINT32,
                {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => "points"}),
            _session.createField("opponent_match_points", FIELD_OPPONENT_MATCH_POINTS, FitContributor.DATA_TYPE_UINT32,
                {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => "points"}),
            _session.createField("point_sequence", FIELD_POINT_SEQUENCE, FitContributor.DATA_TYPE_UINT32,
                {:mesgType => FitContributor.MESG_TYPE_RECORD, :units => "events"})
        ];
        _pointFields[0].setData(_engine.getMode() == PointMatchMode.AMERICANO ? "AMERICANO" : "MEXICANO");
        _pointFields[1].setData(_engine.getEndRule() == PointMatchEndRule.TOTAL_POINTS ? "TOTAL_POINTS" : "TEAM_TARGET");
        _pointFields[2].setData(_engine.getTarget());
        _pointFields[3].setData(_engine.getStartingServerTeam());
    }

    function recordPoint(team, engine) {
        if (!isAttached(engine)) {
            return;
        }
        _pointEventField.setData(team == 0 ? EVENT_MY_POINT : EVENT_OPPONENT_POINT);
        if (engine instanceof PointMatchEngine) {
            _pointSequence += 1;
            updateSummary(engine, null);
            if (engine.isComplete()) { pause(); }
            return;
        }
        updateSummary(engine, null);
        flushPendingSets(engine, engine.getCompletedSets().size());

        if (engine.getMatchWinner() != null) {
            pause();
        }
    }

    function recordUndo(engine) {
        if (isAttached(engine)) {
            _pointEventField.setData(EVENT_UNDO);
            if (engine instanceof PointMatchEngine) {
                _pointSequence += 1;
                updateSummary(engine, null);
                return;
            }
            updateSummary(engine, null);
            // addLap() cannot be removed from an ActivityRecording session,
            // but the set-ending feedback must fire again if the user undoes
            // the winning point and then wins that set again.
            var completedCount = engine.getCompletedSets().size();
            if (completedCount < _recordedSetCount) {
                _recordedSetCount = completedCount;
            }
        }
    }

    function flushPendingSets(engine, completedCount) {
        while (_recordedSetCount < completedCount) {
            var completedSet = engine.getCompletedSets()[_recordedSetCount];
            _mySetScoreField.setData(completedSet[0]);
            _opponentSetScoreField.setData(completedSet[1]);
            _session.addLap();
            _recordedSetCount += 1;
        }
    }

    function getRecordedSetCount() {
        return _recordedSetCount;
    }

    function updateSummary(engine, endState) {
        if (engine instanceof PointMatchEngine) {
            var points = engine.getPoints();
            _pointFields[4].setData(points[0]);
            _pointFields[5].setData(points[1]);
            _pointFields[6].setData(points[0]);
            _pointFields[7].setData(points[1]);
            _pointFields[8].setData(_pointSequence);
            _winnerField.setData(pointResultLabel(engine, endState));
            return;
        }
        _mySetsField.setData(engine.getSets()[0]);
        _opponentSetsField.setData(engine.getSets()[1]);
        var winner = engine.getMatchWinner();
        _winnerField.setData(winner == null
            ? (endState == null ? "-" : endState)
            : (winner == 0 ? "My team" : "Opponent"));
        _setScoresField.setData(winner == null && endState != null
            ? buildIncompleteSetScores(engine, endState)
            : buildSetScores(engine));
    }

    function pointResultLabel(engine, endState) {
        var result = engine.getResult();
        if (result == PointMatchResult.WIN) { return "My team"; }
        if (result == PointMatchResult.LOSS) { return "Opponent"; }
        if (result == PointMatchResult.DRAW) { return "Draw"; }
        return endState == null ? "-" : endState;
    }

    function buildSetScores(engine) {
        var label = "";
        var completedSets = engine.getCompletedSets();
        for (var index = 0; index < completedSets.size(); index += 1) {
            if (index > 0) {
                label += ", ";
            }
            label += completedSets[index][0] + "-" + completedSets[index][1];
            if (completedSets[index][2]) {
                label += " MTB";
            }
        }
        return label.length() == 0 ? "0-0" : label;
    }

    function buildIncompleteSetScores(engine, endState) {
        var label = engine.getCompletedSets().size() == 0
            ? "" : buildSetScores(engine);
        if (label.length() > 0) {
            label += ", ";
        }

        if (engine.isDecidingMatchTieBreak()) {
            label += "MTB " + engine.getPoints()[0] + "-"
                + engine.getPoints()[1];
        } else if (engine.isTieBreak()) {
            label += engine.getGames()[0] + "-" + engine.getGames()[1]
                + " TB " + engine.getPoints()[0] + "-"
                + engine.getPoints()[1];
        } else {
            label += engine.getGames()[0] + "-" + engine.getGames()[1]
                + " " + engine.pointLabel(0) + "-" + engine.pointLabel(1);
        }
        return label + (endState == "Interrupted" ? " INT" : " STOP");
    }

    function enablePositioning() {
        if (_positioningEnabled) {
            return;
        }
        try {
            _positionListener = new PadelPositioningListener();
            Position.enableLocationEvents(Position.LOCATION_CONTINUOUS,
                _positionListener.method(:onPosition));
            _positioningEnabled = true;
        } catch (error) {
            _positioningEnabled = false;
            _positionListener = null;
        }
    }

    function pause() {
        if (_session == null) { return false; }
        try { return !_session.isRecording() || _session.stop(); }
        catch (error) { return false; }
    }

    function resume() {
        if (_session == null) { return false; }
        try { return _session.isRecording() || _session.start(); }
        catch (error) { return false; }
    }

    function finish(engine, shouldSave, stopped) {
        if (!isAttached(engine)) {
            return false;
        }

        try {
            // Some devices flush session fields only after a start/stop pair.
            if (!resume()) { return false; }
            if (!(engine instanceof PointMatchEngine)) {
                flushPendingSets(engine, engine.getCompletedSets().size());
            }
            updateSummary(engine, stopped ? "Stopped" : null);
            if (!pause()) { return false; }
            var result = shouldSave ? _session.save() : _session.discard();
            // Point matches retain failed save/discard sessions for retry.
            if (result || (!shouldSave && !(engine instanceof PointMatchEngine))) {
                reset();
            }
            return result;
        } catch (error) {
            if (!shouldSave && !(engine instanceof PointMatchEngine)) {
                reset();
            }
            return false;
        }
    }

    function handleAppStop() {
        if (_session == null) {
            return;
        }
        try {
            // During onStop a device may refuse to restart the timer. The
            // already stopped session must still be saved and released.
            resume();
            if (!(_engine instanceof PointMatchEngine)) {
                flushPendingSets(_engine, _engine.getCompletedSets().size());
            }
            updateSummary(_engine, "Interrupted");
            pause();
            _session.save();
        } catch (error) {
        }
        reset();
    }

    function reset() {
        _session = null;
        _engine = null;
        _pointEventField = null;
        _mySetScoreField = null;
        _opponentSetScoreField = null;
        _mySetsField = null;
        _opponentSetsField = null;
        _winnerField = null;
        _setScoresField = null;
        _pointFields = null;
        _pointSequence = 0;
        _recordedSetCount = 0;
        try {
            Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
        } catch (error) {
        }
        _positioningEnabled = false;
        _positionListener = null;
        // Cleanup cannot turn a confirmed FIT save into a failed save/retry.
        try { Sensor.setEnabledSensors([]); }
        catch (error) {}
    }
}
