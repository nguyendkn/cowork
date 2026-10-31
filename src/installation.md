---
title: Installation
description: Build Cowork from source, run it, and ship the browser runtime next to the executable.
---

# Installation

Cowork is built from source. There is no installer yet.

## Requirements {#requirements}

- **Windows x64** with the MSVC toolchain (Visual Studio Build Tools). This is the platform the app is developed and tested on. The browser tab is Chromium via CEF and runs on Windows only for now.
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

Your session, shortcuts and command history live in `%APPDATA%\cowork\`. See [Configuration Files](./configuration-files.md). Nothing is written next to the executable.

## Updating and Uninstalling {#update-uninstall}

To update, pull the new source and build again. To uninstall, delete the folder you built in. To also remove your data, delete `%APPDATA%\cowork\` and `%LOCALAPPDATA%\cowork\` (the browser cache and log).
