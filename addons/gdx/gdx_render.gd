class_name GdxRender

class GdxRenderOutput:
	var refs: Dictionary = {}
	var nodes: Array[Node] = []

static func render_text(text: String, root_node: Node, bindings: Variant = {}) -> GdxRenderOutput:
	var out = GdxRenderOutput.new()
	var parser := GdxParser.new()
	var root := parser.parse(GdxLexer.new(text))
	for n in root.nodes:
		var node = _render_node(root_node, n, bindings, out)
		out.nodes.push_back(node)
	return out

static var _control_map: Dictionary = {
	"Control" = Control,
	"Panel" = Panel,
	"Label" = Label,
	"TextureRect" = TextureRect,
	"ColorRect" = ColorRect,
	"HBox" = HBoxContainer,
	"Button" = Button
}

static var _directive_map: Dictionary = {
	"for" = _for_directive
}

static func _render_node(root: Node, n: GdxParser.GdxCtrlNode, bindings: Variant, out: GdxRenderOutput, skip_directives: bool = false):
	var result: Node

	if _control_map.has(n.name):
		result = _control_map.get(n.name).new()
		for param in n.params:
			if param.bound:
				if param.key == "ref":
					out.refs[param.value.text] = result
				else:
					result.set(param.key, bindings[param.value.text])
			else:
				if "res://" in param.value.text:
					var res = ResourceLoader.load(param.value.text)
					result.set(param.key, res)
				else:
					result.set(param.key, param.value.text)
		if not skip_directives:
			for directive in n.directives:
				if _directive_map.has(directive.name):
					_directive_map[directive.name].call(root, n, directive.value, bindings, out)
				else:
					printerr("Directive with name \"" + directive.name + "\" not found")
		for n2 in n.nodes:
			_render_node(result, n2, bindings, out)
		if skip_directives or n.directives.size() == 0:
			root.add_child(result)
	else:
		printerr("Control with type \"" + n.name + "\" not found")

static func _for_directive(root: Node, node: GdxParser.GdxCtrlNode, value: GdxLexer.Token, bindings: Variant, out: GdxRenderOutput):
	if value.type != GdxLexer.TokenType.Number:
		print("Expected Number but got ", value.token_type_name, "=", value.text)
		return

	var count = int(value.text)

	for i in range(count):
		_render_node(root, node, bindings, out, true)
