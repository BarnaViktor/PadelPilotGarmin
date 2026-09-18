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

    function summarize(history as Lang.Array<Storage.ValueType>)
            as Lang.Array<Lang.Number> {
        var summary = [0, 0, 0, 0, 0, 0, 0, 0] as Lang.Array<Lang.Number>;

        for (var index = 0; index < history.size(); index += 1) {
            var record = history[index] as Lang.Array<Storage.ValueType>;
            summary[TOTAL_MATCHES] += 1;
            summary[TOTAL_SECONDS] += record[3];
            summary[SETS_WON] += record[0];
            summary[SETS_LOST] += record[1];

            if (MatchHistoryStore.isStopped(record)) {
                summary[STOPPED_MATCHES] += 1;
            } else {
                summary[COMPLETED_MATCHES] += 1;
                if (record[2] == 0) {
                    summary[MATCH_WINS] += 1;
                } else {
                    summary[MATCH_LOSSES] += 1;
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
