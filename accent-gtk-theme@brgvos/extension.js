/* extension.js
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';
import Gio from 'gi://Gio';
export default class AccentColorGtkThemeExtension extends Extension {
    _settings;
    _preferences;
    _accentColorChangedId = 0;
    _customThemeChangedId = 0;
    gtkThemes = Object.values({});
    enable() {
        // Get the interface settings
        this._settings = new Gio.Settings({
            schema: "org.gnome.desktop.interface",
        });
        // Initializing gtk themes
        this.gtkThemes = Object.values({
            blue: "Fluent-round",
            teal: "Fluent-round-teal",
            green: "Fluent-round-green",
            yellow: "Fluent-round-yellow",
            orange: "Fluent-round-orange",
            red: "Fluent-round-red",
            pink: "Fluent-round-pink",
            purple: "Fluent-round-purple",
            slate: "Fluent-round-grey",
        });
        // Get Preferences
        this._preferences = this.getSettings();
        // Connect to accent color changes
        this._accentColorChangedId = this._settings.connect("changed::accent-color", this._onAccentColorChanged.bind(this));
        // Initial theme update
        this._onAccentColorChanged();
    }
    disable() {
        // Disconnect the signal handler
        if (this._settings && this._accentColorChangedId) {
            this._settings.disconnect(this._accentColorChangedId);
            this._accentColorChangedId = 0;
        }
        if (this._preferences && this._customThemeChangedId) {
            this._preferences.disconnect(this._customThemeChangedId);
            this._customThemeChangedId = 0;
        }
        // Clear the gtkThemes array
        this.gtkThemes = [];
        // Optionally reset to default gtk theme
        this._setGtkTheme("Adwaita");
        // Null out settings
        this._settings = null;
        this._preferences = null;
    }
    _onAccentColorChanged() {
        // Get the current accent color
        const accentColor = this._settings?.get_string("accent-color") ?? "blue";
        // Get custom theme from preferences
        const customTheme = this._preferences?.get_string(`${accentColor}-theme`);
        // Get the corresponding gtk theme or default to Adwaita
        const gtkTheme = customTheme || "Adwaita";
        // Set the gtk theme
        this._setGtkTheme(gtkTheme);
    }
    _setGtkTheme(themeName) {
        // Set the gtk theme
        this._settings?.set_string("gtk-theme", themeName);
    }
}
