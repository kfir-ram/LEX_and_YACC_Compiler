%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
extern int yylex();
extern int yylineno;
%}
%token FUNCTION, TYPE_BOOL, TYPE_STRING, TYPE_VOID, MAIN
%token TYPE_INT, TYPE_CHAR, TYPE_REAL, TYPE_P_INT, TYPE_P_CHAR, TYPE_P_REAL
%token COMMENTS, ILLEGAL_COMMENT, EOS, ID, IF, ELSE, WHILE, FOR, DO, VAR, RETURN, TRUE, FALSE, NULL
%token AND, OR, EQUALIVATION, NOTEQUAL, PLUSONE, MINUSONE, BIGGER_EQ, SMALLER_EQ, BIGGER, SMALLER, DIVIDED, EQUAL, PLUS, MINUS, MULTIPLY
%token NOT, ADDRESS_OF, SCB, ECB, LP, RP, COMMA, BSI, ESI, DLOS
%token ILLEGAL_POINTER, POINTER, CHAR_lowercase, CHAR_uppercase, CHAR, INT, INVALID_STRING, STRING, EMPTY_STRING, DEC_INT, HEX_INT, REAL
%left ESI COMMA RP ECB
%left EQUALIVATION SMALLER_EQ BIGGER_EQ BIGGER SMALLER NOTEQUAL
%left PLUS MINUS
%left MULTIPLY DIVIDED
%left AND OR 
%left EQUAL
%right NOT ADDRESS_OF LP SCB BSI 
%nonassoc IF ELSE FOR DO WHILE FUNCTION ID
%start main_program
%%

main_program:	code 
				|main_func {printf("program: code MAIN\n");}

main_func:		FUNCTION TYPE_VOID MAIN LP parameter_list RP SCB code_block ECB

code: 			code //comments
				|function {printf("code commenst function\n");}
				|void_function {printf("code commenst void_function\n");}
				|comments
				|;

comments:		COMMENTS
				|;

void_function:	FUNCTION TYPE_VOID id LP parameter_list RP SCB code_block ECB
				|comments void_function
				|void_function comments


id:				ID

function:		FUNCTION type id LP parameter_list RP SCB func_body return ECB

code_block: 	SCB var_dec body ECB {printf("block:SCB body ECB");}

args:		id COMMA args 	{printf("args:ID COMMA args\n");}
			|id			{printf("args:ID\n");}

			

parameter_list:	type args EOS parameter_list 
				|;

exp:		exp BIGGER exp {printf("exp:exp BIGGER exp\n");}
			|exp BIGGER_EQ exp {printf("exp:exp BIGGER_EQ exp\n");}
			|exp SMALLER exp {printf("exp:exp SMALLER exp\n");}
			|exp SMALLER_EQ exp {printf("exp:exp SMALLER_EQ exp\n");}
			|exp EQUALIVATION exp {printf("exp:exp EQUALIVATION exp\n");}
			|exp NOTEQUAL exp {printf("exp:exp NOTEQUAL exp\n");}
 			|exp PLUS exp {printf("exp:exp PLUS exp\n");}
			|exp MINUS exp {printf("exp:exp MINUS exp\n");}
			|exp MULTIPLY exp {printf("exp:exp MULTIPLY exp\n");}
			|exp DIVIDED exp {printf("exp:exp DIVIDED exp\n");}
			|exp AND exp {printf("exp:exp AND exp\n");}
			|exp OR exp {printf("exp:exp OR exp\n");}
			|NOT exp {printf("exp:NOT exp\n");}
			|LP exp RP {printf("exp:LP exp RP\n");}
			//|MULTIPLY exp {printf("exp:MULTIPLY exp\n");}
			|literal {printf("exp: literal \n");}
			|pointer_id
			|ADDRESS_OF exp {printf("exp:ADDRESS_OF exp\n");}


/* */

pointer_id:	MULTIPLY exp {printf("exp:MULTIPLY exp\n");}


literal:	id {printf("literal:id\n");}
			|int {printf("literal:DEC_INT\n");}
			//|HEX_INT {printf("literal:HEX_INT\n");}
			|real {printf("literal:REAL\n");}
			|bool {printf("literal:bool\n");}
			|char {printf("literal:char\n");}
			|STRING {printf("literal:STRING\n");}
			|EMPTY_STRING {printf("literal:EMPTY_STRING\n");}
			|NULL	{printf("literal:NULL\n");}

int:		DEC_INT
			|HEX_INT

real:		REAL

bool:		TRUE {printf("bool:TRUE\n");}
			|FALSE {printf("bool:FALSE\n");}

char:		CHAR_uppercase {printf("char:CHAR_uppercase\n");}
			|CHAR_lowercase {printf("char:CHAR_lowercase\n");}
			|CHAR {printf("char:CHAR\n");}


number:			DEC_INT {printf("number:DEC_INT\n");}
				|HEX_INT {printf("number:HEX_INT\n");}
				|REAL {printf("number:REAL\n");}


var_dec:		var_dec premitive_dec {printf("var_dec:var_dec premitive_dec");}
				|var_dec string_dec {printf("var_dec:var_dec string_dec");}
				|;

premitive_dec:	VAR type premitive_assign_op EOS {printf("premitive_dec:VAR type premitive_assign_op EOS");}


string_dec:		TYPE_STRING string_assign_op EOS {printf("string_dec:TYPE_STRING string_assign_op EOS\n");}

string_assign_op:		id BSI exp ESI {printf("string_assign_op:ID BSI exp ESI \n");}
						|id BSI exp ESI COMMA string_assign_op {printf("string_assign_op:ID BSI exp ESI COMMA string_assign_op \n");}
						|id BSI exp ESI EQUAL string {printf("string_assign_op:ID BSI exp ESI EQUAL string \n");}
						|id BSI exp ESI EQUAL string COMMA string_assign_op {printf("string_assign_op:ID BSI exp ESI EQUAL string COMMA string_assign_op \n");}
				

premitive_assign_op:	id {printf("premitive_assign_op:ID\n");}
						|id COMMA premitive_assign_op {printf("premitive_assign_op:ID COMMApremitive_assign_op \n");}
						|id EQUAL exp {printf("premitive_assign_op:ID EQUAL exp \n");}
						|id EQUAL exp COMMA premitive_assign_op {printf("premitive_assign_op:ID EQUAL exp COMMA premitive_assign_op \n");}


string:			STRING
				|EMPTY_STRING



body:			body body_ {printf("block:SCB body ECB");}
				| {printf("block:SCB body ECB");} 

string_type:	

type:			TYPE_INT 	{printf("(TYPE__INT)\n");}
				|TYPE_CHAR 	{printf("(TYPE__CHAR)\n")}
				|TYPE_REAL 	{printf("(TYPE__REAL)\n");}
				|TYPE_BOOL		{printf("(TYPE__BOOL)\n");}
				|TYPE_P_INT		{printf("(TYPE__INT*)\n");}
				|TYPE_P_CHAR	{printf("(TYPE__char*)\n");}
				|TYPE_P_REAL	{printf("(TYPE__REAL*)\n");}

func_body:	body {printf("func_body body\n");}//----todo---we dont need that



return:		RETURN literal 

assignment_statment:	var_type EQUAL exp

var_type:	id
			|pointer_id
			|id BSI exp ESI


body_:		ifelse {printf("body_:ifelse\n")}
			|loop {printf("body_:loop\n")}
			|function {printf("body_:function\n")}
			|void_function {printf("body_:void_function\n")}
			|function_call {printf("body_:function_call\n")}
			|code_block
			//| {printf("block:SCB body ECB");}

function_call:	id LP RP {printf("function_call:ID LP RP \n");}
				|id LP exp_list RP {printf("function_call:ID LP exp_list RP \n");}

exp_list:		exp {pritnf("exp_list:exp\n");}
				|exp_list COMMA exp {printf("exp_list:exp_list COMMA exp");}


ifelse:			IF LP exp RP SCB body ECB {printf("if:IF LP exp RP SCB body ECB \n");}
				|IF LP exp RP SCB body ECB ELSE SCB body ECB //{printf("if:ELSE SCB body ECB\n");}
			//|IF LP exp RP body {printf("if:IF LP exp RP body\n");}
			//|ELSE body_ {printf("if:ELSE body\n");}

loop:		WHILE LP exp RP SCB body ECB {printf("i'm while loop\n");}
			|for_loop {printf("loop: for_loop\n");}
			|DO code_block WHILE LP exp RP EOS {printf("loop:DO SCB body ECB WHILE LP exp RP EOS\n");}

for_loop:	FOR LP loop_i_dec EOS exp EOS inc_dec RP SCB body ECB

inc_dec:	id PLUSONE {printf("i++\n");}
			|PLUSONE id {printf("++i\n");}
			|id MINUSONE {printf("i--\n");}
			|MINUSONE id {printf("--i\n");}

loop_i_dec: INT id EQUAL DEC_INT {printf("loop_i_dec: INT ID EQUAL DEC_INT\n");}
			|id EQUAL DEC_INT {printf("loop_i_dec:ID EQUAL DEC_INT\n");}
			|id {printf("loop_i_dec: ID\n");}

