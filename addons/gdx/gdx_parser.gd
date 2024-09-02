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

class PControlNodeParam:
	var key: String
	var value: String
	var bound: bool = false

var token: GdxLexer.Token
var lexer: GdxLexer

func parse(lex: GdxLexer) -> PRootNode:
	self.lexer = lex
	self.token = lex.next()

	var root = PRootNode.new()
	root.nodes = _parse_control_nodes()
	return root

func _print_error(expected: String):
	printerr("Unexpected token at ", token.line, ":", token.column, ". Expected ", expected)

func _parse_control_nodes():
	var nodes: Array[PNode] = []

	while token.type != GdxLexer.TokenType.EOF:
		if token.type == GdxLexer.TokenType.OpenTag:
			# Closing tag from parent node
			if lexer.peek().type == GdxLexer.TokenType.FwdSlash:
				return nodes
			var node = _parse_control_node()
			if node:
				nodes.push_back(node)
		token = lexer.next()

	return nodes

func _parse_control_node():
	if token.type != GdxLexer.TokenType.OpenTag:
		_print_error("<")
		return null

	token = lexer.next()

	if token.type != GdxLexer.TokenType.Identifier:
		_print_error("identifier")
		return null

	var ctrl_node = PControlNode.new()
	ctrl_node.type_name = token.text
	ctrl_node.line = token.line
	ctrl_node.column = token.column

	token = lexer.next()

	ctrl_node.params = _parse_control_node_params()

	if token.type == GdxLexer.TokenType.FwdSlash:
		token = lexer.next()
		if token.type != GdxLexer.TokenType.CloseTag:
			_print_error("/>")
			return null
		return ctrl_node

	if token.type != GdxLexer.TokenType.CloseTag:
		_print_error(">")
		return null

	token = lexer.next()

	if token.type == GdxLexer.TokenType.OpenTag:
		var temp = lexer.peek()
		if temp.type == GdxLexer.TokenType.FwdSlash:
			token = lexer.next()
			token = lexer.next()
			if token.text == ctrl_node.type_name:
				token = lexer.next()
				if token.type == GdxLexer.TokenType.CloseTag:
					return ctrl_node
				else:
					return null
			else:
				return null
		elif temp.type == GdxLexer.TokenType.Identifier:
			ctrl_node.nodes = _parse_control_nodes()
			if token.type == GdxLexer.TokenType.OpenTag:
				token = lexer.next()
				if token.type == GdxLexer.TokenType.FwdSlash:
					token = lexer.next()
					if token.text == ctrl_node.type_name:
						token = lexer.next()
						if token.type == GdxLexer.TokenType.CloseTag:
							return ctrl_node
						else:
							return null
					else:
						return null
			else:
				_print_error(token.text)
	else:
		_print_error(">")
		return null

	return ctrl_node

func _parse_control_node_params():
	var params: Array[PControlNodeParam] = []
	while token.type != GdxLexer.TokenType.EOF:
		if token.type == GdxLexer.TokenType.Identifier:
			params.push_back(_parse_control_node_param())
		elif token.type == GdxLexer.TokenType.FwdSlash or token.type == GdxLexer.TokenType.CloseTag:
			return params
		token = lexer.next()
	return params

func _parse_control_node_param():
	if token.type != GdxLexer.TokenType.Identifier:
		return {}

	var param_name = token.text
	token = lexer.next()

	var is_bound = false
	if token.type == GdxLexer.TokenType.Binding:
		is_bound = true
		token = lexer.next()

	if token.type != GdxLexer.TokenType.Assign:
		_print_error("=")
		return {}

	token = lexer.next()

	if token.type != GdxLexer.TokenType.Text and token.type != GdxLexer.TokenType.Number:
		_print_error("string or number")
		return {}

	var param_value = token.text
	var param = PControlNodeParam.new()
	param.key = param_name
	param.value = param_value
	param.bound = is_bound
	return param
