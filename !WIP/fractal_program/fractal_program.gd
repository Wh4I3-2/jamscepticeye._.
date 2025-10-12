class_name FractalProgram
extends Resource

const WHITESPACE: String = "\n\t "

@export_multiline var source_code: String

var tokens: Dictionary[String, FractalProgramToken]

func compile() -> void:
	FractalProcGen.logger.debug("Compiling FractalProgram '%s'" % self.to_string(), "FractalProgram")

	tokenize()

enum Keywords {
	NONE,
	DEFINE,
}

const SINGLE_LINE_COMMENT: String = "//"
const MULTI_LINE_COMMENT_ENTER: String = "/*"
const MULTI_LINE_COMMENT_EXIT: String = "*/"
const TERMINATOR: String = ";"

const OR_SYMBOL: String = "||"
const ASSIGN_SYMBOL: String = ":"

const STRING_SYMBOL: String = "\""
const ID_ENTER_SYMBOL: String = "<"
const ID_EXIT_SYMBOL: String = ">"

const NEXT_VALUE_SYMBOL: String = ","

const DICT_ENTER_SYMBOL: String = "{"
const DICT_EXIT_SYMBOL: String = "}"

const KEYWORDS: Dictionary[String, Keywords] = {
	"def": Keywords.DEFINE,
}

func tokenize() -> void:
	FractalProcGen.logger.debug("Tokenizing FractalProgram '%s'" % self.to_string(), "FractalProgram")

	var current_keyword: Keywords = Keywords.NONE
	var val: String = ""

	var i: int = 0

	var in_string: bool = false

	var program_line: int = 1
	var program_column: int = 0

	var in_single_line_comment: bool = false
	var in_multi_line_comment: bool = false

	var found_id: String = ""
	var in_id_definition: bool = false

	var found_result: FractalProgramSymbolResult

	var in_result_definition: bool = false
	var in_terminate_definition: bool = false

	var found_terminate: Variant = null

	var found_token: String = ""

	var in_dict_definition: bool = false
	var in_dict_key: bool = false
	var found_dict_key: String
	var found_dict: Dictionary[String, int] = {}
	for c in source_code:
		program_line += 1

		if c == "\n":
			program_line += 1
			program_column = 0

		if in_multi_line_comment:
			in_multi_line_comment = i < len(MULTI_LINE_COMMENT_EXIT)
			if !in_multi_line_comment: continue

			if c == MULTI_LINE_COMMENT_EXIT[i]: i += 1
			else: i = 0

			continue
		
		if val == MULTI_LINE_COMMENT_ENTER:
			in_multi_line_comment = true
			i = 0
			val = ""
			continue
		
		match current_keyword:
			Keywords.NONE:
				if in_single_line_comment: 
					in_single_line_comment = c != "\n"
					continue

				if val == SINGLE_LINE_COMMENT:
					in_single_line_comment = true
					val = ""
					continue

				if c in WHITESPACE:
					if val == "":
						continue
					
					if val in KEYWORDS.keys():
						current_keyword = KEYWORDS.get(val)
					else:
						FractalProcGen.logger.error("[i]at[%d:%d][/i] Unkown keyword '%s'" % [program_line, program_column - len(val), val], "FractalProgram")

					val = ""
					continue
			Keywords.DEFINE:
				if found_token == "":
					if c in WHITESPACE:
						continue
					found_token = c
					continue

				elif in_id_definition:
					if c == ID_EXIT_SYMBOL:
						in_id_definition = false
						found_id = val
						val = ""
						continue

				elif in_terminate_definition:
					if c == "\"":
						if in_string:
							found_terminate = val

						in_string = !in_string
						val = ""
						continue
					if c in WHITESPACE:
						val = ""
						continue

				elif in_result_definition:
					if c == DICT_ENTER_SYMBOL:
						in_dict_definition = true
						in_dict_key = true
						found_dict = {}
						val = ""
						continue
					
					if in_dict_definition:
						if c == DICT_EXIT_SYMBOL:
							if found_dict_key != "":
								found_dict.set(found_dict_key, int(val))
							found_dict_key = ""
							in_dict_definition = false
							in_dict_key = false
							found_result = FractalProgramWeightedSymbolResult.new()
							found_result.weights = found_dict
							in_result_definition = false
							val = ""
							continue
						if in_dict_key:
							if c == "\"":
								if in_string:
									found_dict_key = val

								in_string = !in_string
								val = ""
								continue
							if c == ASSIGN_SYMBOL:
								in_dict_key = false
								val = ""
								continue
						else:
							if c == NEXT_VALUE_SYMBOL or c == DICT_EXIT_SYMBOL:
								found_dict.set(found_dict_key, int(val))
								found_dict_key = ""
								in_dict_key = true
								val = ""
								continue

					elif c == "\"":
						if in_string:
							found_result = FractalProgramSymbolResult.new()
							found_result.result = val
							in_result_definition = false

						in_string = !in_string
						val = ""
						continue
					if c in WHITESPACE:
						val = ""
						continue

				elif c == ID_ENTER_SYMBOL:
					in_id_definition = true
					val = ""
					continue
				
				elif c == ASSIGN_SYMBOL:
					in_result_definition = true
					val = ""
					continue
				
				elif val == OR_SYMBOL:
					in_terminate_definition = true
					val = ""
					continue

				elif c in WHITESPACE:
					val = ""
					continue
		
		
		if c == TERMINATOR:
			match current_keyword:
				Keywords.DEFINE:
					if in_terminate_definition:
						found_terminate = val
						in_terminate_definition = false

					var token := FractalProgramDefineToken.new()
					token.token = found_token
					token.id = found_id
					token.result = found_result
					token.terminate = found_terminate
					tokens.set(token.token, token)

					found_token = ""
					found_id = ""
					found_result = null
					found_terminate = null

			val = ""
			current_keyword = Keywords.NONE

			continue
		
		val += c
	
	var token_str: String = "["
	for t in tokens:
		token_str += "%s, " % str(t)
	token_str.trim_suffix(", ")
	token_str += "]"
	FractalProcGen.logger.debug("Tokens: '%s'" % token_str, "FractalProgram")
	FractalProcGen.logger.debug("in_id: %s, in_terminate: %s, in_string: %s, in_result: %s, in_dict: %s" % [
		in_id_definition,
		in_terminate_definition,
		in_string,
		in_result_definition,
		in_dict_definition
	], "FractalProgram")


func run(axiom: String, depth: int = 4) -> String:
	FractalProcGen.logger.debug("Running program with axiom: '%s', at depth: %d" % [axiom, depth], "FractalProgram")
	var result: String = ""

	for c in axiom:
		var found_token: bool = false
		for k in tokens.keys():
			if c != k: continue
			var t: FractalProgramToken = tokens.get(k)
			if not t is FractalProgramDefineToken: continue
			var def := t as FractalProgramDefineToken
			if def.result == null:
				break
			found_token = true
			result += def.result.result
			break
		if found_token: continue
		result += c

	if depth > 1:
		result = run(result, depth - 1)
	
	var final: String = ""

	for c in result:
		var found_token: bool = false
		for k in tokens.keys():
			if c != k: continue
			var t: FractalProgramToken = tokens.get(k)
			if not t is FractalProgramDefineToken: continue
			var def := t as FractalProgramDefineToken
			if def.terminate == null:
				break
			if not def.terminate is String:
				break
			final += def.terminate as String
			found_token = true
			break
		if found_token: continue
		final += c

	return final



@warning_ignore("shadowed_variable")
static func from(source_code: String) -> FractalProgram:
	var program: FractalProgram = FractalProgram.new()

	program.source_code = source_code

	program.compile()
	
	return program
