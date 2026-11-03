---
title: Installation
description: Download and install Cowork on Windows, macOS or Linux, or build it from source.
---

# Installation

Download the installer for your system from the [Releases page](https://github.com/nguyendkn/cowork/releases). What changed in each version is in the [Release Notes](./release-notes.md).

| System | File | Install |
| ------ | ---- | ------- |
| Windows 10/11 (x64) | `cowork-<version>-windows-x86_64-setup.exe` | Run it and follow the steps. It installs for your user by default, adds a Start menu entry and can add a desktop icon. |
| macOS, Apple silicon | `cowork-<version>-macos-aarch64.dmg` | Open the disk image and drag **Cowork** to **Applications**. |
| Ubuntu / Debian (x64) | `cowork-<version>-linux-x86_64.deb` | `sudo apt install ./cowork-<version>-linux-x86_64.deb`, then start **Cowork** from the menu or run `cowork`. |

Every release also has `.zip` / `.tar.gz` archives (unpack and run, nothing is installed) and `SHA256SUMS.txt` to check a download:

```sh
sha256sum -c --ignore-missing SHA256SUMS.txt     # Linux
shasum -a 256 -c --ignore-missing SHA256SUMS.txt # macOS
```

## First Launch {#first-launch}

The installers are not signed with a developer certificate yet, so the system asks before it runs them:

- **Windows**: SmartScreen shows "Windows protected your PC". Choose **More info**, then **Run anyway**.
- **macOS**: Control-click **Cowork** in Applications, choose **Open**, then **Open** again. This is needed once.

## Uninstalling {#uninstall}

- **Windows**: Settings, Apps, Installed apps, Cowork, Uninstall.
- **macOS**: drag Cowork from Applications to the Bin.
- **Linux**: `sudo apt remove cowork`.

To also remove your data, delete the folders listed in [Configuration Files](./configuration-files.md).

# Build from Source

To change Cowork yourself, build it from source.

## Requirements {#requirements}

- **Windows x64** with the MSVC toolchain (Visual Studio Build Tools), **macOS** (Xcode with its Metal Toolchain) or **Linux**. Windows is the platform the app is developed on. The browser tab is Chromium via CEF.
- **Rust** stable, installed with [rustup](https://rustup.rs).
- **cmake** and **ninja** on `PATH` for the first build: it compiles CEF's C++ wrapper. The Visual Studio Build Tools ship both, and `make` adds them to `PATH` for you (override the folder with `VS_CMAKE_DIR`).
- **Network access on the first build**: the build downloads the CEF distribution (about 300 MB) into `app/.cef/`.

## Build and Run {#build-and-run}

From the `app/` folder:

```sh
make build           # debug build of the app
make run             # build and start it
make build PROFILE=release
```

`make help` lists every target (`test`, `check`, `fmt`, `clippy`, `watch`, ...). Without `make`, `cargo run -p app` does the same once `cmake` and `ninja` are on `PATH`.

The first build takes a while because of CEF; later builds only recompile what changed.

## Shipping the App {#shipping}

The browser runtime has to sit next to the executable. Copy `app.exe` together with the CEF files that the build places in `target/<profile>/`: `libcef.dll`, the `*.pak` files, `icudtl.dat` and the `locales/` folder. The executable doubles as CEF's helper process, so no other binary is needed.

## Where Cowork Keeps Its Files {#files}

Your session, shortcuts and command history live in `%APPDATA%\cowork\` on Windows and in `~/.config/cowork/` on macOS and Linux. See [Configuration Files](./configuration-files.md). Nothing is written next to the executable.

## Updating a Source Build {#update-uninstall}

Pull the new source and build again. To uninstall, delete the folder you built in.
