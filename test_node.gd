extends Control

class Model:
	var pos := Vector2(100, 100)
	var pos2 := Vector2(200, 200)
	var text := "No hello"

func _ready() -> void:
	var output = GdxRender.render_text('
		<TextureRect texture="res://icon.svg" position:="pos" name="HelloTexture" ref:="texture_ref">
			# <TweenNode on="mouse_entered">
			# 	<TweenProperty prop_name="scale" value:="Vector2(1.2, 1.2)" duration:="0.25" delay:="0.1" />
			# 	<TweenProperty prop_name="scale" value:="Vector2(1, 1)" duration:="0.25" delay:="0.1" />
			# </TweenNode>
		</TextureRect>
		<Control>
			<Label text="Hello \'world\'" position:="pos" />
			<Label text="Hello world" />
			<Control>
				<Button text:="text" position:="pos2" ref:="btn" />
			</Control>
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
