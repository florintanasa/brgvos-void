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
export default class AccentColorUserThemeExtension extends Extension {
    _settings;
    _usettings;
    _preferences;
    _accentColorChangedId = 0;
    _colorSchemeChangedId = 0;
    _customThemeChangedId = 0;
    userThemesLight = Object.values({});
    userThemesDark = Object.values({});
    enable() {
        // Get the interface settings
        this._settings = new Gio.Settings({
            schema: "org.gnome.desktop.interface",
        });
        // Get user theme settings
        this._usettings = new Gio.Settings({
            schema: "org.gnome.shell.extensions.user-theme",
        });
        // Initializing user shell themes
        this.userThemesLight = Object.values({
            blue: "Fluent-round-Light",
            teal: "Fluent-round-teal-Light",
            green: "Fluent-round-green-Light",
            yellow: "Fluent-round-yellow-Light",
            orange: "Fluent-round-orange-Light",
            red: "Fluent-round-red-Light",
            pink: "Fluent-round-pink-Light",
            purple: "Fluent-round-purple-Light",
            slate: "Fluent-round-grey-Light",
        });
        this.userThemesDark = Object.values({
            blue: "Fluent-round-Dark",
            teal: "Fluent-round-teal-Dark",
            green: "Fluent-round-green-Dark",
            yellow: "Fluent-round-yellow-Dark",
            orange: "Fluent-round-orange-Dark",
            red: "Fluent-round-red-Dark",
            pink: "Fluent-round-pink-Dark",
            purple: "Fluent-round-purple-Dark",
            slate: "Fluent-round-grey-Dark",
        });
        // Get Preferences
        this._preferences = this.getSettings();
        // Connect to accent color changes
        this._accentColorChangedId = this._settings.connect("changed::accent-color", this._onAccentColorChanged.bind(this));
        // Connect to color scheme changes
        this._colorSchemeChangedId = this._settings.connect("changed::color-scheme", this._onAccentColorChanged.bind(this));
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
        // Clear the userThemes array
        this.userThemesLight = [];
        this.userThemesDark = [];
        // Optionally reset to default user shell theme - Adwaita
        this._setUserTheme("Adwaita");
        // Null out settings
        this._settings = null;
        this._usettings = null;
        this._preferences = null;
    }
    _onAccentColorChanged() {
        if(this._settings?.get_string("color-scheme") === 'prefer-dark')
        {
            // Get the current accent color
            const accentColor = this._settings?.get_string("accent-color") ?? "blue";
            // Get custom theme from preferences
            const customTheme = this._preferences?.get_string(`${accentColor}-theme-dark`);
            // Get the corresponding user shell theme or default to Adwaita
            const userTheme = customTheme || "Adwaita";
            // Set the user shell theme
            this._setUserTheme(userTheme);
        }
        else
        {
            // Get the current accent color
            const accentColor = this._settings?.get_string("accent-color") ?? "blue";
            // Get custom theme from preferences
            const customTheme = this._preferences?.get_string(`${accentColor}-theme-light`);
            // Get the corresponding user shell theme or default to Adwaita
            const userTheme = customTheme || "Adwaita";
            // Set the user shell theme
            this._setUserTheme(userTheme);            
        }

    }
    _setUserTheme(themeName) {
        // Set the user shell theme
        this._usettings?.set_string("name", themeName);
    }
}
