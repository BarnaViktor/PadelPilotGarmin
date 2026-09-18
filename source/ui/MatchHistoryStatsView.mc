using Toybox.Graphics as Graphics;
using Toybox.Lang as Lang;
using Toybox.WatchUi as WatchUi;

class MatchHistoryStatsView extends WatchUi.View {
    const PAGE_COUNT = 3;

    var _summary as Lang.Array<Lang.Number>;
    var _page;

    function initialize(history) {
        View.initialize();
        _summary = MatchHistoryStatistics.summarize(history);
        _page = 0;
    }

    function movePage(delta) {
        _page = (_page + delta + PAGE_COUNT) % PAGE_COUNT;
    }

    function getPageCount() {
        return PAGE_COUNT;
    }

    function onUpdate(dc) {
        dc = PadelTheme.canvas(dc);
        PadelTheme.clear(dc);

        if (_page == 0) {
            drawOverview(dc);
        } else if (_page == 1) {
            drawMatchRecord(dc);
        } else {
            drawSetRecord(dc);
        }
        PadelTheme.drawPageDots(dc, _page, PAGE_COUNT, 376);
    }

    function drawOverview(dc) {
        PadelTheme.drawHeader(dc, "HISTORY STATS");
        drawMetric(dc, 112, "MATCHES", _summary[MatchHistoryStatistics.TOTAL_MATCHES],
            PadelTheme.WHITE);
        drawMetric(dc, 180, "FINISHED", _summary[MatchHistoryStatistics.COMPLETED_MATCHES],
            PadelTheme.CYAN);
        drawMetric(dc, 248, "STOPPED", _summary[MatchHistoryStatistics.STOPPED_MATCHES],
            PadelTheme.LIME);
    }

    function drawMatchRecord(dc) {
        PadelTheme.drawHeader(dc, "MATCH RECORD");
        drawRecord(dc, _summary[MatchHistoryStatistics.MATCH_WINS],
            _summary[MatchHistoryStatistics.MATCH_LOSSES]);

        var completed = _summary[MatchHistoryStatistics.COMPLETED_MATCHES];
        var matchRate = "--";
        if (completed > 0) {
            matchRate = MatchHistoryStatistics.percentage(
                _summary[MatchHistoryStatistics.MATCH_WINS], completed) + "%";
        }
        drawRate(dc, 253, "WIN RATE", matchRate);
    }

    function drawSetRecord(dc) {
        PadelTheme.drawHeader(dc, "SET RECORD");
        var won = _summary[MatchHistoryStatistics.SETS_WON];
        var lost = _summary[MatchHistoryStatistics.SETS_LOST];
        drawRecord(dc, won, lost);
        var setRate = "--";
        if (won + lost > 0) {
            setRate = MatchHistoryStatistics.percentage(won, won + lost) + "%";
        }
        drawRate(dc, 238, "SET WIN RATE", setRate);
        drawTimeSummary(dc);
    }

    function drawMetric(dc, y, label, value, accent) {
        PadelTheme.drawCard(dc, 68, y, 280, 52, false, PadelTheme.LINE);
        dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
        dc.drawText(92, y + 26, Graphics.FONT_XTINY, label,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(accent, Graphics.COLOR_BLACK);
        dc.drawText(324, y + 26, Graphics.FONT_XTINY, value,
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawRecord(dc, won, lost) {
        dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
        dc.drawText(146, 124, Graphics.FONT_XTINY, "W",
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(270, 124, Graphics.FONT_XTINY, "L",
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(PadelTheme.CYAN, Graphics.COLOR_BLACK);
        dc.drawText(146, 164, Graphics.FONT_MEDIUM, won,
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
        dc.drawText(208, 173, Graphics.FONT_TINY, "–",
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(PadelTheme.RED, Graphics.COLOR_BLACK);
        dc.drawText(270, 164, Graphics.FONT_MEDIUM, lost,
            Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawRate(dc, y, label, value) {
        dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
        dc.drawText(72, y, Graphics.FONT_XTINY, label,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(PadelTheme.WHITE, Graphics.COLOR_BLACK);
        dc.drawText(344, y, Graphics.FONT_XTINY, value,
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawTimeSummary(dc) {
        var centerX = dc.getWidth() / 2;
        dc.setColor(PadelTheme.MUTED, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 286, Graphics.FONT_XTINY, "TOTAL / AVG TIME",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(PadelTheme.WHITE, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 320, Graphics.FONT_XTINY,
            compactDuration(_summary[MatchHistoryStatistics.TOTAL_SECONDS])
                + " / " + compactDuration(
                    MatchHistoryStatistics.averageDuration(_summary)),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function compactDuration(totalSeconds) {
        var hours = (totalSeconds / 3600).toNumber();
        var minutes = ((totalSeconds % 3600) / 60).toNumber();
        if (hours > 0) {
            return hours + "h" + padTwo(minutes);
        }
        return minutes + "m";
    }

    function padTwo(value) {
        return value < 10 ? "0" + value : value.toString();
    }
}
