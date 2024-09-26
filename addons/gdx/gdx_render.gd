class_name GdxRender

class GdxRenderOutput:
	var refs: Dictionary = {}
	var nodes: Array[Node] = []

static func render_text(text: String, root_node: Node, bindings: Dictionary = {}) -> GdxRenderOutput:
	var out = GdxRenderOutput.new()
	var parser := GdxParser.new()
	var root := parser.parse(GdxLexer.new(text))
	var vars = {}
	if parser.errors.size() == 0:
		for n in root.nodes:
			var node = _render_node(root_node, n, bindings, out, false, vars)
			out.nodes.push_back(node)
		return out
	else:
		for err in parser.errors:
			printerr(err)
		return null

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

static func _render_node(root: Node, n: GdxParser.GdxCtrlNode, bindings: Dictionary, out: GdxRenderOutput, skip_directives: bool, vars: Dictionary):
	var result: Node

	if not _control_map.has(n.name):
		printerr("Control with type \"" + n.name + "\" not found")
		return

	result = _control_map.get(n.name).new()
	if n.directives.size() == 0 or skip_directives:
		for param in n.params:
			if param.bound:
				if param.key == "ref":
					out.refs[param.value] = result
				else:
					var expr = Expression.new()
					var expr_vars = bindings.keys()
					expr_vars.append_array(vars.keys())
					expr.parse(param.value, expr_vars)
					var expr_values = bindings.values()
					expr_values.append_array(vars.values())
					var expr_res = expr.execute(expr_values)
					result.set(param.key, expr_res)
			else:
				if "res://" in param.value:
					var res = ResourceLoader.load(param.value)
					result.set(param.key, res)
				else:
					result.set(param.key, param.value)
	if not skip_directives:
		for directive in n.directives:
			if _directive_map.has(directive.name):
				_directive_map[directive.name].call(root, n, directive.value, bindings, out, vars)
			else:
				printerr("Directive with name \"" + directive.name + "\" not found")
	for n2 in n.nodes:
		_render_node(result, n2, bindings, out, false, vars)
	if skip_directives or n.directives.size() == 0:
		root.add_child(result)

static func _for_directive(root: Node, node: GdxParser.GdxCtrlNode, expr: GdxParser.GdxCtrlExpression, bindings: Dictionary, out: GdxRenderOutput, vars: Dictionary):
	if not expr:
		printerr("Directive expression is empty")
		return

	if expr.left.type != GdxLexer.TokenType.Identifier:
		printerr("Expected Identifier but got ", expr.left.token_type_name, "=", expr.text)
		return

	if expr.op.type != GdxLexer.TokenType.Keyword:
		printerr("Expected Keyword (in) but got ", expr.op.token_type_name, "=", expr.text)
		return

	if expr.right.type != GdxLexer.TokenType.Number and expr.right.type != GdxLexer.TokenType.Identifier:
		printerr("Expected Number or Identifier but got ", expr.right.token_type_name, "=", expr.text)
		return

	var count = 0

	if expr.right.type == GdxLexer.TokenType.Number:
		count = _token_to_value(expr.right)
	elif expr.right.type == GdxLexer.TokenType.Identifier:
		if bindings.has(expr.right.text):
			count = bindings[expr.right.text]
		elif vars.has(expr.right.text):
			count = bindings[expr.right.text]
		else:
			printerr("No variable or binding was found with name \"" + expr.right.text + "\"")

	for i in range(count):
		var next_vars = {
			expr.left.text: i
		}
		next_vars.merge(vars)
		_render_node(root, node, bindings, out, true, next_vars)

static func _token_to_value(token: GdxLexer.Token):
	if token.type == GdxLexer.TokenType.Identifier or token.type == GdxLexer.TokenType.Keyword:
		if token.text == "true":
			return true
		elif token.text == "false":
			return false
	elif token.type == GdxLexer.TokenType.Number:
		if "." in token.text:
			return float(token.text)
		else:
			return int(token.text)
	else:
		printerr("Cannot convert ", token.token_type_name, " to value")
		return null
