%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
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
S:			exp {printf("OK\n");
			printf("the answer is: %d\n", $1);}
			|code {printf("(CODE\n");}

exp:		exp PLUS exp {$$=$1 + $3;
			printf("I'M DOING PLUS\n");}|
			exp MINUS exp {$$=$1 - $3;
			printf("I'M DOING MINUS\n");}|
			exp MULTIPLY exp {$$=$1 * $3;
			printf("I'M DOING MUL\n");}|
			exp DIVIDED exp {$$=$1 / $3;
			printf("I'M DOING DIVIDE\n");}|
			NUM {$$=$1;
			printf("I'M a number, and the number is: %d \n", $1);};

code:		FUNCTION func_type id LP parameter_list RP SCB fuc_body ECB { printf("(FUNCTION\n");}

func_type:	TYPE_VOID 	{printf("(TYPE VOID)\n");}
			|TYPE_INT 	{printf("(TYPE INT)\n");}
			|TYPE_CHAR 	{printf("(TYPE CHAR)\n");}
			|TYPE_REAL 	{printf("(TYPE REAL)\n");}
			|TYPE_P_INT {printf("(TYPE INT pointer)\n");}
			|TYPE_P_REAL {printf("(TYPE REAL pointer)\n");}
			|TYPE_P_CHAR {printf("(TYPE CHAR pointer)\n");}

func_body:	body RETURN literal EOS {printf("I'M a function body\n");}
			|code {printf("function inside a function\n");}

body:		type id EQUAL literal EOS body {printf("I'M a EQUAL body\n");}
			|type id EOS body{printf("I'M a decleration body\n");}
			|ifelse body{printf("I'M if body\n");}
			|;

literal:	NUM {printf("literal NUM\n");}
			|DEC_INT {printf("literal DEC_INT\n");}
			|HEX_INT {printf("literal HEX_INT\n");}
			|REAL {printf("literal REAL\n");}
			|CHAR_lowercase {printf("literal CHAR_lowercase\n");}
			|CHAR_uppercase {printf("literal CHAR_uppercase\n");}
			|CHAR {printf("literal CHAR\n")}
			|STRING {printf("literal STRING\n");}
			|EMPTY_STRING {printf("literal EMPTY_STRING\n");}
			|ID {printf("literal ID");}


ifelse:		IF LP bool_statment RP SCB body ECB {printf("I'M a if statment\n");}

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

parameter_list:	type id {printf("I'M a parameter list\n");}

%%

#include "lex.yy.c"
main() {return yyparse();}

int yyerror(char *msg){
	printf("Error: located in token %s\n", yytext);
	return 0;}


int yywrap(){
	return 1;
}
