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
	}node;

	int yyerror();
	struct node* make_leaf(char* token);
	struct node* make_two_nodes(char* token, node* son1, node* son2);
	struct node* make_three_nodes(char* token, node*son1, node*son2, node*son3);
	int printTree(node* tree);
%}

%union{
  char* string; 
  struct node* node;
}

%token FUNCTION, TYPE_BOOL, TYPE_STRING, TYPE_VOID
%token TYPE_INT, TYPE_CHAR, TYPE_REAL, TYPE_P_INT, TYPE_P_CHAR, TYPE_P_REAL
%token COMMENTS, ILLEGAL_COMMENT, EOS, ID, IF, ELSE, WHILE, FOR, DO, VAR, RETURN, TRUE, FALSE, NULL
%token AND, OR, EQUALIVATION, NOTEQUAL, PLUSONE, MINUSONE, BIGGER_EQ, SMALLER_EQ, BIGGER, SMALLER, DIVIDED, EQUAL, PLUS, MINUS, MULTIPLY
%token NOT, ADDRESS_OF, SCB, ECB, LP, RP, COMMA, BSI, ESI, DLOS, NUM
%token ILLEGAL_POINTER, POINTER, CHAR_lowercase, CHAR_uppercase, CHAR, INT, INVALID_STRING, STRING, DEC_INT, HEX_INT, REAL

%left PLUS MINUS
%left MULTIPLY DIVIDED

%type <node> program code body exp bool_statment func_body ifelse parameter_list return
%type <string> id type func_type literal
%start program

%%
program:	code {printTree($1);}

code:		FUNCTION func_type id LP parameter_list RP SCB func_body ECB code 
			{$$ = make_two_nodes("CODE",
			make_two_nodes("FUNCTION", make_leaf($3),
			make_three_nodes("ARGS", $5, $2, $3)), make_leaf($8));}
			| {$$ = NULL;}

func_type:	TYPE_VOID 		{$$ = strdup(yytext);}
			|TYPE_INT 		{$$ = strdup(yytext);}
			|TYPE_CHAR 		{$$ = strdup(yytext);}
			|TYPE_REAL 		{$$ = strdup(yytext);}
			|TYPE_P_INT 	{$$ = strdup(yytext);}
			|TYPE_P_REAL 	{$$ = strdup(yytext);}
			|TYPE_P_CHAR 	{$$ = strdup(yytext);}

func_body:	body {$$ = make_two_nodes("BODY", $1, NULL);}
			| {$$ = NULL;}

body:		type id EQUAL literal EOS body 
			|type id EOS body
			|ifelse body
			|id EQUAL exp EOS body
			| {}

literal:	NUM 
			|DEC_INT 
			|HEX_INT 
			|REAL 
			|CHAR_lowercase 
			|CHAR_uppercase 
			|CHAR 
			|STRING 
			|ID 

ifelse:		IF LP bool_statment RP SCB func_body ECB {printf("I'M a if statment\n");}
			|ELSE SCB func_body ECB {printf("I'M a else statment\n");}

bool_statment:	id EQUALIVATION literal {printf("EQUALIVATION on if\n");}
				|id NOTEQUAL literal {printf("NOTEQUAL on if\n");}
				|id BIGGER_EQ literal {printf("BIGGER_EQ on if\n");}
				|id SMALLER_EQ literal {printf("SMALLER_EQ on if\n");}
				|id BIGGER literal {printf("BIGGER on if\n");}
				|id SMALLER literal {printf("SMALLER on if\n");}
				|bool_statment AND bool_statment {printf("bool_statment AND on if\n");}
				|bool_statment OR bool_statment {printf("bool_statment OR on if\n");}
				|NOT bool_statment {printf("NOT bool_statment on if\n");}


id: 		id COMMA id {$$ = make_two_nodes($1, NULL, $3);}
			|ID 		{$$ = strdup(yytext);}

type:		TYPE_INT 	{$$ = "INT";}
			|TYPE_CHAR 	{$$ = "CHAR";}
			|TYPE_REAL 	{$$ = "REAL";}
			|TYPE_STRING{$$ = "STRING";}

parameter_list:	type id EOS parameter_list {$$ = make_two_nodes($1, $2, $4);}
				|type id {$$ = make_two_nodes($1, NULL, make_leaf($2));}

exp:		exp PLUS exp {printf("I'M DOING PLUS\n");}
			|exp MINUS exp {printf("I'M DOING MINUS\n");}
			|exp MULTIPLY exp {printf("I'M DOING MUL\n");}
			|exp DIVIDED exp {printf("I'M DOING DIVIDE\n");}
			|literal

return:		RETURN literal EOS {}
			| {}

%%



#include "lex.yy.c"
int main() {return yyparse();}

int tab_count = -1;

void printTabs(){
	int i;
	for(i=0; i < tab_count; i++){
		printf("    ");	
	}
}

int printTree(node* tree)
{	
	tab_count++;
	printTabs();
	if(tree->son1 != NULL)
		printf("(");
	printf("%s\n",tree->token);
	
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
	node* new_node = make_two_nodes(token,son1,son2);
	new_node->son3 = son3;
	return new_node;
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