class PointInputGuard {
    var _minimumIntervalMs;
    var _lastAcceptedAt;

    function initialize(minimumIntervalMs) {
        _minimumIntervalMs = minimumIntervalMs;
        _lastAcceptedAt = null;
    }

    function accept(now) {
        if (_lastAcceptedAt != null && now >= _lastAcceptedAt) {
            var elapsed = now - _lastAcceptedAt;
            if (elapsed < _minimumIntervalMs) {
                return false;
            }
        }

        _lastAcceptedAt = now;
        return true;
    }

    function reset() {
        _lastAcceptedAt = null;
    }
}
