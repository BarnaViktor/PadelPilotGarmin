using Toybox.Application.Storage as Storage;
using Toybox.Lang as Lang;

module MatchHistoryStatistics {
    const TOTAL_MATCHES = 0;
    const COMPLETED_MATCHES = 1;
    const STOPPED_MATCHES = 2;
    const MATCH_WINS = 3;
    const MATCH_LOSSES = 4;
    const TOTAL_SECONDS = 5;
    const SETS_WON = 6;
    const SETS_LOST = 7;
    const POINT_DATA_MATCHES = 8;
    const POINTS_WON = 9;
    const POINTS_LOST = 10;
    const MATCH_DRAWS = 11;

    function summarize(history as Lang.Array<Storage.ValueType>)
            as Lang.Array<Lang.Number> {
        var summary = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
            as Lang.Array<Lang.Number>;

        for (var index = 0; index < history.size(); index += 1) {
            var record = history[index] as Lang.Array<Storage.ValueType>;
            summary[TOTAL_MATCHES] += 1;
            summary[TOTAL_SECONDS] += MatchHistoryStore.getDurationSeconds(record);
            if (!MatchHistoryStore.isPointRecord(record)) {
                summary[SETS_WON] += record[0];
                summary[SETS_LOST] += record[1];
            }

            var pointTotals = MatchHistoryStore.getPointTotals(record);
            if (pointTotals != null) {
                summary[POINT_DATA_MATCHES] += 1;
                summary[POINTS_WON] += pointTotals[0];
                summary[POINTS_LOST] += pointTotals[1];
            }

            if (MatchHistoryStore.isStopped(record)) {
                summary[STOPPED_MATCHES] += 1;
            } else {
                summary[COMPLETED_MATCHES] += 1;
                var result = MatchHistoryStore.getResult(record);
                if (result == PointMatchResult.WIN) {
                    summary[MATCH_WINS] += 1;
                } else if (result == PointMatchResult.LOSS) {
                    summary[MATCH_LOSSES] += 1;
                } else {
                    summary[MATCH_DRAWS] += 1;
                }
            }
        }

        return summary;
    }

    function percentage(part, total) {
        if (total <= 0) {
            return 0;
        }
        return ((part * 100) / total).toNumber();
    }

    function averageDuration(summary as Lang.Array<Lang.Number>) {
        if (summary[TOTAL_MATCHES] == 0) {
            return 0;
        }
        return (summary[TOTAL_SECONDS] / summary[TOTAL_MATCHES]).toNumber();
    }
}
