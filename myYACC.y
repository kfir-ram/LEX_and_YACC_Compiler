%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
%}
%token FUNCTION, VOID, IF, ELSE, INT, CHAR, REAL, EQUAL, PLUST, MINUS, MULTIPLY, DIVIDED %token EQUALIVATION, PLUSONE, MINUSONE, SEMICOLON, LCB, RCB, RP, LP, NUM, ID, COMMA
%token STRING, BOOL, NOTEQUAL, NOT, AND, OR, RETURN, TRUE, FALSE, NULL
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

code:		FUNCTION func_type id LP body RP { printf("(FUNCTION\n");}

func_type:	VOID 	{printf("(TYPE VOID)\n");}
			|INT 	{printf("(TYPE INT)\n");}
			|CHAR 	{printf("(TYPE CHAR)\n");}
			|REAL 	{printf("(TYPE REAL)\n");}

id: 		id COMMA id {printf("I found 2 id's\n");}
			|ID 		{printf("I'm some ID\n");}


type:		INT 	{printf("(INT)\n");}
			|CHAR 	{printf("(CHAR)")}

body:		type id



%%
#include "lex.yy.c"
main() {return yyparse();}

int yyerror(char *msg){
	printf("Error: located in token %s\n", yytext);
	return 0;}


int yywrap(){
	return 1;
}
