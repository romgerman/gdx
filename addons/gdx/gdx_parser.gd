class_name GdxParser

class PNode:
	var line: int = 0
	var column: int = 0
	var length: int = 0

class PRootNode extends PNode:
	var nodes: Array[PNode] = []

class PControlNode extends PNode:
	var type_name: String
	var nodes: Array[PNode] = []
	var params: Array[PControlNodeParam] = []
	var directives: Array[PControlNodeDirective] = []

class PControlNodeParam:
	var value_type: GdxLexer.TokenType = GdxLexer.TokenType.Text
	var key: String
	var value: String
	var bound: bool = false

class PControlNodeDirective:
	var name: String
	var value: String

var token: GdxLexer.Token
var lexer: GdxLexer

func parse(lex: GdxLexer) -> PRootNode:
	self.lexer = lex
	self.token = lex.next()

	var root = PRootNode.new()
	_parse_control_nodes(root.nodes)
	return root

func _take(token_type: GdxLexer.TokenType, meta: String = ""):
	if self.token.type == token_type:
		self.token = lexer.next()
		return true
	else:
		printerr(
			"Unexpected token at ", token.line, ":", token.column,
			". Expected ",
			GdxLexer.TokenType.find_key(token_type),
			", got ",
			GdxLexer.TokenType.find_key(self.token.type),
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
		self.token = lexer.next()
		return true
	else:
		printerr(
			"Unexpected token at ", token.line, ":", token.column,
			". Expected ",
			" or ".join(err_result),
			", got ",
			GdxLexer.TokenType.find_key(self.token.type),
			meta
		)
		return false

func _expect(token_type: GdxLexer.TokenType, meta: String = ""):
	if self.token.type == token_type:
		return true
	else:
		printerr(
			"Unexpected token at ", token.line, ":", token.column,
			". Expected ",
			GdxLexer.TokenType.find_key(token_type),
			", got ",
			GdxLexer.TokenType.find_key(self.token.type),
			meta
		)
		return false

func _parse_control_nodes(nodes: Array[PNode]):
	while token.type != GdxLexer.TokenType.EOF:
		if !_parse_control_node(nodes): return false
	return true

func _parse_control_node(nodes: Array[PNode]):
	var meta = " while parsing node";
	if !_take(GdxLexer.TokenType.OpenTag, meta): return false

	var ctrl_node = PControlNode.new()
	ctrl_node.type_name = token.text
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
				if identifier == ctrl_node.type_name:
					token = lexer.next()
					if !_take(GdxLexer.TokenType.CloseTag, meta): return false
					nodes.push_back(ctrl_node)
					return true
				else:
					printerr("Closing and opening tag does not match. ", identifier, " != ", ctrl_node.type_name)
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
							if identifier == ctrl_node.type_name:
								token = lexer.next()
								if !_take(GdxLexer.TokenType.CloseTag, meta): return false
								nodes.push_back(ctrl_node)
								return true
							else:
								printerr("Closing and opening tag does not match. ", identifier, " != ", ctrl_node.type_name)
								return false
						else:
							return false
		else:
			return false

	return true

func _parse_control_node_param(params: Array[PControlNodeParam]):
	var meta = " while parsing node param"
	var param_name = token.text

	if !_take(GdxLexer.TokenType.Identifier, meta): return false

	var is_bound = false
	if token.type == GdxLexer.TokenType.Binding:
		token = lexer.next()
		is_bound = true

	if !_take(GdxLexer.TokenType.Assign, meta): return false

	var param_value = token.text
	if !_take_any([GdxLexer.TokenType.Text], meta):
		return false

	var param = PControlNodeParam.new()
	param.value_type = token.type
	param.key = param_name
	param.value = param_value
	param.bound = is_bound
	params.push_back(param)
	return true

func _parse_control_node_directive(directives: Array[PControlNodeDirective]):
	var meta = " while parsing node directive"

	if !_take(GdxLexer.TokenType.Binding, meta): return false

	var param_name = token.text
	if !_take(GdxLexer.TokenType.Identifier, meta): return false
	if !_take(GdxLexer.TokenType.Assign, meta): return false

	var param_value = token.text
	if !_take_any([GdxLexer.TokenType.Text], meta):
		return false

	var param = PControlNodeDirective.new()
	param.name = param_name
	param.value = param_value
	directives.push_back(param)
	return true
