 //this file was made by:
 //Kfir Rahamim 203426721
 //Hen Dahan 312585953 
 //Bar Piglanski 204590384
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
	struct node* empty_node();

	int printTree(node* tree);
%}

%union{
  char* string; 
  struct node* node;
}

%token FUNCTION, TYPE_BOOL, TYPE_STRING, TYPE_VOID, MAIN
%token TYPE_INT, TYPE_CHAR, TYPE_REAL, TYPE_P_INT, TYPE_P_CHAR, TYPE_P_REAL
%token EOS, ID, IF, ELSE, WHILE, FOR, DO, VAR, RETURN, TRUE, FALSE, NULL
%token AND, OR, EQUALIVATION, NOTEQUAL, PLUSONE, MINUSONE, BIGGER_EQ, SMALLER_EQ
%token BIGGER, SMALLER, DIVIDED, EQUAL, PLUS, MINUS, MULTIPLY
%token NOT, ADDRESS_OF, SCB, ECB, LP, RP, COMMA, BSI, ESI, LENGTH
%token CHAR_lowercase, CHAR_uppercase, CHAR, STRING, EMPTY_STRING, DEC_INT, HEX_INT, REAL
%left ESI COMMA RP ECB
%left SMALLER_EQ BIGGER_EQ BIGGER SMALLER NOTEQUAL
%left PLUS MINUS
%left MULTIPLY DIVIDED
%left AND OR EQUALIVATION
%left EQUAL 
%right NOT ADDRESS_OF LP SCB BSI 
%nonassoc IF ELSE FOR DO WHILE FUNCTION ID

%type <node> main_program main_func code code_ functions void_function function 
%type <node> void_code_block code_block parameter_list args pointer_id exp string_length 
%type <node> var_dec string_dec string_assign_op premitive_assign_op return loop
%type <node> assignment_statment body body_ function_call exp_list ifelse for_loop literal
%type <node> while_loop inc_dec loop_i_dec block code_block_ non_func_code_block premitive_dec
%type <string> null int real bool char type id string number

%start main_program
%%

main_program:	code 		{$$ = make_two_nodes("CODE", $1, empty_node());
							printTree($$);}

code: 			functions code		{$$ = make_two_nodes("", $1, $2);}
				|main_func code_ 	{$$ = make_two_nodes("",$1, $2);}
				| 					{$$ = empty_node();}

code_:			functions code_		{$$ = make_two_nodes("", $1, $2);}
				| 					{$$ = empty_node();}

main_func:		FUNCTION TYPE_VOID MAIN LP parameter_list RP void_code_block code
				{$$ = make_four_nodes("", make_leaf("main"), make_two_nodes("ARGS", $5, empty_node())
				,make_two_nodes("", make_leaf("TYPE VOID"), $7), $8);}

functions:		function      		{$$ = $1}
				|void_function 		{$$ = $1}

void_function:	FUNCTION TYPE_VOID id LP parameter_list RP void_code_block
				{$$ = make_four_nodes("FUNCTION", make_leaf($3),
					make_two_nodes("ARGS",$5, empty_node())
					,make_two_nodes("TYPE ", make_leaf("VOID"), empty_node()), $7);}

function:		FUNCTION type id LP parameter_list RP code_block
				{$$ = make_four_nodes("FUNCTION", make_leaf($3), make_two_nodes("ARGS",$5, empty_node())
					,make_two_nodes("TYPE ", make_leaf($2), empty_node()), $7);}

void_code_block: 	SCB block ECB 			{$$ = make_two_nodes("BODY", $2, empty_node());}

code_block:			SCB block return ECB 	{$$ = make_two_nodes("BODY", $2, $3);}

block:			var_dec block 				{$$ = make_two_nodes("", $1, $2);}
				|body 						{$$ = $1;}
									
parameter_list:	type args EOS parameter_list 	{$$ = make_two_nodes("", make_two_nodes($1, $2, empty_node()), $4);}
				|type args 						{$$ = make_two_nodes($1, $2, empty_node());}
				|								{$$ = make_leaf("NONE");}

args:			id COMMA args 		{$$ = make_two_nodes("", make_leaf($1), $3);}
				|id					{$$ = make_leaf($1);}

exp_list:	exp						{$$ = $1;}
			|exp COMMA exp_list 	{$$ = make_two_nodes("", $1, $3);}

exp:		exp BIGGER exp 				{$$ = make_two_nodes(">", $1, $3);}
			|exp BIGGER_EQ exp 			{$$ = make_two_nodes(">=", $1, $3);}
			|exp SMALLER exp 			{$$ = make_two_nodes("<", $1, $3);}
			|exp SMALLER_EQ exp 		{$$ = make_two_nodes("<=", $1, $3);}
			|exp EQUALIVATION exp 		{$$ = make_two_nodes("==", $1, $3);}
			|exp NOTEQUAL exp 			{$$ = make_two_nodes("!=", $1, $3);}
 			|exp PLUS exp 				{$$ = make_two_nodes("+", $1, $3);}
			|exp MINUS exp 				{$$ = make_two_nodes("-", $1, $3);}
			|exp MULTIPLY exp 			{$$ = make_two_nodes("*", $1, $3);}
			|exp DIVIDED exp 			{$$ = make_two_nodes("/", $1, $3);}
			|exp AND exp 				{$$ = make_two_nodes("&&", $1, $3);}
			|exp OR exp 				{$$ = make_two_nodes("||", $1, $3);}
			|NOT exp 					{$$ = make_two_nodes("!", $2, empty_node());}
			|LP exp RP 					{$$ = make_two_nodes(" ( ", $2, make_leaf(" ) "));}
			|literal 					{$$ = $1;}
			|pointer_id 				{$$ = $1;}
			|ADDRESS_OF exp 			{$$ = make_two_nodes("&", $2, empty_node());}
			|inc_dec 					{$$ = $1;}
			|function_call 				{$$ = $1;}
			|null						{$$ = make_leaf($1);}

literal:	number 						{$$ = make_leaf($1);}
			|id 						{$$ = make_leaf($1);}
			|bool 						{$$ = make_leaf($1);}
			|char 						{$$ = make_leaf($1);}
			|string 					{$$ = make_leaf($1);}
			|id BSI exp ESI 			{$$ = make_three_nodes($1, make_leaf("["), $3, make_leaf("]"));}//{$$ = make_two_nodes("",$1, make_three_nodes("", make_leaf("["), $3, make_leaf("]")));}
			|string_length				{$$ = $1}

pointer_id:		MULTIPLY exp 			{$$ = make_two_nodes("*", $2, empty_node());}

id:				ID 						{$$ = strdup(yytext);}

null:			NULL 					{$$ = strdup(yytext);}

number:			int 					{$$ = $1;}
				|real 					{$$ = $1;}

int:			DEC_INT					{$$ = strdup(yytext);}
				|HEX_INT				{$$ = strdup(yytext);}

real:			REAL 					{$$ = strdup(yytext);}

bool:			TRUE 					{$$ = strdup(yytext);}
				|FALSE 					{$$ = strdup(yytext);}

char:			CHAR_uppercase 			{$$ = strdup(yytext);}
				|CHAR_lowercase 		{$$ = strdup(yytext);}
				|CHAR 					{$$ = strdup(yytext);}

string_length:	LENGTH string LENGTH 	{$$ = make_three_nodes("", make_leaf("|"), make_leaf($2), make_leaf("|"));}
				|LENGTH id LENGTH 		{$$ = make_three_nodes("", make_leaf("|"), make_leaf($2), make_leaf("|"));}

string:		STRING 						{$$ = strdup(yytext);}
			|EMPTY_STRING				{$$ = "";}
			
type:		TYPE_INT 					{$$ = "INT";}
			|TYPE_CHAR 					{$$ = "CHAR";}
			|TYPE_REAL 					{$$ = "REAL";}
			|TYPE_BOOL					{$$ = "BOOL";}
			|TYPE_P_INT					{$$ = strdup(yytext);}
			|TYPE_P_CHAR				{$$ = strdup(yytext);}
			|TYPE_P_REAL				{$$ = strdup(yytext);}

body:		body_ body 					{$$ = make_two_nodes("", $1, $2);}	
			|exp_list 					{$$ = $1;}
			|							{$$ = empty_node();}

body_:		ifelse 						{$$ = $1;}
			|loop 						{$$ = $1;}
			|function 					{$$ = $1;}
			|void_function 				{$$ = $1;}
			|function_call EOS 			{$$ = $1;}
			|void_code_block 			{$$ = $1;}
			|assignment_statment EOS 	{$$ = $1;}
			
var_dec:	premitive_dec 				{$$ = $1;}
			|string_dec					{$$ = $1;}
				
premitive_dec:	VAR type premitive_assign_op EOS {$$ = make_two_nodes("VAR", make_leaf($2),$3);}

string_dec:		TYPE_STRING string_assign_op {$$ = make_two_nodes("string", $2, empty_node());}

//I moved the string_assign_op to the right side.
string_assign_op:		id BSI exp ESI EOS										{$$ = make_three_nodes($1, make_leaf("["), $3, make_leaf("]"));}
						|id BSI exp ESI COMMA string_assign_op 					{$$ = make_two_nodes("", make_three_nodes($1, make_leaf("["), $3, make_leaf("]")), $6);}
						|id BSI exp ESI EQUAL literal COMMA string_assign_op 	{$$ = make_two_nodes("", make_two_nodes("=",
																				make_three_nodes($1, make_leaf("["), $3, make_two_nodes("]", $6, empty_node())), empty_node()),$8);}
						|id BSI exp ESI EQUAL literal EOS						{$$ = make_two_nodes("=", make_three_nodes($1, make_leaf("["), $3, make_two_nodes("]", $6, empty_node())), empty_node());}

premitive_assign_op:	id 											{$$ = make_leaf($1);}
						|id COMMA premitive_assign_op				{$$ = make_two_nodes("", make_leaf($1), $3)}
						|id EQUAL exp 								{$$ = make_two_nodes("=", make_two_nodes($1, $3, empty_node()), empty_node());}
						|id EQUAL exp COMMA premitive_assign_op 	{$$ = make_two_nodes("", make_two_nodes("=", make_two_nodes($1, $3, empty_node()), empty_node()), $5);}

assignment_statment:	id EQUAL exp {$$ = make_two_nodes("=", make_two_nodes($1, $3, empty_node()), empty_node());}
						|MULTIPLY id EQUAL exp {$$ = make_two_nodes("=", make_two_nodes("*", make_leaf($2), $4), empty_node());}

function_call:	id LP RP 			{$$ = make_two_nodes("FUNCTION CALL", make_leaf($1), make_leaf("ARGS NONE"));}
				|id LP exp_list RP 	{$$ = make_two_nodes("FUNCTION CALL", make_leaf($1), make_two_nodes("ARGS", $3, empty_node()));}

ifelse:			IF LP exp RP code_block_ 					{$$ = make_two_nodes("IF", $3, $5);}
				|IF LP exp RP code_block_ ELSE code_block_ 	{$$ = make_two_nodes("IF-ELSE", make_three_nodes("", $3, $5, $7), empty_node());}

code_block_:	non_func_code_block 					{$$ = $1;}
				|void_code_block 						{$$ = $1;}
				|code_block 							{$$ = $1;}

loop:		for_loop 									{$$ = $1;}
			|while_loop 								{$$ = $1;}

for_loop:	FOR LP loop_i_dec EOS exp EOS id EQUAL exp RP code_block_ 	{$$ = make_four_nodes("FOR LOOP", $3, $5, make_two_nodes("=", make_leaf($7), $9), $11);}
			|FOR LP loop_i_dec EOS exp EOS inc_dec RP code_block_ 		{$$ = make_four_nodes("FOR LOOP", $3, $5, $7, $9);}

while_loop:	WHILE LP exp RP code_block_ 				{$$ = make_two_nodes("WHILE", $3, $5);}
			|DO void_code_block WHILE LP exp RP EOS 	{$$ = make_three_nodes("DO", $2, make_leaf("WHILE"), $5);}
			|DO code_block WHILE LP exp RP EOS 			{$$ = make_three_nodes("DO", $2, make_leaf("WHILE"), $5);}

non_func_code_block:	var_dec 						{$$ = $1;}
						|exp 							{$$ = $1;}
						|assignment_statment EOS 		{$$ = $1;}
						|return 						{$$ = $1;}

inc_dec:	id PLUSONE 		{$$ = make_two_nodes($1, make_leaf("++"), empty_node());}
			|PLUSONE id 	{$$ = make_two_nodes("++", make_leaf($2), empty_node());}
			|id MINUSONE 	{$$ = make_two_nodes($1, make_leaf("--"), empty_node());}
			|MINUSONE id 	{$$ = make_two_nodes("--", make_leaf($2), empty_node());}

loop_i_dec: TYPE_INT id EQUAL int 	{$$ = make_two_nodes("INT", make_two_nodes("=", make_leaf($2), make_leaf($4)), empty_node());}
			|id EQUAL exp 			{$$ = make_two_nodes("=", make_leaf($1), $3);}
			|id 						{$$ = make_leaf($1);}

return:		RETURN literal EOS {$$ = make_two_nodes("RETURN", $2, empty_node());}

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
	tab_count++;

	if(strcmp(tree->token, "") == 0){
		tab_count--;
	}

	else if(tree->son1 != NULL){
		printTabs();
		printf("(%s\n",tree->token);
	}

	else{
		printTabs();
		printf("(%s)\n",tree->token);
	}
	
	if(tree->son1)printTree(tree->son1);
	if(tree->son2)printTree(tree->son2);
	if(tree->son3)printTree(tree->son3);
	if(tree->son4)printTree(tree->son4);

	if(strcmp(tree->token, "") == 0){
		tab_count++;}
	else if((tree->son1 != NULL || tree->son2 != NULL) && (tree->token != "")){
		printTabs();
		printf(")\n");
	}
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
struct node* make_two_nodes(char* token, node* son1, node *son2)
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
node* empty_node(){
	node* new_node = NULL;
	return new_node;
}
int yyerror(){
 	fflush(stdout);
 	fprintf(stderr, "------------------------------------------------------\nError located in line: %d\n", yylineno);
	fprintf(stderr, "The parser can not accept: \" %s \" .\n",yytext);
	return 0;
}