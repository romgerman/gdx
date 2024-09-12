class_name GdxParser

class GdxNode:
	var line: int = 0
	var column: int = 0
	var length: int = 0

class GdxRootNode extends GdxNode:
	var nodes: Array[GdxNode] = []

class GdxCtrlNode extends GdxNode:
	var name: String
	var nodes: Array[GdxNode] = []
	var params: Array[GdxCtrlNodeParam] = []
	var directives: Array[GdxCtrlNodeDirective] = []

class GdxCtrlNodeParam:
	var value_type: GdxLexer.TokenType = GdxLexer.TokenType.Text
	var key: String
	var value: GdxLexer.Token
	var bound: bool = false

class GdxCtrlNodeDirective:
	var name: String
	var value: GdxLexer.Token

var token: GdxLexer.Token
var lexer: GdxLexer

func parse(lex: GdxLexer) -> GdxRootNode:
	self.lexer = lex
	self.token = lex.next()

	var root = GdxRootNode.new()
	_parse_control_nodes(root.nodes)
	return root

func _take(token_type: GdxLexer.TokenType, meta: String = ""):
	if token.type == token_type:
		token = lexer.next()
		return true
	else:
		printerr(
			"Unexpected token at ", token.line, ":", token.column,
			". Expected ",
			GdxLexer.TokenType.find_key(token_type),
			", got ",
			GdxLexer.TokenType.find_key(token.type),
			meta
		)
		return false

func _take_any(token_types: Array[GdxLexer.TokenType], meta: String = ""):
	var found = false
	var err_result: Array[String] = []

	for token_type in token_types:
		if token.type == token_type:
			found = true
			break
		else:
			err_result.push_back(GdxLexer.TokenType.find_key(token_type))

	if found:
		token = lexer.next()
		return true
	else:
		printerr(
			"Unexpected token at ", token.line, ":", token.column,
			". Expected ",
			" or ".join(err_result),
			", got ",
			GdxLexer.TokenType.find_key(token.type),
			meta
		)
		return false

func _expect(token_type: GdxLexer.TokenType, meta: String = ""):
	if token.type == token_type:
		return true
	else:
		printerr(
			"Unexpected token at ", token.line, ":", token.column,
			". Expected ",
			GdxLexer.TokenType.find_key(token_type),
			", got ",
			GdxLexer.TokenType.find_key(token.type),
			meta
		)
		return false

func _parse_control_nodes(nodes: Array[GdxNode]):
	while token.type != GdxLexer.TokenType.EOF:
		if !_parse_control_node(nodes): return false
	return true

func _parse_control_node(nodes: Array[GdxNode]):
	var meta = " while parsing node";
	if !_take(GdxLexer.TokenType.OpenTag, meta): return false

	var ctrl_node = GdxCtrlNode.new()
	ctrl_node.name = token.text
	ctrl_node.line = token.line
	ctrl_node.column = token.column

	if !_take(GdxLexer.TokenType.Identifier, meta): return false

	while token.type == GdxLexer.TokenType.Binding:
		if !_parse_control_node_directive(ctrl_node.directives): return false

	while token.type == GdxLexer.TokenType.Identifier:
		if !_parse_control_node_param(ctrl_node.params): return false

	# Self-closing node
	if token.type == GdxLexer.TokenType.FwdSlash:
		token = lexer.next()
		if !_take(GdxLexer.TokenType.CloseTag, meta):
			return false
		nodes.push_back(ctrl_node)
		return true

	if !_take(GdxLexer.TokenType.CloseTag, meta): return false

	# Parse nested nodes
	if _expect(GdxLexer.TokenType.OpenTag, meta):
		if lexer.peek().type == GdxLexer.TokenType.FwdSlash:
			token = lexer.next()
			token = lexer.next()
			if _expect(GdxLexer.TokenType.Identifier, meta):
				var identifier = token.text
				if identifier == ctrl_node.name:
					token = lexer.next()
					if !_take(GdxLexer.TokenType.CloseTag, meta): return false
					nodes.push_back(ctrl_node)
					return true
				else:
					printerr("Closing and opening tag does not match. ", identifier, " != ", ctrl_node.name)
					return false
			else:
				return false
		elif lexer.peek().type == GdxLexer.TokenType.Identifier:
			while token.type == GdxLexer.TokenType.OpenTag:
				if !_parse_control_node(ctrl_node.nodes): return false
				if _expect(GdxLexer.TokenType.OpenTag, meta):
					if lexer.peek().type == GdxLexer.TokenType.FwdSlash:
						token = lexer.next()
						token = lexer.next()
						if _expect(GdxLexer.TokenType.Identifier, meta):
							var identifier = token.text
							if identifier == ctrl_node.name:
								token = lexer.next()
								if !_take(GdxLexer.TokenType.CloseTag, meta): return false
								nodes.push_back(ctrl_node)
								return true
							else:
								printerr("Closing and opening tag does not match. ", identifier, " != ", ctrl_node.name)
								return false
						else:
							return false
		else:
			return false

	return true

func _parse_control_node_param(params: Array[GdxCtrlNodeParam]):
	var meta = " while parsing node param"
	var param_name = token.text

	if !_take(GdxLexer.TokenType.Identifier, meta): return false

	var is_bound = false
	if token.type == GdxLexer.TokenType.Binding:
		token = lexer.next()
		is_bound = true

	if !_take(GdxLexer.TokenType.Assign, meta): return false

	var param_value = token

	if is_bound:
		var lex := GdxLexer.new(param_value.text)
		var tok := lex.next()
		param_value = tok
		_take(GdxLexer.TokenType.Text)
	elif !_take(GdxLexer.TokenType.Text, meta):
		return false

	var param = GdxCtrlNodeParam.new()
	param.value_type = token.type
	param.key = param_name
	param.value = param_value
	param.bound = is_bound
	params.push_back(param)
	return true

func _parse_control_node_directive(directives: Array[GdxCtrlNodeDirective]):
	var meta = " while parsing node directive"

	if !_take(GdxLexer.TokenType.Binding, meta): return false

	var param_name = token.text
	if !_take(GdxLexer.TokenType.Identifier, meta): return false
	if !_take(GdxLexer.TokenType.Assign, meta): return false

	var lex := GdxLexer.new(token.text)
	var param_value = lex.next()
	if !_take(GdxLexer.TokenType.Text, meta):
		return false

	var param = GdxCtrlNodeDirective.new()
	param.name = param_name
	param.value = param_value
	directives.push_back(param)
	return true
