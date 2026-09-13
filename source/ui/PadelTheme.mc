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

    // The Enduro family has a 280px round display. Keep layout coordinates
    // in the existing 416px design space, drawing directly to the native DC
    // so the 128 KiB Enduro does not need an intermediate bitmap.
    function canvas(dc) {
        if (dc.getWidth() == 280 && dc.getHeight() == 280) {
            return new PadelScaledCanvas(dc);
        }
        return dc;
    }

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
        dc.drawLine(centerX - 82, 84, centerX - 8, 84);
        dc.setColor(WHITE, BLACK);
        dc.drawLine(centerX, 78, centerX, 90);
        dc.setColor(RED, BLACK);
        dc.drawLine(centerX + 8, 84, centerX + 82, 84);
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
        var dividerX = x + (width * 60 / 100);
        var centerY = y + height / 2;
        dc.setColor(LINE, BLACK);
        dc.drawLine(dividerX, y + 10, dividerX, y + height - 10);
        dc.setColor(selected ? WHITE : MUTED, BLACK);
        dc.drawText(x + 20, centerY, Graphics.FONT_XTINY, label,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(selected ? LIME : WHITE, BLACK);
        dc.drawText(x + width - 18, centerY, Graphics.FONT_XTINY, value,
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawActionButton(dc, x, y, width, height, selected, label) {
        drawCard(dc, x, y, width, height, selected, selected ? LIME : LINE);
        dc.setColor(selected ? LIME : MUTED, BLACK);
        dc.drawText(x + width / 2, y + height / 2, Graphics.FONT_XTINY, label,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawTennisBall(dc, x, y, radius) {
        dc.setColor(LIME, BLACK);
        dc.fillCircle(x, y, radius);
        dc.setColor(BLACK, LIME);
        dc.setPenWidth(2);
        dc.drawArc(x - radius, y, radius, Graphics.ARC_COUNTER_CLOCKWISE,
            300, 60);
        dc.drawArc(x + radius, y, radius, Graphics.ARC_COUNTER_CLOCKWISE,
            120, 240);
        dc.setPenWidth(1);
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

class PadelScaledCanvas {
    var _dc;

    function initialize(dc) {
        _dc = dc;
    }

    function getWidth() { return 416; }
    function getHeight() { return 416; }

    function pixel(value) {
        return (value * 280.0 / 416.0).toNumber();
    }

    function setColor(foreground, background) {
        _dc.setColor(foreground, background);
    }

    function clear() { _dc.clear(); }

    function setPenWidth(width) {
        var scaled = pixel(width);
        _dc.setPenWidth(scaled < 1 ? 1 : scaled);
    }

    function drawLine(x1, y1, x2, y2) {
        _dc.drawLine(pixel(x1), pixel(y1), pixel(x2), pixel(y2));
    }

    function drawText(x, y, font, text, justification) {
        // System fonts are supplied at the device's native size.
        _dc.drawText(pixel(x), pixel(y), font, text, justification);
    }

    function drawCircle(x, y, radius) {
        _dc.drawCircle(pixel(x), pixel(y), pixel(radius));
    }

    function fillCircle(x, y, radius) {
        _dc.fillCircle(pixel(x), pixel(y), pixel(radius));
    }

    function drawArc(x, y, radius, direction, start, end) {
        _dc.drawArc(pixel(x), pixel(y), pixel(radius), direction, start, end);
    }

    function fillRectangle(x, y, width, height) {
        _dc.fillRectangle(pixel(x), pixel(y), pixel(x + width) - pixel(x),
            pixel(y + height) - pixel(y));
    }

    function drawRoundedRectangle(x, y, width, height, radius) {
        _dc.drawRoundedRectangle(pixel(x), pixel(y),
            pixel(x + width) - pixel(x), pixel(y + height) - pixel(y), pixel(radius));
    }

    function fillRoundedRectangle(x, y, width, height, radius) {
        _dc.fillRoundedRectangle(pixel(x), pixel(y),
            pixel(x + width) - pixel(x), pixel(y + height) - pixel(y), pixel(radius));
    }
}
