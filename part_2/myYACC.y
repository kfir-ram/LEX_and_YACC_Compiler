 //this file was made by:
 //Kfir Rahamim 203426721
 //Hen Dahan 312585953 
 //Bar Piglanski 204590384
%{
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	extern int yylex();
	extern char* yytext;
	extern int yylineno;
	typedef enum {false,true} bool;

	typedef struct node
	{
		char* token;
		struct node* left;
		struct node* right;
	}node;

	typedef struct Function 
	{
        char* name;
		struct Varaiables* args;
        char*returnType; 
		int argNum;
		bool findreturn;
    }Function;


	typedef struct Varaiables
	{	int isArg;
		char* name;
		char* value;
		char* type;
		char* length;
	}Varaiables;

	typedef struct Scope
	{	
		char* name;
		Varaiables* var;
		int VarCount;
		int Fcount;
		Function** func;
		struct Scope* nextScope;
		struct Scope* preScope;
	}Scope;


	struct node* make_leaf(char* token);
	struct node* make_node(char* token, node* left, node* right);
	//struct node* make_three_nodes(char* token, node* son1, node* son2, node* son3);
	//struct node* make_four_nodes(char* token, node* son1, node* son2, node* son3, node* son4);
	struct node* empty_node();
	int yyerror(char* error);
	static int scope = 0;
	Scope* globalScope = NULL;
	Scope* make_scope(char* name);
	Scope* finalScope(Scope* scopes);
	void pushScopes(Scope* from,char* name);
	void addFunc_toScope(char* name,Varaiables* args,node* returnType,int arg_num,Scope* current_scope);
	void addVar_toScope(Varaiables* args, int count_vars ,int is_arg, Scope* current_scope);
	char* find_func(node* tree, Scope* current_scope);
	char* find_var(node* tree, Scope* current_scope);
	char* expType(node* tree, Scope* current_scope);
	Varaiables* make_args(node* tree, int* args);
	Varaiables* call_function_args(Scope* current_scope, node* tree, int* count);
	void Syntax_Analyze(node* tree, Scope* current_scope);


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

main_program:	code {Syntax_Analyze($1, globalScope);}

code:			code_ main_func		{$$ = make_node("CODE", $1, $2);}

code_:			code_ functions 	{$$ = make_node("", $1, $2);}
				| 					{$$ = empty_node();}

main_func:		FUNCTION TYPE_VOID MAIN LP RP void_code_block code_
				{$$ = make_node("Main", make_node("ARGS", empty_node(), $6), $7);}

functions:		function      		{$$ = $1}
				|void_function 		{$$ = $1}

void_function:	FUNCTION TYPE_VOID id LP parameter_list RP void_code_block
				{$$ = make_node("FUNC", make_node("VOID", make_leaf($3),
					make_node("ARGS", $5, make_node("", $7, empty_node()))), empty_node());}

function:		FUNCTION type id LP parameter_list RP code_block
				{$$ = make_node("FUNC", make_node($2, make_leaf($3),
					make_node("ARGS", $5, make_node("", $7, empty_node()))), empty_node());}


void_code_block: 	SCB block ECB 			{$$ = make_node("BODY", $2, empty_node());}

code_block:			SCB block return ECB 	{$$ = make_node("BODY", $2, $3);}

block:			var_dec block 				{$$ = make_node("", $1, $2);}
				|body 						{$$ = $1;}
									
parameter_list:	type args EOS parameter_list 	{$$ = make_node("(", make_node($1, $2, empty_node()), make_node("", $4, make_node(")", empty_node(), empty_node())));}
				|type args 						{$$ = make_node("(", make_leaf($1), $2);}
				|								{$$ = make_leaf("NONE");}

args:			id COMMA args 		{$$ = make_node("", make_leaf($1), $3);}
				|id					{$$ = make_leaf($1);}


var_dec:	premitive_dec 				{printf("I'm here");$$ = $1;}
			|string_dec					{$$ = $1;}
				
premitive_dec:	VAR type premitive_assign_op EOS {$$ = make_node("var", make_leaf($2),$3);}

string_dec:		TYPE_STRING string_assign_op {$$ = make_node("string", $2, empty_node());}

//I moved the string_assign_op to the right side.
string_assign_op:		id BSI exp ESI EOS										{$$ = make_node("solovar", make_leaf($1), make_node("[", $3, make_leaf("]")));}
						|id BSI exp ESI COMMA string_assign_op 					{$$ = make_node("", make_node($1, make_leaf("["), make_node("", $3, make_leaf("]"))), $6);}
						|id BSI exp ESI EQUAL literal COMMA string_assign_op 	{$$ = make_node("=", make_node($1, make_leaf("["), make_node("", $3,
																					make_node("]", $6, empty_node()))),$8);}
						|id BSI exp ESI EQUAL literal EOS						{$$ = make_node("=", make_node($1, make_leaf("["), make_node("", $3, make_node("]", $6, empty_node()))), empty_node());}

premitive_assign_op:	id 											{$$ = make_node("solovar",make_leaf($1), empty_node());}
						|id COMMA premitive_assign_op				{$$ = make_node("", make_leaf($1), $3);}
						|id EQUAL exp 								{printf("I'm here");$$ = make_node("=", make_node($1, $3, empty_node()), empty_node());}
						|id EQUAL exp COMMA premitive_assign_op 	{$$ = make_node("", make_node("=", make_node($1, $3, empty_node()), empty_node()), $5);}

assignment_statment:	id EQUAL exp {$$ = make_node("=", make_node($1, $3, empty_node()), empty_node());}
						|MULTIPLY id EQUAL exp {$$ = make_node("=", make_node("*", make_leaf($2), $4), empty_node());}

pointer_id:		MULTIPLY exp 			{$$ = make_node("*", $2, empty_node());}

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

string_length:	LENGTH string LENGTH 	{$$ = make_node("|", make_leaf($2), empty_node());}
				|LENGTH id LENGTH 		{$$ = make_node("|", make_leaf($2), empty_node());}

string:		STRING 						{$$ = strdup(yytext);}
			|EMPTY_STRING				{$$ = "";}
			
type:		TYPE_INT 					{$$ = "int";}
			|TYPE_CHAR 					{$$ = "char";}
			|TYPE_REAL 					{$$ = "real";}
			|TYPE_BOOL					{$$ = "boolean";}
			|TYPE_P_INT					{$$ = "int*";}
			|TYPE_P_CHAR				{$$ = "char*";}
			|TYPE_P_REAL				{$$ = "real*";}

body:		body_ body 					{$$ = make_node("", $1, $2);}	
			|exp_list 					{$$ = $1;}
			|							{$$ = empty_node();}

body_:		ifelse 						{$$ = $1;}
			|loop 						{$$ = $1;}
			|function 					{$$ = $1;}
			|void_function 				{$$ = $1;}
			|function_call EOS 			{$$ = $1;}
			|void_code_block 			{$$ = $1;}
			|assignment_statment EOS 	{$$ = $1;}

exp_list:	exp						{$$ = $1;}
			|exp COMMA exp_list 	{$$ = make_node("", $1, $3);}

exp:		exp BIGGER exp 				{$$ = make_node(">", $1, $3);}
			|exp BIGGER_EQ exp 			{$$ = make_node(">=", $1, $3);}
			|exp SMALLER exp 			{$$ = make_node("<", $1, $3);}
			|exp SMALLER_EQ exp 		{$$ = make_node("<=", $1, $3);}
			|exp EQUALIVATION exp 		{$$ = make_node("==", $1, $3);}
			|exp NOTEQUAL exp 			{$$ = make_node("!=", $1, $3);}
 			|exp PLUS exp 				{$$ = make_node("+", $1, $3);}
			|exp MINUS exp 				{$$ = make_node("-", $1, $3);}
			|exp MULTIPLY exp 			{$$ = make_node("*", $1, $3);}
			|exp DIVIDED exp 			{$$ = make_node("/", $1, $3);}
			|exp AND exp 				{$$ = make_node("&&", $1, $3);}
			|exp OR exp 				{$$ = make_node("||", $1, $3);}
			|NOT exp 					{$$ = make_node("!", $2, empty_node());}
			|LP exp RP 					{$$ = make_node(" ( ", $2, make_leaf(" ) "));}
			|literal 					{$$ = $1;}
			|pointer_id 				{$$ = $1;}
			|ADDRESS_OF exp 			{$$ = make_node("&", $2, empty_node());}
			|inc_dec 					{$$ = $1;}
			|function_call 				{$$ = $1;}
			|null						{$$ = make_leaf($1);}

literal:	number 						{$$ = make_leaf($1);}
			|id 						{$$ = make_leaf($1);}
			|bool 						{$$ = make_leaf($1);}
			|char 						{$$ = make_leaf($1);}
			|string 					{$$ = make_leaf($1);}
			|id BSI exp ESI 			{$$ = make_node($1, make_leaf("["), make_node("", $3, make_leaf("]")));}
			|string_length				{$$ = $1}

			

function_call:	id LP RP 			{$$ = make_node("call func", make_leaf($1), make_leaf("ARGS NONE"));}
				|id LP exp_list RP 	{$$ = make_node("call func", make_leaf($1), make_node("ARGS", $3, empty_node()));}

ifelse:			IF LP exp RP code_block_ 					{$$ = make_node("if", $3, $5);}
				|IF LP exp RP code_block_ ELSE code_block_ 	{$$ = make_node("if-else", make_node("(", $3, make_node("",$5, $7)), empty_node());}

code_block_:	non_func_code_block 					{$$ = $1;}
				|void_code_block 						{$$ = $1;}
				|code_block 							{$$ = $1;}

loop:		for_loop 									{$$ = $1;}
			|while_loop 								{$$ = $1;}

for_loop:	FOR LP loop_i_dec EOS exp EOS id EQUAL exp RP code_block_ 	{$$ = make_node("for", make_node("(", make_node("", $3, $5), make_node("=", make_leaf($7), $9)), $11);}
			|FOR LP loop_i_dec EOS exp EOS inc_dec RP code_block_ 		{$$ = make_node("for", make_node("(", make_node("",$3, $5), make_node("", $7, make_node(")", empty_node(), empty_node()))), $9);}

while_loop:	WHILE LP exp RP code_block_ 				{$$ = make_node("while", $3, $5);}
			|DO void_code_block WHILE LP exp RP EOS 	{$$ = make_node("do", $2, make_node("while", $5, empty_node()));}
			|DO code_block WHILE LP exp RP EOS 			{$$ = make_node("do", $2, make_node("while", $5, empty_node()));}

non_func_code_block:	var_dec 						{$$ = $1;}
						|exp 							{$$ = $1;}
						|assignment_statment EOS 		{$$ = $1;}
						|return 						{$$ = $1;}

inc_dec:	id PLUSONE 		{$$ = make_node($1, make_leaf("++"), empty_node());}
			|PLUSONE id 	{$$ = make_node("++", make_leaf($2), empty_node());}
			|id MINUSONE 	{$$ = make_node($1, make_leaf("--"), empty_node());}
			|MINUSONE id 	{$$ = make_node("--", make_leaf($2), empty_node());}

loop_i_dec: TYPE_INT id EQUAL int 	{$$ = make_node("INT", make_node("=", make_leaf($2), make_leaf($4)), empty_node());}
			|id EQUAL exp 			{$$ = make_node("=", make_leaf($1), $3);}
			|id 						{$$ = make_leaf($1);}

return:		RETURN literal EOS {$$ = make_node("return", $2, empty_node());}

%%










#include "lex.yy.c"
//main and error.
int main() {
	int res = yyparse();
	if(res == 0)
		printf("The Code is VALID!\n"); 
	return res;	
}
int yyerror(char* error){
 	fflush(stdout);
 	fprintf(stderr, "------------------------------------------------------\nError located in line: %d\n", yylineno);
	fprintf(stderr, "Cannot accept: \" %s \" .\n",yytext);
	fprintf(stderr, "Error: \" %s \" .\n",error);
	return 0;
}


//struct of the node.

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
	new_node->left = NULL;
	new_node->right = NULL;
	new_node->token = value;
}

struct node* make_node(char* token, node* left, node *right)
{
	node* new_node = (node*)malloc(sizeof(node));
	new_node->left = left;
	new_node->right = right;
	new_node->token = token;
	return new_node;
}
/*
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
*/
node* empty_node(){
	node* new_node = NULL;
	return new_node;
}






























void addVar_toScope(Varaiables* args, int count_vars ,int is_arg, Scope* current_scope){
	if (count_vars == 0)
		return;
	Varaiables* temp;
	Scope* scopes = current_scope;

	for (int i = 0; i < count_vars; i++)
		for (int j=0; j < count_vars; j++)
			if (i != j && strcmp(args[j].name, args[i].name) == 0){
				printf("The var %s has already been declared", args[j].name);
				Scope* temp_scope = scopes -> preScope;
				while (temp_scope->preScope != NULL && temp_scope->preScope->Fcount == 0)
					temp_scope = temp_scope->preScope;
				if (temp_scope->func != NULL)
					printf(" inside function \"%s\".", temp_scope->func[temp_scope->Fcount]->name);
				else
					printf(".\n");
				exit(1);
			}
			if (scopes->var == NULL)
				scopes->var = (Varaiables*)malloc(sizeof(Varaiables)*count_vars);
			else{
				temp = scopes->var;
				scopes->var = (Varaiables*)malloc(sizeof(Varaiables)*(scopes->VarCount + count_vars));
				for (int i=0; i < scopes->VarCount; i++){
					for (int j=0; j< count_vars; j++){
						if (strcmp(temp[i].name, args[j].name) == 0){
							printf("The var %s has already been declared", args[j].name);
							Scope* temp_scope = scopes -> preScope;
							while (temp_scope->preScope != NULL && temp_scope->preScope->Fcount == 0)
								temp_scope = temp_scope->preScope;
							if (temp_scope->func != NULL)
								printf(" inside function \"%s\".", temp_scope->func[temp_scope->Fcount]->name);
							else
								printf(".\n");
							exit(1);
						}
					}
					scopes->var[i] = temp[i];
				}
			}
			for (int j = 0; j < count_vars; j++){
				scopes->var[scopes->VarCount].value = NULL;
				scopes->var[scopes->VarCount].isArg = is_arg;
				scopes->var[scopes->VarCount].length = args[j].length;
				scopes->var[scopes->VarCount].name = args[j].name;
				scopes->var[(scopes->VarCount)++].type = args[j].type;
			}



}
Scope* make_scope(char* name)
{	
	Scope* newScope = (Scope*)malloc(sizeof(Scope));
	newScope->name = name;
	newScope->var = NULL;
	newScope->Fcount = 0;
	newScope->nextScope = NULL;
	newScope->preScope = NULL;
	newScope->VarCount = 0;
	newScope->func = NULL;
	return newScope;
}


void addFunc_toScope(char* name,Varaiables* args,node* returnType,int arg_num,Scope* current_scope){
	Function** temp;
	Scope* scopes = current_scope;
	for(int i=0;i<arg_num;i++)
		for(int j=0;j<arg_num;j++)
	if(i!=j && strcmp(args[j].name,args[i].name)==0 )
	{
		printf("The argument \"%s\" has already been declared inside function \"%s\"\n",args[i].name,name);
		exit(1);
	}
	if(scopes->func==NULL)
	{ 
		scopes->func=(Function**) malloc(sizeof(Function*));
	}
	else
	{
		temp=scopes->func;
		scopes->func=(Function**) malloc(sizeof(Function*)*(scopes->Fcount+1));
		for(int i=0;i<scopes->Fcount;i++)
		{
				if(strcmp(temp[i]->name,name)==0 )//if name taken, ERROR exit
				{
					printf("func %s already exists in scope \n",temp[i]->name);
					exit(1);
				}
				scopes->func[i]=temp[i];
		}
	}
		scopes->func[scopes->Fcount]=(Function*) malloc(sizeof(Function));
		scopes->func[scopes->Fcount]->name=name;
		scopes->func[scopes->Fcount]->args=args;
		if(returnType==NULL)
		scopes->func[scopes->Fcount]->returnType=NULL;
		else{
		if(strcmp(returnType->token,"string") == 0)//if func return string, ERROR exit
			{
				printf("Function \"%s\" cannot return string.\n",name);
				exit(1);
			}
		scopes->func[scopes->Fcount]->returnType=returnType->token;
		}
		scopes->func[scopes->Fcount]->argNum=arg_num;
		scopes->func[scopes->Fcount]->findreturn=false;
		++(scopes->Fcount); 
}



void pushScopes(Scope* from,char* name)
{
	Scope* point;
	if(globalScope == NULL)
		globalScope = make_scope(name);
	else{
	point = globalScope;
	while(point->nextScope != NULL)
		point = point->nextScope;
	point->nextScope = make_scope(name);
	point->nextScope->preScope = from;
	}
}

char* find_func(node* tree, Scope* current_scope){
	Scope* tmp=current_scope;
	Varaiables* arguments;
	bool find = false, flag = true;
	while(tmp!=NULL)
	{
		for(int i=0;i<tmp->Fcount;i++)
		if(!strcmp(tree->left->token,tmp->func[i]->name))
		{
			find=true;
			flag=true;
			int count=0;
			arguments=call_function_args(current_scope,tree->right->left,&count);
			if(count==tmp->func[i]->argNum)
			{
				for(int j=0,t=count-1;j<count;j++,t--)
				{
					if(strcmp(arguments[j].type,tmp->func[i]->args[t].type))
						flag=false;
				}
				if(flag==true)
					return tmp->func[i]->returnType;
			}
		}
		tmp=tmp->preScope;
	}
	printf("The function \"%s\" cannot find the call inside scope \"%s\" of %s.\n",tree->left->token, current_scope->name,globalScope->func[globalScope->Fcount-1]->name);
	if(find==true)
		printf("A function with the same name takes different arguments.\n");
	exit(1);
}

char* find_var(node* tree,Scope* current_scope)
{
	Scope* tmp = current_scope;
	if(strcmp(tree->token,"solovar")==0) //where we put it inside the tree.
		tree=tree->left;
	while(tmp!=NULL)
	{
		for(int i=0;i<tmp->VarCount;i++)
		if(!strcmp(tree->token,tmp->var[i].name))
		{
			
			if(tree->left!=NULL && strcmp(tree->left->token,"[")==0)
			{
				if(!strcmp(tmp->var[i].type,"string"))
					if(!strcmp(expType(tree->left->left,current_scope),"int"))
					{
						return "char";
					}
					else
					{
						printf("An index in a string must be of type int at scope \"%s\" in \"%s\".\n",current_scope->name,globalScope->func[globalScope->Fcount-1]->name);
						exit(1);
					}
				else
				{
					printf("An index in a string must be of type int at scope \"%s\" in \"%s\".\n",current_scope->name,globalScope->func[globalScope->Fcount-1]->name);
					exit(1);
				}

			}
			else{
				return tmp->var[i].type;
			}
		}
		tmp=tmp->preScope;
	}
	printf("\"%s\" is not declared in the scope \"%s\" of function \"%s\".\n",tree->token, current_scope->name, globalScope->func[globalScope->Fcount-1]->name);
	exit(1);	
}

Varaiables* call_function_args(Scope* current_scope, node* tree, int* count){
	Varaiables  *arr = NULL,arr2[50];
	char *type,*length;
	while(tree!=NULL)
	{
		arr2[(*count)++].type=expType(tree->left,current_scope);
		if(tree->right!=NULL)
			tree = tree->right->left;
		else
			tree = NULL;
	}
	arr=(Varaiables*)malloc(sizeof(Varaiables)*(*count));
	for(int i = 0; i<*count; i++)
		arr[i].type=arr2[i].type;
	return arr;
}



Varaiables* make_args(node *tree,int *count){
	Varaiables  *arr=NULL,arr2[50];
	char* type,*length;
	if(tree!=NULL)
	{
		node * temp1=tree,*tmp=tree;
		do{
		if(!strcmp(temp1->token, ""))
		{
			tmp=temp1->right->left;
			temp1=temp1->left;
			
			
			if(strcmp(tmp->token, "(")==0||strcmp(tmp->token, "var")==0)
			{
				type=tmp->left->token;
				if(tmp->left->left!=NULL)
					length=tmp->left->left->left->token;
				node * tmptree;
				tmptree=tmp->right->left;
				do{
				arr2[*count].name=tmptree->token;
				arr2[*count].type=type;
				arr2[*count].length=length;
				(*count)++;
				if(tmptree->left==NULL)
					tmptree=NULL;
				else
					tmptree=tmptree->left->left;
				}while(tmptree!=NULL);
			}
		}
		}while(strcmp(temp1->token, "(")!=0 && strcmp(tmp->token, "var")!=0);
		tmp = temp1;
		if(strcmp(tmp->token, "(")==0||strcmp(tmp->token, "var")==0)
		{
			type=tmp->left->token;
			node * tmptree;
			if(strcmp(tmp->token, "var")==0)
			tmptree=tmp->right;
			else
			tmptree=tmp->right->left;
			if(tmp->left->left!=NULL)
			length=tmp->left->left->left->token;
			do{
			arr2[*count].name=tmptree->token;
			arr2[*count].type=type;
			arr2[*count].length=length;
			(*count)++;
			if(tmptree->left==NULL)
				tmptree=NULL;
			else
				tmptree=tmptree->left->left;
			}while(tmptree!=NULL);
		}
		arr=(Varaiables*)malloc(sizeof(Varaiables)*(*count));
		for(int i=0;i<*count;i++)
		{
			for(int j=0;j<*count;j++){
			}
			arr[i].name=arr2[i].name;
			arr[i].type=arr2[i].type;
		}
	}
	return arr;
}

Scope* finalScope(Scope* scopes)
{
	Scope* this_scope = scopes;
	if(this_scope != NULL)
	while(this_scope->nextScope != NULL)
		this_scope = this_scope->nextScope;
	return this_scope;
}


char* expType(node * tree,Scope* current_scope){
	char* msg=(char*)malloc(sizeof(char)*7);
	msg="";
	if(strcmp(tree->token,"null")==0)
		msg="NULL";
	else
	if(tree->left!=NULL){
		if(!strcmp(tree->left->token,"INT"))
			msg= "int";
		if(!strcmp(tree->left->token,"HEX"))
			msg= "hex";
		if(!strcmp(tree->left->token,"STRING"))
			msg= "string";
		if(!strcmp(tree->left->token,"BOOLEAN"))
			msg= "boolean";
		if(!strcmp(tree->left->token,"CHAR"))
			msg= "char";
		if(!strcmp(tree->left->token,"REAL"))
			msg= "real";
		if(!strcmp(tree->token,"!"))
		if(!strcmp(expType(tree->left,current_scope),"boolean"))
			msg="boolean";
		else{
			printf("can use op ! on boolean type only");
			exit(1);
		}
		if(!strcmp(tree->token,"|"))
		if(!strcmp(expType(tree->left,current_scope),"string"))
		msg="int";
		else{
			printf("can use op | on string type in func %s",globalScope->func[globalScope->Fcount-1]->name);
			exit(1);
		}
		if(strcmp(tree->token,"==")==0||strcmp(tree->token,"!=")==0)
		{
			if(strcmp(expType(tree->left,current_scope),expType(tree->right,current_scope))==0&&strcmp(expType(tree->right,current_scope),"string")!=0)
			msg="boolean";
			else{
				printf("cant use op %s on %s and %s in func %s\n",tree->token,expType(tree->left,current_scope),expType(tree->right,current_scope),globalScope->func[globalScope->Fcount-1]->name);
				exit(1);
			}
		}

		if(strcmp(tree->token,">=")==0||strcmp(tree->token,">")==0||strcmp(tree->token,"<=")==0||strcmp(tree->token,"<")==0)
		{
			if((strcmp(expType(tree->left,current_scope),"int")==0||strcmp(expType(tree->left,current_scope),"real")==0)&&(strcmp(expType(tree->right,current_scope),"int")==0||strcmp(expType(tree->right,current_scope),"real")==0))
			msg="boolean";
			else{
				printf("cant use op %s on %s and %s in func %s\n",tree->token,expType(tree->left,current_scope),expType(tree->right,current_scope),globalScope->func[globalScope->Fcount-1]->name);
				exit(1);
			}
		}

		if(strcmp(tree->token,"&&")==0||strcmp(tree->token,"||")==0)
		{

			if(strcmp(expType(tree->left,current_scope),expType(tree->right,current_scope))==0&&strcmp(expType(tree->right,current_scope),"boolean")==0)
			msg="boolean";
			else{
				printf("cant use op %s on %s and %s in func %s\n",tree->token,expType(tree->left,current_scope),expType(tree->right,current_scope),globalScope->func[globalScope->Fcount-1]->name);
				exit(1);
			}
			

		}
		if(strcmp(tree->token,"-")==0||strcmp(tree->token,"+")==0)
		{
			if((strcmp(expType(tree->left,current_scope),"int")==0||strcmp(expType(tree->left,current_scope),"real")==0)&&(strcmp(expType(tree->right,current_scope),"int")==0||strcmp(expType(tree->right,current_scope),"real")==0))
			{
			if(strcmp(expType(tree->left,current_scope),expType(tree->right,current_scope))==0&&strcmp(expType(tree->left,current_scope),"int")==0)
			msg="int";
			else
			msg="real";
			}

			if(strcmp(expType(tree->right,current_scope),"int")==0&&(strcmp(expType(tree->left,current_scope),"char*")==0||strcmp(expType(tree->right,current_scope),"int*")==0||strcmp(expType(tree->right,current_scope),"real*")==0)){
				msg=expType(tree->left,current_scope);
			}
			else if(strcmp(msg,"")==0)
			{
				printf("cant use op %s on %s and %s in func/proc %s\n",tree->token,expType(tree->left,current_scope),expType(tree->right,current_scope),globalScope->func[globalScope->Fcount-1]->name);
				exit(1);
			}

		}
		if(strcmp(tree->token,"*")==0||strcmp(tree->token,"/")==0)
		{
			if((strcmp(expType(tree->left,current_scope),"int")==0||strcmp(expType(tree->left,current_scope),"real")==0)&&(strcmp(expType(tree->right,current_scope),"int")==0||strcmp(expType(tree->right,current_scope),"real")==0))
			{
			if(strcmp(expType(tree->left,current_scope),expType(tree->right,current_scope))==0&&strcmp(expType(tree->left,current_scope),"int")==0)
			msg="int";
			else
			msg="real";
			}
			else
			{
				printf("cant use op %s on %s and %s in func/proc %s\n",tree->token,expType(tree->left,current_scope),expType(tree->right,current_scope),globalScope->func[globalScope->Fcount-1]->name);
				exit(1);
			}
		}
		if(!strcmp(tree->token,"&"))
		{
			if(!strcmp(tree->left->token,"("))
				msg=expType(tree->left->left,current_scope);
			else{
				msg=expType(tree->left,current_scope);
				
				}
			if(!strcmp(msg,"char"))
			msg="char*";
			else
			if(!strcmp(msg,"int"))
			msg="int*";
			else
			if(!strcmp(msg,"real"))
			msg="real*";
			else
			{
				printf("cant use %s on %s\n",tree->token,msg);
				exit(1);
			}
		}
		if(!strcmp(tree->token,"^"))
		{
			if(!strcmp(tree->left->token,"("))
				msg=expType(tree->left->left,current_scope);
			else
				msg=expType(tree->left,current_scope);
			
			if(!strcmp(msg,"char*"))
			msg="char";
			else
			if(!strcmp(msg,"int*"))
			msg="int";
			else
			if(!strcmp(msg,"real*"))
			msg="real";
			else
			{
				printf("cant use %s on %s\n",tree->token,msg);
				exit(1);
			}

		}
		if(!strcmp(tree->token,"("))
			msg=expType(tree->left,current_scope);
		if(!strcmp(tree->token,"Call func")) //call func from the tree
			msg=find_func(tree,current_scope);
	}
	if(!strcmp(msg,""))
		msg=find_var(tree,current_scope);
	return msg;
}


















void Syntax_Analyze(node* tree, Scope* current_scope){

	printf("I'm herzzzze");
	/*
	if(strcmp(tree->token, "=") == 0 )
	{
		if(!(strcmp(expType(tree->right,current_scope),"NULL")==0&& (strcmp(expType(tree->left,current_scope),"real*")==0||strcmp(expType(tree->left,current_scope),"int*")==0||strcmp(expType(tree->left,current_scope),"char*")==0)))
		if(strcmp(expType(tree->left,current_scope),expType(tree->right,current_scope))!=0)
		{
			printf("OP = cant have %s and %s in scope %s in %s\n",expType(tree->left,current_scope),expType(tree->right,current_scope),current_scope->name,globalScope->func[globalScope->Fcount-1]->name);
			exit(1);
		}
	}
	else if(strcmp(tree->token, "var") == 0)
	{
		int VarCount=0;
		Varaiables * var=make_args(tree,&VarCount);
		addVar_toScope(var,VarCount,0,current_scope);
		
		
	}
	else if(!strcmp(tree->token, "if"))
	{
		if(strcmp(expType(tree->left->left,current_scope),"boolean"))
		{
			printf("condition must be of boolean type\n");
			exit(1);
		}

		if(strcmp(tree->right->token,"{"))
		{
			pushScopes(current_scope,tree->token);
			if (tree->left) 
				Syntax_Analyze(tree->left,finalScope( current_scope->nextScope));
	
			if (tree->right)
				Syntax_Analyze(tree->right,finalScope( current_scope->nextScope));
        	scope--;
			return;
		}
		
		
		
	}
		else if(!strcmp(tree->token, "while"))
	{
		if(strcmp(expType(tree->left->left,current_scope),"boolean"))
		{
			printf("condition must be of boolean type\n");
			exit(1);
		}

		if(strcmp(tree->right->token,"{"))
		{
			pushScopes(current_scope,tree->token);
			if (tree->left) 
				Syntax_Analyze(tree->left,finalScope( current_scope->nextScope));
	
			if (tree->right)
				Syntax_Analyze(tree->right,finalScope( current_scope->nextScope));
        	scope--;
			return;
		}
		
		
		
	}
			else if(!strcmp(tree->token, "for"))
	{

	 if(strcmp(expType(tree->left->left->right,current_scope),"boolean"))
		{
			printf("condition must be of boolean type\n");
			exit(1);
		}

		Syntax_Analyze(tree->left->left->left,current_scope);

		Syntax_Analyze(tree->left->right->left,current_scope);

		if(strcmp(tree->right->token,"{"))
		{

			pushScopes(current_scope,tree->token);

			if (tree->left) 
				Syntax_Analyze(tree->left,finalScope( current_scope->nextScope));
	
			if (tree->right)
				Syntax_Analyze(tree->right,finalScope( current_scope->nextScope));
        	scope--;
			return;
		}

		
		
	}
	
	else if(!strcmp(tree->token, "FUNC"))
	{
		printf("zzzsadsa\n");
        int count=0;
		Varaiables * arg=make_args(tree->left->right->left,&count);
		addFunc_toScope(tree->left->token,arg,tree->left->right->right->left,count,current_scope);
		pushScopes(current_scope,tree->token);
		addVar_toScope(arg,count,1,finalScope(current_scope));
	if (tree->left) 
		Syntax_Analyze(tree->left,finalScope( current_scope->nextScope));
	
	if (tree->right)
		Syntax_Analyze(tree->right,finalScope( current_scope->nextScope));
		if(current_scope->func[current_scope->Fcount-1]->findreturn==false)
		{
			printf("function %s must have return\n",tree->left->token);
			exit(0);
		}
        scope--;		
		return;
	}

	
    else if(strcmp(tree->token, "PROC") == 0)
	{
		
        int count=0;
		Varaiables * arg=make_args(tree->right->left,&count);
		addFunc_toScope(tree->left->token,arg,NULL,count,current_scope);
		pushScopes(current_scope,tree->token);
		addVar_toScope(arg,count,1,finalScope(current_scope));
	if (tree->left) 
		Syntax_Analyze(tree->left,finalScope( current_scope->nextScope));
	
	if (tree->right)
		Syntax_Analyze(tree->right,finalScope( current_scope->nextScope));
		scope--;	
		return;
    }

	else if(!strcmp(tree->token, "Call func"))
	{
		find_func(tree,current_scope);
		
		
	}*/
	if(!strcmp(tree->token, "CODE"))
	{
		pushScopes(NULL,tree->token);
	if (tree->left) 
		Syntax_Analyze(tree->left,globalScope);
	
	if (tree->right)
		Syntax_Analyze(tree->right,globalScope);
		scope--;
		return;
	}
	
    else if(strcmp(tree->token, "Main") == 0)
	{
		printf("zasdqweqweqwewqewqe\n");
		addFunc_toScope(tree->token,NULL,NULL,0,current_scope);
		pushScopes(current_scope,tree->token);

	if (tree->left) 
		Syntax_Analyze(tree->left,finalScope( current_scope->nextScope));
	
	if (tree->right)
		Syntax_Analyze(tree->right,finalScope( current_scope->nextScope));
        scope--;
		return;
               
    }
    /*       
	else if(!strcmp(tree->token, "if-else"))
	{
		if(strcmp(expType(tree->left->left,current_scope),"boolean"))
		{
			printf("condition must be of boolean type\n");
			exit(1);
		}

		if(strcmp(tree->right->left->token,"{"))
		{
			pushScopes(current_scope,tree->token);
			Syntax_Analyze(tree->right->left,finalScope( current_scope->nextScope));
			scope--;
			pushScopes(current_scope,tree->token);
			Syntax_Analyze(tree->right->right->left,finalScope( current_scope->nextScope));
        	scope--;
			return;
		}
	}

	else if(!strcmp(tree->token, "return"))
	{
		Scope * tmp= current_scope;
		int flag=true;
		while(strcmp(tmp->name,"FUNC")!=0&&strcmp(tmp->name,"PROC")!=0&&strcmp(tmp->name,"CODE")!=0)
		{
			tmp=tmp->preScope;
			flag=false;
		}
		if(flag==false)
		{
			if(strcmp(expType(tree->left,current_scope),tmp->preScope->func[tmp->preScope->Fcount-1]->returnType))
			{
			printf("func %s doesnt return the same type declared \n",tmp->preScope->func[tmp->preScope->Fcount-1]->name);
			printf("%s ,%s %s\n",expType(tree->left,current_scope),tmp->preScope->func[tmp->preScope->Fcount-1]->returnType,tmp->preScope->func[tmp->preScope->Fcount-1]->name);
			exit(1);
			}
		}
		else
		{
			if(tmp->preScope->func[tmp->preScope->Fcount-1]->returnType!=NULL)
			{
				if(0==strcmp(expType(tree->left,current_scope),tmp->preScope->func[tmp->preScope->Fcount-1]->returnType))
				{
					tmp->preScope->func[tmp->preScope->Fcount-1]->findreturn=true;
				}
				else
				{
					printf("return type is different than func %s declared \n",tmp->preScope->func[tmp->preScope->Fcount-1]->name);
					printf("%s ,%s %s\n",expType(tree->left,current_scope),tmp->preScope->func[tmp->preScope->Fcount-1]->returnType,tmp->preScope->func[tmp->preScope->Fcount-1]->name);
					exit(1);
				}
			}
			else
			{
				printf("proc %s cant have a return value\n",tmp->preScope->func[tmp->preScope->Fcount-1]->name);
				exit(1);
			}  
		}  
	}
	else if(strcmp(tree->token, "{") == 0)
	{
    pushScopes(current_scope,tree->token);
	if (tree->left) 
		Syntax_Analyze(tree->left,finalScope( current_scope->nextScope));
	
	if (tree->right)
		Syntax_Analyze(tree->right,finalScope( current_scope->nextScope));
        scope--;
		return;			
	}
	else if(!strcmp(tree->token, "solovar"))
	{
		find_var(tree->left,current_scope);
	}
	if (tree->left) 
		Syntax_Analyze(tree->left,current_scope);
	
	if (tree->right)
		Syntax_Analyze(tree->right,current_scope);
		*/
}












//printing the tree
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

	if(strcmp(tree->token, "") == 0){
		tab_count--;
	}

	else if(tree->left != NULL){
		printTabs();
		printf("%s\n",tree->token);
	}

	else{
		printTabs();
		printf("%s\n",tree->token);
	}
	
	if(tree->left)printTree(tree->left);
	if(tree->right)printTree(tree->right);


	if(strcmp(tree->token, "") == 0){
		tab_count++;}
	else if((tree->left != NULL ) && (tree->token != "")){
		printTabs();
		printf("\n");
	}
	tab_count--;
	return 0;

}