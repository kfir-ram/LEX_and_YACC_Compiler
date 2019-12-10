%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
extern int yylex();
extern int yylineno;
%}
%token FUNCTION, TYPE_BOOL, TYPE_STRING, TYPE_VOID
%token TYPE_INT, TYPE_CHAR, TYPE_REAL, TYPE_P_INT, TYPE_P_CHAR, TYPE_P_REAL
%token COMMENTS, ILLEGAL_COMMENT, EOS, ID, IF, ELSE, WHILE, FOR, DO, VAR, RETURN, TRUE, FALSE, NULL
%token AND, OR, EQUALIVATION, NOTEQUAL, PLUSONE, MINUSONE, BIGGER_EQ, SMALLER_EQ, BIGGER, SMALLER, DIVIDED, EQUAL, PLUS, MINUS, MULTIPLY
%token NOT, ADDRESS_OF, SCB, ECB, LP, RP, COMMA, BSI, ESI, DLOS, NUM
%token ILLEGAL_POINTER, POINTER, CHAR_lowercase, CHAR_uppercase, CHAR, INT, INVALID_STRING, STRING, EMPTY_STRING, DEC_INT, HEX_INT, REAL
%left PLUS MINUS
%left MULTIPLY DIVIDED
%%
program:	exp {printf("OK\n");
			printf("the answer is: %d\n", $1);}
			|code {printf("(CODE\n");}

exp:		exp PLUS exp {printf("I'M DOING PLUS\n");}
			|exp MINUS exp {printf("I'M DOING MINUS\n");}
			|exp MULTIPLY exp {printf("I'M DOING MUL\n");}
			|exp DIVIDED exp {printf("I'M DOING DIVIDE\n");}
			|literal {printf("I'M a literal \n");};


code:		comments FUNCTION func_type id LP parameter_list RP SCB func_body ECB code { printf("(FUNCTION\n");}
			|;

func_type:	TYPE_VOID 	{printf("(TYPE VOID)\n");}
			|TYPE_INT 	{printf("(TYPE INT)\n");}
			|TYPE_CHAR 	{printf("(TYPE CHAR)\n");}
			|TYPE_REAL 	{printf("(TYPE REAL)\n");}
			|TYPE_P_INT {printf("(TYPE INT pointer)\n");}
			|TYPE_P_REAL {printf("(TYPE REAL pointer)\n");}
			|TYPE_P_CHAR {printf("(TYPE CHAR pointer)\n");}

func_body:	body return {printf("I'M a function body\n");}
			|code {printf("function inside a function\n");}


body:		type_string EOS body {printf("I'M a type_string body\n");}
			|VAR type id EQUAL literal body EOS body {printf("I'M a EQUAL body\n");}
			|VAR type id EOS body {printf("I'M a decleration body\n");}
			|ifelse body {printf("I'M if body\n");}
			|COMMA id EQUAL literal body {printf("I'M y=23 body \n");}
			|COMMA id body {printf("I'M ,t body \n");}
			|id EQUAL exp EOS body {printf("I'M body EXP\n");}
			|loop body {printf("I'M body loop\n");}
			|ID {printf("I'M body ID\n");}
			|COMMENTS body {printf("im a comment\n");}
			|;

literal:	HEX_INT {printf("literal HEX_INT\n");}
			|DEC_INT {printf("literal DEC_INT\n");}
			|NUM {printf("literal NUM\n");}
			|REAL {printf("literal REAL\n");}
			|CHAR_lowercase {printf("literal CHAR_lowercase\n");}
			|CHAR_uppercase {printf("literal CHAR_uppercase\n");}
			|CHAR {printf("literal CHAR\n")}
			|STRING {printf("literal STRING\n");}
			|EMPTY_STRING {printf("literal EMPTY_STRING\n");}
			|ID {printf("literal ID\n");}
			


ifelse:		IF LP bool_statment RP SCB func_body ECB {printf("I'M a if statment\n");}
			|IF LP bool_statment RP {printf("I'M a if statment without block\n");}
			|ELSE SCB func_body ECB {printf("I'M a else statment\n");}
			|ELSE {printf("I'M a ELSE statment without block\n");}


bool_statment:	id EQUALIVATION literal {printf("EQUALIVATION on if\n");}
				|id NOTEQUAL literal {printf("NOTEQUAL on if\n");}
				|id BIGGER_EQ literal {printf("BIGGER_EQ on if\n");}
				|id SMALLER_EQ literal {printf("SMALLER_EQ on if\n");}
				|id BIGGER literal {printf("BIGGER on if\n");}
				|id SMALLER literal {printf("SMALLER on if\n");}
				|bool_statment AND bool_statment {printf("bool_statment AND on if\n");}
				|bool_statment OR bool_statment {printf("bool_statment OR on if\n");}
				|NOT bool_statment {printf("NOT bool_statment on if\n");}

id: 		id COMMA id {printf("I found 2 id's\n");}
			|ID 		{printf("I'm some ID\n");}

type:		TYPE_INT 	{printf("(TYPE__INT)\n");}
			|TYPE_CHAR 	{printf("(TYPE__CHAR)\n")}
			|TYPE_REAL 	{printf("(TYPE__REAL)\n");}
			|type_string	{printf("(TYPE__STRING)\n");}
			|TYPE_BOOL		{printf("(TYPE__BOOL)\n");}
			|TYPE_P_INT		{printf("(TYPE__INT*)\n");}
			|TYPE_P_CHAR	{printf("(TYPE__char*)\n");}
			|TYPE_P_REAL	{printf("(TYPE__REAL*)\n");}
			


parameter_list:	type id EOS parameter_list {printf("I'M a parameter list\n");}
				|type id {printf("I'M the second parameter list\n");}
				|;


return:		RETURN literal EOS {printf("RETURN-----\n");}
			|;

loop:		WHILE LP bool_statment RP SCB body ECB {printf("i'm while loop\n");}
			|FOR LP loop_body EOS bool_statment EOS inc_dec RP SCB body ECB {printf("i'm FOR loop\n");}
			|DO SCB body ECB WHILE LP bool_statment RP EOS {printf("i'm DO WHILE loop\n");}

loop_body:	type ID EQUAL literal
			|ID EQUAL literal
			|ID

inc_dec:	ID PLUSONE {printf("i++\n");}
			|PLUSONE ID {printf("++i\n");}
			|ID MINUSONE {printf("i--\n");}
			|MINUSONE ID {printf("--i\n");}

comments:	COMMENTS
			|;

type_string:	TYPE_STRING ID BSI NUM ESI type_string {printf("type string 1111\n");}
				|COMMA ID BSI NUM ESI type_string {printf("type string 22222\n");}
				|;
%%

#include "lex.yy.c"
main() {return yyparse();}

int yyerror(){
 	fflush(stdout);
 	fprintf(stderr, "------------------------------------------------------\nError located in line: %d\n", yylineno);
	fprintf(stderr, "The parser can not accept: \" %s \" .\n",yytext);
	return 0;
}


int yywrap(){
	return 1;
}
