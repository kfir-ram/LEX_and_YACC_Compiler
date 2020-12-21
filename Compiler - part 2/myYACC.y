%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <math.h>

#if YYBISON
int yylex(void);
int yyerror();
int printf(const char *format, ...);
char* yytext;
#endif

#define YYSTYPE struct node*

typedef struct node
{
    char *token;
    char *value;
    int childs_length;
    struct node **childs;
    struct node *parent;
    char *type;
    char *var;
    
} node;

struct sym_link_list
{
    struct id_data *id;
    struct sym_link_list *next;
} sym_link_list;

typedef struct
{
    int position;
    struct sym_link_list *declarations;
} scope;

struct scope_link_list
{
    int position;
    scope *s;
    char *type;
    struct scope_link_list *next;
} scope_link_list;

struct scope_stack
{
    scope *data;
    struct scope_stack *next;
} scope_stack;

struct id_data
{
    char *symbol;
    char *kind;
    int count_params;
    char **param_list;
    char **param_list_type;
    struct scope_link_list *decl;
} id_data;

typedef struct object
{
    char *key;
    struct id_data *id;
} object;

typedef struct hash_table
{
    int base_size;
    int size;
    int count;
    object **objects;
} hash_table;

node *tree;
hash_table *current_hash;
struct scope_stack *stack;
static object ht_memo = {NULL, NULL};
static int position = 0;




node *make_node(char *token);
void add_child(node *parent, node *son);
void print_tab(int count_tabs, int eq);
void print_node(node *n, int count_tabs);
void free_memory(node *n);
void get_child(node *dest, node *tar);
void set_value(node *tar, char *val);

hash_table *hash_table_initiate();
struct id_data* hash_table_find(hash_table *hashTable, const char *k);
static hash_table* hash_table_newSize(const int size);
void delete_hash_table(hash_table *current_hash, const char *key);
void hash_table_insert(hash_table *current_hash, const char *key, struct id_data *id);
static void hash_table_biggerSize(hash_table* hashTable);
static void hash_table_smallerSize(hash_table* hashTable);
static void hash_table_changeSize(hash_table *current_hash, const int base_size);


int is_prime(const int x);
int next_prime(int x);

struct sym_link_list* symbol_list_insert(struct id_data *id_);
void scope_list_insert(struct scope_link_list **scll);
scope *scope_list_pop(struct scope_link_list **scll);



struct scope_stack *stack_scope_initiate();
void stack_scope_push(scope *data);
scope *stack_scope_pop();

static scope* new_scope();
static void dec_new_scope(struct id_data* id_);
static void delete_scope();
struct scope_link_list *scope_list_initiate();


static int make_hash(const char *str, const int p, const int hashTable_size);
static int get_hash(const char *str, const int hashTable_size, const int attempt_num);

static struct id_data* new_idInfo(char* sym, char* k, char* type);
struct id_data* id_info_initiate(hash_table *hashTable, char *sym, char *k, char *t);

void args_initiate(node *params);
void set_chanages(struct id_data *id, char *arg_type);

static object* new_item(const char* key, struct id_data* id);
static void delete_item(object* item_);


int count_tabs = 0;

char *get_view(node *n);
char *get_type(node *n);
int does_var_exists(char *id);
void one_main_check();
void type_main_check(node *main);
void id_exist_check(char *id);
void func_exist_check(node *id);
void func_args_check(node *func_call);
void arg_type_check(node *args, char *func_name);
void arithmetic_check(node *left_operand, node *right_operand, char *op);
void equal_check(node *left_operand, node *right_operand, char *op);
void bool_check(node *left_operand, node *right_operand, char *op);
void not_check(node *operand);
void address_check(node *operand);
void pointer_check(node *operand);
void function_check(node *func, node *args);
void return_check(node *func);
void call_func_check(node *call, node *args);
void string_check(node *element);
void assign_check(node *assign);
void bool_cond_check(node *condition);
void var_dec_check(node *n);



%}

%token INT REAL CHAR INT_P REAL_P CHAR_P STRING_T VOID_T BOOL 
MAIN FUNC VAR RETURN IF ELSE WHILE FOR DO ID
DOUBLE INTEGER NULL_E PLUS MINUS MULTIPLY DIVIDE CHARACTER
GT GTE LT LTE EQUAL NOT_EQUAL NOT ASSIGN AND OR STRING
 '{' '}' '(' ')'  '[' ']' ',' ADDRESS LENGTH BOOL_TRUE BOOL_FALSE

%left ',' '}' ')' ']'
%left OR AND
%left GT GTE LT LTE EQUAL NOT_EQUAL
%left DIVIDE MULTIPLY
%left MINUS PLUS
%left ASSIGN
%right ADDRESS NOT '{' '(' '['
%nonassoc FUNC MAIN ID IF ELSE DO FOR fWHILE  
%start program





















%%
program:  code {
        get_child(tree, $1);
        free($1);
    }

code: code function { 
    $$ = $1;
    add_child($$, $2);
    }
    | {
        $$ = make_node("CODE");
        
    }


function: FUNC type id '(' param_list push_scope initiate_params ')' function_block pop_scope { 
        $$ = make_node("FUNCTION");
        set_value($$, $3->value);
        free($3);
        add_child($$, $2);
        add_child($$, $5);
        $9->token = strdup("BODY");
        add_child($$, $9);
        $$->type = strdup($2->type);
        function_check($$, $5);
        return_check($$);

    }
    | FUNC void id '(' param_list push_scope initiate_params ')' block pop_scope  {
        $$ = make_node("FUNCTION");
        set_value($$, $3->value);
        free($3);
        add_child($$, $2);
        add_child($$, $5);
        $9->token = strdup("BODY");
        add_child($$, $9);
        $$->type = strdup($2->type);
        function_check($$, $5);

    }

block: '{' dec_list statments '}' { 
        $$ = make_node("BLOCK"); 
        add_child($$, $2); 
        add_child($$, $3); 

    }
    | '{' dec_list '}' { 
        $$ = make_node("BLOCK"); 
        add_child($$, $2); 

    }
    | '{' statments '}' { 
        $$ = make_node("BLOCK"); 
        add_child($$, $2); 

    }
    | '{' '}' { 
        $$ = make_node("BLOCK");

    }

function_block: '{' dec_list statments return_statment '}' {
        $$ = make_node("BLOCK");
        add_child($$, $2);
        add_child($$, $3);
        add_child($$, $4);

    }
    | '{' statments return_statment '}' {
        $$ = make_node("BLOCK");
        add_child($$, $2);
        add_child($$, $3);
    
    }
    | '{' dec_list return_statment '}' {
        $$ = make_node("BLOCK");
        add_child($$, $2);
        add_child($$, $3);
    
    }
    | '{' return_statment '}' {
        $$ = make_node("BLOCK");
        add_child($$, $2);
    
    }

param_list:  param_list ';' type args {
                    $$ = make_node("PARAMS_LIST");
                    get_child($$, $1);
                    free($1);
                    get_child($3, $4);
                    free($4);
                    add_child($$, $3);
                    $3->type = strdup($3->value);
                }
                |  type args {
                    $$ = make_node("PARAMS_LIST");
                    get_child($1, $2);
                    free($2);
                    add_child($$, $1);
                    $1->type = strdup($1->value);
                    }
                | { 
                    $$ = make_node("PARAMS_LIST");
                    set_value($$, "NONE");
                }

args: id { 
    $$ = make_node("");
    add_child($$,$1);
    }
    | args ',' id { 
        $$ = $1;
        add_child($$, $3);
    }

for_statment: FOR '(' for_initiate ';' expression ';' for_update ')' statment {
        $$ = make_node("FOR");
        add_child($$, $3);
        add_child($$, $5);
        add_child($$, $7);
        add_child($$, $9);
        bool_cond_check($5);
    
    }



if_statment: IF '(' expression ')' statment ELSE statment {
            $$ = make_node("IF_ELSE");
            add_child($$, $3);
            add_child($$, $5);
            add_child($$, $7);
            bool_cond_check($3);
    }

            |   IF '(' expression ')' statment {
            $$ = make_node("IF");
            add_child($$, $3);
            add_child($$, $5);
            bool_cond_check($3);

    }

while_statment: WHILE '(' expression ')' statment {
        $$ = make_node("WHILE");
        add_child($$, $3);
        add_child($$, $5);
        bool_cond_check($3);


    }
    | DO push_scope block pop_scope WHILE '(' expression ')' ';' {
        $$ = make_node("DO");
        add_child($$, $7);
        add_child($$, $3);
        bool_cond_check($7);


    }

for_initiate:   assign_statment {
                $$ = $1;
                assign_check($1);
    }

for_update:     assign_statment {
                $$ = $1;
                assign_check($$);
    }

statments: statments statment { 
        $$ = make_node("STATEMENTS");
        get_child($$, $1);
        free($1);
        add_child($$, $2);

    }
    | statment { 
        $$ = make_node("STATEMENTS"); 
        add_child($$, $1); 

    }

statment:   for_statment { $$ = $1;}
            | if_statment { $$ = $1; }
            | while_statment { $$ = $1; }
            | func_call ';' { $$ = $1;}
            | assign_statment ';' { $$ = $1; assign_check($1); }
            | return_statment { $$ = $1;}
            | push_scope block pop_scope { $$ = $2;}
    
assign_statment: assign_var ASSIGN expression {
        $$ = make_node("=");
        add_child($$, $1);
        add_child($$, $3);

    }

dec_list: dec_list dec {
        $$ = make_node("DEC_LIST");
        get_child($$, $1);
        free($1);
        add_child($$, $2);
    }
    | dec {
        $$ = make_node("DEC_LIST"); 
        add_child($$, $1); 
    }

dec: var_dec { $$ = $1; }
    | string_dec { 
        $$ = $1; 
        $$->type = strdup("STRING"); 
    }
    | function { 
        $$ = $1; 
    }

var_dec: VAR type var_dec_args ';' {
        $$ = make_node("VAR");
        get_child($2, $3);
        add_child($$, $2);
        $$->type = strdup($2->value);
        for (int i = 0; i < $3->childs_length; i++)  {
            node *var = $3->childs[i];
            if (strcmp(var->token, "ID") != 0) 
                var = var->childs[0];
            else
                var->type = strdup($$->type);

            struct id_data *id = hash_table_find(current_hash, var->value);
            id->decl->type = strdup($$->type);
        }
    }



string_dec: STRING_T string_dec_args ';' {
        $$ = make_node("VAR");
        node *t = make_node("TYPE");
        set_value(t, "STRING");
        get_child(t, $2);
        $$->type = strdup(t->value);
        for (int i = 0; i < $2->childs_length; i++)  {
            node *var = $2->childs[i];
            if (strcmp(var->token, "=") == 0)  {
                struct id_data *id = hash_table_find(current_hash, var->childs[0]->value);
                id->decl->type = strdup($$->type);
                assign_check(var);
            } else {
                struct id_data *id = hash_table_find(current_hash, var->value);
                id->decl->type = strdup($$->type);
                string_check(var);
            }
        }
        add_child($$, t);
    }

expression_list: expression_list ',' expression {
        $$ = $1;
        add_child($$, $3);

    }
    | expression {
        $$ = make_node("PARAMS_LIST");
        add_child($$, $1);

    }

var_dec_args: id { 
        $$ = make_node("");
        add_child($$, $1);
        var_dec_check($1);
    }
    | assign_statment {
        $$ = make_node("");
        add_child($$, $1);
        var_dec_check($1->childs[0]);
    }
    | var_dec_args ',' id { 
        $$ = make_node("VAR");
        get_child($$, $1);
        free($1);
        add_child($$, $3);
        var_dec_check($3);
    }
    | var_dec_args ',' assign_statment {
        $$ = make_node("VAR");
        get_child($$, $1);
        free($1);
        add_child($$, $3);
        var_dec_check($3->childs[0]);
    }


string_dec_args: string_element {
        $$ = make_node("");
        add_child($$, $1);
        $1->type = strdup("STRING");
        var_dec_check($1);
    }
    | assign_statment {
        $$ = make_node("");
        add_child($$, $1);
        $1->type = strdup("STRING");
        var_dec_check($1->childs[0]);
    }
    | string_element ',' string_dec_args {
        $$ = make_node("VAR");
        add_child($$, $1);
        get_child($$, $3);
        free($3);
        $1->type = strdup("STRING");
        var_dec_check($1);
    }
    | assign_statment ',' string_dec_args {
        $$ = make_node("VAR");
        add_child($$, $1);
        get_child($$, $3);
        free($3);
        $1->type = strdup("STRING");
        var_dec_check($1->childs[0]);
    }

func_call: id '(' expression_list ')' {
        $$ = make_node("FUNC_CALL");
        set_value($$, $1->value);
        free($1);
        add_child($$, $3);
        call_func_check($$, $3);
       

    }
    | id '(' ')' {
        $$ = make_node("FUNC_CALL");
        set_value($$, $1->value);
        free($1);
        add_child($$, make_node("PARAMS_LIST NONE"));
        call_func_check($$, $$->childs[0]);

    }



return_statment:    RETURN expression ';' {
                    $$ = make_node("RETURN");
                    add_child($$, $2);
                    $$->type = get_type($2);

    }


expression: expression PLUS expression {
        $$ = make_node(" + ");
        add_child($$, $1);
        add_child($$, $3);
        arithmetic_check($1, $3, $$->token);
        $$->type = strdup(get_type($1));

    }
    | expression MINUS expression {
        $$ = make_node(" - ");
        add_child($$, $1);
        add_child($$, $3);
        arithmetic_check($1, $3, $$->token);
        $$->type = strdup(get_type($1));

    }
    | expression MULTIPLY expression {
        $$ = make_node(" * ");
        add_child($$, $1);
        add_child($$, $3);
        arithmetic_check($1, $3, $$->token);
        $$->type = strdup(get_type($1));

    }
    | expression DIVIDE expression {
        $$ = make_node(" / ");
        add_child($$, $1);
        add_child($$, $3);
        arithmetic_check($1, $3, $$->token);
        $$->type = strdup(get_type($1));

    }
    | expression EQUAL expression {
        $$ = make_node(" == ");
        add_child($$, $1);
        add_child($$, $3);
        equal_check($1, $3, $$->token);
        $$->type = strdup("BOOL");

    }
    | expression NOT_EQUAL expression {
        $$ = make_node(" != ");
        add_child($$, $1);
        add_child($$, $3);
        equal_check($1, $3, $$->token);
        $$->type = strdup("BOOL");

    }

    | expression AND expression {
        $$ = make_node(" && ");
        add_child($$, $1);
        add_child($$, $3);
        bool_check($1, $3, $$->token);
        $$->type = strdup(get_type($1));

    }
    | expression OR expression {
        $$ = make_node(" || ");
        add_child($$, $1);
        add_child($$, $3);
        bool_check($1, $3, $$->token);
        $$->type = strdup(get_type($1));

    }
    | NOT expression {
        $$ = make_node("!");
        add_child ($$, $2);
        not_check($2);
        $$->type = strdup(get_type($2));

    }
    | expression GT expression {
        $$ = make_node(" > ");
        add_child($$, $1);
        add_child($$, $3);
        arithmetic_check($1, $3, $$->token);
        $$->type = strdup("BOOL");

    }
    | expression LT expression {
        $$ = make_node(" < ");
        add_child($$, $1);
        add_child($$, $3);
        arithmetic_check($1, $3, $$->token);
        $$->type = strdup("BOOL");

    }
    | expression GTE expression {
        $$ = make_node(" >= ");
        add_child($$, $1);
        add_child($$, $3);
        arithmetic_check($1, $3, $$->token);
        $$->type = strdup("BOOL");

    }
    | expression LTE expression {
        $$ = make_node(" <= ");
        add_child($$, $1);
        add_child($$, $3);
        arithmetic_check($1, $3, $$->token);
        $$->type = strdup("BOOL");

    }
    | ADDRESS expression {
        $$ = make_node("&");
        add_child($$, $2);
        address_check($2);
        char *type = strdup(get_type($2));
        int size = strlen(type) + strlen("PTR") + 1;
        char *temp = realloc(type, size);
        if (!temp) {
            printf("The parser can not accept the address reallocation.\n");
            exit(1);
        }
        type = temp;
        strcat(type, "PTR");
        $$->type = strdup(type);

    }
    | pointer {
        $$ = $1;
    }
    | '(' expression ')' {
        $$ = $2;
    }
    | literal { 
        $$ = $1;
    }

literal: id { $$ = $1;}
        | INTEGER { 
            $$ = make_node("INTEGER"); 
            set_value($$, yytext); 
            $$->type = strdup("INT"); 
            $$->var = strdup($$->value);

        }
        | CHARACTER { 
            $$ = make_node("CHARACTER"); 
            set_value($$, yytext); 
            $$->type = strdup("CHAR"); 
            $$->var = strdup($$->value);

        }
        | DOUBLE { 
            $$ = make_node("DOUBLE"); 
            set_value($$, yytext); 
            $$->type = strdup("REAL"); 
            $$->var = strdup($$->value);

        }
        | string_literal { 
            $$ = $1; 
            $$->var = strdup($$->value);

        }
        | boolean { 
            $$ = $1; 
            $$->var = strdup($$->value);

        }
        | abs { $$ = $1; }
        | NULL_E { 
            $$ = make_node("NULL"); 
            $$->value = strdup("NULL"); 
            $$->type = strdup("NULL");
            $$->var = strdup($$->value);

        }
        | string_element { $$ = $1; }
        | func_call { $$ = $1; }


push_scope: {
    stack_scope_push(new_scope());}
pop_scope: {
    delete_scope();}
initiate_params: {
    args_initiate($-1);}

type: INT       {
    $$ = make_node("TYPE");
    set_value($$, "INT"); 
    $$->type = strdup($$->value);
    }
    | REAL      {
    $$ = make_node("TYPE");
    set_value($$, "REAL"); 
    $$->type = strdup($$->value);
    }
    | CHAR      {
    $$ = make_node("TYPE");
    set_value($$, "CHAR"); 
    $$->type = strdup($$->value);
    }
    | INT_P    {
    $$ = make_node("TYPE");
    set_value($$, "INT_P"); 
    $$->type = strdup($$->value);
    }
    | REAL_P   {
    $$ = make_node("TYPE");
    set_value($$, "REAL_P"); 
    $$->type = strdup($$->value);
    }
    | CHAR_P   {
    $$ = make_node("TYPE");
    set_value($$, "CHAR_P");
    $$->type = strdup($$->value);
    }
    | BOOL      {
    $$ = make_node("TYPE"); 
    set_value($$, "BOOL");
    $$->type = strdup($$->value);
    }

void: VOID_T { 
    $$ = make_node("TYPE"); 
    set_value($$, "VOID");
    $$->type = strdup($$->value);
    }

string_element: id '[' expression ']' {
    $$ = make_node("STRING ELEMENT");
    set_value($$, $1->value);
    free($1);
    add_child($$, $3);
    $$->type = strdup("CHAR");
    int size = strlen($$->value) + strlen($3->var) + 3;
    $$->var = malloc(size);
    *$$->var = '\0';
    strcat($$->var, $$->value);
    strcat($$->var, "[");
    strcat($$->var, $3->var);
    strcat($$->var, "]");

}

boolean: BOOL_TRUE { 
        $$ = make_node("BOOLEAN"); 
        set_value($$, yytext); 
        $$->type = strdup("BOOL");
        $$->var = strdup($$->value);

    }
    | BOOL_FALSE { 
        $$ = make_node("BOOLEAN"); 
        set_value($$, yytext); 
        $$->type = strdup("BOOL"); 
        $$->var = strdup($$->value);

    }



pointer: MULTIPLY expression {
        $$ = make_node("POINTER");
        add_child($$, $2);
        pointer_check($2);
        char *type = strdup(get_type($2));
        if (strcmp(type, "INT_P") == 0) $$->type = strdup("INT");
        if (strcmp(type, "CHAR_P") == 0) $$->type = strdup("CHAR");
        if (strcmp(type, "REAL_P") == 0) $$->type = strdup("REAL");

    }

assign_var: id { $$ = $1; }
            | string_element { $$ = $1; }
            | pointer { $$ = $1; }



id: ID { 
    $$ = make_node("ID"); 
    set_value($$, yytext);
    $$->var = strdup($$->value);

}

string_literal: STRING { 
    $$ = make_node("STRING LITERAL"); 
    set_value($$, yytext); 
    $$->type = strdup("STRING"); 
    $$->var = strdup($$->value);

}

abs: LENGTH id LENGTH {
        $$ = make_node("LEN");
        add_child($$, $2);
        if(strcmp(get_type($2), "STRING")) {
            printf("Operand |<string>| must be only on string type.\n");
            exit(1);
        }
        $$->type = strdup("INT");

    }
    | LENGTH string_literal LENGTH {
        $$ = make_node("STRING LEN");
        add_child($$, $2);
        $$->type = strdup("INT");

    }



%%











#include "lex.yy.c"

int main()
{
    tree = make_node("CODE"); 
    current_hash = hash_table_initiate();
    stack = stack_scope_initiate(new_scope());
    int ast_result = yyparse(); 
    if (ast_result == 0) {
        //print_node(tree, 0);
        printf("Parsing Succeeded!\n");
    }
    else {
        printf("Parsing Failed!\n");
    }

    return ast_result;
}

int yyerror(){
    extern int yylineno;
	fflush(stdout);
 	fprintf(stderr, "------------------------------------------------------\nError located in line: %d\n", yylineno);
	fprintf(stderr, "The parser can not accept: \" %s \" .\n",yytext);
	return 0;
}





node *make_node(char *new_node_token)
{
    node *new_node = (node *)malloc(sizeof(node));
    new_node->token = strdup(new_node_token);
    new_node->value = NULL;
    new_node->parent = NULL;
    char *type = NULL;
    new_node->childs_length = 0;
    new_node->childs = NULL;
    char *code = strdup("");
    char *var = strdup("");
    char *next_label = NULL;

    
    return new_node;
}

void get_child(node *node_destination, node *node_target)
{
    int n_index;
    
    if (node_target && node_destination)
    {
        for (n_index = 0; n_index < node_target->childs_length; n_index++)
        {
            add_child(node_destination, node_target->childs[n_index]);
        }
    }
}


void print_tab(int tab_count, int is_equal)
{
    int n_index;
    
    if (!is_equal)
    {
        for (n_index = 0; n_index < tab_count; n_index++)
        {
            printf("\t");
        }
    }
    else
    {
        for (n_index = 0; n_index <= tab_count; n_index++)
        {
            printf("\t");
        }
    }
}

void print_node(node *tree_node, int tab_count)
{

    print_tab(tab_count, 0);
    
    if (tree_node->type)
    {
        printf("(%s (type %s)", tree_node->token, tree_node->type);
    }
    
    else
    {
        printf("(%s", tree_node->token);
    }
    
    if (tree_node->value)
    {
        printf("\n");
        print_tab(tab_count, 1);
        printf("%s", tree_node->value);
    }
    if (tree_node->childs_length > 0)
    {
        printf("\n");
    }
    
    for (int i = 0; i < tree_node->childs_length; i++)
    {
        print_node(tree_node->childs[i], tab_count + 1);
    }

    if (tree_node->childs_length)
    {
        print_tab(tab_count, 0);
    }
    
    printf(")\n");
}

void add_child(node *par_node, node *son_node)
{
    if (par_node && son_node)
    {
        par_node->childs_length += 1;
        
        par_node->childs = realloc(par_node->childs, par_node->childs_length * sizeof(node *));
        par_node->childs[par_node->childs_length - 1] = son_node;
        son_node->parent = par_node;
    }
}

void free_memory(node *node_tree)
{
    
    
    for (int i = 0; i < node_tree->childs_length; i++)
    {
        free_memory(node_tree->childs[i]);
    }
    
    free(node_tree);
}

void set_value(node *base, char *value)
{
    
    base->value = strdup(value);
}







static scope* new_scope()
{
    scope *newScope = (scope*)malloc(sizeof(scope));
    newScope->position = position++;
    newScope->declarations = NULL;
    return newScope;
}

static void dec_new_scope(struct id_data* id)
{
    symbol_list_insert(id);
}

static void delete_scope()
{

    struct sym_link_list* s = stack->data->declarations;
    int current_Scope = stack->data->position;
    while (s != NULL)
    {
        scope_list_pop( &s->id->decl);
        if ( s->id->decl == NULL )
            delete_hash_table(current_hash, s->id->symbol);
        s = s->next;
    }
    stack_scope_pop();
}

static struct id_data* new_idInfo(char* sym, char* k, char* type)
{
    struct id_data *new_id = (struct id_data*)malloc(sizeof(struct id_data));
    new_id->symbol = strdup(sym);
    new_id->kind = strdup(k);
    new_id->decl = scope_list_initiate(stack->data);
    new_id->decl->type = type != NULL ? strdup(type) : type;
    new_id->count_params = 0;
    new_id->param_list = NULL;
    new_id->param_list_type = NULL;
    return new_id;
}



hash_table *hash_table_initiate()
{
    hash_table* new_hashTable = hash_table_newSize(50);
    return new_hashTable;
}

static int get_hash(const char *str, const int hashTable_size, const int attempt_num)
{
    const int hash1 = make_hash(str, 151, hashTable_size);
    const int hash2 = make_hash(str, 163, hashTable_size);
    return (hash1 + (attempt_num * (hash2 + 1))) % hashTable_size;
}

struct id_data* hash_table_find(hash_table *hashTable, const char *k)
{
    int i = 1;
    int i_ = get_hash(k, hashTable->size, 0);
    object* itemp = hashTable->objects[i_];
    while (itemp != NULL)
    {
        if (itemp != (object*)&ht_memo)
        {
            if (strcmp(itemp->key, k) == 0)
                return itemp->id;
        }
        i_ = get_hash(k, hashTable->size, i);
        itemp = hashTable->objects[i_];
        i++;
    }
    return NULL;
}

void hash_table_insert(hash_table *hashTable, const char *k, struct id_data *id)
{
    const int x = hashTable->count * 100 / hashTable->size;
    if (x > 70)
        hash_table_biggerSize(hashTable);

    object* itemp = new_item(k, id);
    int index = get_hash(itemp->key, hashTable->size, 0);
    object* current_item = hashTable->objects[index];
    int i = 1;
    while (current_item != NULL)
    {
        if (current_item != (object *)&ht_memo)
        {
            if (strcmp(current_item->key, k) == 0)
            {
                delete_item(current_item);
                hashTable->objects[index] = itemp;
                return;
            }
        }
        index = get_hash(itemp->key, hashTable->size, i);
        current_item = hashTable->objects[index];
        i++;
    }
    hashTable->objects[index] = itemp;
    hashTable->count++;
}





static hash_table* hash_table_newSize(const int size)
{
    hash_table* hTable = (hash_table*)malloc(sizeof(hash_table*));
    hTable->base_size = size;
    hTable->size = next_prime(hTable->base_size);
    hTable->count = 0;
    hTable->objects = (object **)calloc((size_t)hTable->size, sizeof(object *));
    return hTable;
}

static void hash_table_biggerSize(hash_table* hashTable)
{
    const int resize = hashTable->base_size * 2;
    hash_table_changeSize(hashTable, resize);
}

static void hash_table_smallerSize(hash_table* hashTable)
{
    const int resize = current_hash->base_size / 2;
    hash_table_changeSize(hashTable, resize);
}


static void hash_table_changeSize(hash_table *current_hash, const int base_size)
{
    if (base_size < 50)
    {
        return ;
    }
    hash_table* new_hashTable = hash_table_newSize(base_size);
    for (int i = 0; i < current_hash->size; i++)
    {
        object* itemp = current_hash->objects[i];
        if (itemp != NULL && itemp != (object*)&ht_memo)
        {
            hash_table_insert(current_hash, itemp->key, itemp->id);
        }
    }
    current_hash->base_size = new_hashTable->base_size;
    current_hash->count = new_hashTable->count;
    const int tmp_size = current_hash->size;
    current_hash->size = new_hashTable->size;
    new_hashTable->size = tmp_size;
    object **tmp_items = current_hash->objects;
    current_hash->objects = new_hashTable->objects;
    new_hashTable->objects = tmp_items;
}



static int make_hash(const char *str, const int p, const int hashTable_size)
{
    const int str_len = strlen(str);
    long int hash = 0;
    for (int i = 0; i < str_len; i++)
    {
        hash += (long)pow(p, str_len - (i + 1)) * str[i];
        hash = hash % hashTable_size;
    }
    return hash;
}



void delete_hash_table(hash_table *hashTable, const char *k)
{
    const int x = hashTable->count * 100 / hashTable->size;
    if (x < 10)
        hash_table_smallerSize(hashTable);

    int i = 1;
    int i_ = get_hash(k, hashTable->size, 0);
    object* itemp = hashTable->objects[i_];
    while (itemp != NULL)
    {
        if (itemp != (object *)&ht_memo)
        {
            if (strcmp(itemp->key, k) == 0)
            {
                delete_item(itemp);
                hashTable->objects[i_] = (object *)&ht_memo;
            }
        }
        i_ = get_hash(k, hashTable->size, i);
        itemp = hashTable->objects[i_];
        i++;
    }
    hashTable->count--;
}



struct sym_link_list* symbol_list_insert(struct id_data *id_)
{
    struct sym_link_list* new_sll = (struct sym_link_list *)malloc(sizeof(struct sym_link_list));
    new_sll->id = id_;
    new_sll->next = stack->data->declarations;
    stack->data->declarations = new_sll;
    return stack->data->declarations;
}


int is_prime(const int p)
{
    if (p < 2)
        return -1;
    if (p < 4)
        return 1;
    if ((p % 2) == 0)
        return 0;
    for (int i = 3; i <= floor(sqrt((double)p)); i += 2)
    {
        if ((p % 2) == 0)
            return 0;
    }
    return 1;
}

int next_prime(int p)
{
    while (is_prime(p) != 1)
        p++;
    return p;
}



struct scope_stack* stack_scope_initiate(scope *scope_)
{
    struct scope_stack *newScope_stack = (struct scope_stack *)malloc(sizeof(struct scope_stack));
    newScope_stack->next = NULL;
    newScope_stack->data = scope_;
    return newScope_stack;
}

void stack_scope_push(scope *data_)
{
    struct scope_stack *newScope_s = (struct scope_stack *)malloc(sizeof(struct scope_stack));
    newScope_s->data = data_;
    newScope_s->next = stack;
    stack = newScope_s;
}

scope* stack_scope_pop()
{
    if (stack != NULL)
    {
        struct scope_stack *current_stack = stack;
        stack = stack->next;
        return current_stack->data;
    }
    else
    {
        return NULL;
    }
}

struct scope_link_list* scope_list_initiate()
{
    struct scope_link_list* temp = (struct scope_link_list *)malloc(sizeof(struct scope_link_list));
    temp->s = stack->data;
    temp->position = stack->data->position;
    temp->next = NULL;
    return temp;
}

void scope_list_insert(struct scope_link_list **scope_LL)
{
    struct scope_link_list *newScope_LL = (struct scope_link_list *)malloc(sizeof(struct scope_link_list));
    newScope_LL->next = (*scope_LL);
    newScope_LL->position = stack->data->position;
    newScope_LL->s = stack->data;
    (*scope_LL) = newScope_LL;
}


scope* scope_list_pop(struct scope_link_list **scope_LL)
{
    if (*scope_LL != NULL)
    {
        struct scope_link_list *tempScope = (*scope_LL);
        *scope_LL = (*scope_LL)->next;
        return tempScope->s;
    }
    else
        return NULL;
}

void args_initiate(node *params)
{
    for (int i = 0; i < params->childs_length; i++)
    {
        node *current_type = params->childs[i];
        for (int j = 0; j < current_type->childs_length; j++)
        {
            if (hash_table_find(current_hash, current_type->childs[j]->value))
            {
                printf("Variable '%s' already exist.\n", current_type->childs[j]->value);
                exit(1);
            }
            id_info_initiate(current_hash, current_type->childs[j]->value, "ARG", current_type->type);
        }
    }
}

struct id_data* id_info_initiate(hash_table *hashTable, char *sym, char *k, char *t)
{
    struct id_data *data = new_idInfo(sym, k, t);
    hash_table_insert(hashTable, sym, data);
    dec_new_scope(data);
    return data;
}

void set_chanages(struct id_data *id_, char *arg_type)
{
    scope_list_insert(&id_->decl);
    if (arg_type)
        id_->decl->type = strdup(arg_type);
    dec_new_scope(id_);
}


static object* new_item(const char* k, struct id_data* id_)
{
    object* itemp = malloc(sizeof(object));
    itemp->key = strdup(k);
    itemp->id = id_;
    return itemp;
}

static void delete_item(object* item_)
{
    free(item_->key);
    free(item_->id);
    free(item_);
}






































char *get_view(node *node)
{
    return node->value ? node->value : node->token;
}

int does_var_exists(char *id_)
{
    struct id_data *res = hash_table_find(current_hash, id_);
    
    if (res == NULL)
    {
        printf("Variable %s not declared.\n", id_);
        exit(1);
    }
}

char *get_type(node *node)
{
    char *type = NULL;
    if (!strcmp(node->token, "ID"))
    {
        does_var_exists(node->value);
        type = strdup(hash_table_find(current_hash, node->value)->decl->type);
        
        node->type = strdup(type);
    }
    else
    {
        type = strdup(node->type);
    }
    
    return type;
}










void one_main_check()
{
    if (hash_table_find(current_hash, "main") != NULL)
    {
        printf("The program cannot have more than ONE Main function.\n");
        exit(1);

    }
}

void type_main_check(node *node_main)
{
    if (!(strcmp(node_main->childs[0]->value, "VOID") == 0 && node_main->childs[1]->value != NULL && strcmp(node_main->childs[1]->value, "NONE") == 0))
    {
        
        printf("The Main function should be of type VOID and take no arguments.\n");
        exit(1);
    }
}

void id_exist_check(char *identifier_node)
{
    struct id_data *res = hash_table_find(current_hash, identifier_node);
    
    if (res != NULL)
    {
        
        if (res->decl->position == stack->data->position)
        {
            printf("Variable '%s' declared in scope: '%d'.\n", identifier_node, stack->data->position);
            exit(1);
        }
    }
}

void func_exist_check(node *identifier_node)
{
    struct id_data *res = hash_table_find(current_hash, identifier_node->value);
    
    if (res == NULL)
    {
        printf("Function '%s' does not exist.\n", identifier_node->value);
        exit(1);
    }
    
    else if (strcmp(res->kind, "FUNCTION") != 0)
    {
        printf("Variable '%s' is not declared as function.\n", identifier_node->value);
    	exit(1);
    }
}

void func_args_check(node *node_req_func_call)
{
    struct id_data *res = hash_table_find(current_hash, node_req_func_call->value);
    int count_args = node_req_func_call->childs[0]->childs_length;
    
    if (res == NULL || res->count_params != count_args)
    {
        
        printf("Function '%s' sends different number of arguments as it defined.\n", node_req_func_call->value);
    	exit(1);
    }
}

void arg_type_check(node *node_argumenrs, char *req_function_name)
{
    int n_index;
    int arguments_counter = node_argumenrs->childs_length;
    struct id_data *symbol_table_functions = hash_table_find(current_hash, req_function_name);
    
    for (int n_index = 0; n_index < arguments_counter; n_index++)
    {
        
        if (node_argumenrs->childs[n_index]->type)
        {
            if (strcmp(node_argumenrs->childs[n_index]->type, symbol_table_functions->param_list_type[n_index]) != 0)
            {
                printf("Function '%s' expects '%s' from the argument '%s'.\n", req_function_name, symbol_table_functions->param_list_type[n_index], get_view(node_argumenrs->childs[n_index]));
            	exit(1);
            }
            
        }
        else
        {
            
            struct id_data *var = hash_table_find(current_hash, node_argumenrs->childs[n_index]->value);
            if (!var)
            {
                printf("Variable '%s' used in function '%s' undefined call.\n", get_view(node_argumenrs->childs[n_index]), req_function_name);
                exit(1);
            }
            else
            {
                if (strcmp(var->decl->type, symbol_table_functions->param_list_type[n_index]) != 0)
                {
                    
                    printf("Function '%s' expects '%s' from the argument '%s'.\n", req_function_name, symbol_table_functions->param_list_type[n_index], var->symbol);
                	exit(1);
                }
            }
        }
    }
}

void arithmetic_check(node *node_left_op, node *node_right_op, char *operand)
{
    if (!strcmp(get_type(node_left_op), "INT_P") || !strcmp(get_type(node_left_op), "CHAR_P") || !strcmp(get_type(node_left_op), "REAL_P"))
    {
        if (strcmp(operand, " + ") && strcmp(operand, " - "))
        {
            printf("Pointers variables can only accepts '+'' and '-''and not '%s'.\n", get_type(node_left_op));
        	exit(1);
        }
        else if (!strcmp(get_type(node_right_op), "INT"))
        {
            printf("Operand with points can only accept 'int' and not'%s'.\n", get_type(node_left_op));
        	exit(1);
        }
    }
    
    
    else if (strcmp(get_type(node_left_op), get_type(node_right_op)))
    {
        printf("Operand '%s' can only accept two 'int' or two 'real'\n", operand);
    	exit(1);
    }
    else if (strcmp(get_type(node_left_op), "INT") && strcmp(get_type(node_left_op), "REAL"))
    {
        printf("Operand '%s' can only accept two 'int' or two 'real'\n", operand);
    	exit(1);
    }
}

void equal_check(node *node_left_op, node *node_right_op, char *operand)
{
    if (strcmp(get_type(node_left_op), get_type(node_right_op)))
    {
        printf("Operand '%s' cannot accept types of '%s' and '%s'.\n", operand, get_view(node_left_op), get_view(node_right_op));
    	exit(1);
    }
    
    else if (strcmp(get_type(node_left_op), "INT") && strcmp(get_type(node_left_op), "REAL") && strcmp(get_type(node_left_op), "BOOL") && strcmp(get_type(node_left_op), "CHAR") && strcmp(get_type(node_left_op), "REAL_P") && strcmp(get_type(node_left_op), "INT_P") && strcmp(get_type(node_left_op), "CHAR_P"))
    {
        printf("Operand '%s' cannot accept types '%s' and '%s'.\n", operand, get_view(node_left_op), get_view(node_right_op));
    	exit(1);
    }
}

void bool_check(node *node_left_op, node *node_right_op, char *operand)
{
    if (strcmp(get_type(node_left_op), get_type(node_right_op)) || strcmp(get_type(node_left_op), "BOOL"))
    {
        
        printf("Operand '%s' cannot accept types '%s' and '%s', expect them both to be type 'BOOL'.\n", operand, get_type(node_left_op), get_type(node_right_op));
    	exit(1);
    }
    
}

void not_check(node *node_operand)
{
    
    if (strcmp(get_type(node_operand), "BOOL"))
    {
        printf("Operand '!' cannot accept type '%s', expect to get 'BOOL'\n.", get_type(node_operand));
        exit(1);
    }
}

void address_check(node *node_operand)
{
    if (strcmp(get_type(node_operand), "INT") && strcmp(get_type(node_operand), "CHAR") && strcmp(get_type(node_operand), "REAL") && strcmp(get_type(node_operand), "STRING"))
    {
        printf("Operand '&' cannot accept type '%s', expect to get 'int' or 'real' or 'char' or 'string'.\n", get_type(node_operand));
    	exit(1);
    }
    
}

void pointer_check(node *node_operand)
{
    if (strcmp(get_type(node_operand), "INT_P") && strcmp(get_type(node_operand), "REAL_P") && strcmp(get_type(node_operand), "CHAR"))
    {
    	printf("Operand '*' cannot accept type '%s', expect to get 'int_p' or 'real_p' or 'char_p'.\n", get_type(node_operand));
        exit(1);
    }
}


void function_check(node *node_functions, node *node_arguments)
{
    if (!(strcmp(node_functions->token, "FUNCTION")) && !(strcmp(node_functions->value, "main")))
    {
        
        one_main_check();
        type_main_check(node_functions);
        id_info_initiate(current_hash, node_functions->value, node_functions->token, node_functions->type);
    }
    
    else
    {
        int a_index;
        int b_index;
        
        id_exist_check(node_functions->value);
        struct id_data *id = hash_table_find(current_hash, node_functions->value);
        
        if (id == NULL)
        {
            
            id = id_info_initiate(current_hash, node_functions->value, node_functions->token, node_functions->type);
            int count_params = 0;
            
            for (a_index = 0; a_index < node_arguments->childs_length; a_index++)
            {
                count_params += node_arguments->childs[a_index]->childs_length;
            }
            
            id->count_params = count_params;
            id->param_list = (char **)calloc(id->count_params, sizeof(char *));
            id->param_list_type = (char **)calloc(id->count_params, sizeof(char *));
            int counter = 0;
            
            for (a_index = 0; a_index < node_arguments->childs_length; a_index++)
            {
                node *node_type = node_arguments->childs[a_index];
                for (b_index = 0; b_index < node_type->childs_length; b_index++)
                {
                    id->param_list[counter] = strdup(node_type->childs[b_index]->value);
                    id->param_list_type[counter] = strdup(node_type->value);             
                    counter++;
                }
            }
        }
        else
        {
            set_chanages(id, node_functions->type);
        }
    }
}

void return_check(node *node_function)
{
    node *node_body = node_function->childs[node_function->childs_length - 1];
    node *node_return = node_body->childs[node_body->childs_length - 1];

    if (!strcmp(get_type(node_return), "STRING"))
    {
        printf("Function '%s' cannot return type 'string'.\n", node_function->value);
        exit(1);
    }
    
    if (strcmp(get_type(node_function), get_type(node_return)))
    {
        printf("Function '%s' expect to return '%s' and not '%s'.\n", node_function->value, node_function->type, node_return->type);
    	exit(1);
    }
}

void call_func_check(node *node_recall, node *node_arguments)
{
    int n_index;
    
    func_exist_check(node_recall);
    func_args_check(node_recall);
    
    for (n_index = 0; n_index < node_arguments->childs_length; n_index++)
    {
        if (!strcmp(node_arguments->childs[n_index]->token, "ID"))
        {
            does_var_exists(node_arguments->childs[n_index]->value);
        }
    }
    
    
    arg_type_check(node_arguments, node_recall->value);
    node_recall->type = strdup(hash_table_find(current_hash, node_recall->value)->decl->type);
}

void string_check(node *string_elm)
{
    does_var_exists(string_elm->value);
    if (strcmp(hash_table_find(current_hash, string_elm->value)->decl->type, "STRING"))
    {
        printf("Operator '[]' expects type 'STRING', and it gets '%s' which is of type '%s'.\n", get_view(string_elm), get_type(string_elm));
        exit(1);
    }
    
    if (strcmp(get_type(string_elm->childs[0]), "INT"))
    {
        printf("Operator '[]'' expects type 'INT', and it gets '%s' which is of type '%s'.\n", get_view(string_elm->childs[0]), get_type(string_elm->childs[0]));
        exit(1);
    }
}



void assign_check(node *node_ass)
{
    node *left_child = node_ass->childs[0];
    node *right_child = node_ass->childs[1];
    
    if (!strcmp(left_child->token, "STRING ELEMENT"))
    {
        string_check(left_child);
    }
    if (!strcmp(right_child->token, "STRING ELEMENT"))
    {
        string_check(right_child);
    }
    if (!(!strcmp(get_type(left_child), "REAL_P") || !strcmp(get_type(left_child), "CHAR_P") || !strcmp(get_type(left_child), "INT_P")) &&
        (!strcmp(get_type(left_child), "STRING") && !strcmp(get_type(right_child), "CHAR")) || (!strcmp(right_child->token, "NULL")))
    {
        return;
    }
    
    
    if (!(!strcmp(get_type(right_child), "CHAR") || !strcmp(get_type(right_child), "STRING")) && !strcmp(get_type(left_child), "STRING"))
    {
        printf("String cell can only accept 'char' or 'null' inside of it.\n");
        exit(1);
    }
    else if (!strcmp(right_child->token, "NULL") && !(!strcmp(get_type(left_child), "REAL_P") || !strcmp(get_type(left_child), "CHAR_P") || !strcmp(get_type(left_child), "INT_P")))
    {
        printf("Only pointers can accept 'null'.\n");
    	exit(1);
    }
    if (strcmp(get_type(left_child), get_type(right_child)))
    {
        printf("Operator '=' cannot work with types '%s' and '%s'.\n", get_type(left_child), get_type(right_child));
    	exit(1);
    }
    
    right_child->type = get_type(right_child);
    left_child->type = get_type(left_child);
    node_ass->type = strdup(get_type(left_child));
}

void bool_cond_check(node *node_cond)
{
    if (strcmp(get_type(node_cond), "BOOL"))
    {
        printf("Expression of condition must be of type 'BOOL' and not '%s'.\n", get_type(node_cond));
        exit(1);
    }
}

void var_dec_check(node *tree_node)
{
    id_exist_check(tree_node->value);
    struct id_data *identifier_info = hash_table_find(current_hash, tree_node->value);
    
    if (identifier_info == NULL)
    {
        identifier_info = id_info_initiate(current_hash, tree_node->value, tree_node->token, tree_node->type);
    }
    else
    {
        set_chanages(identifier_info, tree_node->type);
    }
}
