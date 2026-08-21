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
    var _recordedSetCount = 0;
    var _positioningEnabled = false;
    var _positionListener = null;

    function start(engine) {
        if (_session != null) {
            return true;
        }

        try {
            Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
            enablePositioning();

            _session = ActivityRecording.createSession({
                :name => "Padel",
                :sport => Activity.SPORT_RACKET,
                :subSport => Activity.SUB_SPORT_PADEL
            });
            _engine = engine;
            _recordedSetCount = 0;
            createFields();
            updateSummary(engine);
            return _session.start();
        } catch (error) {
            reset();
            return false;
        }
    }

    function createFields() {
        _pointEventField = _session.createField("point_event", FIELD_POINT_EVENT,
            FitContributor.DATA_TYPE_UINT8,
            {:mesgType => FitContributor.MESG_TYPE_RECORD, :units => "code"});
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
        _winnerField = _session.createField("winner", FIELD_WINNER,
            FitContributor.DATA_TYPE_STRING,
            {:count => 16, :mesgType => FitContributor.MESG_TYPE_SESSION, :units => ""});
        _setScoresField = _session.createField("set_scores", FIELD_SET_SCORES,
            FitContributor.DATA_TYPE_STRING,
            {:count => 64, :mesgType => FitContributor.MESG_TYPE_SESSION, :units => ""});
    }

    function recordPoint(team, engine, completedSetsBeforePoint) {
        if (_session == null) {
            return;
        }
        flushPendingSets(engine, completedSetsBeforePoint);
        _pointEventField.setData(team == 0 ? EVENT_MY_POINT : EVENT_OPPONENT_POINT);
        updateSummary(engine);

        if (engine.getMatchWinner() != null) {
            pause();
        }
    }

    function recordUndo(engine) {
        if (_session != null) {
            _pointEventField.setData(EVENT_UNDO);
            updateSummary(engine);
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

    function updateSummary(engine) {
        _mySetsField.setData(engine.getSets()[0]);
        _opponentSetsField.setData(engine.getSets()[1]);
        var winner = engine.getMatchWinner();
        _winnerField.setData(winner == null ? "-" : (winner == 0 ? "My team" : "Opponent"));
        _setScoresField.setData(buildSetScores(engine));
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

    function getStats() {
        var stats = {
            :distance => null,
            :currentSpeed => null,
            :averageSpeed => null,
            :maxSpeed => null,
            :currentHeartRate => null,
            :averageHeartRate => null,
            :maxHeartRate => null,
            :calories => null,
            :currentCadence => null,
            :averageCadence => null,
            :maxCadence => null
        };

        if (_session == null) {
            return stats;
        }

        try {
            var info = Activity.getActivityInfo();
            stats[:distance] = info.elapsedDistance;
            stats[:currentSpeed] = info.currentSpeed;
            stats[:averageSpeed] = info.averageSpeed;
            stats[:maxSpeed] = info.maxSpeed;
            stats[:currentHeartRate] = info.currentHeartRate;
            stats[:averageHeartRate] = info.averageHeartRate;
            stats[:maxHeartRate] = info.maxHeartRate;
            stats[:calories] = info.calories;
            stats[:currentCadence] = info.currentCadence;
            stats[:averageCadence] = info.averageCadence;
            stats[:maxCadence] = info.maxCadence;
        } catch (error) {
        }
        return stats;
    }

    function formatDistance(meters) {
        if (meters == null) {
            return "--";
        }
        if (meters >= 1000) {
            return (meters / 1000.0).format("%.2f") + " km";
        }
        return meters.toNumber() + " m";
    }

    function formatSpeed(metersPerSecond) {
        if (metersPerSecond == null) {
            return "--";
        }
        return (metersPerSecond * 3.6).format("%.1f") + " km/h";
    }

    function formatHeartRate(beatsPerMinute) {
        return beatsPerMinute == null ? "--" : beatsPerMinute + " bpm";
    }

    function formatCalories(calories) {
        return calories == null ? "--" : calories + " kcal";
    }

    function pause() {
        if (_session != null && _session.isRecording()) {
            _session.stop();
        }
    }

    function resume() {
        if (_session != null && !_session.isRecording()) {
            _session.start();
        }
    }

    function finish(engine, shouldSave) {
        if (_session == null) {
            return false;
        }

        try {
            if (!_session.isRecording()) {
                _session.start();
            }
            flushPendingSets(engine, engine.getCompletedSets().size());
            updateSummary(engine);
            pause();
            var result = shouldSave ? _session.save() : _session.discard();
            reset();
            return result;
        } catch (error) {
            reset();
            return false;
        }
    }

    function handleAppStop() {
        if (_session == null) {
            return;
        }
        try {
            if (!_session.isRecording()) {
                _session.start();
            }
            flushPendingSets(_engine, _engine.getCompletedSets().size());
            updateSummary(_engine);
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
        _recordedSetCount = 0;
        try {
            Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
        } catch (error) {
        }
        _positioningEnabled = false;
        _positionListener = null;
        Sensor.setEnabledSensors([]);
    }
}
