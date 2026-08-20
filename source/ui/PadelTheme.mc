using Toybox.Graphics as Graphics;

module PadelTheme {
    const CYAN = 0x08C7EE;
    const CYAN_DARK = 0x063644;
    const RED = 0xFF3850;
    const RED_DARK = 0x451019;
    const LIME = 0xC9FF18;
    const WHITE = 0xF4F4F2;
    const MUTED = 0x9A9DA2;
    const LINE = 0x4C5056;
    const PANEL = Graphics.COLOR_BLACK;
    const BLACK = Graphics.COLOR_BLACK;

    function clear(dc) {
        dc.setColor(WHITE, BLACK);
        dc.clear();
    }

    function drawHeader(dc, title) {
        var centerX = dc.getWidth() / 2;
        dc.setColor(WHITE, BLACK);
        dc.drawText(centerX, 46, Graphics.FONT_XTINY, title,
            Graphics.TEXT_JUSTIFY_CENTER);

        dc.setPenWidth(3);
        dc.setColor(CYAN, BLACK);
        dc.drawLine(centerX - 82, 78, centerX - 8, 78);
        dc.setColor(WHITE, BLACK);
        dc.drawLine(centerX - 2, 72, centerX - 2, 84);
        dc.setColor(RED, BLACK);
        dc.drawLine(centerX + 8, 78, centerX + 82, 78);
        dc.setPenWidth(1);
    }

    function drawCard(dc, x, y, width, height, selected, accent) {
        dc.setColor(PANEL, BLACK);
        dc.fillRoundedRectangle(x, y, width, height, 15);
        dc.setColor(selected ? accent : LINE, BLACK);
        dc.setPenWidth(selected ? 3 : 2);
        dc.drawRoundedRectangle(x, y, width, height, 15);
        dc.setPenWidth(1);
    }

    function drawSplitCard(dc, x, y, width, height, selected, label, value) {
        drawCard(dc, x, y, width, height, selected, selected ? CYAN : LINE);
        var dividerX = x + (width * 57 / 100);
        dc.setColor(LINE, BLACK);
        dc.drawLine(dividerX, y + 10, dividerX, y + height - 10);
        dc.setColor(selected ? WHITE : MUTED, BLACK);
        dc.drawText(x + 20, y + 12, Graphics.FONT_XTINY, label,
            Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(selected ? LIME : WHITE, BLACK);
        dc.drawText(x + width - 18, y + 12, Graphics.FONT_XTINY, value,
            Graphics.TEXT_JUSTIFY_RIGHT);
    }

    function drawActionButton(dc, x, y, width, height, selected, label) {
        drawCard(dc, x, y, width, height, selected, selected ? LIME : LINE);
        dc.setColor(selected ? LIME : MUTED, BLACK);
        dc.drawText(x + width / 2, y + 17, Graphics.FONT_XTINY, label,
            Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawPageDots(dc, active, count, y) {
        var centerX = dc.getWidth() / 2;
        var firstX = centerX - ((count - 1) * 10);
        for (var i = 0; i < count; i += 1) {
            dc.setColor(i == active ? CYAN : LINE, BLACK);
            if (i == active) {
                dc.fillCircle(firstX + i * 20, y, 5);
            } else {
                dc.drawCircle(firstX + i * 20, y, 5);
            }
        }
    }
}
