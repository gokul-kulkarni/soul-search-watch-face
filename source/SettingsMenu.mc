import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// On-device customisation. The top menu lists every setting; selecting one
// opens a picker list of its choices.
class SettingsMenu extends WatchUi.Menu2 {

    const SLOT_TITLES = [
        "Top pod", "Left pod", "Right pod", "Bottom pod",
        "Arc top-left", "Arc top-right", "Arc bottom-left", "Arc bottom-right"
    ] as Array<String>;

    function initialize() {
        Menu2.initialize({:title => "Customize"});
        addEntry("Style", Settings.KEY_STYLE);
        addEntry("Theme", Settings.KEY_THEME);
        addEntry("Time size", Settings.KEY_TIME_SIZE);
        addEntry("Hours colour", Settings.KEY_HOUR_COLOR);
        addEntry("Minutes colour", Settings.KEY_MINUTE_COLOR);
        addEntry("Accent colour", Settings.KEY_ACCENT_COLOR);
        addEntry("Field colours", Settings.KEY_FIELD_COLORS);
        addEntry("Dynamic colours", Settings.KEY_DYNAMIC);
        for (var i = 0; i < Settings.SLOT_COUNT; i++) {
            addEntry(SLOT_TITLES[i], Settings.SLOT_KEYS[i]);
        }
    }

    private function addEntry(title as String, key as String) as Void {
        var current = Options.name(key, Settings.get(key));
        addItem(new WatchUi.MenuItem(title, current, key, null));
    }
}

class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var key = item.getId() as String;
        WatchUi.pushView(new OptionMenu(item.getLabel(), key), new OptionMenuDelegate(key, item), WatchUi.SLIDE_LEFT);
    }
}

// Picker for one setting. Colour settings show a swatch beside each name.
class OptionMenu extends WatchUi.Menu2 {

    function initialize(title as String, key as String) {
        var values = Options.choices(key);
        var focus = values.indexOf(Settings.get(key));
        Menu2.initialize({:title => title, :focus => focus < 0 ? 0 : focus});
        var isColor = Options.kind(key) == Options.KIND_COLOR;
        for (var i = 0; i < values.size(); i++) {
            var v = values[i];
            var label = Options.name(key, v);
            if (isColor) {
                addItem(new WatchUi.IconMenuItem(label, null, v, new Swatch(swatchColor(key, v)), null));
            } else {
                addItem(new WatchUi.MenuItem(label, null, v, null));
            }
        }
    }

    // "Theme" shows the colour the current theme would use for this role.
    private function swatchColor(key as String, index as Number) as Number {
        var role = key.equals(Settings.KEY_HOUR_COLOR) ? Theme.HOUR
            : (key.equals(Settings.KEY_MINUTE_COLOR) ? Theme.MINUTE : Theme.ACCENT);
        return Palette.resolve(index, Theme.PALETTES[Settings.theme][role]);
    }
}

class OptionMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _key as String;
    private var _parentItem as WatchUi.MenuItem;

    function initialize(key as String, parentItem as WatchUi.MenuItem) {
        Menu2InputDelegate.initialize();
        _key = key;
        _parentItem = parentItem;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var value = item.getId() as Number;
        Settings.save(_key, value);
        _parentItem.setSubLabel(Options.name(_key, value));
        WatchUi.requestUpdate();
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}

// Round colour sample for the colour picker, outlined so dark colours stay visible.
class Swatch extends WatchUi.Drawable {

    const OUTLINE = 0x6E6E6E;
    private var _color as Number;

    function initialize(color as Number) {
        Drawable.initialize({});
        _color = color;
    }

    function draw(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var r = (w < h ? w : h) / 2 - 2;
        dc.setColor(_color, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(w / 2, h / 2, r);
        dc.setColor(OUTLINE, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(w / 2, h / 2, r);
    }
}
