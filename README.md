# Godot Script XML

Just a proof of concept

# Installation

Place contents of `addons/gdx` folder into your `addons/gdx` folder.

# Usage

Use `GdxRender.render_text` to "render" nodes.

Example:

```gdscript
var output = GdxRender.render_text('
	<TextureRect texture="res://icon.svg" position:="pos" name="HelloTexture" ref:="texture_ref" />
	<Control>
		<Label text="Hello world" position:="pos" />
		<Label text="Hello world" />
		<Control>
			<Label text:="text" position:="pos2" />
		</Control>
	</Control>
', self, {
	"pos": Vector2(100, 100),
	"pos2": Vector2(200, 200),
	"text": "No hello"
})
```

`output.refs` contains refs you defined inside the code. It's a `Dictionary` with nodes.

Example:

```gdscript
var ref := output.refs.texture_ref as TextureRect
var tween = create_tween().set_trans(Tween.TRANS_SINE).set_loops()
tween.tween_property(ref, "scale", Vector2(1.2, 1.2), 0.25).set_delay(0.1)
tween.tween_property(ref, "scale", Vector2.ONE, 0.25).set_delay(0.1)
tween.play()
```

See full example inside `test_node.gd`.
