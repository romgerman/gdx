extends Control

class Model:
	var pos := Vector2(100, 100)
	var pos2 := Vector2(200, 200)
	var text := "Hello \"world\""
	var rect_size := Vector2(50, 20)

func _ready() -> void:
	var output = GdxRender.render_text('
		<TextureRect texture="res://icon.svg" position:="pos" name="HelloTexture" ref:="texture_ref" />
		<Control>
			<Label text="Hello \'world\'" position:="pos" />
			<Label text="Hello world" />
			<Control>
				<Button text:="text" position:="pos2" ref:="btn" />
			</Control>
			<ColorRect :for="i in 5" size:="rect_size" visible:="false" />
			# <HBox anchor_left:="0.0" anchor_right:="1.0">
			# </HBox>
		</Control>
	', self, Model.new())

	var ref := output.refs.texture_ref as TextureRect
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_loops()
	tween.tween_property(ref, "scale", Vector2(1.2, 1.2), 0.25).set_delay(0.1)
	tween.tween_property(ref, "scale", Vector2.ONE, 0.25).set_delay(0.1)
	tween.play()

	var btn := output.refs.btn as Button
	btn.pressed.connect(func ():
		print("Button pressed")
	)
