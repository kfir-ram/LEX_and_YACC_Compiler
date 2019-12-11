%{
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	extern int yylex();
	extern char *yytext;
	extern int yylineno;

	typedef struct node
	{
		char *token;
		struct node *son1;
		struct node *son2;
		struct node *son3;
		struct node *son4;
	}node;

	int yyerror();
	struct node* make_leaf(char* token);
	struct node* make_two_nodes(char* token, node* son1, node* son2);
	struct node* make_three_nodes(char* token, node* son1, node* son2, node* son3);
	struct node* make_four_nodes(char* token, node* son1, node* son2, node* son3, node* son4);

	int printTree(node* tree);
%}

%union{
  char* string; 
  struct node* node;
}

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

%type <node> program code body exp bool_statment func_body ifelse parameter_list return args
%type <string> id type literal

%start program

%%
program:	code {$$ = make_two_nodes("CODE", $1, NULL);
					printTree($$);}

exp:		exp PLUS exp {printf("I'M DOING PLUS\n");}
			|exp MINUS exp {printf("I'M DOING MINUS\n");}
			|exp MULTIPLY exp {printf("I'M DOING MUL\n");}
			|exp DIVIDED exp {printf("I'M DOING DIVIDE\n");}
			|literal {printf("I'M a literal \n");};


code:		comments FUNCTION type id LP parameter_list RP SCB func_body ECB
			{$$ = make_four_nodes("FUNCTION", make_leaf($4), $6, make_leaf($3), $9);}
			| {$$ = NULL;}


func_body:	body return {$$ = make_two_nodes("BODY", $1, NULL);}
			|code {printf("function inside a function\n");}


body:		type_string EOS body {printf("I'M a type_string body\n");}
			|VAR type id EQUAL literal body EOS body {$$ = make_two_nodes("BLOCK", NULL, NULL);}
			|VAR type id EOS body {printf("I'M a decleration body\n");}
			|ifelse body {printf("I'M if body\n");}
			|COMMA id EQUAL literal body {printf("I'M y=23 body \n");}
			|COMMA id body {printf("I'M ,t body \n");}
			|id EQUAL exp EOS body {printf("I'M body EXP\n");}
			|loop body {printf("I'M body loop\n");}
			|ID {printf("I'M body ID\n");}
			|COMMENTS body {printf("im a comment\n");}
			|{}

literal:	HEX_INT {printf("literal HEX_INT\n");}
			|DEC_INT {printf("literal DEC_INT\n");}
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

args:		id COMMA args 	{$$ = make_two_nodes($1, $3, NULL);}
			|id 			{$$ = make_two_nodes($1, NULL, NULL);}

id: 		ID {$$ = strdup(yytext);}
			

type:		TYPE_INT 		{$$ = strdup("INT");}
			|TYPE_VOID		{$$ = strdup("VOID");}
			|TYPE_CHAR 		{$$ = strdup("CHAR");}
			|TYPE_REAL 		{$$ = strdup("REAL");}
			|type_string	{printf("(TYPE__STRING)\n");}
			|TYPE_BOOL		{printf("(TYPE__BOOL)\n");}
			|TYPE_P_INT		{printf("(TYPE__INT*)\n");}
			|TYPE_P_CHAR	{printf("(TYPE__char*)\n");}
			|TYPE_P_REAL	{printf("(TYPE__REAL*)\n");}
			


parameter_list:	type args EOS parameter_list {$$ = make_three_nodes("ARGS", make_leaf($1), $2, $4);}
				|type args {$$ = make_two_nodes("ARGS", make_leaf($1), $2);}
				| {$$ = NULL;}


return:		RETURN literal EOS {printf("RETURN-----\n");}
			| {}

loop:		WHILE LP bool_statment RP SCB body ECB {printf("i'm while loop\n");}
			|FOR LP loop_body EOS bool_statment EOS inc_dec RP SCB body ECB {printf("i'm FOR loop\n");}
			|DO SCB body ECB WHILE LP bool_statment RP EOS {printf("i'm DO WHILE loop\n");}

loop_body:	type id EQUAL literal {}
			|id EQUAL literal {}
			|id

inc_dec:	ID PLUSONE {printf("i++\n");}
			|PLUSONE ID {printf("++i\n");}
			|ID MINUSONE {printf("i--\n");}
			|MINUSONE ID {printf("--i\n");}

comments:	COMMENTS
			| {}

type_string:	TYPE_STRING ID BSI ESI type_string {printf("type string 1111\n");}
				|COMMA ID BSI ESI type_string {printf("type string 22222\n");}
				| {}
%%


#include "lex.yy.c"
int main() {return yyparse();}

int tab_count = -1;
int test_count = 1;

void printTabs(){
	int i;
	for(i=0; i < tab_count; i++){
		printf("    ");	
	}
}

int printTree(node* tree)
{	
	/*
	int sons = 0;
	if(tree->son1) sons++;
	if(tree->son2) sons++;
	if(tree->son3) sons++;
	printf("I have %d sons.    ", sons);
	sons = 0;

	printf("Number    %d    token is :    %s\n", test_count, tree->token);
	test_count++;
	if(tree->son1)printTree(tree->son1);
	if(tree->son2)printTree(tree->son2);
	if(tree->son3)printTree(tree->son3);
	*/
	tab_count++;
	printTabs();
	if(tree->son1 == NULL && tree->son2 == NULL)
		printf("%s\n",tree->token);
	else if(tree->token == "")
		printf("");
	else{
		printf("(");
		printf("%s\n",tree->token);
	}
	
	if(tree->son1)printTree(tree->son1);
	if(tree->son2)printTree(tree->son2);
	if(tree->son3)printTree(tree->son3);
	
	tab_count--;
	
	return 0;
	
}

struct node* make_leaf(char* token){
	node* new_node = (node*)malloc(sizeof(node));
	char* value;

	if(token){
		value = (char*)malloc(sizeof(token)+1);
		value[sizeof(token)] = '\0';
		strcpy(value,token);
	}
	else{
		value = (char*)malloc(1);
		strcpy(value,"");
	}
	new_node->son1 = NULL;
	new_node->son2 = NULL;
	new_node->son3 = NULL;
	new_node->son4 = NULL;
	new_node->token = value;
}

struct node* make_two_nodes(char* token, node* son1, node* son2)
{
	node* new_node = make_leaf(token);
	new_node->son1 = son1;
	new_node->son2 = son2;
	return new_node;
}

struct node* make_three_nodes(char* token, node* son1, node* son2, node* son3)
{
	node* new_node = make_leaf(token);
	new_node->son1 = son1;
	new_node->son2 = son2;
	new_node->son3 = son3;
	return new_node;
}

struct node* make_four_nodes(char* token, node* son1, node* son2, node* son3, node* son4)
{
	node* new_node = make_leaf(token);
	new_node->son1 = son1;
	new_node->son2 = son2;
	new_node->son3 = son3;
	new_node->son4 = son4;
	return new_node;
}

char* toString(char* token){
	char* value;
	if (token){
		value = (char*)malloc(sizeof(token)+1);
		value[sizeof(token)] = '\0';
		strcpy(value,token);
	}
	else{
		value = (char*)malloc(1);
		strcpy(value,"");
	}
	return value;
}




void openTag(){
	printf("(%d)" , tab_count);	
}

void closeTag(){
	printf("(/%d)" , tab_count);	
}



int yyerror(){
 	fflush(stdout);
 	fprintf(stderr, "------------------------------------------------------\nError located in line: %d\n", yylineno);
	fprintf(stderr, "The parser can not accept: \" %s \" .\n",yytext);
	return 0;
}