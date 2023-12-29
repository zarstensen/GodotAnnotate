<div align="center">
  <h1 align="center">Godot Annotate</h1>
  <img src=annotate_layer.svg alt="Icon" width="200" height="200"/>
</div>

[![Godot Assets](https://img.shields.io/badge/Godot_Asset_Library-blue)](https://godotengine.org/asset-library/asset/2432)

This is a [Godot](https://godotengine.org/) plugin which allows one to make planning  annotations and sketches directly in the 2D editor, without affecting runtime visuals, using a custom 'AnnotateCanvas' node.

- [Features](#features)
  - [Annotate](#annotate)
  - [Polygon Mode](#polygon-mode)
  - [Erase](#erase)
  - [Control Annotation Visibility](#control-annotation-visibility)
  - [Save Canvas As Image](#save-canvas-as-image)
- [Usage](#usage)
  - [Controls](#controls)
  - [Locking](#locking)
- [Installing](#installing)
- [Links](#links)
- [License](#license)

## Features

### Annotate

Annotate with variable brush size and color directly in the 2D editor using the 'AnnotateCanvas' node.

![Annotate Example](examples/Annotate.gif)

### Polygon Mode

Use polygon mode to draw straight lines between clicks.

![Polygon Mode Example](examples/AnnotatePoly.gif)

### Erase

Erase any previously drawn annotate strokes.

![Erase Example](examples/Erase.gif)

### Control Annotation Visibility

Only show annotations in the 2D editor (optionally show in run mode).

![Visibility Example](examples/Visibility.gif)

### Save Canvas As Image

Save the canvas to disk as an image file.

![Save To Disk Example](examples/SaveToDisk.gif)

## Usage

To start annotating, add the 'AnnotateCanvas' node to a godot scene.

### Controls

**Left Mouse Button**
: Annotate on the currenty selected 'AnnotateCanvas' node.

**Alt + Left Mouse Button**
: Annotate on the currently selected 'AnnotateCanvas' node using the polygon mode.

**Right Mouse Button**
: Erase annotate strokes on the currently selected 'AnnotateCanvas' node.

**Shift + Mouse Scroll**
: Change brush size.

**Shift + Alt + S**
: Save the selected 'AnnotateCanvas' to disk as an image.

### Locking

Locking an 'AnnotateCanvas' node does not prevent it from being drawn on, instead toggle the 'Advanced > Lock Canvas' property to prevent this.

## Installing

See [Installing Plugins](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html), for how to add this plugin to your Godot project.

## Links

[Godot Assets](https://godotengine.org/asset-library/asset/2432)

## License

See [LICENSE](LICENSE)
