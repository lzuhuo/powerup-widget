# powerup-widget

Tech-styled Omarchy power widget with live hardware telemetry.

## Features

- Battery percentage, charge state, health, cycles, rate and charge limit.
- Power profile switching for balanced, power-saver and performance modes.
- CPU usage, memory usage, load average and system uptime.
- CPU temperature and fan RPM through `lm-sensors` when available.
- Automatic refresh while the panel is open.
- Keyboard navigation and right-click percentage toggle.

## Requirements

- Omarchy with the Quickshell shell.
- `lm-sensors` is optional and enables temperature/fan readings.
- The Omarchy commands `omarchy-battery-status`, `omarchy-system-stats` and
  `omarchy-powerprofiles-list`.

## Install

```bash
git clone https://github.com/lzuhuo/powerup-widget.git
cd powerup-widget
chmod +x install.sh
./install.sh
```

The installer copies the plugin to
`~/.config/omarchy/plugins/powerup.power`, adds it to the right side of the bar,
and creates a timestamped backup if an existing copy is found.

To enable hardware sensors:

```bash
sudo pacman -S lm_sensors
sudo sensors-detect
```

The widget continues to work without sensors and shows `N/A` for unavailable
readings.

## Remove

```bash
./uninstall.sh
```

## Development

The live plugin files are in `plugin/`. Changes under
`~/.config/omarchy/plugins/` are hot-reloaded by Omarchy Shell. After editing
the project copy, run `./install.sh` to deploy it.

## License

MIT. See [LICENSE](LICENSE).
