class_name GdxRender

class GdxRenderOutput:
	var refs: Dictionary = {}

static func render_text(text: String, root_node: Node, bindings: Variant = {}) -> GdxRenderOutput:
	var out = GdxRenderOutput.new()
	var parser := GdxParser.new()
	var root := parser.parse(GdxLexer.new(text))
	var nodes = []
	for n in root.nodes:
		var node = _render_node(n, bindings, out)
		root_node.add_child(node)
	return out

static var _control_map: Dictionary = {
	"Control" = Control,
	"Panel" = Panel,
	"Label" = Label,
	"TextureRect" = TextureRect,
	"Button" = Button
}

static func _render_node(n: GdxParser.PControlNode, bindings: Variant, out: GdxRenderOutput) -> Node:
	var result: Node

	if _control_map.has(n.type_name):
		result = _control_map.get(n.type_name).new()

	if result != null:
		for param in n.params:
			if param.bound:
				if param.key == "ref":
					out.refs[param.value] = result
				else:
					result.set(param.key, bindings[param.value])
			else:
				if "res://" in param.value:
					var res = ResourceLoader.load(param.value)
					result.set(param.key, res)
				else:
					result.set(param.key, param.value)
		for n2 in n.nodes:
			result.add_child(_render_node(n2, bindings, out))
	return result
