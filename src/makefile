all: 
	ocamlc -c AST.ml 

	menhir Parser.mly
	ocamllex Lexer.mll
	ocamlc -c Parser.mli Lexer.ml Parser.ml
	ocamlc -c Decoration.ml
	ocamlc -c Domain.ml
	ocamlc -c Transition.ml
	ocamlc -c Interpreter.ml

	ocamlc -o interpreter AST.cmo Lexer.cmo Parser.cmo Decoration.cmo  Domain.cmo Transition.cmo Interpreter.cmo



delete:
	rm -f parser.mli parser.ml lexer.ml 
	rm -f *.cmi *.cmo 