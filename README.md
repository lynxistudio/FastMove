# FastMove

[![Download](https://img.shields.io/badge/Download-v1.0-blue?style=flat-square&logo=github)](https://github.com/lynxistudio/FastMove/releases/latest)
[![Platform](https://img.shields.io/badge/macOS-14.0%2B-lightgrey?style=flat-square&logo=apple)](https://github.com/lynxistudio/FastMove)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

A macOS utility for moving large numbers of small files to NAS / SMB shares without the Finder bottleneck.

## Why

Finder's file copy/move is painfully slow when dealing with thousands of small files over SMB. It serializes metadata operations and chokes on latency. `rsync` handles this efficiently with bulk streaming and delta transfers — FastMove wraps `rsync` in a clean SwiftUI interface.

## Features

- **Left-right split layout**: drag files into the source panel, set the target directory, hit go
- **rsync-powered moves**: uses `rsync -avh --remove-source-files --ignore-existing` under the hood
- **Real-time progress**: per-file logs with timestamps, completed/failed counts
- **Cancellation**: cancel mid-flight without losing data (files already moved stay moved)
- **Additive drag-and-drop**: drop more files onto the source panel at any time to append
- **No Finder dependency**: bypasses Finder entirely; no `.DS_Store` noise, no metadata lag

## Requirements

- macOS 14.0 (Sonoma) or later
- Apple Silicon (arm64)
- Xcode Command Line Tools (`xcode-select --install`)
- `rsync` (pre-installed on macOS)

## Quick Start

### Build from source

```bash
chmod +x build.sh
./build.sh
open build/FastMove.app
```

### Open in Xcode

```bash
open FastMove.xcodeproj
```

Then Product > Run (Cmd+R).

## Project Structure

```
FastMove/
├── FastMove.xcodeproj/       # Xcode project
├── FastMove/                 # Source code
│   ├── FastMoveApp.swift     # App entry point
│   ├── ContentView.swift     # Main split layout
│   ├── Info.plist            # App metadata
│   ├── Models/
│   │   └── FileItem.swift    # File data model
│   ├── ViewModels/
│   │   └── MoverViewModel.swift  # Business logic
│   ├── Services/
│   │   └── RsyncService.swift    # rsync wrapper
│   └── Views/
│       ├── SourcePanel.swift     # Drag-and-drop source
│       ├── TargetPanel.swift     # Destination picker
│       ├── ProgressPanel.swift   # Progress bar + stats
│       └── LogView.swift         # Scrollable log
├── build.sh                  # CLI build script
├── LICENSE
└── README.md
```

## Usage

1. Launch FastMove
2. Drag files/folders into the left panel (or click "Select Files")
3. Click "Select" on the right panel to pick a destination
4. Click "Start Moving"
5. Watch the progress — cancel anytime if needed

## How It Works

Each source file/folder is moved individually using:

```bash
rsync -avh --remove-source-files --ignore-existing <source> <destination>/
```

- `-a`: archive mode (preserves permissions, timestamps)
- `-v`: verbose (feeds the log panel)
- `-h`: human-readable sizes
- `--remove-source-files`: deletes source after successful transfer (effectively a move)
- `--ignore-existing`: skips files already at destination

The SwiftUI layer reads `rsync` stdout/stderr in real time via `Process()` and `Pipe`.

## License

MIT — see [LICENSE](LICENSE).