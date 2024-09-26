extends GutTest

func test_parse_self_closing_node():
	var lex := GdxLexer.new('
		<Control />
	')
	var parser := GdxParser.new()
	var root = parser.parse(lex)

	assert_eq(root.nodes[0].name, "Control")

func test_parse_default_node():
	var lex := GdxLexer.new('
		<Control></Control>
	')
	var parser := GdxParser.new()
	var root = parser.parse(lex)

	assert_eq(root.nodes[0].name, "Control")

func test_parse_nested_nodes():
	var lex := GdxLexer.new('
		<Control>
			<Control2></Control2>
		</Control>
	')
	var parser := GdxParser.new()
	var root = parser.parse(lex)

	assert_eq(root.nodes[0].name, "Control")
	assert_eq(root.nodes[0].nodes[0].name, "Control2")

func test_parse_nested_nodes_2():
	var lex := GdxLexer.new('
		<Control>
			<Control2>
				<Control3></Control3>
			</Control2>
		</Control>
	')
	var parser := GdxParser.new()
	var root = parser.parse(lex)

	assert_eq(root.nodes[0].name, "Control")
	assert_eq(root.nodes[0].nodes[0].name, "Control2")
	assert_eq(root.nodes[0].nodes[0].nodes[0].name, "Control3")

func test_parse_nested_nodes_3():
	var lex := GdxLexer.new('
		<Control>
			<Control2>
				<Control3></Control3>
				<Control3></Control3>
				<Control3></Control3>
			</Control2>
		</Control>
	')
	var parser := GdxParser.new()
	var root = parser.parse(lex)

	assert_eq(root.nodes[0].name, "Control")
	assert_eq(root.nodes[0].nodes[0].name, "Control2")
	assert_eq(root.nodes[0].nodes[0].nodes[0].name, "Control3")
	assert_eq(root.nodes[0].nodes[0].nodes[1].name, "Control3")
	assert_eq(root.nodes[0].nodes[0].nodes[2].name, "Control3")

func test_parse_params():
	var lex := GdxLexer.new('
		<Control param="test"></Control>
	')
	var parser := GdxParser.new()
	var root = parser.parse(lex)

	assert_eq(root.nodes[0].name, "Control")
	assert_eq(root.nodes[0].params[0].key, "param")
	assert_eq(root.nodes[0].params[0].value, "test")

func test_parse_params_on_self_closing():
	var lex := GdxLexer.new('
		<Control param="test" />
	')
	var parser := GdxParser.new()
	var root = parser.parse(lex)

	assert_eq(root.nodes[0].name, "Control")
	assert_eq(root.nodes[0].params[0].key, "param")
	assert_eq(root.nodes[0].params[0].value, "test")

func test_parse_param_binding():
	var lex := GdxLexer.new('
		<Control param:="test" />
	')
	var parser := GdxParser.new()
	var root = parser.parse(lex)

	assert_eq(root.nodes[0].name, "Control")
	assert_eq(root.nodes[0].params[0].key, "param")
	assert_eq(root.nodes[0].params[0].value, "test")
	assert_eq(root.nodes[0].params[0].bound, true)

func test_parse_directive_for():
	var lex := GdxLexer.new('
		<Control :for="i in 3" />
	')
	var parser := GdxParser.new()
	var root = parser.parse(lex)

	assert_eq(root.nodes[0].name, "Control")
	assert_eq(root.nodes[0].directives.size() > 0, true)
