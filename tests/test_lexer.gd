extends GutTest

func test_lex_one_node_default():
	var lex := GdxLexer.new('
		<Control></Control>
	')
	assert_eq(lex.next().type, GdxLexer.TokenType.OpenTag)
	var open_identifier := lex.next()
	assert_eq(open_identifier.type, GdxLexer.TokenType.Identifier)
	assert_eq(lex.next().type, GdxLexer.TokenType.CloseTag)
	assert_eq(lex.next().type, GdxLexer.TokenType.OpenTag)
	assert_eq(lex.next().type, GdxLexer.TokenType.FwdSlash)
	var close_idenfidier := lex.next()
	assert_eq(close_idenfidier.type, GdxLexer.TokenType.Identifier)
	assert_eq(open_identifier.text, close_idenfidier.text)
	assert_eq(lex.next().type, GdxLexer.TokenType.CloseTag)
	assert_eq(lex.next().type, GdxLexer.TokenType.EOF)

func test_lex_one_node_self_closing():
	var lex := GdxLexer.new('
		<Control />
	')
	assert_eq(lex.next().type, GdxLexer.TokenType.OpenTag)
	assert_eq(lex.next().type, GdxLexer.TokenType.Identifier)
	assert_eq(lex.next().type, GdxLexer.TokenType.FwdSlash)
	assert_eq(lex.next().type, GdxLexer.TokenType.CloseTag)

func test_lex_nested_control():
	var lex := GdxLexer.new('
		<Control1>
			<Control2></Control2>
		</Control1>
	')
	assert_eq(lex.next().type, GdxLexer.TokenType.OpenTag)
	var _1_open_identifier := lex.next()
	assert_eq(_1_open_identifier.type, GdxLexer.TokenType.Identifier)
	assert_eq(lex.next().type, GdxLexer.TokenType.CloseTag)

	assert_eq(lex.next().type, GdxLexer.TokenType.OpenTag)
	var _2_open_identifier := lex.next()
	assert_eq(_2_open_identifier.type, GdxLexer.TokenType.Identifier)
	assert_eq(lex.next().type, GdxLexer.TokenType.CloseTag)
	assert_eq(lex.next().type, GdxLexer.TokenType.OpenTag)
	assert_eq(lex.next().type, GdxLexer.TokenType.FwdSlash)
	var _2_close_identifier := lex.next()
	assert_eq(_2_close_identifier.type, GdxLexer.TokenType.Identifier)
	assert_eq(_2_open_identifier.text, _2_close_identifier.text)
	assert_eq(lex.next().type, GdxLexer.TokenType.CloseTag)

	assert_eq(lex.next().type, GdxLexer.TokenType.OpenTag)
	assert_eq(lex.next().type, GdxLexer.TokenType.FwdSlash)
	var _1_close_identifier := lex.next()
	assert_eq(_1_close_identifier.type, GdxLexer.TokenType.Identifier)
	assert_eq(_1_open_identifier.text, _1_close_identifier.text)
	assert_eq(lex.next().type, GdxLexer.TokenType.CloseTag)
