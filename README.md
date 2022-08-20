## fl2xui

fl2xui is a cross-platform  GUI for the [flightlog2kml](https://github.com/stronnag/bbl2kml), a tool to generate beautiful colour coded, annotated, animated KML / KMZ from INAV blackbox and other (OTX, ETX, Bullet GCSS) flight logs.

![Linux](docs/docs/images/linux.png)
![MacOS](docs/docs/images/macos.png)
![Windows](docs/docs/images/windows.png)

* Multiple logs (BBL, OTX)
* Summary information

<figure>
  <img src="docs/docs/images/v3.jpeg" alt="Efficiency" style="width:100%">
  <figcaption>example flightlog2kml Efficiency Plot</figcaption>
</figure>

## User Guide

The user guide is [online](https://stronnag.github.io/fl2xui/). The following sections are a summary.

## OS Specific features and limitations

### Linux, FreeBSD

* Drag and drop of (multiple) logs and mission files from the file manager.
* Multiple selection of logs from file chooser

### Windows

* Multiple selection of logs from file chooser
* Drag and drop via Desktop shortcut

## Dependencies

fl2xui depends upon the following open source packages:

* [flight2kml](https://github.com/stronnag/bbl2kml/)
* [INAV's blackbox_decode](https://github.com/iNavFlight/blackbox-tools)

## Installation

### Linux, FreeBSD

* Common GTK packages (meson (and ninja), vala, gtk4 / lib-gtk-4-dev, json-glib, desktop-file-utils)
* Easily built from source
    ```
	# Once (setup)
	meson build --buildtype=release --strip --prefix=~/.local
	# Build and install to ~/.local/bin (add to PATH if necessary)
	meson install -C build
   ```
* Debian package `*.deb` for Debian / Ubuntu and derivatives in release area.
* Output by default to current working directory.

### Windows

* Win64 Installer (release area)
* Multiple files may be selected from the file chooser.
* Output by default to the user's "Documents" (`C:\Users\USERNAME\Documents`) directory.
* Can be built from source using Msys2.
    ```
	pacman -Syu
	pacman -S gtk4 vala meson ninja json-glib
	meson build --buildtype=release --strip --prefix=~/.local
	# Note, need to say where the gir files are for blueprint-compiler
    XDG_DATA_DIRS=/mingw64/share meson -C build install
	```
* Recommended that `blackbox_decode` and `flightlog2kml` are in the `fl2xui\bin` directory (as in the release archive).

### MacOS

* Use Homebrew:
    ```
	# install requirements:
	brew install meson vala gtk4 json-glib
	# Once (setup)
	meson build --buildtype=release --strip --prefix=~/.local
	# Build and install to ~/.local/bin (add to PATH if necessary)
	meson install -C build
   ```
* If there are missing icons (specifically the +/- for time interval widget), it may be necessary to `brew install adwaita-icon-theme`.

### All platforms

You can build a `gtk3` version from the `legacy` branch.
