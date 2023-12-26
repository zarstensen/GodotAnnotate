<div align="center">
  <h1 align="center">Godot Annotate</h1>
  <img src=annotate_layer.svg alt="Icon" width="200" height="200"/>
</div>

[![Godot Assets](https://img.shields.io/badge/Godot_Asset_Library-blue)](https://godotengine.org/asset-library/asset/2432)

This is a [Godot](https://godotengine.org/) plugin which allows one to make planning  annotations and sketches directly in the 2D editor, without affecting runtime visuals, using a custom 'AnnotateCanvas' node.

- [Features](#features)
  - [Annotate](#annotate)
  - [Erase](#erase)
  - [Run Mode Annotations](#run-mode-annotations)
- [Usage](#usage)
- [Links](#links)
- [License](#license)

## Features

### Annotate

Annotate with variable brush size and color directly in the 2D editor using the 'AnnotateCanvas' node.

![Annotate Example](examples/Annotate.gif)

### Erase

Erase any previously drawn annotate strokes.

![Erase Example](examples/Erase.gif)

### Run Mode Annotations

Only show annotations in the 2D editor (optionally show in run mode).

![Visibility Example](examples/Visibility.gif)

## Usage

To start annotating, add the 'AnnotateCanvas' node to a godot scene.

Use Left Mouse Button to annotate on the currenty selected 'AnnotateCanvas' node.

Use Right Mouse Button to erase annotate strokes on the currently selected 'AnnotateCanvas' node.

Use Shift + Mouse Scroll to quickly change the brush size.

## Links

[Godot Assets](https://godotengine.org/asset-library/asset/2432)

## License

See [LICENSE](LICENSE)
