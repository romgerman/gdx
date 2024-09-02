class_name GdxLexer

enum TokenType {
	Unknown,
	OpenTag, # <
	CloseTag, # >
	Identifier, # Label
	Text, # "Text"
	Number, # 123 or 3.14
	Assign, # =
	FwdSlash, # /
	Binding, # :
	EOF, # End of file
}

class Token:
	var type: TokenType = TokenType.Unknown
	var text: String
	var line: int = 0
	var column: int = 0

	func _init(_type: TokenType, _line: int, _column: int) -> void:
		self.type = _type
		self.line = _line
		self.column = _column

var text: String = ""
var index := 0
var line: int = 0
var column: int = 0

func _init(_text: String) -> void:
	self.text = _text

var IDENTIFIER_REGEX = RegEx.create_from_string("_?[A-Za-z0-9]")
var NUMBER_REGEX = RegEx.create_from_string("[0-9]+\\.?[0-9]+")

func next() -> Token:
	while index < text.length():
		if text[index] == " " || text[index] == "\t" || text[index] == "\r":
			_advance()
			continue
		elif text[index] == "\n":
			index += 1
			line += 1
			column = 0
			continue
		elif text[index] == "<":
			var token = Token.new(TokenType.OpenTag, line, column)
			token.text = "<"
			_advance()
			return token
		elif text[index] == ">":
			var token = Token.new(TokenType.CloseTag, line, column)
			token.text = ">"
			_advance()
			return token
		elif text[index] == "=":
			var token = Token.new(TokenType.Assign, line, column)
			token.text = "="
			_advance()
			return token
		elif text[index] == ":":
			var token = Token.new(TokenType.Binding, line, column)
			token.text = ":"
			_advance()
			return token
		elif text[index] == "/":
			var token = Token.new(TokenType.FwdSlash, line, column)
			token.text = "/"
			_advance()
			return token
		elif text[index] == "\"":
			var token = Token.new(TokenType.Text, line, column)
			token.text = ""
			_advance()

			while index < text.length():
				if text[index] != "\"":
					token.text += text[index]
					_advance()
				else:
					_advance()
					break

			return token
		elif IDENTIFIER_REGEX.search(text[index]) != null:
			var token = Token.new(TokenType.Identifier, line, column)
			token.text = text[index]
			_advance()

			while index < text.length():
				if IDENTIFIER_REGEX.search(text[index]) != null:
					token.text += text[index]
					_advance()
				else:
					break

			return token
		elif NUMBER_REGEX.search(text[index]) != null:
			var token = Token.new(TokenType.Number, line, column)
			token.text = text[index]
			_advance()

			while index < text.length():
				if NUMBER_REGEX.search(text[index]) != null:
					token.text += text[index]
					_advance()
				else:
					break

			return token
		else:
			var token = Token.new(TokenType.Unknown, line, column)
			_advance()
			return token
	return Token.new(TokenType.EOF, line, column)

func _advance():
	index += 1
	column += 1

func peek() -> Token:
	var prev_line = line
	var prev_column = column
	var prev_index = index
	var tok = next()
	line = prev_line
	column = prev_column
	index = prev_index
	return tok
