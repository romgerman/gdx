extends Control

func render_ui(hello: String) -> GdxRender.GdxRenderOutput:
	return GdxRender.render_text('
		<TextureRect texture="res://icon.svg" position:="pos" name="HelloTexture" ref:="texture_ref" />
		<Control>
			<Label text="Hello \'world\'" position:="pos" />
			<Label text="Hello world" />
			<Control>
				<Button text:="btn_text" position:="pos2" size:="Vector2(100, 100)" ref:="btn" />
			</Control>
			<ColorRect :for="i in 5" name:="i" size:="rect_size * 2" visible:="false" />
			# <HBox anchor_left:="0.0" anchor_right:="1.0">
			# </HBox>
		</Control>
	', self, {
		"pos" = Vector2(100, 100),
		"pos2" = Vector2(200, 200),
		"btn_text" = "Hello \"" + hello + "\"",
		"rect_size" = Vector2(50, 20),
	})

func _ready() -> void:
	var output = render_ui("World")
	if not output: return

	var ref := output.refs.texture_ref as TextureRect
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_loops()
	tween.tween_property(ref, "scale", Vector2(1.2, 1.2), 0.25).set_delay(0.1)
	tween.tween_property(ref, "scale", Vector2.ONE, 0.25).set_delay(0.1)
	tween.play()

	var btn := output.refs.btn as Button
	btn.pressed.connect(func ():
		print("Button pressed")
	)
