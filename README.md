<div align="center">
  <h1 align="center">Godot Annotate</h1>
  <img src=src/canvas/annotate_canvas_icon.svg alt="Icon" width="200" height="200"/>
</div>

[![Godot Assets](https://img.shields.io/badge/Godot_Asset_Library-blue)](https://godotengine.org/asset-library/asset/2432)

Godot Annotate is a [Godot](https://godotengine.org/) plugin which allows one to make mockups and sketches directly in the 2D editor using a custom 'AnnotateCanvas' node.

<!-- omit in toc -->
## Table of Contents
- [Features](#features)
  - [Sketch](#sketch)
  - [Multiple Modes / Brushes](#multiple-modes--brushes)
  - [Edit Strokes Post Finish](#edit-strokes-post-finish)
  - [Undo / Redo History](#undo--redo-history)
  - [Generate Hitboxes from Canvas](#generate-hitboxes-from-canvas)
  - [Control Canvas Visibility](#control-canvas-visibility)
  - [Save Canvas As Image](#save-canvas-as-image)
- [Usage](#usage)
  - [Toolbar](#toolbar)
    - [Toggle Annotate](#toggle-annotate)
  - [Keyboard Shortcuts](#keyboard-shortcuts)
  - [Locking](#locking)
- [Installing](#installing)
  - [Latest Version](#latest-version)
  - [Any Version](#any-version)
- [Links](#links)
- [License](#license)

## Features

### Sketch

Draw sketches or mockups with variable brush size and color directly in the 2D editor using the 'AnnotateCanvas' node.

![Annotate Example](examples/Annotate.gif)

### Multiple Modes / Brushes

Use polygon mode to draw straight lines between clicks.

![Polygon Mode Example](examples/AnnotatePoly.gif)

### Edit Strokes Post Finish

Erase any previously drawn annotate strokes.

![Erase Example](examples/Erase.gif)

### Undo / Redo History

Each action performed in a 'AnnotateCanvas' is added to the editors undo / redo history, so you dont have to wory about drawing the perfect stroke first try every time.

### Generate Hitboxes from Canvas

Use the 'CanvasCollisionShape' node to convert all sketches in a 'AnnotateCanvas' to a series of CollisionShape2D's.

### Control Canvas Visibility

Only show annotations in the 2D editor (optionally show in run mode).

![Visibility Example](examples/Visibility.gif)

### Save Canvas As Image

Save the canvas to disk as an image file.

![Save To Disk Example](examples/SaveToDisk.gif)

## Usage

To start annotating, add the 'AnnotateCanvas' node to a godot scene, then perform one of the following actions.

**Left Mouse Button**
: Draw a stroke on the currenty selected 'AnnotateCanvas' node.

**Right Mouse Button**
: Erase strokes on the currently selected 'AnnotateCanvas' node.



### Toolbar
#### Toggle Annotate
### Keyboard Shortcuts

### Locking

Locking an 'AnnotateCanvas' node does not prevent it from being drawn on, instead toggle the 'Advanced > Lock Canvas' property to prevent this.

## Installing
> [!CAUTION]
> **v0.3.x** is not compatible with **v1.x** or later. This means all AnnotateCanvas nodes need to be **DELETED AND REDRAWN** if you want to update this plugin from v0.3.x to a later version. If you want to install a v0.3.x version of this plugin, please refer to the [Any Version](#any-version) isntall section.

### Latest Version
TODO: write


### Any Version
TODO: write


See [Installing Plugins](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html), for how to add this plugin to your Godot project.

## Links

[Godot Assets](https://godotengine.org/asset-library/asset/2432)

## License

See [LICENSE](LICENSE)
