extends Control

func _ready() -> void:
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

	var ref := output.refs.texture_ref as TextureRect
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_loops()
	tween.tween_property(ref, "scale", Vector2(1.2, 1.2), 0.25).set_delay(0.1)
	tween.tween_property(ref, "scale", Vector2.ONE, 0.25).set_delay(0.1)
	tween.play()
